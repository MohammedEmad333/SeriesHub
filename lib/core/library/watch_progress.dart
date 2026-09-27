import '../models/episode.dart';
import '../models/series.dart';

class WatchProgress {
  const WatchProgress({
    required this.series,
    required this.episode,
    required this.position,
    required this.duration,
  });

  final Series series;
  final Episode episode;
  final Duration position;
  final Duration duration;

  double get fraction {
    if (duration.inMilliseconds <= 0) return 0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0, 1);
  }
}
