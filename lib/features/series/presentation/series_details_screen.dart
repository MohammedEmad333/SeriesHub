import 'package:flutter/material.dart';

import '../../../core/library/library_store.dart';
import '../../../core/models/episode.dart';
import '../../../core/models/playback_source.dart';
import '../../../core/models/season.dart';
import '../../../core/models/series.dart';
import '../../../core/providers/series_provider.dart';
import '../../player/presentation/playback_launcher.dart';

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
    _selectInitialSeason();
  }

  Future<void> _selectInitialSeason() async {
    try {
      final seasons = await _seasons;
      if (!mounted || seasons.isEmpty || _selectedSeasonId != null) return;
      _selectSeason(seasons.first);
    } on Object {
      // The FutureBuilder below owns the visible error state.
    }
  }

  void _selectSeason(Season season) {
    setState(() {
      _selectedSeasonId = season.id;
      _episodes = widget.provider.getEpisodes(season.id);
    });
  }

  Future<void> _playEpisode(
    Episode episode,
    List<Episode> episodes,
  ) async {
    List<PlaybackSource> sources;
    try {
      sources = await widget.provider.getPlaybackSources(episode.id);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر جلب رابط التشغيل من هذا المصدر.'),
        ),
      );
      return;
    }
    if (!mounted) return;

    if (sources.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هذا المصدر لا يوفر رابط تشغيل مباشر بعد.'),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => buildPlaybackScreen(
          series: widget.series,
          episode: episode,
          episodes: episodes,
          sources: sources,
          provider: widget.provider,
          libraryStore: widget.libraryStore,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
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
              final isFavorite =
                  widget.libraryStore.isFavorite(series.id);

              return IconButton(
                tooltip:
                    isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
                onPressed: () =>
                    widget.libraryStore.toggleFavorite(series),
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
            height: 230,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: series.posterUrl == null || series.posterUrl!.isEmpty
                ? const Icon(Icons.movie_outlined, size: 72)
                : Image.network(
                    series.posterUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.movie_outlined, size: 72),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            series.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (series.year != null)
                Chip(
                  avatar: const Icon(Icons.calendar_month, size: 17),
                  label: Text('${series.year}'),
                ),
              if (series.rating != null)
                Chip(
                  avatar: const Icon(Icons.star, size: 17),
                  label: Text(series.rating!.toStringAsFixed(1)),
                ),
              if (series.country != null)
                Chip(
                  avatar: const Icon(Icons.public, size: 17),
                  label: Text(series.country!),
                ),
              Chip(
                avatar: const Icon(Icons.translate, size: 17),
                label: Text(_languageLabel(series.language)),
              ),
              for (final genre in series.genres)
                Chip(label: Text(genre)),
            ],
          ),
          const SizedBox(height: 16),
          Text(series.overview),
          const SizedBox(height: 24),
          Text(
            'المواسم والحلقات',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Season>>(
            future: _seasons,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'تعذر تحميل المواسم والحلقات من هذا المصدر.',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final seasons = snapshot.data!;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final season in seasons)
                    ChoiceChip(
                      label: Text(
                        season.episodeCount == null
                            ? season.title
                            : '${season.title} · ${season.episodeCount} حلقات',
                      ),
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
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'تعذر تحميل الحلقات من هذا المصدر.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final episodes = snapshot.data!;

                return AnimatedBuilder(
                  animation: widget.libraryStore,
                  builder: (context, _) {
                    return Column(
                      children: [
                        for (final episode in episodes)
                          _EpisodeTile(
                            episode: episode,
                            progress: widget.libraryStore
                                .progressForEpisode(episode.id)
                                ?.fraction,
                            onTap: () =>
                                _playEpisode(episode, episodes),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  static String _languageLabel(SeriesLanguage language) {
    return switch (language) {
      SeriesLanguage.arabic => 'عربي',
      SeriesLanguage.subtitled => 'مترجم',
      SeriesLanguage.dubbed => 'مدبلج',
    };
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({
    required this.episode,
    required this.progress,
    required this.onTap,
  });

  final Episode episode;
  final double? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasProgress = progress != null && progress! > 0;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Text('${episode.number}'),
      ),
      title: Text(episode.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (episode.duration != null)
            Text('${episode.duration!.inMinutes} دقيقة'),
          if (hasProgress) ...[
            const SizedBox(height: 6),
            LinearProgressIndicator(value: progress),
          ],
        ],
      ),
      trailing: Icon(
        hasProgress ? Icons.play_circle_fill : Icons.play_arrow,
      ),
      onTap: onTap,
    );
  }
}
