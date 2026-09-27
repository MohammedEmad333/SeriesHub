import 'package:flutter/material.dart';

import '../../../core/library/library_store.dart';
import '../../../core/models/episode.dart';
import '../../../core/models/season.dart';
import '../../../core/models/series.dart';
import '../../../core/providers/series_provider.dart';
import '../../player/presentation/player_screen.dart';

class SeriesDetailsScreen extends StatefulWidget {
  const SeriesDetailsScreen({
    super.key,
    required this.series,
    required this.provider,
    required this.libraryStore,
  });

  final Series series;
  final SeriesProvider provider;
  final LibraryStore libraryStore;

  @override
  State<SeriesDetailsScreen> createState() => _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends State<SeriesDetailsScreen> {
  late final Future<List<Season>> _seasons =
      widget.provider.getSeasons(widget.series.id);
  String? _selectedSeasonId;
  Future<List<Episode>>? _episodes;

  @override
  void initState() {
    super.initState();
    widget.libraryStore.addToHistory(widget.series);
  }

  void _selectSeason(Season season) {
    setState(() {
      _selectedSeasonId = season.id;
      _episodes = widget.provider.getEpisodes(season.id);
    });
  }

  Future<void> _playEpisode(Episode episode) async {
    final sources = await widget.provider.getPlaybackSources(episode.id);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayerScreen(
          series: widget.series,
          episode: episode,
          sources: sources,
          libraryStore: widget.libraryStore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final series = widget.series;
    return Scaffold(
      appBar: AppBar(
        title: Text(series.title),
        actions: [
          AnimatedBuilder(
            animation: widget.libraryStore,
            builder: (context, _) {
              final isFavorite = widget.libraryStore.isFavorite(series.id);
              return IconButton(
                tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                onPressed: () => widget.libraryStore.toggleFavorite(series),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.movie_outlined, size: 72),
          ),
          const SizedBox(height: 16),
          Text(series.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(series.overview),
          const SizedBox(height: 8),
          Row(
            children: [
              if (series.year != null) Text('${series.year}'),
              if (series.rating != null) ...[
                const SizedBox(width: 12),
                const Icon(Icons.star, size: 18),
                const SizedBox(width: 4),
                Text(series.rating!.toStringAsFixed(1)),
              ],
            ],
          ),
          const SizedBox(height: 20),
          Text('المواسم', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          FutureBuilder<List<Season>>(
            future: _seasons,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final seasons = snapshot.data!;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final season in seasons)
                    ChoiceChip(
                      label: Text(season.title),
                      selected: _selectedSeasonId == season.id,
                      onSelected: (_) => _selectSeason(season),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (_episodes != null)
            FutureBuilder<List<Episode>>(
              future: _episodes,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: [
                    for (final episode in snapshot.data!)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(child: Text('${episode.number}')),
                        title: Text(episode.title),
                        subtitle: Text(
                          episode.duration == null
                              ? ''
                              : '${episode.duration!.inMinutes} دقيقة',
                        ),
                        trailing: const Icon(Icons.play_arrow),
                        onTap: () => _playEpisode(episode),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
