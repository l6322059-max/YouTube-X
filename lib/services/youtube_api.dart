import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoItem {
  const VideoItem({required this.id, required this.title, required this.channel, required this.thumbnail, required this.description});
  final String id, title, channel, thumbnail, description;

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>? ?? {};
    final idValue = json['id'];
    final id = idValue is Map ? (idValue['videoId'] ?? '') : (idValue ?? '');
    final thumbs = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
    final thumb = (thumbs['high'] ?? thumbs['medium'] ?? thumbs['default'] ?? {}) as Map<String, dynamic>;
    return VideoItem(
      id: id.toString(),
      title: (snippet['title'] ?? 'Untitled video').toString(),
      channel: (snippet['channelTitle'] ?? 'Unknown channel').toString(),
      thumbnail: (thumb['url'] ?? '').toString(),
      description: (snippet['description'] ?? '').toString(),
    );
  }
}

class YouTubeApi {
  YouTubeApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static const _base = 'https://www.googleapis.com/youtube/v3';
  static const apiKey = String.fromEnvironment('YOUTUBE_API_KEY');

  Future<List<VideoItem>> search(String query) => _request('search', {
    'part': 'snippet', 'type': 'video', 'maxResults': '25', 'q': query,
  });

  Future<List<VideoItem>> popular() => _request('videos', {
    'part': 'snippet', 'chart': 'mostPopular', 'maxResults': '25', 'regionCode': 'US',
  });

  Future<List<VideoItem>> _request(String endpoint, Map<String, String> params) async {
    if (apiKey.isEmpty) {
      throw Exception('YouTube API key is missing. Add --dart-define=YOUTUBE_API_KEY=YOUR_KEY when running or building.');
    }
    final uri = Uri.parse('$_base/$endpoint').replace(queryParameters: {...params, 'key': apiKey});
    final response = await _client.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      String message = 'YouTube API error (${response.statusCode})';
      try {
        final data = jsonDecode(response.body);
        message = data['error']?['message']?.toString() ?? message;
      } catch (_) {}
      throw Exception(message);
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['items'] as List<dynamic>? ?? [])
        .map((e) => VideoItem.fromJson(e as Map<String, dynamic>))
        .where((v) => v.id.isNotEmpty)
        .toList();
  }

  void close() => _client.close();
}
