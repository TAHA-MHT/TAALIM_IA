import 'package:flutter/material.dart';

void main() {
  runApp(const TaalimApp());
}

class TaalimApp extends StatelessWidget {
  const TaalimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAALIM_IA',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'TAALIM_IA',
            style: TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }
}
