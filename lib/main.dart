import 'package:flutter/material.dart';
import 'package:serieshub_providers/serieshub_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/library/library_store.dart';
import 'core/models/series.dart';
import 'core/providers/external_series_provider.dart';
import 'core/providers/mock_series_provider.dart';
import 'core/providers/provider_registry.dart';
import 'core/providers/remote_provider_repository.dart';
import 'core/providers/series_provider.dart';
import 'features/shell/presentation/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final libraryStore = LibraryStore(preferences);
  await libraryStore.load();

  final builtIns = <String, SeriesProvider>{
    'official-youtube': ExternalSeriesProvider(
      OfficialYouTubeProvider(),
      language: SeriesLanguage.subtitled,
    ),
    'roya': ExternalSeriesProvider(RoyaProvider()),
    'watanflix': ExternalSeriesProvider(WatanFlixProvider()),
  };

  final remoteIndex = await RemoteProviderRepository().load();
  final providers = <SeriesProvider>[];
  final metadata = <String, RemoteProviderDescriptor>{};

  if (remoteIndex == null) {
    providers.addAll(builtIns.values);
  } else {
    for (final descriptor in remoteIndex.providers) {
      metadata[descriptor.id] = descriptor;
      if (!descriptor.isUsable) continue;

      final provider = builtIns[descriptor.id];
      if (provider != null) providers.add(provider);
    }

    if (providers.isEmpty) {
      providers.addAll(builtIns.values);
    }
  }

  providers.add(MockSeriesProvider());

  final registry = ProviderRegistry(
    providers,
    metadata: metadata,
  );

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
