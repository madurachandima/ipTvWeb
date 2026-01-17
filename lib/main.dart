import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'views/home_view.dart';
import 'services/iptv_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
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
      title: 'Solixa',
      debugShowCheckedModeBanner: false,
      theme: CodeThemes.darkTheme,
      home: const HomeView(),
    );
  }
}
