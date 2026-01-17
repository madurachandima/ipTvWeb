import 'package:http/http.dart' as http;
import '../models/iptv_models.dart';

class IPTVService {
  static const String categoryIndexUrl =
      'https://iptv-org.github.io/iptv/index.category.m3u';

  List<ChannelModel>? _cachedChannels;

  Future<List<ChannelModel>> fetchChannels() async {
    if (_cachedChannels != null) return _cachedChannels!;

    try {
      final response = await http.get(Uri.parse(categoryIndexUrl));
      if (response.statusCode == 200) {
        final content = response.body;
        _cachedChannels = _parseM3U(content);
        return _cachedChannels!;
      } else {
        throw Exception('Failed to load IPTV index');
      }
    } catch (e) {
      throw Exception('Error fetching IPTV data: $e');
    }
  }

  List<ChannelModel> _parseM3U(String content) {
    final Map<String, ChannelModel> channelMap = {};
    final Map<String, ChannelModel> nameMap = {};
    final lines = content.split('\n');

    String? currentName;
    String? currentLogo;
    List<String> currentCategories = [];
    String? currentId;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.startsWith('#EXTINF:')) {
        final logoMatch = RegExp(r'tvg-logo="([^"]*)"').firstMatch(line);
        final groupMatch = RegExp(r'group-title="([^"]*)"').firstMatch(line);
        final idMatch = RegExp(r'tvg-id="([^"]*)"').firstMatch(line);

        currentLogo = logoMatch?.group(1);
        final groupTitle = groupMatch?.group(1) ?? 'Other';
        currentCategories = groupTitle.split(';').map((e) => e.trim()).toList();
        currentId = idMatch?.group(1);

        final commaIndex = line.lastIndexOf(',');
        if (commaIndex != -1) {
          currentName = line.substring(commaIndex + 1).trim();
        }
      } else if (line.isNotEmpty && !line.startsWith('#')) {
        if (currentName != null) {
          final id = currentId ?? currentName;
          final normalizedName = currentName.toLowerCase().trim();

          // Detect quality
          int priority = 1; // Default SD/Medium
          String? qualityLabel;

          if (normalizedName.contains('4k') || normalizedName.contains('uhd')) {
            priority = 3;
            qualityLabel = '4K';
          } else if (normalizedName.contains('1080p') ||
              normalizedName.contains('fhd') ||
              normalizedName.contains('hd')) {
            priority = 2;
            qualityLabel = 'HD';
          } else if (normalizedName.contains('720p')) {
            priority = 2;
            qualityLabel = 'HD';
          } else if (normalizedName.contains('480p') ||
              normalizedName.contains('sd')) {
            priority = 1;
            qualityLabel = 'SD';
          } else if (normalizedName.contains('360p') ||
              normalizedName.contains('low')) {
            priority = 0;
            qualityLabel = 'Low';
          }

          final stream = Stream(
            channel: id,
            url: line,
            quality: qualityLabel,
            priority: priority,
          );

          // Find existing channel by ID or normalized name
          final existingChannel = channelMap[id] ?? nameMap[normalizedName];

          if (existingChannel != null) {
            if (!existingChannel.streams.any((s) => s.url == line)) {
              existingChannel.streams.add(stream);
            }
          } else {
            final newChannel = ChannelModel(
              channel: Channel(
                id: id,
                name: currentName,
                categories: currentCategories,
              ),
              streams: [stream],
              logo: currentLogo != null
                  ? ChannelLogo(channel: id, url: currentLogo)
                  : null,
            );
            channelMap[id] = newChannel;
            nameMap[normalizedName] = newChannel;
          }
        }
        currentName = null;
        currentLogo = null;
        currentCategories = [];
        currentId = null;
      }
    }
    return channelMap.values.toSet().toList();
  }

  Future<List<Category>> fetchCategories() async {
    final channels = await fetchChannels();
    final Set<String> categoryNames = {};
    for (var c in channels) {
      for (var cat in c.channel.categories) {
        categoryNames.add(cat);
      }
    }

    final List<Category> categories = categoryNames
        .map((name) => Category(id: name, name: name))
        .toList();
    categories.sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }
}
