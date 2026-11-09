import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as android;
import 'package:webview_flutter_windows/webview_flutter_windows.dart' as windows;

class YouTubePlayerScreen extends StatefulWidget {
  const YouTubePlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
  });

  final String videoId;
  final String title;

  @override
  State<YouTubePlayerScreen> createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  android.WebViewController? _androidController;
  final windows.WebviewController _windowsController = windows.WebviewController();
  bool _ready = false;
  bool _windowsInitialized = false;
  String? _error;

  String get _embedUrl =>
      'https://l6322059-max.github.io/YouTube-X/?v=${Uri.encodeComponent(widget.videoId)}&title=${Uri.encodeComponent(widget.title)}';

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (!kIsWeb && Platform.isWindows) {
        await _windowsController.initialize();
        _windowsInitialized = true;
        await _windowsController.loadUrl(_embedUrl);
      } else {
        final controller = android.WebViewController();
        await controller.setJavaScriptMode(android.JavaScriptMode.unrestricted);
        await controller.setBackgroundColor(const Color(0xFF000000));
        await controller.loadRequest(Uri.parse(_embedUrl));
        _androidController = controller;
      }
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    if (_windowsInitialized) _windowsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget player;
    if (_error != null) {
      player = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Could not load the YouTube player. $_error',
              textAlign: TextAlign.center),
        ),
      );
    } else if (!_ready) {
      player = const Center(child: CircularProgressIndicator());
    } else if (!kIsWeb && Platform.isWindows) {
      player = windows.Webview(_windowsController);
    } else {
      player = android.WebViewWidget(controller: _androidController!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: const Color(0xFF0F0F0F),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(color: Colors.black, child: player),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.ondemand_video, color: Color(0xFFFF0033)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Playing with the official YouTube embedded player',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
