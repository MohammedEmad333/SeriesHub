import 'package:flutter/material.dart';

import '../../../core/library/library_store.dart';
import '../../../core/providers/series_provider.dart';
import '../../home/presentation/home_screen.dart';
import '../../library/presentation/library_screen.dart';
import '../../search/presentation/search_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.provider,
    required this.libraryStore,
  });

  final SeriesProvider provider;
  final LibraryStore libraryStore;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _selectTab(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        provider: widget.provider,
        libraryStore: widget.libraryStore,
        onSearchRequested: () => _selectTab(1),
      ),
      SearchScreen(
        provider: widget.provider,
        libraryStore: widget.libraryStore,
      ),
      LibraryScreen(
        store: widget.libraryStore,
        provider: widget.provider,
        mode: LibraryMode.favorites,
      ),
      LibraryScreen(
        store: widget.libraryStore,
        provider: widget.provider,
        mode: LibraryMode.history,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'البحث',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'السجل',
          ),
        ],
      ),
    );
  }
}
