import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/library/library_store.dart';
import '../../../core/models/episode.dart';
import '../../../core/models/playback_source.dart';
import '../../../core/models/series.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.series,
    required this.episode,
    required this.sources,
    required this.libraryStore,
  });

  final Series series;
  final Episode episode;
  final List<PlaybackSource> sources;
  final LibraryStore libraryStore;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  PlaybackSource? _selectedSource;
  bool _initializing = true;
  bool _holdingForSpeed = false;

  @override
  void initState() {
    super.initState();
    if (widget.sources.isNotEmpty) {
      _loadSource(widget.sources.first);
    } else {
      _initializing = false;
    }
  }

  Future<void> _loadSource(
    PlaybackSource source, {
    Duration? restorePosition,
  }) async {
    final previous = _controller;
    final oldPosition = restorePosition ?? previous?.value.position;
    final wasPlaying = previous?.value.isPlaying ?? true;

    setState(() {
      _initializing = true;
      _selectedSource = source;
    });

    await previous?.dispose();

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(source.url),
      httpHeaders: source.headers,
    );
    _controller = controller;

    try {
      await controller.initialize();
      final saved = widget.libraryStore.progressForEpisode(widget.episode.id);
      final target = oldPosition ?? saved?.position;
      if (target != null && target < controller.value.duration) {
        await controller.seekTo(target);
      }
      if (wasPlaying) {
        await controller.play();
      }
      controller.addListener(_onVideoChanged);
    } finally {
      if (mounted) {
        setState(() => _initializing = false);
      }
    }
  }

  void _onVideoChanged() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;

    if (duration.inSeconds > 0 && position.inSeconds % 5 == 0) {
      widget.libraryStore.saveProgress(
        series: widget.series,
        episode: widget.episode,
        position: position,
        duration: duration,
      );
    }
  }

  Future<void> _togglePlayPause() async {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _beginFastForward() async {
    final controller = _controller;
    if (controller == null) return;
    _holdingForSpeed = true;
    await controller.setPlaybackSpeed(2);
    if (mounted) setState(() {});
  }

  Future<void> _endFastForward() async {
    final controller = _controller;
    if (controller == null || !_holdingForSpeed) return;
    _holdingForSpeed = false;
    await controller.setPlaybackSpeed(1);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      widget.libraryStore.saveProgress(
        series: widget.series,
        episode: widget.episode,
        position: controller.value.position,
        duration: controller.value.duration,
      );
    }
    controller?.removeListener(_onVideoChanged);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.episode.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _initializing
                    ? const CircularProgressIndicator()
                    : widget.sources.isEmpty
                        ? const Text(
                            'لا يوجد مصدر تشغيل متاح لهذه الحلقة',
                            style: TextStyle(color: Colors.white70),
                          )
                        : GestureDetector(
                            onTap: _togglePlayPause,
                            onLongPressStart: (_) => _beginFastForward(),
                            onLongPressEnd: (_) => _endFastForward(),
                            child: AspectRatio(
                              aspectRatio: ready
                                  ? controller.value.aspectRatio
                                  : 16 / 9,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (ready) VideoPlayer(controller),
                                  if (ready && !controller.value.isPlaying)
                                    const Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.white,
                                      size: 72,
                                    ),
                                  if (_holdingForSpeed)
                                    const Positioned(
                                      top: 16,
                                      child: Chip(label: Text('2x')),
                                    ),
                                ],
                              ),
                            ),
                          ),
              ),
            ),
            if (ready)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.white,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white12,
                  ),
                ),
              ),
            if (widget.sources.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'الجودة:',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: [
                          for (final source in widget.sources)
                            ChoiceChip(
                              label: Text(source.label),
                              selected: source == _selectedSource,
                              onSelected: (_) => _loadSource(source),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
