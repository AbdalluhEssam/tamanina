import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repo/chatbot_repository_impl.dart';
import '../../data/services/islamic_ai_service.dart';
import '../../data/repo/chatbot_usecases.dart';
import '../cubit/chatbot_cubit.dart';
import 'chatbot_screen.dart';

/// Provider wrapper for the ChatbotScreen with dependency injection
class ChatbotProvider extends StatelessWidget {
  final String? userId;

  const ChatbotProvider({
    super.key,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error initializing chatbot: ${snapshot.error}'),
            ),
          );
        }

        final sharedPreferences = snapshot.data!;
        final aiService = IslamicAiService();
        final repository = ChatbotRepositoryImpl(
          sharedPreferences: sharedPreferences,
          aiService: aiService,
        );

        return BlocProvider(
          create: (context) => ChatbotCubit(
            sendMessageUseCase: SendMessageUseCase(repository),
            sendStreamingMessageUseCase:
                SendStreamingMessageUseCase(repository),
            getChatHistoryUseCase: GetChatHistoryUseCase(repository),
            getChatSessionUseCase: GetChatSessionUseCase(repository),
            createChatSessionUseCase: CreateChatSessionUseCase(repository),
            saveChatSessionUseCase: SaveChatSessionUseCase(repository),
            deleteChatSessionUseCase: DeleteChatSessionUseCase(repository),
            clearChatHistoryUseCase: ClearChatHistoryUseCase(repository),
            searchMessagesUseCase: SearchMessagesUseCase(repository),
          )..initialize(userId ?? 'anonymous_user'),
          child: ChatbotScreen(userId: userId),
        );
      },
    );
  }
}
