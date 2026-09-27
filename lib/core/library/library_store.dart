import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/episode.dart';
import '../models/series.dart';
import 'watch_progress.dart';

class LibraryStore extends ChangeNotifier {
  LibraryStore(this._prefs);

  static const _favoritesKey = 'library.favorites';
  static const _historyKey = 'library.history';
  static const _progressKey = 'library.progress';

  final SharedPreferences _prefs;
  final List<Series> _favorites = [];
  final List<Series> _history = [];
  final Map<String, WatchProgress> _progress = {};

  List<Series> get favorites => List.unmodifiable(_favorites);
  List<Series> get history => List.unmodifiable(_history);

  List<WatchProgress> get continueWatching {
    final items = _progress.values
        .where((item) => item.fraction > 0 && item.fraction < 0.95)
        .toList()
      ..sort(
        (a, b) => b.position.compareTo(a.position),
      );
    return List.unmodifiable(items);
  }

  Future<void> load() async {
    _favorites
      ..clear()
      ..addAll(_decodeSeriesList(_prefs.getString(_favoritesKey)));
    _history
      ..clear()
      ..addAll(_decodeSeriesList(_prefs.getString(_historyKey)));

    _progress.clear();
    final rawProgress = _prefs.getString(_progressKey);
    if (rawProgress != null && rawProgress.isNotEmpty) {
      final decoded = jsonDecode(rawProgress) as List<dynamic>;
      for (final item in decoded) {
        final progress = WatchProgress.fromJson(
          Map<String, Object?>.from(item as Map),
        );
        _progress[progress.episode.id] = progress;
      }
    }

    notifyListeners();
  }

  bool isFavorite(String id) => _favorites.any((item) => item.id == id);

  WatchProgress? progressForEpisode(String episodeId) => _progress[episodeId];

  Future<void> toggleFavorite(Series series) async {
    if (isFavorite(series.id)) {
      _favorites.removeWhere((item) => item.id == series.id);
    } else {
      _favorites.add(series);
    }

    notifyListeners();
    await _persistSeriesList(_favoritesKey, _favorites);
  }

  Future<void> addToHistory(Series series) async {
    _history.removeWhere((item) => item.id == series.id);
    _history.insert(0, series);

    if (_history.length > 100) {
      _history.removeRange(100, _history.length);
    }

    notifyListeners();
    await _persistSeriesList(_historyKey, _history);
  }

  Future<void> saveProgress({
    required Series series,
    required Episode episode,
    required Duration position,
    required Duration duration,
  }) async {
    _progress[episode.id] = WatchProgress(
      series: series,
      episode: episode,
      position: position,
      duration: duration,
    );

    notifyListeners();
    await _persistProgress();
  }

  Future<void> markCompleted(String episodeId) async {
    _progress.remove(episodeId);
    notifyListeners();
    await _persistProgress();
  }

  List<Series> _decodeSeriesList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (item) => Series.fromJson(
            Map<String, Object?>.from(item as Map),
          ),
        )
        .toList(growable: false);
  }

  Future<void> _persistSeriesList(
    String key,
    List<Series> items,
  ) async {
    await _prefs.setString(
      key,
      jsonEncode(items.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> _persistProgress() async {
    await _prefs.setString(
      _progressKey,
      jsonEncode(
        _progress.values.map((item) => item.toJson()).toList(),
      ),
    );
  }
}
