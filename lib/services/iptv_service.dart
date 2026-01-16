import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/iptv_models.dart';

class IPTVService {
  static const String baseUrl = 'https://iptv-org.github.io/api';

  Future<List<ChannelModel>> fetchChannels() async {
    final client = http.Client();
    try {
      final futures = [
        client
            .get(Uri.parse('$baseUrl/channels.json'))
            .timeout(const Duration(seconds: 15)),
        client
            .get(Uri.parse('$baseUrl/streams.json'))
            .timeout(const Duration(seconds: 15)),
        client
            .get(Uri.parse('$baseUrl/logos.json'))
            .timeout(const Duration(seconds: 15)),
      ];

      final responses = await Future.wait(futures);
      final channelsResponse = responses[0];
      final streamsResponse = responses[1];
      final logosResponse = responses[2];

      if (channelsResponse.statusCode == 200 &&
          streamsResponse.statusCode == 200 &&
          logosResponse.statusCode == 200) {
        final List<dynamic> channelsData = json.decode(channelsResponse.body);
        final List<dynamic> streamsData = json.decode(streamsResponse.body);
        final List<dynamic> logosData = json.decode(logosResponse.body);

        final channels = channelsData.map((j) => Channel.fromJson(j)).toList();
        final streams = streamsData.map((j) => Stream.fromJson(j)).toList();
        final logos = logosData.map((j) => ChannelLogo.fromJson(j)).toList();

        // Create maps for efficient lookup
        final streamMap = {for (var s in streams) s.channel: s};
        final logoMap = {for (var l in logos) l.channel: l};

        // Combine data
        return channels
            .where(
              (c) => streamMap.containsKey(c.id),
            ) // Only show channels with streams
            .map(
              (c) => ChannelModel(
                channel: c,
                stream: streamMap[c.id],
                logo: logoMap[c.id],
              ),
            )
            .toList();
      } else {
        throw Exception(
          'Server returned error status. Please check your connection.',
        );
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception(
          'Network error: Please check your internet connection.',
        );
      } else if (e is FormatException) {
        throw Exception(
          'Data format error: Received invalid response from server.',
        );
      }
      throw Exception('Connection timed out or failed. Please try again.');
    } finally {
      client.close();
    }
  }

  Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories.json'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((j) => Category.fromJson(j)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }
}
