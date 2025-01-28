import 'package:flutter/material.dart';
import 'package:portfolio_tracker/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_tracker/providers/settings_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider()..loadSettings(),
      child: MaterialApp(
        title: 'Asset Portfolio Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}