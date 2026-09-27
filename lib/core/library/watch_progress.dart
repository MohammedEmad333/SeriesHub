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

  Map<String, Object?> toJson() => {
        'series': series.toJson(),
        'episode': episode.toJson(),
        'positionMs': position.inMilliseconds,
        'durationMs': duration.inMilliseconds,
      };

  factory WatchProgress.fromJson(Map<String, Object?> json) {
    return WatchProgress(
      series: Series.fromJson(
        Map<String, Object?>.from(json['series']! as Map),
      ),
      episode: Episode.fromJson(
        Map<String, Object?>.from(json['episode']! as Map),
      ),
      position: Duration(milliseconds: json['positionMs']! as int),
      duration: Duration(milliseconds: json['durationMs']! as int),
    );
  }
}
