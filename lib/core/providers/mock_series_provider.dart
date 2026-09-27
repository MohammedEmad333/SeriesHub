import '../models/episode.dart';
import '../models/season.dart';
import '../models/series.dart';
import 'series_provider.dart';

class MockSeriesProvider implements SeriesProvider {
  @override
  String get id => 'mock';

  @override
  String get name => 'بيانات تجريبية';

  static const _series = <Series>[
    Series(
      id: 'arabic-1',
      title: 'ليالي المدينة',
      overview: 'دراما عربية تجريبية لاختبار واجهات SeriesHub.',
      language: SeriesLanguage.arabic,
      year: 2026,
      rating: 8.2,
    ),
    Series(
      id: 'sub-1',
      title: 'الرحلة الأخيرة',
      overview: 'مسلسل أجنبي مترجم ببيانات تجريبية.',
      language: SeriesLanguage.subtitled,
      year: 2025,
      rating: 7.8,
    ),
    Series(
      id: 'dub-1',
      title: 'أبطال الغد',
      overview: 'مسلسل مدبلج ببيانات تجريبية.',
      language: SeriesLanguage.dubbed,
      year: 2024,
      rating: 8.0,
    ),
  ];

  @override
  Future<List<Series>> browse() async => _series;

  @override
  Future<List<Series>> search(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return _series;
    return _series
        .where((item) => item.title.toLowerCase().contains(normalized))
        .toList(growable: false);
  }

  @override
  Future<Series> getSeries(String seriesId) async =>
      _series.firstWhere((item) => item.id == seriesId);

  @override
  Future<List<Season>> getSeasons(String seriesId) async => [
        Season(
          id: '${seriesId}-s1',
          seriesId: seriesId,
          number: 1,
          title: 'الموسم الأول',
          episodeCount: 8,
        ),
      ];

  @override
  Future<List<Episode>> getEpisodes(String seasonId) async => List.generate(
        8,
        (index) => Episode(
          id: '${seasonId}-e${index + 1}',
          seasonId: seasonId,
          number: index + 1,
          title: 'الحلقة ${index + 1}',
          duration: const Duration(minutes: 45),
        ),
      );
}
