import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const DapurDuniaApp());
}

class DapurDuniaApp extends StatelessWidget {
  const DapurDuniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dapur Dunia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
