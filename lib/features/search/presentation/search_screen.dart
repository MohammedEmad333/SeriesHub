import 'package:flutter/material.dart';

import '../../../core/library/library_store.dart';
import '../../../core/models/series.dart';
import '../../../core/providers/series_provider.dart';
import '../../series/presentation/series_details_screen.dart';

enum SearchSort { relevance, rating, newest, oldest }

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.provider,
    required this.libraryStore,
  });

  final SeriesProvider provider;
  final LibraryStore libraryStore;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Series> _results = const [];
  bool _loading = false;
  SeriesLanguage? _language;
  String? _country;
  String? _genre;
  int? _year;
  SearchSort _sort = SearchSort.relevance;

  Future<void> _search([String? value]) async {
    setState(() => _loading = true);
    final results = await widget.provider.search(value ?? _controller.text);
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  List<Series> get _filteredResults {
    final items = _results.where((item) {
      if (_language != null && item.language != _language) return false;
      if (_country != null && item.country != _country) return false;
      if (_genre != null && !item.genres.contains(_genre)) return false;
      if (_year != null && item.year != _year) return false;
      return true;
    }).toList();

    switch (_sort) {
      case SearchSort.rating:
        items.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      case SearchSort.newest:
        items.sort((a, b) => (b.year ?? 0).compareTo(a.year ?? 0));
      case SearchSort.oldest:
        items.sort((a, b) => (a.year ?? 9999).compareTo(b.year ?? 9999));
      case SearchSort.relevance:
        break;
    }

    return items;
  }

  List<String> get _countries {
    final values = _results
        .map((item) => item.country)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
    return values;
  }

  List<String> get _genres {
    final values = _results.expand((item) => item.genres).toSet().toList()
      ..sort();
    return values;
  }

  List<int> get _years {
    final values = _results
        .map((item) => item.year)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return values;
  }

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _language = null;
      _country = null;
      _genre = null;
      _year = null;
      _sort = SearchSort.relevance;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredResults;

    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث'),
        actions: [
          IconButton(
            tooltip: 'مسح الفلاتر',
            onPressed: _clearFilters,
            icon: const Icon(Icons.filter_alt_off),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchBar(
              controller: _controller,
              hintText: 'ابحث بالعنوان، النوع أو الدولة',
              leading: const Icon(Icons.search),
              onChanged: _search,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterMenu<SeriesLanguage>(
                    label: 'اللغة',
                    value: _language,
                    values: SeriesLanguage.values,
                    valueLabel: _languageLabel,
                    onSelected: (value) => setState(() => _language = value),
                  ),
                  const SizedBox(width: 8),
                  _FilterMenu<String>(
                    label: 'الدولة',
                    value: _country,
                    values: _countries,
                    valueLabel: (value) => value,
                    onSelected: (value) => setState(() => _country = value),
                  ),
                  const SizedBox(width: 8),
                  _FilterMenu<String>(
                    label: 'النوع',
                    value: _genre,
                    values: _genres,
                    valueLabel: (value) => value,
                    onSelected: (value) => setState(() => _genre = value),
                  ),
                  const SizedBox(width: 8),
                  _FilterMenu<int>(
                    label: 'السنة',
                    value: _year,
                    values: _years,
                    valueLabel: (value) => value.toString(),
                    onSelected: (value) => setState(() => _year = value),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<SearchSort>(
                    initialValue: _sort,
                    onSelected: (value) => setState(() => _sort = value),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: SearchSort.relevance,
                        child: Text('الأكثر صلة'),
                      ),
                      PopupMenuItem(
                        value: SearchSort.rating,
                        child: Text('الأعلى تقييمًا'),
                      ),
                      PopupMenuItem(
                        value: SearchSort.newest,
                        child: Text('الأحدث'),
                      ),
                      PopupMenuItem(
                        value: SearchSort.oldest,
                        child: Text('الأقدم'),
                      ),
                    ],
                    child: Chip(
                      avatar: const Icon(Icons.sort, size: 18),
                      label: Text(_sortLabel(_sort)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${filtered.length} نتيجة'),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(child: Text('لا توجد نتائج مطابقة'))
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.movie),
                              ),
                              title: Text(item.title),
                              subtitle: Text(
                                [
                                  if (item.country != null) item.country!,
                                  if (item.year != null) '${item.year}',
                                  if (item.genres.isNotEmpty)
                                    item.genres.join(' • '),
                                ].join(' · '),
                              ),
                              trailing: item.rating == null
                                  ? null
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.rating!.toStringAsFixed(1),
                                        ),
                                      ],
                                    ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => SeriesDetailsScreen(
                                      series: item,
                                      provider: widget.provider,
                                      libraryStore: widget.libraryStore,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
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

  static String _sortLabel(SearchSort sort) {
    return switch (sort) {
      SearchSort.relevance => 'الصلة',
      SearchSort.rating => 'التقييم',
      SearchSort.newest => 'الأحدث',
      SearchSort.oldest => 'الأقدم',
    };
  }
}

class _FilterMenu<T> extends StatelessWidget {
  const _FilterMenu({
    required this.label,
    required this.value,
    required this.values,
    required this.valueLabel,
    required this.onSelected,
  });

  final String label;
  final T? value;
  final List<T> values;
  final String Function(T value) valueLabel;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T?>(
      onSelected: onSelected,
      itemBuilder: (_) => [
        PopupMenuItem<T?>(
          value: null,
          child: Text('كل $label'),
        ),
        for (final item in values)
          PopupMenuItem<T?>(
            value: item,
            child: Text(valueLabel(item)),
          ),
      ],
      child: Chip(
        label: Text(value == null ? label : valueLabel(value as T)),
      ),
    );
  }
}
