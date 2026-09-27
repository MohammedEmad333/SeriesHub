import 'package:flutter/foundation.dart';

import '../models/episode.dart';
import '../models/series.dart';
import 'watch_progress.dart';

class LibraryStore extends ChangeNotifier {
  final List<Series> _favorites = [];
  final List<Series> _history = [];
  final Map<String, WatchProgress> _progress = {};

  List<Series> get favorites => List.unmodifiable(_favorites);
  List<Series> get history => List.unmodifiable(_history);
  List<WatchProgress> get continueWatching {
    final items = _progress.values
        .where((item) => item.fraction > 0 && item.fraction < 0.95)
        .toList();
    items.sort((a, b) => b.position.compareTo(a.position));
    return List.unmodifiable(items);
  }

  bool isFavorite(String id) => _favorites.any((item) => item.id == id);

  WatchProgress? progressForEpisode(String episodeId) => _progress[episodeId];

  void toggleFavorite(Series series) {
    if (isFavorite(series.id)) {
      _favorites.removeWhere((item) => item.id == series.id);
    } else {
      _favorites.add(series);
    }
    notifyListeners();
  }

  void addToHistory(Series series) {
    _history.removeWhere((item) => item.id == series.id);
    _history.insert(0, series);
    notifyListeners();
  }

  void saveProgress({
    required Series series,
    required Episode episode,
    required Duration position,
    required Duration duration,
  }) {
    _progress[episode.id] = WatchProgress(
      series: series,
      episode: episode,
      position: position,
      duration: duration,
    );
    notifyListeners();
  }

  void markCompleted(String episodeId) {
    _progress.remove(episodeId);
    notifyListeners();
  }
}
