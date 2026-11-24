import 'package:flutter_test/flutter_test.dart';
import 'package:tamanina/core/services/reminder_schedule.dart';

void main() {
  test('dhikr is opt-in and schedules only the requested daytime interval', () {
    expect(dhikrReminderHours(0), isEmpty);
    expect(dhikrReminderHours(30), isEmpty);
    expect(dhikrReminderHours(60), List.generate(12, (index) => index + 9));
    expect(dhikrReminderHours(180), [9, 12, 15, 18]);
  });

  test('quiet hours work for daytime and overnight periods', () {
    expect(dhikrReminderHours(120, quietStart: 12, quietEnd: 18), [9, 11, 19]);
    expect(
      dhikrReminderHours(60, quietStart: 20, quietEnd: 10),
      List.generate(10, (index) => index + 10),
    );
    expect(dhikrReminderHours(120, quietStart: 9, quietEnd: 9), isEmpty);
    expect(isQuietHour(22, 22, 7), isTrue);
    expect(isQuietHour(7, 22, 7), isFalse);
  });
}
