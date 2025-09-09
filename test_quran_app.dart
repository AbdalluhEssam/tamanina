import 'package:flutter/material.dart';
import 'lib/features/quran/presentation/screens/simple_quran_screen.dart';

class TestQuranApp extends StatelessWidget {
  const TestQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اختبار القرآن الكريم',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Arial',
      ),
      home: const SimpleQuranScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(const TestQuranApp());
}
