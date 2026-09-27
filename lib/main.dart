import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/library/library_store.dart';
import 'core/providers/mock_series_provider.dart';
import 'features/home/presentation/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final libraryStore = LibraryStore(preferences);
  await libraryStore.load();

  runApp(SeriesHubApp(libraryStore: libraryStore));
}

class SeriesHubApp extends StatelessWidget {
  const SeriesHubApp({
    super.key,
    required this.libraryStore,
  });

  final LibraryStore libraryStore;

  @override
  Widget build(BuildContext context) {
    final provider = MockSeriesProvider();

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
        child: HomeScreen(
          provider: provider,
          libraryStore: libraryStore,
        ),
      ),
    );
  }
}
