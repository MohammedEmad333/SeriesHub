import 'package:flutter/material.dart';

import '../../../core/models/series.dart';
import '../../../core/providers/series_provider.dart';
import '../../search/presentation/search_screen.dart';
import '../../series/presentation/series_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.provider});

  final SeriesProvider provider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SeriesHub'),
        actions: [
          IconButton(
            tooltip: 'بحث',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SearchScreen(provider: provider),
                ),
              );
            },
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
              items.where((item) => item.language == SeriesLanguage.arabic).toList(),
            ),
            _HomeSection(
              'مترجمة',
              Icons.subtitles,
              items.where((item) => item.language == SeriesLanguage.subtitled).toList(),
            ),
            _HomeSection(
              'مدبلجة',
              Icons.record_voice_over,
              items.where((item) => item.language == SeriesLanguage.dubbed).toList(),
            ),
          ];

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sections.length,
            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final section = sections[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, itemIndex) {
                              final item = section.items[itemIndex];
                              return _SeriesCard(
                                series: item,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => SeriesDetailsScreen(
                                        series: item,
                                        provider: provider,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => SearchScreen(provider: provider),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'البحث'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'السجل'),
        ],
      ),
    );
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.series, required this.onTap});

  final Series series;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
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
            if (series.year != null)
              Text(
                '${series.year}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _HomeSection {
  const _HomeSection(this.title, this.icon, this.items);

  final String title;
  final IconData icon;
  final List<Series> items;
}
