import 'package:flutter/material.dart';

import '../../../core/library/library_store.dart';
import '../../../core/models/series.dart';
import '../../../core/providers/series_provider.dart';
import '../../series/presentation/series_details_screen.dart';

enum LibraryMode { favorites, history }

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({
    super.key,
    required this.store,
    required this.provider,
    required this.mode,
  });

  final LibraryStore store;
  final SeriesProvider provider;
  final LibraryMode mode;

  void _openDetails(
    BuildContext context,
    Series series,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SeriesDetailsScreen(
          series: series,
          provider: provider,
          libraryStore: store,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFavorites = mode == LibraryMode.favorites;

    return Scaffold(
      appBar: AppBar(
        title: Text(isFavorites ? 'المفضلة' : 'سجل المشاهدة'),
      ),
      body: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final items = isFavorites ? store.favorites : store.history;

          if (items.isEmpty) {
            return Center(
              child: Text(
                isFavorites
                    ? 'لم تضف أي مسلسل إلى المفضلة بعد'
                    : 'سجل المشاهدة فارغ',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final series = items[index];

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.movie_outlined),
                ),
                title: Text(series.title),
                subtitle: Text(
                  [
                    if (series.country != null) series.country!,
                    if (series.year != null) '${series.year}',
                    if (series.rating != null)
                      '★ ${series.rating!.toStringAsFixed(1)}',
                  ].join(' · '),
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _openDetails(context, series),
              );
            },
          );
        },
      ),
    );
  }
}
