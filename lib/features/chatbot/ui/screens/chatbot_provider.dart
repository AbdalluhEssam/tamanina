import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/service_locator.dart';
import '../../data/repo/chatbot_repository_impl.dart';
import '../../data/repo/chatbot_usecases.dart';
import '../../data/services/islamic_ai_service.dart';
import '../../data/services/local_assistant_model.dart';
import '../cubit/chatbot_cubit.dart';
import 'chatbot_screen.dart';

class ChatbotProvider extends StatelessWidget {
  const ChatbotProvider({super.key, this.userId});

  final String? userId;

  @override
  Widget build(BuildContext context) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    final localModel = LocalAssistantModel.instance;
    return BlocProvider(
      key: ValueKey((userId, arabic)),
      create: (_) {
        final repository = ChatbotRepositoryImpl(
          sharedPreferences: sl(),
          aiService: IslamicAiService(arabic: arabic, localModel: localModel),
        );
        return ChatbotCubit(
          sendMessageUseCase: SendMessageUseCase(repository),
          sendStreamingMessageUseCase: SendStreamingMessageUseCase(repository),
          getChatHistoryUseCase: GetChatHistoryUseCase(repository),
          getChatSessionUseCase: GetChatSessionUseCase(repository),
          createChatSessionUseCase: CreateChatSessionUseCase(repository),
          saveChatSessionUseCase: SaveChatSessionUseCase(repository),
          deleteChatSessionUseCase: DeleteChatSessionUseCase(repository),
          clearChatHistoryUseCase: ClearChatHistoryUseCase(repository),
          searchMessagesUseCase: SearchMessagesUseCase(repository),
        )..initialize(userId ?? 'anonymous_user');
      },
      child: ChatbotScreen(userId: userId, localModel: localModel),
    );
  }
}
