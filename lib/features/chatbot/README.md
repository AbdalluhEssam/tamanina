# Islamic Chatbot Module

A comprehensive Islamic chatbot feature for the **طمأنينة (Tamanina)** Flutter application, providing an AI-powered Islamic assistant with clean architecture and Arabic RTL support.

## ✨ Features

### Core Features
- **Islamic AI Assistant**: Virtual assistant specialized in Islamic knowledge
- **Real-time Chat Interface**: Modern chat UI with message bubbles
- **Arabic RTL Support**: Full right-to-left text support for Arabic content
- **Message Types**: Special formatting for Quran verses, Hadith, Duas, and teachings
- **Chat History**: Persistent conversation history with local storage
- **Session Management**: Multiple chat sessions support

### UI/UX Features
- **Islamic Theme**: Green and gold color scheme matching app theme
- **Dark Mode Support**: Full dark/light theme compatibility  
- **Animated Interactions**: Smooth animations and transitions
- **Message Actions**: Copy text, long press options
- **Quick Suggestions**: Pre-built question shortcuts
- **Typing Indicators**: Loading states during AI response generation

### Technical Features
- **Clean Architecture**: Domain, Data, and Presentation layers
- **State Management**: BLoC/Cubit pattern with reactive state updates
- **Local Storage**: SharedPreferences for offline data persistence
- **Extensible AI Service**: Easy to integrate with OpenAI, Claude, or custom APIs
- **Dependency Injection**: Proper dependency management
- **Error Handling**: Comprehensive error states and recovery

## 🏗️ Architecture

### Clean Architecture Layers

```
lib/features/chatbot/
├── domain/               # Business logic layer
│   ├── entities/        # Core business objects
│   ├── repositories/    # Abstract repository interfaces  
│   └── usecases/        # Business use cases
├── data/                # Data layer
│   ├── models/          # Data models with JSON serialization
│   ├── repositories/    # Repository implementations
│   └── services/        # External services (AI, storage)
└── presentation/        # UI layer
    ├── cubit/           # State management
    ├── screens/         # UI screens
    └── widgets/         # Reusable UI components
```

### Key Components

#### Domain Layer
- **`ChatMessage`**: Core message entity with support for different message types
- **`ChatSession`**: Conversation session with message history
- **`ChatbotRepository`**: Repository interface for data operations
- **Use Cases**: `SendMessageUseCase`, `GetChatHistoryUseCase`, etc.

#### Data Layer  
- **`ChatMessageModel`**: JSON serializable message model
- **`ChatSessionModel`**: JSON serializable session model
- **`ChatbotRepositoryImpl`**: Local storage implementation
- **`IslamicAiService`**: AI service with Islamic knowledge responses

#### Presentation Layer
- **`ChatbotCubit`**: State management with reactive updates
- **`ChatbotScreen`**: Main chat interface
- **`ChatMessageBubble`**: Individual message widget
- **`ChatInputWidget`**: Message input with send functionality

## 🚀 Usage

### Basic Integration

1. **Add to Router**: The chatbot route is already added to `AppRouter`:
```dart
case AppRoutes.chatbot:
  return _createRoute(const ChatbotProvider());
```

2. **Navigate to Chatbot**: Use the floating action button or navigate programmatically:
```dart
Navigator.pushNamed(context, AppRoutes.chatbot);
```

### Custom Implementation

```dart
// Create with custom user ID
const ChatbotProvider(userId: 'your_user_id')

// Direct cubit usage
BlocProvider<ChatbotCubit>(
  create: (context) => ChatbotCubit(/* inject dependencies */)
    ..initialize('user_id'),
  child: ChatbotScreen(),
)
```

### Extending AI Responses

The `IslamicAiService` can be extended or replaced:

```dart
class CustomIslamicAiService extends IslamicAiService {
  @override
  Future<ChatMessage> generateResponse({
    required String userMessage,
    required String sessionId,
  }) async {
    // Your custom AI integration
    // E.g., OpenAI, Claude, or custom Islamic AI model
  }
}
```

## 🎨 UI Components

### Message Types
- **Text**: Regular conversation messages
- **Quran**: Styled Quranic verses with special formatting
- **Hadith**: Prophetic traditions with reference styling  
- **Dua**: Supplications with Arabic emphasis
- **Teaching**: Islamic educational content
- **Error**: Error messages with appropriate styling

