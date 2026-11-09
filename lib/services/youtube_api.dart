import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class VideoItem {
  const VideoItem({
    required this.id,
    required this.title,
    required this.channel,
    required this.thumbnail,
    required this.description,
  });

  final String id, title, channel, thumbnail, description;

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>? ?? {};
    final idValue = json['id'];
    final id = idValue is Map ? (idValue['videoId'] ?? '') : (idValue ?? '');
    final thumbs = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
    final thumb =
        (thumbs['high'] ?? thumbs['medium'] ?? thumbs['default'] ?? {})
            as Map<String, dynamic>;
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

  // Defaults to the Russian YouTube catalogue. Override at build time with
  // --dart-define=YOUTUBE_REGION=US (or another supported region code).
  static const regionCode =
      String.fromEnvironment('YOUTUBE_REGION', defaultValue: 'RU');

  Future<List<VideoItem>> search(String query) => _request('search', {
        'part': 'snippet',
        'type': 'video',
        'maxResults': '25',
        'q': query,
      });

  Future<List<VideoItem>> popular() => _request('videos', {
        'part': 'snippet',
        'chart': 'mostPopular',
        'maxResults': '25',
        'regionCode': regionCode,
      });

  Future<List<VideoItem>> _request(
    String endpoint,
    Map<String, String> params,
  ) async {
    if (apiKey.isEmpty) {
      throw Exception(
        'YouTube API key is missing. Configure YOUTUBE_API_KEY in the build.',
      );
    }

    final uri = Uri.parse('$_base/$endpoint')
        .replace(queryParameters: {...params, 'key': apiKey});

    try {
      final response =
          await _client.get(uri).timeout(const Duration(seconds: 20));

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
    } on SocketException {
      throw Exception(
        'Cannot reach Google/YouTube from this network. YouTube may be '
        'restricted by the network provider or region. Check whether '
        'youtube.com and googleapis.com are reachable on this connection.',
      );
    } on TimeoutException {
      throw Exception(
        'Connection to YouTube timed out. The service may be unreachable '
        'or very slow on this network.',
      );
    } on http.ClientException {
      throw Exception(
        'The network connection to YouTube failed. Check your connection '
        'and try again.',
      );
    }
  }

  void close() => _client.close();
}
