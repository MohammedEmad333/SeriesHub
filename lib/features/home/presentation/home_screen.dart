import 'package:flutter/material.dart';

import '../../../core/library/library_store.dart';
import '../../../core/library/watch_progress.dart';
import '../../../core/models/series.dart';
import '../../../core/providers/remote_provider_repository.dart';
import '../../../core/providers/series_provider.dart';
import '../../player/presentation/playback_launcher.dart';
import '../../series/presentation/series_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.provider,
    required this.availableProviders,
    required this.providerMetadata,
    required this.onProviderSelected,
    required this.libraryStore,
    required this.onSearchRequested,
  });

  final SeriesProvider provider;
  final List<SeriesProvider> availableProviders;
  final Map<String, RemoteProviderDescriptor> providerMetadata;
  final ValueChanged<String> onProviderSelected;
  final LibraryStore libraryStore;
  final VoidCallback onSearchRequested;

  Future<void> _resumeWatching(
    BuildContext context,
    WatchProgress progress,
  ) async {
    final episodes = await provider.getEpisodes(progress.episode.seasonId);
    final sources = await provider.getPlaybackSources(progress.episode.id);

    if (!context.mounted) return;
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
          series: progress.series,
          episode: progress.episode,
          episodes: episodes,
          sources: sources,
          provider: provider,
          libraryStore: libraryStore,
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, Series series) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SeriesDetailsScreen(
          series: series,
          provider: provider,
          libraryStore: libraryStore,
        ),
      ),
    );
  }

  static String _providerLabel(
    SeriesProvider provider,
    RemoteProviderDescriptor? metadata,
  ) {
    if (metadata == null) return provider.name;

    return switch (metadata.status) {
      'working' when metadata.playback => '${provider.name} · تشغيل',
      'metadata_only' => '${provider.name} · بيانات فقط',
      'broken' => '${provider.name} · متوقف',
      'disabled' => '${provider.name} · معطل',
      _ => provider.name,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SeriesHub · ${provider.name}'),
        actions: [
          if (availableProviders.length > 1)
            PopupMenuButton<String>(
              tooltip: 'المصدر',
              initialValue: provider.id,
              icon: const Icon(Icons.source_outlined),
              onSelected: onProviderSelected,
              itemBuilder: (context) => [
                for (final item in availableProviders)
                  CheckedPopupMenuItem<String>(
                    value: item.id,
                    checked: item.id == provider.id,
                    child: Text(
                      _providerLabel(
                        item,
                        providerMetadata[item.id],
                      ),
                    ),
                  ),
              ],
            ),
          IconButton(
            tooltip: 'بحث',
            onPressed: onSearchRequested,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: FutureBuilder<List<Series>>(
        future: provider.browse(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          final sections = <_HomeSection>[
            _HomeSection(
              'مسلسلات عربية',
              Icons.language,
              items
                  .where((item) => item.language == SeriesLanguage.arabic)
                  .toList(),
            ),
            _HomeSection(
              'مترجمة',
              Icons.subtitles,
              items
                  .where((item) => item.language == SeriesLanguage.subtitled)
                  .toList(),
            ),
            _HomeSection(
              'مدبلجة',
              Icons.record_voice_over,
              items
                  .where((item) => item.language == SeriesLanguage.dubbed)
                  .toList(),
            ),
          ];

          return AnimatedBuilder(
            animation: libraryStore,
            builder: (context, _) {
              final continueWatching = libraryStore.continueWatching;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (continueWatching.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.play_circle_outline),
                        const SizedBox(width: 8),
                        Text(
                          'أكمل المشاهدة',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 124,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: continueWatching.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final progress = continueWatching[index];

                          return SizedBox(
                            width: 230,
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => _resumeWatching(
                                  context,
                                  progress,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        progress.series.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(progress.episode.title),
                                      const Spacer(),
                                      LinearProgressIndicator(
                                        value: progress.fraction,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${(progress.fraction * 100).round()}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  for (final section in sections) ...[
                    Row(
                      children: [
                        Icon(section.icon),
                        const SizedBox(width: 8),
                        Text(
                          section.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 190,
                      child: section.items.isEmpty
                          ? const Center(child: Text('لا توجد عناصر بعد'))
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: section.items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, itemIndex) {
                                final item = section.items[itemIndex];

                                return _SeriesCard(
                                  series: item,
                                  onTap: () => _openDetails(context, item),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({
    required this.series,
    required this.onTap,
  });

  final Series series;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 136,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.movie_outlined, size: 44),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              series.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              [
                if (series.year != null) '${series.year}',
                if (series.rating != null)
                  '★ ${series.rating!.toStringAsFixed(1)}',
              ].join(' · '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSection {
  const _HomeSection(
    this.title,
    this.icon,
    this.items,
  );

  final String title;
  final IconData icon;
  final List<Series> items;
}
