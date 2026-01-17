class Channel {
  final String id;
  final String name;
  final List<String> categories;
  final String? country;
  final String? website;

  Channel({
    required this.id,
    required this.name,
    required this.categories,
    this.country,
    this.website,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      categories: List<String>.from(json['categories'] ?? []),
      country: json['country'],
      website: json['website'],
    );
  }
}

class Stream {
  final String channel;
  final String url;
  final String? quality;
  final int priority; // 0 (Low) to 3 (Ultra)

  Stream({
    required this.channel,
    required this.url,
    this.quality,
    this.priority = 1,
  });

  factory Stream.fromJson(Map<String, dynamic> json) {
    return Stream(
      channel: json['channel'] ?? '',
      url: json['url'] ?? '',
      quality: json['quality'],
    );
  }
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'] ?? '', name: json['name'] ?? '');
  }
}

class ChannelLogo {
  final String channel;
  final String url;

  ChannelLogo({required this.channel, required this.url});

  factory ChannelLogo.fromJson(Map<String, dynamic> json) {
    return ChannelLogo(channel: json['channel'] ?? '', url: json['url'] ?? '');
  }
}

class ChannelModel {
  final Channel channel;
  final List<Stream> streams;
  final ChannelLogo? logo;

  ChannelModel({required this.channel, required this.streams, this.logo});

  Stream? get stream => streams.isNotEmpty ? streams.first : null;
}
