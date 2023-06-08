import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

void main() {
  runApp(EasyDynamicThemeWidget(
    child: const CodetestApp(),
  ));
}

const _brandColor = Colors.orange;

class CodetestApp extends StatelessWidget {
  const CodetestApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Codetest App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _brandColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _brandColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: EasyDynamicTheme.of(context).themeMode,
      home: const MyHomePage(title: 'Codetest'),
    );
  }
}