### Theming
The chatbot respects the app's Islamic theme:
- **Primary**: Green (`AppColors.primaryGreen`) 
- **Secondary**: Gold (`AppColors.goldAccent`)
- **Background**: Light/Dark mode compatible
- **Typography**: Arabic fonts (Reem Kufi, Amiri) with RTL support

## 📱 Responsive Design

- **Mobile First**: Optimized for mobile screens
- **Flutter ScreenUtil**: Responsive sizing across devices
- **Adaptive Colors**: Dark/light theme support
- **Accessibility**: Proper contrast ratios and text sizing

## 🔧 Configuration

### Storage Configuration
Messages are stored locally using SharedPreferences. For production, consider:

```dart
// Firebase Firestore integration example
class FirestoreChatbotRepository implements ChatbotRepository {
  final FirebaseFirestore firestore;
  
  @override  
  Future<void> saveChatSession(ChatSession session) async {
    await firestore
        .collection('chat_sessions')
        .doc(session.id)
        .set(ChatSessionModel.fromEntity(session).toFirestore());
  }
}
```

### AI Service Configuration
Replace the dummy AI service with real implementations:

```dart
// OpenAI integration example  
class OpenAIIslamicService implements IslamicAiService {
  final OpenAI openAI;
  
  @override
  Future<ChatMessage> generateResponse({
    required String userMessage,
    required String sessionId,
  }) async {
    final response = await openAI.onChatCompletion(
      request: ChatCompletionRequest(
        model: "gpt-4",
        messages: [
          ChatCompletionMessage(
            role: ChatCompletionRole.system,
            content: "You are an Islamic assistant...",
          ),
          ChatCompletionMessage(
            role: ChatCompletionRole.user, 
            content: userMessage,
          ),
        ],
      ),
    );
    
    return ChatMessage.assistant(
      id: generateMessageId(),
      content: response.choices.first.message.content,
    );
  }
}
```

## 🧪 Testing

The module is designed for easy testing:

```dart
// Unit tests example
testWidgets('should send message and receive response', (tester) async {
  final mockRepository = MockChatbotRepository();
  final cubit = ChatbotCubit(/* inject mock dependencies */);
  
  await cubit.initialize('test_user');
  await cubit.sendMessage('السلام عليكم');
  
  expect(cubit.state, isA<ChatbotLoaded>());
});
```

## 🔄 State Management

The chatbot uses BLoC/Cubit pattern with the following states:

- **`ChatbotInitial`**: Initial state before initialization
- **`ChatbotLoading`**: Loading state during initialization  
- **`ChatbotLoaded`**: Active chat state with current session
- **`ChatbotError`**: Error state with error message
- **`ChatbotSendingMessage`**: Intermediate state while sending
- **`ChatbotMessageSent`**: Success state after message sent

## 🌐 Internationalization

The chatbot supports Arabic and English:
- **RTL Support**: Automatic text direction detection
- **Arabic Typography**: Islamic fonts (Reem Kufi, Amiri)
- **Localized Messages**: Arabic interface with English fallbacks

## 🔒 Privacy & Security

- **Local Storage**: Messages stored locally by default
- **No External Calls**: Dummy AI service doesn't make network calls
- **User Control**: Users can clear history at any time
- **Anonymous Support**: Works with anonymous users

## 🚢 Deployment

The chatbot is ready for production:

1. **Replace Dummy Service**: Integrate with real AI service
2. **Add Cloud Storage**: Use Firebase Firestore for persistence  
3. **Add Authentication**: Integrate with user authentication
4. **Add Analytics**: Track usage and improve responses
5. **Add Push Notifications**: Notify users of responses

## 📋 Future Enhancements

- **Voice Input**: Speech-to-text for Arabic
- **Voice Output**: Text-to-speech for responses  
- **Image Support**: Upload images for questions
- **Search History**: Search through chat history
- **Export Chat**: Export conversations as PDF
- **Offline Mode**: Basic responses without internet
- **Multilingual**: Support for more languages
- **Advanced AI**: Integration with specialized Islamic AI models

## 🤝 Contributing

When contributing to the chatbot module:

1. Follow the existing clean architecture pattern
2. Maintain Arabic RTL support
3. Add comprehensive tests for new features  
4. Follow the Islamic theme and design principles
5. Update documentation for new features

## 📄 License

This chatbot module is part of the **طمأنينة (Tamanina)** application and follows the same licensing terms.

---

**طمأنينة (Tamanina)** - Your companion in the journey of faith 🕌
