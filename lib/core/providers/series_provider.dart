import '../models/episode.dart';
import '../models/media_track.dart';
import '../models/playback_source.dart';
import '../models/season.dart';
import '../models/series.dart';

abstract interface class SeriesProvider {
  String get id;
  String get name;

  Future<List<Series>> browse();
  Future<List<Series>> search(String query);
  Future<Series> getSeries(String seriesId);
  Future<List<Season>> getSeasons(String seriesId);
  Future<List<Episode>> getEpisodes(String seasonId);
  Future<List<PlaybackSource>> getPlaybackSources(String episodeId);
  Future<List<MediaTrack>> getAudioTracks(String episodeId);
  Future<List<MediaTrack>> getSubtitleTracks(String episodeId);
}
