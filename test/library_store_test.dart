import 'package:flutter_test/flutter_test.dart';
import 'package:serieshub/core/library/library_store.dart';
import 'package:serieshub/core/models/episode.dart';
import 'package:serieshub/core/models/series.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('favorites history and progress survive a reload', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = LibraryStore(preferences);
    await store.load();

    const series = Series(
      id: 'series-1',
      title: 'مسلسل تجريبي',
      overview: 'وصف',
      language: SeriesLanguage.arabic,
      year: 2026,
      rating: 8.5,
      country: 'فلسطين',
      genres: ['دراما'],
    );

    const episode = Episode(
      id: 'episode-1',
      seasonId: 'season-1',
      number: 1,
      title: 'الحلقة 1',
      duration: Duration(minutes: 45),
    );

    await store.toggleFavorite(series);
    await store.addToHistory(series);
    await store.saveProgress(
      series: series,
      episode: episode,
      position: const Duration(minutes: 12),
      duration: const Duration(minutes: 45),
    );

    final restored = LibraryStore(preferences);
    await restored.load();

    expect(restored.isFavorite(series.id), isTrue);
    expect(restored.history.single.id, series.id);
    expect(
      restored.progressForEpisode(episode.id)?.position,
      const Duration(minutes: 12),
    );
    expect(restored.continueWatching.single.episode.id, episode.id);
  });

  test('markCompleted removes an episode from continue watching', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = LibraryStore(preferences);
    await store.load();

    const series = Series(
      id: 'series-2',
      title: 'مسلسل آخر',
      overview: 'وصف',
      language: SeriesLanguage.subtitled,
    );

    const episode = Episode(
      id: 'episode-2',
      seasonId: 'season-2',
      number: 2,
      title: 'الحلقة 2',
    );

    await store.saveProgress(
      series: series,
      episode: episode,
      position: const Duration(minutes: 10),
      duration: const Duration(minutes: 40),
    );

    expect(store.continueWatching, hasLength(1));

    await store.markCompleted(episode.id);

    expect(store.continueWatching, isEmpty);
    expect(store.progressForEpisode(episode.id), isNull);
  });
}
