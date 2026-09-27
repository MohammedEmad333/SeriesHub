import 'package:flutter/material.dart';

import '../../../core/library/library_store.dart';
import '../../../core/models/series.dart';

enum LibraryMode { favorites, history }

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({
    super.key,
    required this.store,
    required this.mode,
  });

  final LibraryStore store;
  final LibraryMode mode;

  @override
  Widget build(BuildContext context) {
    final isFavorites = mode == LibraryMode.favorites;
    return Scaffold(
      appBar: AppBar(title: Text(isFavorites ? 'المفضلة' : 'سجل المشاهدة')),
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
            itemBuilder: (context, index) => _LibraryTile(series: items[index]),
          );
        },
      ),
    );
  }
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({required this.series});

  final Series series;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.movie_outlined)),
      title: Text(series.title),
      subtitle: Text(series.year?.toString() ?? ''),
    );
  }
}
