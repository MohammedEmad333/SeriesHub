import 'package:flutter/material.dart';
import 'package:serieshub_providers/serieshub_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/library/library_store.dart';
import 'core/models/series.dart';
import 'core/providers/external_series_provider.dart';
import 'core/providers/mock_series_provider.dart';
import 'core/providers/provider_registry.dart';
import 'features/shell/presentation/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final libraryStore = LibraryStore(preferences);
  await libraryStore.load();

  final registry = ProviderRegistry([
    ExternalSeriesProvider(
      OfficialYouTubeProvider(),
      language: SeriesLanguage.subtitled,
    ),
    ExternalSeriesProvider(RoyaProvider()),
    ExternalSeriesProvider(WatanFlixProvider()),
    MockSeriesProvider(),
  ]);

  runApp(
    SeriesHubApp(
      libraryStore: libraryStore,
      registry: registry,
    ),
  );
}

class SeriesHubApp extends StatelessWidget {
  const SeriesHubApp({
    super.key,
    required this.libraryStore,
    required this.registry,
  });

  final LibraryStore libraryStore;
  final ProviderRegistry registry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SeriesHub',
      locale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFFE65100),
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: AppShell(
          registry: registry,
          libraryStore: libraryStore,
        ),
      ),
    );
  }
}
