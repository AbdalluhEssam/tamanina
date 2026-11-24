import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/tamanina_ui.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = [
    (
      'البيانات على جهازك',
      'On-device data',
      'تُحفظ إعداداتك وعلامات المصحف وتقدّم القراءة والعبادات والمحادثات '
          'والملفات التي تنزّلها على جهازك. يمكنك استخدام التطبيق بدون حساب.',
      'Your settings, bookmarks, reading and worship progress, conversations '
          'and downloads are stored on your device. You can use the app without '
          'an account.',
    ),
    (
      'الموقع والتنبيهات',
      'Location and reminders',
      'إذا سمحت بالموقع، يستخدم التطبيق الإحداثيات لحساب مواقيت الصلاة '
          'واتجاه القبلة على جهازك. قد تستخدم خدمة الموقع في نظام التشغيل '
          'الإحداثيات لمعرفة اسم المدينة. يمكنك اختيار المدينة يدويًا. '
          'يجدول التطبيق تنبيهات الصلاة والأذكار محليًا حسب إعداداتك.',
      'With your permission, the app uses coordinates to calculate prayer times '
          'and Qibla direction on your device. Your operating system’s location '
          'service may use the coordinates to look up the city name. You can '
          'choose a city manually. Prayer and adhkar reminders are scheduled '
          'on your device according to your settings.',
    ),
    (
      'الخدمات التي تستخدم الإنترنت',
      'Online services',
      'تستخدم رسائل التطبيق عبر Firebase معرّف تثبيت لإيصال الإشعارات '
          'وبيانات فنية عن التطبيق والجهاز لتشغيل الخدمة. '
          'قد يتصل التطبيق بمتجر جهازك للتحقق من التحديثات. يتصل التطبيق '
          'بمزودي الملفات عند تنزيل التلاوات أو نموذج المساعد. قد يتلقى '
          'مزودو هذه الطلبات عنوان IP ومعلومات الاتصال اللازمة لتنفيذها.',
      'Firebase Cloud Messaging uses an installation identifier to deliver app '
          'messages and technical app and device information to operate the '
          'service. The app may check your device’s app store for updates. '
          'Downloading recitations or the assistant model contacts the file '
          'providers, who may receive your IP address and other connection data '
          'needed to handle these requests.',
    ),
    (
      'المساعد',
      'Assistant',
      'يعمل بحث القرآن ومحتوى المساعدة على جهازك. بعد تنزيل نموذج المساعد '
          'المحلي تُعالَج أسئلتك على جهازك. إذا كانت الإجابة عبر الإنترنت '
          'متاحة واخترت استخدامها، يُرسل سؤالك وبعض الرسائل الأخيرة إلى '
          'مزود الإجابة.',
      'Quran search and in-app help run on your device. After the local model is '
          'downloaded, it processes your questions on your device. If online '
          'answers are available and you choose them, the answer provider '
          'receives your question and some recent messages.',
    ),
    (
      'إدارة بياناتك',
      'Managing your data',
      'يمكنك تغيير أذونات الموقع والإشعارات من إعدادات الجهاز. يمكنك حذف '
          'نموذج المساعد من داخل التطبيق أو حذف بيانات التطبيق من جهازك. قد '
          'تحتفظ النسخ الاحتياطية التي يديرها جهازك بنسخ حسب إعداداتك.',
      'You can change location and notification permissions in your device '
          'settings. You can remove the assistant model in the app or remove '
          'app data from your device. System-managed backups may retain copies '
          'according to your preferences.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appText(context, 'سياسة الخصوصية', 'Privacy policy')),
      ),
      body: SafeArea(
        top: false,
        child: ContentFrame(
          maxWidth: 680,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              for (final (titleAr, titleEn, bodyAr, bodyEn) in _sections) ...[
                Text(
                  appText(context, titleAr, titleEn),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                SelectableText(
                  appText(context, bodyAr, bodyEn),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
              ],
              if (AppConstants.supportEmail.isNotEmpty)
                SelectableText(
                  appText(
                    context,
                    'التواصل بشأن الخصوصية: ${AppConstants.supportEmail}',
                    'Privacy contact: ${AppConstants.supportEmail}',
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
