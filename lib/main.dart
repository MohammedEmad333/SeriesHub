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
    'youku-arabic': ExternalSeriesProvider(
      YoukuArabicProvider(),
      language: SeriesLanguage.subtitled,
    ),
    'wetv-arabic': ExternalSeriesProvider(
      WeTvArabicProvider(),
      language: SeriesLanguage.subtitled,
    ),
    'roya': ExternalSeriesProvider(RoyaProvider()),
    'watanflix': ExternalSeriesProvider(WatanFlixProvider()),
    'laroza': ExternalSeriesProvider(LarozaProvider()),
    'elcinema': ExternalSeriesProvider(ElCinemaProvider()),
    'egibest': ExternalSeriesProvider(EgyBestProvider()),
    'cima4u': ExternalSeriesProvider(Cima4uProvider()),
    'dramacafe': ExternalSeriesProvider(DramaCafeProvider()),
  };

  final remoteIndex = await RemoteProviderRepository().load();
  final metadata = <String, RemoteProviderDescriptor>{};
  final activeIds = <String>{};

  if (remoteIndex == null) {
    // Keep startup safe when the remote provider index cannot be fetched.
    // Sources known to be metadata-only or currently unavailable must not
    // suddenly reappear just because GitHub/raw is temporarily unreachable.
    activeIds.addAll(const {
      'official-youtube',
      'youku-arabic',
      'wetv-arabic',
      'roya',
      'watanflix',
      'laroza',
      'cima4u',
      'dramacafe',
    });
  } else {
    for (final descriptor in remoteIndex.providers) {
      metadata[descriptor.id] = descriptor;
      if (descriptor.isUsable && builtIns.containsKey(descriptor.id)) {
        activeIds.add(descriptor.id);
      }
    }
  }

  final registry = ProviderRegistry(
    [
      ...builtIns.values,
      MockSeriesProvider(),
    ],
    metadata: metadata,
    activeIds: activeIds,
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
