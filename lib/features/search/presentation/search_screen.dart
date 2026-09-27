import 'package:flutter/material.dart';

import '../../../core/models/series.dart';
import '../../../core/providers/series_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.provider});

  final SeriesProvider provider;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Series> _results = const [];
  bool _loading = false;

  Future<void> _search(String value) async {
    setState(() => _loading = true);
    final results = await widget.provider.search(value);
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('البحث')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchBar(
              controller: _controller,
              hintText: 'ابحث عن مسلسل',
              leading: const Icon(Icons.search),
              onChanged: _search,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.movie)),
                          title: Text(item.title),
                          subtitle: Text(item.year?.toString() ?? ''),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
