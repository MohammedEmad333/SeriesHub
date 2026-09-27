import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../core/library/library_store.dart';
import '../../../core/models/episode.dart';
import '../../../core/models/playback_source.dart';
import '../../../core/models/series.dart';
import '../../../core/providers/series_provider.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({
    super.key,
    required this.series,
    required this.episode,
    required this.episodes,
    required this.sources,
    required this.provider,
    required this.libraryStore,
  });

  final Series series;
  final Episode episode;
  final List<Episode> episodes;
  final List<PlaybackSource> sources;
  final SeriesProvider provider;
  final LibraryStore libraryStore;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  late Episode _episode;
  late List<PlaybackSource> _sources;
  PlaybackSource? _selectedSource;
  bool _initializing = true;
  bool _holdingForSpeed = false;
  bool _locked = false;
  bool _fullscreen = false;
  bool _advancing = false;
  double _playbackSpeed = 1;
  int _lastSavedSecond = -1;

  @override
  void initState() {
    super.initState();
    _episode = widget.episode;
    _sources = widget.sources;
    if (_sources.isNotEmpty) {
      _loadSource(_sources.first);
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

    previous?.removeListener(_onVideoChanged);

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
      final saved = widget.libraryStore.progressForEpisode(_episode.id);
      final target = oldPosition ?? saved?.position;
      if (target != null && target < controller.value.duration) {
        await controller.seekTo(target);
      }
      await controller.setPlaybackSpeed(_playbackSpeed);
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
    final second = position.inSeconds;

    if (duration.inSeconds > 0 && second % 5 == 0 && second != _lastSavedSecond) {
      _lastSavedSecond = second;
      widget.libraryStore.saveProgress(
        series: widget.series,
        episode: _episode,
        position: position,
        duration: duration,
      );
    }

    final complete = duration.inMilliseconds > 0 &&
        position.inMilliseconds >= duration.inMilliseconds - 1000;

    if (complete && !_advancing) {
      widget.libraryStore.markCompleted(_episode.id);
      _playNextEpisode();
    }
  }

  Future<void> _playNextEpisode() async {
    final currentIndex =
        widget.episodes.indexWhere((item) => item.id == _episode.id);
    if (currentIndex < 0 || currentIndex + 1 >= widget.episodes.length) return;

    _advancing = true;
    final nextEpisode = widget.episodes[currentIndex + 1];
    final nextSources =
        await widget.provider.getPlaybackSources(nextEpisode.id);

    if (!mounted) return;

    setState(() {
      _episode = nextEpisode;
      _sources = nextSources;
      _selectedSource = null;
      _lastSavedSecond = -1;
    });

    if (nextSources.isNotEmpty) {
      await _loadSource(nextSources.first, restorePosition: Duration.zero);
    } else {
      await _controller?.pause();
      setState(() => _initializing = false);
    }

    _advancing = false;
  }

  Future<void> _togglePlayPause() async {
    final controller = _controller;
    if (controller == null || _locked) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _seekRelative(Duration delta) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _locked) {
      return;
    }

    final target = controller.value.position + delta;
    final clamped = target < Duration.zero
        ? Duration.zero
        : target > controller.value.duration
            ? controller.value.duration
            : target;

    await controller.seekTo(clamped);
  }

  Future<void> _handleDoubleTap(TapDownDetails details) async {
    final width = MediaQuery.sizeOf(context).width;
    final isLeftHalf = details.localPosition.dx < width / 2;
    await _seekRelative(
      Duration(seconds: isLeftHalf ? -10 : 10),
    );
  }

  Future<void> _beginFastForward() async {
    final controller = _controller;
    if (controller == null || _locked) return;
    _holdingForSpeed = true;
    await controller.setPlaybackSpeed(2);
    if (mounted) setState(() {});
  }

  Future<void> _endFastForward() async {
    final controller = _controller;
    if (controller == null || !_holdingForSpeed) return;
    _holdingForSpeed = false;
    await controller.setPlaybackSpeed(_playbackSpeed);
    if (mounted) setState(() {});
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    await _controller?.setPlaybackSpeed(speed);
    if (mounted) setState(() {});
  }

  Future<void> _toggleFullscreen() async {
    _fullscreen = !_fullscreen;
    if (_fullscreen) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await _restoreSystemUi();
    }
    if (mounted) setState(() {});
  }

  Future<void> _restoreSystemUi() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      widget.libraryStore.saveProgress(
        series: widget.series,
        episode: _episode,
        position: controller.value.position,
        duration: controller.value.duration,
      );
    }
    controller?.removeListener(_onVideoChanged);
    controller?.dispose();
    _restoreSystemUi();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _fullscreen
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: Text(_episode.title),
            ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _initializing
                    ? const CircularProgressIndicator()
                    : _sources.isEmpty
                        ? const Text(
                            'لا يوجد مصدر تشغيل متاح لهذه الحلقة',
                            style: TextStyle(color: Colors.white70),
                          )
                        : GestureDetector(
                            onTap: _togglePlayPause,
                            onDoubleTapDown: _handleDoubleTap,
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
                                  if (ready &&
                                      !controller.value.isPlaying &&
                                      !_locked)
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
                                  Positioned(
                                    right: 12,
                                    top: 12,
                                    child: IconButton.filledTonal(
                                      tooltip:
                                          _locked ? 'إلغاء القفل' : 'قفل اللمس',
                                      onPressed: () {
                                        setState(() => _locked = !_locked);
                                      },
                                      icon: Icon(
                                        _locked
                                            ? Icons.lock
                                            : Icons.lock_open,
                                      ),
                                    ),
                                  ),
                                  if (!_locked)
                                    Positioned(
                                      left: 12,
                                      top: 12,
                                      child: IconButton.filledTonal(
                                        tooltip: _fullscreen
                                            ? 'الخروج من ملء الشاشة'
                                            : 'ملء الشاشة',
                                        onPressed: _toggleFullscreen,
                                        icon: Icon(
                                          _fullscreen
                                              ? Icons.fullscreen_exit
                                              : Icons.fullscreen,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
              ),
            ),
            if (ready && !_locked)
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
            if (!_locked && _sources.isNotEmpty)
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
                        runSpacing: 8,
                        children: [
                          for (final source in _sources)
                            ChoiceChip(
                              label: Text(source.label),
                              selected: source == _selectedSource,
                              onSelected: (_) => _loadSource(source),
                            ),
                          PopupMenuButton<double>(
                            tooltip: 'سرعة التشغيل',
                            initialValue: _playbackSpeed,
                            onSelected: _setPlaybackSpeed,
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 0.5, child: Text('0.5x')),
                              PopupMenuItem(value: 1.0, child: Text('1x')),
                              PopupMenuItem(value: 1.25, child: Text('1.25x')),
                              PopupMenuItem(value: 1.5, child: Text('1.5x')),
                              PopupMenuItem(value: 2.0, child: Text('2x')),
                            ],
                            child: Chip(
                              avatar: const Icon(Icons.speed, size: 18),
                              label: Text('${_playbackSpeed}x'),
                            ),
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
