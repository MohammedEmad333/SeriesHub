import 'package:flutter/material.dart';

import '../../../core/models/episode.dart';
import '../../../core/models/playback_source.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({
    super.key,
    required this.episode,
    required this.sources,
  });

  final Episode episode;
  final List<PlaybackSource> sources;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(episode.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: const Color(0xFF111111),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 72,
                    ),
                  ),
                ),
              ),
            ),
            if (sources.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'لا يوجد مصدر تشغيل متاح لهذه الحلقة',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            else
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
                          for (final source in sources)
                            Chip(label: Text(source.label)),
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
