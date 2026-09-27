import 'package:serieshub_providers/serieshub_providers.dart' as source;

import '../models/episode.dart';
import '../models/media_track.dart';
import '../models/playback_source.dart';
import '../models/season.dart';
import '../models/series.dart';
import 'series_provider.dart';

class ExternalSeriesProvider implements SeriesProvider {
  ExternalSeriesProvider(
    this.sourceProvider, {
    this.language = SeriesLanguage.arabic,
  });

  final source.SourceProvider sourceProvider;
  final SeriesLanguage language;
  final Map<String, List<source.SourceEpisode>> _episodeCache = {};

  @override
  String get id => sourceProvider.id;

  @override
  String get name => sourceProvider.name;

  @override
  Future<List<Series>> browse() async {
    final items = await sourceProvider.browse();
    return items.map(_mapSeries).toList(growable: false);
  }

  @override
  Future<List<Series>> search(String query) async {
    final items = await sourceProvider.search(query);
    return items.map(_mapSeries).toList(growable: false);
  }

  @override
  Future<Series> getSeries(String seriesId) async {
    return _mapSeries(await sourceProvider.getSeries(seriesId));
  }

  @override
  Future<List<Season>> getSeasons(String seriesId) async {
    final episodes = await _sourceEpisodes(seriesId);
    return [
      Season(
        id: _seasonId(seriesId),
        seriesId: seriesId,
        number: 1,
        title: 'الحلقات',
        episodeCount: episodes.length,
      ),
    ];
  }

  @override
  Future<List<Episode>> getEpisodes(String seasonId) async {
    final seriesId = _seriesIdFromSeason(seasonId);
    final episodes = await _sourceEpisodes(seriesId);
    return episodes
        .map(
          (item) => Episode(
            id: item.id,
            seasonId: seasonId,
            number: item.number,
            title: item.title,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<PlaybackSource>> getPlaybackSources(String episodeId) async {
    final items = await sourceProvider.getPlaybackSources(episodeId);
    return items
        .map(
          (item) => PlaybackSource(
            url: item.url.toString(),
            label: item.label ?? 'Auto',
            mimeType: item.mimeType,
            headers: item.headers,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<MediaTrack>> getAudioTracks(String episodeId) async => const [];

  @override
  Future<List<MediaTrack>> getSubtitleTracks(String episodeId) async => const [];

  Future<List<source.SourceEpisode>> _sourceEpisodes(String seriesId) async {
    final cached = _episodeCache[seriesId];
    if (cached != null) return cached;

    final episodes = await sourceProvider.getEpisodes(seriesId);
    _episodeCache[seriesId] = episodes;
    return episodes;
  }

  Series _mapSeries(source.SourceSeries item) {
    return Series(
      id: item.id,
      title: item.title,
      overview: item.overview ?? '',
      language: language,
      posterUrl: item.posterUrl?.toString(),
      year: item.year,
      genres: item.genres,
    );
  }

  static String _seasonId(String seriesId) => '$seriesId::season-1';

  static String _seriesIdFromSeason(String seasonId) {
    const suffix = '::season-1';
    if (!seasonId.endsWith(suffix)) {
      throw ArgumentError.value(seasonId, 'seasonId', 'Unknown season id');
    }
    return seasonId.substring(0, seasonId.length - suffix.length);
  }
}
