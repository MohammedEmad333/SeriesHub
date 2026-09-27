import 'package:flutter/material.dart';

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SeriesHub'),
      ),
      body: const Center(
        child: Text('المسلسلات العربية والمترجمة والمدبلجة'),
      ),
    );
  }
}
