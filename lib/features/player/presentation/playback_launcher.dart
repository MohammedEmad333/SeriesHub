import 'package:flutter/material.dart';

import '../../../core/library/library_store.dart';
import '../../../core/models/episode.dart';
import '../../../core/models/playback_source.dart';
import '../../../core/models/series.dart';
import '../../../core/providers/series_provider.dart';
import 'player_screen.dart';
import 'youtube_player_screen.dart';

Widget buildPlaybackScreen({
  required Series series,
  required Episode episode,
  required List<Episode> episodes,
  required List<PlaybackSource> sources,
  required SeriesProvider provider,
  required LibraryStore libraryStore,
}) {
  final first = sources.first;

  if (first.mimeType == 'video/youtube') {
    return YoutubePlayerScreen(
      series: series,
      episode: episode,
      videoUrl: first.url,
    );
  }

  return PlayerScreen(
    series: series,
    episode: episode,
    episodes: episodes,
    sources: sources,
    provider: provider,
    libraryStore: libraryStore,
  );
}
