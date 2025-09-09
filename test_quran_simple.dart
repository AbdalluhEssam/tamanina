import 'package:flutter/material.dart';
import 'package:quran_sharif/quran_sharif.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran Test',
      home: QuranTestScreen(),
    );
  }
}

class QuranTestScreen extends StatefulWidget {
  const QuranTestScreen({super.key});

  @override
  _QuranTestScreenState createState() => _QuranTestScreenState();
}

class _QuranTestScreenState extends State<QuranTestScreen> {
  List<Surahs> allSurahs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuran();
  }

  void _loadQuran() {
    print('🔄 Starting to load Quran...');
    try {
      allSurahs = Quran.getAllSurah();
      print('✅ Loaded ${allSurahs.length} surahs successfully');
      if (allSurahs.isNotEmpty) {
        print(
            '📖 First surah: ${allSurahs.first.name} (${allSurahs.first.ayahs.length} ayahs)');
        print(
            '📖 Last surah: ${allSurahs.last.name} (${allSurahs.last.ayahs.length} ayahs)');
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading Quran: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quran Test'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Loading Quran...'),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.green.shade100,
                  child: Text(
                    'Loaded ${allSurahs.length} surahs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: allSurahs.length,
                    itemBuilder: (context, index) {
                      final surah = allSurahs[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text('${surah.number}'),
                        ),
                        title: Text(surah.name),
                        subtitle: Text(
                            '${surah.ayahs.length} ayahs • ${surah.englishName}'),
                        trailing: Icon(Icons.arrow_forward_ios),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
