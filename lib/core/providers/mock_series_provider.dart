import '../models/episode.dart';
import '../models/media_track.dart';
import '../models/playback_source.dart';
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
          id: '$seriesId-s1',
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
          id: '$seasonId-e${index + 1}',
          seasonId: seasonId,
          number: index + 1,
          title: 'الحلقة ${index + 1}',
          duration: const Duration(minutes: 45),
        ),
      );

  @override
  Future<List<PlaybackSource>> getPlaybackSources(String episodeId) async => [
        const PlaybackSource(
          url: 'https://example.com/video-720p.m3u8',
          label: '720p',
          mimeType: 'application/x-mpegURL',
        ),
        const PlaybackSource(
          url: 'https://example.com/video-1080p.m3u8',
          label: '1080p',
          mimeType: 'application/x-mpegURL',
        ),
      ];

  @override
  Future<List<MediaTrack>> getAudioTracks(String episodeId) async => const [
        MediaTrack(
          id: 'audio-ar',
          label: 'العربية',
          language: 'ar',
          type: MediaTrackType.audio,
        ),
        MediaTrack(
          id: 'audio-original',
          label: 'الصوت الأصلي',
          language: 'original',
          type: MediaTrackType.audio,
        ),
      ];

  @override
  Future<List<MediaTrack>> getSubtitleTracks(String episodeId) async => const [
        MediaTrack(
          id: 'sub-ar',
          label: 'العربية',
          language: 'ar',
          type: MediaTrackType.subtitle,
          url: 'https://example.com/subtitles-ar.vtt',
        ),
        MediaTrack(
          id: 'sub-off',
          label: 'بدون ترجمة',
          language: 'off',
          type: MediaTrackType.subtitle,
        ),
      ];
}
