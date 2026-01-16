import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'views/home_view.dart';
import 'services/iptv_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => IPTVProvider(),
      child: const IPTVApp(),
    ),
  );
}

class IPTVApp extends StatelessWidget {
  const IPTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPTV Web',
      debugShowCheckedModeBanner: false,
      theme: CodeThemes.darkTheme,
      home: const HomeView(),
    );
  }
}
