import 'package:flutter/foundation.dart';

import '../models/series.dart';

class LibraryStore extends ChangeNotifier {
  final List<Series> _favorites = [];
  final List<Series> _history = [];

  List<Series> get favorites => List.unmodifiable(_favorites);
  List<Series> get history => List.unmodifiable(_history);

  bool isFavorite(String id) => _favorites.any((item) => item.id == id);

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
}
