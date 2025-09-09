import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'lib/features/quran/presentation/screens/simple_mushaf_page_screen.dart';

void main() {
  runApp(const MushafTestApp());
}

class MushafTestApp extends StatelessWidget {
  const MushafTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'اختبار المصحف',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.brown,
            fontFamily: 'Amiri', // خط عربي مناسب
          ),
          home: const SimpleMushafPageScreen(),
        );
      },
    );
  }
}
