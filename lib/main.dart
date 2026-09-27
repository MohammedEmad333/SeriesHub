import 'package:flutter/material.dart';

import 'features/home/presentation/home_screen.dart';

void main() {
  runApp(const SeriesHubApp());
}

class SeriesHubApp extends StatelessWidget {
  const SeriesHubApp({super.key});

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
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),
    );
  }
}
