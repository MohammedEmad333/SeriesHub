import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../core/models/episode.dart';
import '../../../core/models/series.dart';

class YoutubePlayerScreen extends StatefulWidget {
  const YoutubePlayerScreen({
    super.key,
    required this.series,
    required this.episode,
    required this.videoUrl,
  });

  final Series series;
  final Episode episode;
  final String videoUrl;

  @override
  State<YoutubePlayerScreen> createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = _videoId(widget.videoUrl);
    if (videoId == null) {
      throw ArgumentError.value(
        widget.videoUrl,
        'videoUrl',
        'Invalid YouTube URL',
      );
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        captionLanguage: 'ar',
        interfaceLanguage: 'ar',
        strictRelatedVideos: true,
        privacyEnhancedMode: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.episode.title),
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }

  static String? _videoId(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return null;

    if (uri.host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }

    if (uri.host.endsWith('youtube.com')) {
      final queryId = uri.queryParameters['v'];
      if (queryId != null && queryId.isNotEmpty) return queryId;

      final segments = uri.pathSegments;
      if (segments.length >= 2 &&
          (segments.first == 'embed' || segments.first == 'shorts')) {
        return segments[1];
      }
    }

    return null;
  }
}
