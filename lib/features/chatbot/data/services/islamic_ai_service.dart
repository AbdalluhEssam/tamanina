import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../../core/config/api_config.dart';
import '../model/chat_message.dart';
import 'local_assistant_model.dart';
import '../../../quran/data/services/mushaf_library.dart';

class IslamicAiService {
  IslamicAiService({
    this.model = ApiConfig.defaultModel,
    this.arabic = true,
    Uri? endpoint,
    http.Client? client,
    LocalAssistantModel? localModel,
  }) : _endpoint = endpoint ?? ApiConfig.guideUri,
       _client = client,
       _localModel = localModel;

  final String model;
  final bool arabic;
  final Uri? _endpoint;
  final http.Client? _client;
  final LocalAssistantModel? _localModel;

  Future<ChatMessage> generateResponse({
    required String userMessage,
    required String sessionId,
    List<ChatMessage> context = const [],
  }) async {
    final response =
        _quranAnswer(userMessage) ??
        _localAnswer(userMessage) ??
        await _answerQuestion(userMessage, context) ??
        (arabic
            ? 'المساعد بالذكاء الاصطناعي غير متاح الآن. تقدر تبحث عن آية أو تسأل عن استخدام طمأنينة. في الأسئلة الشرعية، ارجع إلى عالم موثوق.'
            : 'AI answers are unavailable right now. You can find a Quran verse or ask about using Tamanina. For religious rulings, consult a qualified scholar.');
    return ChatMessage.assistant(id: const Uuid().v4(), content: response);
  }

  Stream<String> generateStreamingResponse({
    required String userMessage,
    required String sessionId,
    List<ChatMessage> context = const [],
  }) async* {
    final response = await generateResponse(
      userMessage: userMessage,
      sessionId: sessionId,
      context: context,
    );
    yield response.content;
  }

  Future<String?> _answerQuestion(
    String message,
    List<ChatMessage> history,
  ) async {
    final localModel = _localModel;
    if (localModel != null) {
      await localModel.check();
      if (localModel.status == LocalModelStatus.ready) {
        return localModel.answer(message, history, arabic: arabic);
      }
    }
    return _onlineAnswer(message, history);
  }

  Future<String?> _onlineAnswer(
    String message,
    List<ChatMessage> context,
  ) async {
    final endpoint = _endpoint;
    if (endpoint == null) return null;

    try {
      final response = await (_client?.post ?? http.post)(
        endpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'language': arabic ? 'ar' : 'en',
          'model': model,
          'history': [
            for (final message
                in context.reversed
                    .where((message) => message.type != MessageType.greeting)
                    .take(6)
                    .toList()
                    .reversed)
              {
                'role': message.isUser ? 'user' : 'assistant',
                'content': message.content,
              },
          ],
        }),
      ).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;
      final result = jsonDecode(response.body);
      if (result is Map && result['answer'] is String) {
        final answer = (result['answer'] as String).trim();
        if (answer.isNotEmpty) return answer;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  String? _quranAnswer(String message) {
    final request = RegExp(
      r'^(?:ابحث عن آية|ابحث عن اية|find a verse)\s*[:：]?\s*(.*)$',
      caseSensitive: false,
    ).firstMatch(message.trim());
    if (request == null) return null;
    final query = MushafLibrary.normalize(request.group(1)!);
    if (query.isEmpty) {
      return arabic
          ? 'اكتب جزءًا من الآية بعد عبارة «ابحث عن آية».'
          : 'Type an Arabic phrase from the verse after “Find a verse”.';
    }
    final matches = MushafLibrary.searchVerses(query).take(3).toList();
    if (matches.isEmpty) {
      return arabic
          ? 'مفيش آيات مطابقة. جرّب جزءًا أقصر من الآية.'
          : 'No verses matched. Try a shorter Arabic phrase.';
    }
    return matches
        .map((entry) {
          final verse = entry.verse;
          final reference = arabic
              ? '${entry.surah.name}، آية ${verse.numberInSurah}، صفحة ${verse.page}'
              : '${entry.surah.englishName}, verse ${verse.numberInSurah}, page ${verse.page}';
          return '${verse.text}\n$reference';
        })
        .join('\n\n');
  }

  String? _localAnswer(String message) {
    final text = message.trim().toLowerCase().replaceAll(
      RegExp(r'[\u064b-\u065f]'),
      '',
    );
    bool mentions(List<String> terms) => terms.any(text.contains);
    if (const [
      'السلام عليكم',
      'مرحبا',
      'اهلا',
      'أهلا',
      'hello',
      'hi',
    ].contains(text)) {
      return arabic
          ? 'وعليكم السلام ورحمة الله وبركاته. اسألني عن أي أداة في طمأنينة.'
          : 'Peace be upon you. Ask me about any tool in Tamanina.';
    }
    if (mentions([
      'ما حكم',
      'هل يجوز',
      'حلال',
      'حرام',
      'is it permissible',
      'ruling',
    ])) {
      return null;
    }
    final aboutApp = mentions([
      'طمأنينة',
      'التطبيق',
      'كيف أستخدم',
      'كيف استخدم',
      'كيف أضبط',
      'كيف اضبط',
      'كيف أتابع',
      'كيف اتابع',
      'ازاي استخدم',
      'فين الاقي',
      'how do i use',
      'how do i set',
      'how do i continue',
      'the app',
      'tamanina',
    ]);
    if (!aboutApp) return null;
    if (mentions(['قبلة', 'qibla', 'compass'])) {
      return arabic
          ? 'افتح «اتجاه القبلة» من الرئيسية. بعد تحديد الموقع، امسك الهاتف أفقيًا وبعيدًا عن المعادن حتى تستقر البوصلة.'
          : 'Open Qibla from Today. Set your location, then hold the phone flat and away from metal until the compass settles.';
    }
    if (mentions(['مواقيت', 'صلاة', 'أذان', 'prayer', 'adhan'])) {
      return arabic
          ? 'افتح «مواقيت الصلاة» واختر مدينتك أو استخدم موقعك. يمكنك ضبط طريقة الحساب والتنبيهات من الإعدادات.'
          : 'Open Prayer times and choose your city or use your location. Calculation methods and alerts are in Settings.';
    }
    if (mentions(['مصحف', 'قرآن', 'quran', 'bookmark', 'قراءة'])) {
      return arabic
          ? 'افتح «القرآن» للبحث باسم السورة. «تابع القراءة» ترجعك لآخر موضع، وأيقونة الحفظ تضيف علامة للصفحة.'
          : 'Open Quran to search for a surah. Continue reading opens your last position, and the bookmark button saves the page.';
    }
    if (mentions(['سبحة', 'تسبيح', 'tasbeeh', 'counter'])) {
      return arabic
          ? 'افتح «السبحة» واضغط «سبّح» مع كل تكرار أو اسحب الزر للمكان المريح لك. ينتقل العداد تلقائيًا للذكر التالي ويحفظ تقدّمك.'
          : 'Open Tasbeeh and tap Count after each repetition or drag the button to a comfortable spot. The counter advances automatically and saves your progress.';
    }
    if (mentions(['أذكار', 'اذكار', 'adhkar', 'dhikr'])) {
      return arabic
          ? 'افتح «الأذكار» واختر المجموعة المطلوبة. اضغط عداد الذكر بعد كل قراءة، أو احفظ الذكر في المفضلة.'
          : 'Open Adhkar and choose a collection. Tap the counter after each repetition, or save the remembrance to favorites.';
    }
    return null;
  }

  void clearHistory() {}
}
