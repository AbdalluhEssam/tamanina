import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tamanina/features/chatbot/data/services/local_assistant_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the installed model generates on the device', (tester) async {
    final response = await tester.runAsync(() async {
      final model = LocalAssistantModel.instance;
      expect(model.supported, isTrue);
      await model.check();
      expect(model.status, LocalModelStatus.ready);
      return model.answer(
        'Reply with the single English word Peace.',
        const [],
        arabic: false,
      );
    });

    expect(response, isNotNull);
    expect(response!.toLowerCase(), contains('peace'));
  }, skip: !const bool.fromEnvironment('VERIFY_ON_DEVICE_ASSISTANT'));
}
