import 'package:flutter/material.dart';

import '../../../core/library/library_store.dart';
import '../../../core/providers/provider_registry.dart';
import '../../../core/providers/series_provider.dart';
import '../../home/presentation/home_screen.dart';
import '../../library/presentation/library_screen.dart';
import '../../search/presentation/search_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.registry,
    required this.libraryStore,
  });

  final ProviderRegistry registry;
  final LibraryStore libraryStore;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  late String _providerId;

  @override
  void initState() {
    super.initState();
    _providerId = widget.registry.all.first.id;
  }

  SeriesProvider get _provider =>
      widget.registry.byId(_providerId) ?? widget.registry.all.first;

  void _selectTab(int index) {
    setState(() => _index = index);
  }

  void _selectProvider(String providerId) {
    if (providerId == _providerId) return;
    setState(() => _providerId = providerId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider;
    final pages = [
      HomeScreen(
        provider: provider,
        availableProviders: widget.registry.all,
        providerMetadata: {
          for (final item in widget.registry.all)
            if (widget.registry.metadataFor(item.id) != null)
              item.id: widget.registry.metadataFor(item.id)!,
        },
        onProviderSelected: _selectProvider,
        libraryStore: widget.libraryStore,
        onSearchRequested: () => _selectTab(1),
      ),
      SearchScreen(
        provider: provider,
        libraryStore: widget.libraryStore,
      ),
      LibraryScreen(
        store: widget.libraryStore,
        provider: provider,
        mode: LibraryMode.favorites,
      ),
      LibraryScreen(
        store: widget.libraryStore,
        provider: provider,
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
