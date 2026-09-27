import 'package:flutter_test/flutter_test.dart';
import 'package:serieshub/core/providers/external_series_provider.dart';
import 'package:serieshub_providers/serieshub_providers.dart';

class _FakeSourceProvider implements SourceProvider {
  @override
  Uri get baseUri => Uri.parse('https://example.com/');

  @override
  String get id => 'fake';

  @override
  String get name => 'Fake';

  @override
  Future<List<SourceSeries>> browse({int page = 1}) async => [
        SourceSeries(
          id: 'show',
          title: 'Show',
          webUrl: baseUri.resolve('series/show'),
          overview: 'Overview',
          year: 2026,
          genres: const ['Drama'],
        ),
      ];

  @override
  Future<List<SourceSeries>> search(String query) => browse();

  @override
  Future<SourceSeries> getSeries(String seriesId) async => (await browse()).first;

  @override
  Future<List<SourceEpisode>> getEpisodes(String seriesId) async => [
        SourceEpisode(
          id: 'episode-1',
          seriesId: seriesId,
          number: 1,
          title: 'Episode 1',
          webUrl: baseUri.resolve('episode/1'),
        ),
      ];

  @override
  Future<List<SourcePlayback>> getPlaybackSources(String episodeId) async => [
        SourcePlayback(
          url: baseUri.resolve('video.m3u8'),
          label: '720p',
          mimeType: 'application/x-mpegURL',
        ),
      ];
}

void main() {
  test('maps source models into SeriesHub models', () async {
    final provider = ExternalSeriesProvider(_FakeSourceProvider());

    final series = (await provider.browse()).single;
    final seasons = await provider.getSeasons(series.id);
    final episodes = await provider.getEpisodes(seasons.single.id);
    final playback = await provider.getPlaybackSources(episodes.single.id);

    expect(provider.id, 'fake');
    expect(series.title, 'Show');
    expect(series.year, 2026);
    expect(seasons.single.episodeCount, 1);
    expect(episodes.single.title, 'Episode 1');
    expect(playback.single.label, '720p');
  });
}
