import 'package:uuid/uuid.dart';

import '../model/chat_message.dart';
import 'assistant_gateway.dart';
import 'local_assistant_model.dart';
import '../../../quran/data/services/mushaf_library.dart';

typedef AssistantCall = Future<Object?> Function(Map<String, Object?> request);
typedef AssistantStream = Stream<String> Function(Map<String, Object?> request);

final _gateway = AssistantGateway();

class IslamicAiService {
  IslamicAiService({
    this.arabic = true,
    AssistantCall? assistantCall,
    AssistantStream? assistantStream,
    LocalAssistantModel? localModel,
  }) : _assistantCall = assistantCall ?? _gateway.call,
       // Real streaming is used unless a test supplies its own call.
       _assistantStream =
           assistantStream ?? (assistantCall == null ? _gateway.stream : null),
       _localModel = localModel;

  final bool arabic;
  final AssistantCall _assistantCall;
  final AssistantStream? _assistantStream;
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
        _unavailable;
    return ChatMessage.assistant(id: const Uuid().v4(), content: response);
  }

  String get _unavailable => arabic
      ? 'المساعد بالذكاء الاصطناعي غير متاح الآن. تقدر تبحث عن آية أو تسأل عن استخدام طمأنينة. في الأسئلة الشرعية، ارجع إلى عالم موثوق.'
      : 'AI answers are unavailable right now. You can find a Quran verse or ask about using Tamanina. For religious rulings, consult a qualified scholar.';

  /// Yields the answer so far (each event is the whole text up to now). The AI
  /// answer streams in as it is written; instant local answers are revealed
  /// word by word so every reply reads the same way.
  Stream<String> generateStreamingResponse({
    required String userMessage,
    required String sessionId,
    List<ChatMessage> context = const [],
  }) async* {
    final instant = _quranAnswer(userMessage) ?? _localAnswer(userMessage);
    if (instant != null) {
      yield* _reveal(instant);
      return;
    }
    final streamer = _assistantStream;
    String? answer;
    if (streamer != null) {
      var text = '';
      var shown = '';
      final clock = Stopwatch()..start();
      var lastEmit = 0;
      try {
        await for (final piece in streamer(_request(userMessage, context))) {
          text += piece;
          // About 25 updates a second keeps long answers smooth.
          if (clock.elapsedMilliseconds - lastEmit >= 40) {
            lastEmit = clock.elapsedMilliseconds;
            shown = text;
            yield text;
          }
        }
      } catch (_) {
        // Keep whatever arrived.
      }
      if (text.trim().isNotEmpty) {
        if (shown != text) yield text;
        return;
      }
      answer = await _localModelAnswer(userMessage, context);
    } else {
      answer = await _answerQuestion(userMessage, context);
    }
    yield* _reveal(answer ?? _unavailable);
  }

  Stream<String> _reveal(String text) async* {
    final words = RegExp(r'\S+\s*').allMatches(text).toList();
    if (words.length < 2) {
      yield text;
      return;
    }
    final delay = Duration(
      milliseconds: (2600 / words.length).clamp(4, 22).round(),
    );
    var shown = '';
    for (final word in words) {
      shown += word.group(0)!;
      yield shown;
      await Future<void>.delayed(delay);
    }
  }

  Map<String, Object?> _request(String message, List<ChatMessage> context) => {
    'message': message,
    'language': arabic ? 'ar' : 'en',
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
  };

  Future<String?> _localModelAnswer(
    String message,
    List<ChatMessage> history,
  ) async {
    final localModel = _localModel;
    if (localModel == null) return null;
    await localModel.check();
    return localModel.status == LocalModelStatus.ready
        ? localModel.answer(message, history, arabic: arabic)
        : null;
  }

  Future<String?> _answerQuestion(
    String message,
    List<ChatMessage> history,
  ) async {
    // Online first (Groq); the on-device model answers only when that fails.
    final online = await _onlineAnswer(message, history);
    if (online != null) return online;
    return _localModelAnswer(message, history);
  }

  Future<String?> _onlineAnswer(
    String message,
    List<ChatMessage> context,
  ) async {
    try {
      final result = await _assistantCall(
        _request(message, context),
      ).timeout(const Duration(seconds: 25));
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
