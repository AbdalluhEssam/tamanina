import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/markdown_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/tamanina_ui.dart';
import '../../data/model/chat_message.dart';
import '../../data/services/local_assistant_model.dart';
import '../cubit/chatbot_cubit.dart';
import '../cubit/chatbot_state.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key, this.userId, this.localModel});

  final String? userId;
  final LocalAssistantModel? localModel;

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String raw) {
    final cubit = context.read<ChatbotCubit>();
    final state = cubit.state;
    final text = raw.trim();
    if (text.isEmpty || state is! ChatbotLoaded || state.isTyping) return;
    _input.clear();
    cubit.sendStreamingMessage(text);
  }

  Future<void> _manageLocalModel(LocalAssistantModel model) async {
    await model.check();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (context) => ListenableBuilder(
        listenable: model,
        builder: (context, _) {
          final status = model.status;
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    appText(
                      context,
                      'الذكاء الاصطناعي على الجهاز',
                      'On-device AI',
                    ),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status == LocalModelStatus.ready
                        ? appText(
                            context,
                            'النموذج جاهز. الأسئلة المفتوحة تُعالَج على جهازك من غير اتصال.',
                            'The model is ready. Open-ended questions run on your device without a connection.',
                          )
                        : appText(
                            context,
                            'نزّل النموذج مرة واحدة (491 ميجابايت) عشان تسأل من غير إنترنت.',
                            'Download the model once (491 MB) to ask questions offline.',
                          ),
                  ),
                  const SizedBox(height: 16),
                  if (status == LocalModelStatus.downloading) ...[
                    LinearProgressIndicator(value: model.percent / 100),
                    const SizedBox(height: 8),
                    Text(
                      model.percent == 100
                          ? appText(
                              context,
                              'جارٍ التحقق من الملف',
                              'Verifying the file',
                            )
                          : appText(
                              context,
                              'تم تنزيل ${model.percent}٪',
                              '${model.percent}% downloaded',
                            ),
                    ),
                    TextButton(
                      onPressed: model.cancelDownload,
                      child: Text(
                        appText(context, 'إلغاء التنزيل', 'Cancel download'),
                      ),
                    ),
                  ] else if (status == LocalModelStatus.ready)
                    OutlinedButton(
                      onPressed: model.remove,
                      child: Text(
                        appText(
                          context,
                          'إزالة النموذج من الجهاز',
                          'Remove model from this device',
                        ),
                      ),
                    )
                  else ...[
                    if (status == LocalModelStatus.failed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          appText(
                            context,
                            'تعذّر إكمال العملية. جرّب مرة تانية.',
                            'Could not complete the operation. Try again.',
                          ),
                        ),
                      ),
                    FilledButton.icon(
                      onPressed: model.download,
                      icon: const Icon(Icons.download_rounded),
                      label: Text(
                        appText(context, 'تنزيل النموذج', 'Download model'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _history() async {
    final cubit = context.read<ChatbotCubit>();
    var query = '';
    final selection = await showModalBottomSheet<(String?, bool)>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, update) {
          final term = query.trim().toLowerCase();
          final sessions = cubit.chatHistory.where(
            (session) => session.messages.any(
              (message) => message.content.toLowerCase().contains(term),
            ),
          );
          return FractionallySizedBox(
            heightFactor: .75,
            child: ContentFrame(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ListTile(
                    title: Text(
                      appText(
                        context,
                        'المحادثات السابقة',
                        'Past conversations',
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: appText(
                        context,
                        'حذف سجل المحادثات',
                        'Clear chat history',
                      ),
                      icon: const Icon(Icons.delete_outline),
                      onPressed:
                          cubit.chatHistory.any(
                            (session) => session.messages.isNotEmpty,
                          )
                          ? () => Navigator.pop(context, (null, true))
                          : null,
                    ),
                  ),
                  TextField(
                    onChanged: (value) => update(() => query = value),
                    decoration: InputDecoration(
                      labelText: appText(
                        context,
                        'ابحث في المحادثات',
                        'Search conversations',
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                  if (sessions.isEmpty)
                    ListTile(
                      title: Text(
                        appText(
                          context,
                          'لا توجد محادثات مطابقة.',
                          'No matching conversations.',
                        ),
                      ),
                    ),
                  for (final session in sessions)
                    ListTile(
                      title: Text(
                        session.messages
                            .firstWhere(
                              (message) =>
                                  message.content.toLowerCase().contains(term),
                            )
                            .content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.pop(context, (session.id, false)),
                      trailing: IconButton(
                        tooltip: appText(
                          context,
                          'حذف المحادثة',
                          'Delete conversation',
                        ),
                        onPressed: () =>
                            Navigator.pop(context, (session.id, true)),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (!mounted || selection == null) return;
    final (id, remove) = selection;
    if (!remove && id != null) {
      await cubit.switchToSession(id);
      return;
    }
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(
          id == null
              ? appText(context, 'حذف المحادثات؟', 'Clear conversations?')
              : appText(
                  context,
                  'حذف هذه المحادثة؟',
                  'Delete this conversation?',
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(appText(context, 'إلغاء', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(appText(context, 'حذف', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (id == null) {
      await cubit.clearHistory();
    } else {
      await cubit.deleteSession(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<ChatbotCubit, ChatbotState>(
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_scroll.hasClients) return;
          final position = _scroll.position;
          // Follow the answer as it grows, unless the reader scrolled up.
          if (state is ChatbotStreamingResponse &&
              position.maxScrollExtent - position.pixels > 160) {
            return;
          }
          _scroll.jumpTo(position.maxScrollExtent);
        });
      },
      builder: (context, state) {
        final cubit = context.read<ChatbotCubit>();
        final session = cubit.currentSession;
        final streaming = state is ChatbotStreamingResponse;
        final busy = streaming || (state is ChatbotLoaded && state.isTyping);
        final ready = session != null;
        final messages =
            session?.messages
                .where((message) => message.type != MessageType.greeting)
                .toList() ??
            const <ChatMessage>[];
        return Scaffold(
          appBar: AppBar(
            title: Text(
              appText(context, 'مساعد طمأنينة', 'Tamanina assistant'),
            ),
            actions: [
              if (widget.localModel case final model? when model.supported)
                IconButton(
                  tooltip: appText(
                    context,
                    'الذكاء الاصطناعي على الجهاز',
                    'On-device AI',
                  ),
                  icon: Icon(
                    platformIcon(
                      context,
                      Icons.smartphone_outlined,
                      CupertinoIcons.device_phone_portrait,
                    ),
                  ),
                  onPressed: busy ? null : () => _manageLocalModel(model),
                ),
              IconButton(
                tooltip: appText(context, 'سجل المحادثات', 'Chat history'),
                icon: Icon(
                  platformIcon(context, Icons.history, CupertinoIcons.clock),
                ),
                onPressed: ready && !busy ? _history : null,
              ),
              IconButton(
                tooltip: appText(context, 'محادثة جديدة', 'New conversation'),
                icon: Icon(
                  platformIcon(
                    context,
                    Icons.add_comment_outlined,
                    CupertinoIcons.square_pencil,
                  ),
                ),
                onPressed: ready && !busy ? cubit.createNewSession : null,
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: ContentFrame(
              child: Column(
                children: [
                  Expanded(
                    child: state is ChatbotError
                        ? Center(
                            child: OutlinedButton(
                              onPressed: () => cubit.initialize(
                                widget.userId ?? 'anonymous_user',
                              ),
                              child: Text(
                                appText(context, 'إعادة المحاولة', 'Try again'),
                              ),
                            ),
                          )
                        : !ready
                        ? const ListSkeleton(rows: 3)
                        : ListView(
                            controller: _scroll,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.all(16),
                            children: [
                              if (messages.isEmpty) ...[
                                Text(
                                  appText(
                                    context,
                                    'كيف أساعدك؟',
                                    'How can I help?',
                                  ),
                                  style: theme.textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  appText(
                                    context,
                                    'البحث في القرآن واستخدام التطبيق متاحان محليًا. أسئلة الذكاء الاصطناعي تُرسل لخدمة الإجابة مع بعض الرسائل الأخيرة.',
                                    'Quran search and app help are available offline. AI questions and recent chat messages are shared with the answering service.',
                                  ),
                                ),
                                const SizedBox(height: 18),
                                for (final question in [
                                  appText(
                                    context,
                                    'ابحث عن آية: إن مع العسر يسرا',
                                    'Find a verse: إن مع العسر يسرا',
                                  ),
                                  appText(
                                    context,
                                    'كيف أتابع قراءة القرآن؟',
                                    'How do I continue reading Quran?',
                                  ),
                                  appText(
                                    context,
                                    'كيف أضبط مواقيت الصلاة؟',
                                    'How do I set prayer times?',
                                  ),
                                  appText(
                                    context,
                                    'كيف أستخدم السبحة؟',
                                    'How do I use tasbeeh?',
                                  ),
                                ])
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: OutlinedButton(
                                      onPressed: busy
                                          ? null
                                          : () => _send(question),
                                      child: Text(question),
                                    ),
                                  ),
                              ],
                              for (final message in messages)
                                _Bubble(message: message),
                              if (streaming)
                                if (state.currentStreamText.isEmpty)
                                  const _Thinking()
                                else
                                  _Bubble(
                                    message: ChatMessage.assistant(
                                      id: 'streaming',
                                      content: state.currentStreamText,
                                    ),
                                    streaming: true,
                                  )
                              else if (busy)
                                const _Thinking(),
                              if (state is ChatbotLoaded && state.error != null)
                                Text(
                                  appText(
                                    context,
                                    'تعذّر إرسال الرسالة.',
                                    'Message could not be sent.',
                                  ),
                                ),
                            ],
                          ),
                  ),
                  if (ready)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _input,
                              maxLength: 1000,
                              textInputAction: TextInputAction.send,
                              onSubmitted: _send,
                              decoration: InputDecoration(
                                labelText: appText(
                                  context,
                                  'اكتب سؤالك',
                                  'Type a question',
                                ),
                                counterText: '',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: busy ? null : () => _send(_input.text),
                            tooltip: appText(context, 'إرسال', 'Send'),
                            icon: Icon(
                              platformIcon(
                                context,
                                Icons.send,
                                CupertinoIcons.arrow_up,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Thinking extends StatelessWidget {
  const _Thinking();

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        appText(context, 'يكتب…', 'Typing…'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ),
  );
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, this.streaming = false});

  final ChatMessage message;
  final bool streaming;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = Theme.of(
      context,
    ).textTheme.bodyMedium!.copyWith(height: 1.65);
    return Align(
      alignment: message.isUser
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: message.isUser ? colors.primaryContainer : colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: message.isUser
              ? SelectableText(message.content, style: style)
              : MarkdownText(
                  message.content,
                  style: style,
                  caret: streaming,
                  selectable: !streaming,
                ),
        ),
      ),
    );
  }
}
