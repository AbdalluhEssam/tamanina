# تجهيز إصدار طمأنينة للنشر

آخر تحقق محلي في 24 نوفمبر 2026. هذا الدليل يجمع حالة الإصدار، نصوص المتجرين، الإفصاحات المبنية على الكود، وخطوات التوقيع والاختبار والرفع.

## الإصدار ومعرّفات التطبيق

| الحقل | القيمة |
| --- | --- |
| اسم التطبيق | طمأنينة · Tamanina |
| الإصدار في المشروع | `1.0.1+2` |
| Android application ID وiOS bundle ID | `com.abdalluh.tamanina` |
| iOS WidgetKit extension | `com.abdalluh.tamanina.Widgets` |
| iOS App Group | `group.com.abdalluh.tamanina` |
| Apple Team في المشروع | `P48S5252F6` |
| لغات الواجهة والمتجر المقترحة | العربية والإنجليزية |
| الفئة المقترحة | Lifestyle |
| نموذج التوزيع المقترح | مجاني، بدون حساب أو إعلانات أو مشتريات داخل التطبيق في هذا البناء |
| دعم Android | من API 24، واستخدام compileSdk وtargetSdk 36 |
| بيئة البناء | Flutter 3.47.2، Dart 3.13.2، JDK 17، NDK 28.0.12433566، CMake 3.31.6، Xcode 27.2 وCocoaPods |

راجع أعلى رقم بناء في Play Console وApp Store Connect قبل إعادة البناء أو إرسال نسخة لأي مسار اختبار. استخدم رقم الإصدار الحالي إذا لم يُستخدم في المسار المطلوب، أو مرّر رقمًا أعلى من البناء الموجود باستخدام `--build-number`. تحقّق من سجل المتجر حتى لو لم تجد التطبيق في البحث العام.

تطلّب Google Play للرفع من تطبيقات الهواتف استهداف Android 16 ‏(API 36) على الأقل بتاريخ المراجعة. يتطلب App Store Connect بناءً بـ Xcode 26 وSDK iOS 26 على الأقل. حد تشغيل مشروع iOS هو iOS 15. [متطلبات Google Play](https://support.google.com/googleplay/android-developer/answer/11926878) · [متطلبات Apple](https://developer.apple.com/news/upcoming-requirements/)

## ملفات الإصدار

| المنصة | الملف | الغرض |
| --- | --- | --- |
| Google Play | `build/app/outputs/bundle/release/app-release.aab` | Android App Bundle موقّع بمفتاح الرفع المحلي لهذا الإصدار |
| Android arm64 | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` | التثبيت المباشر على معظم هواتف Android الحديثة |
| Android armv7 | `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` | أجهزة Android ذات نظام ARM ‏32-bit |
| Android x86_64 | `build/app/outputs/flutter-apk/app-x86_64-release.apk` | أجهزة ومحاكيات Android على x86_64 |
| iOS | `build/ios/archive/Runner.xcarchive` | أرشيف جهاز حقيقي بامتداد الويدجت. يحتاج توقيعًا وتصديرًا للحصول على IPA للمتجر |
| iOS للنقل | `build/ios/archive/Tamanina-1.0.1+2-iOS-unsigned.xcarchive.zip` | نسخة ZIP من الأرشيف للفتح في Xcode بعد فك الضغط |
| iOS بعد التوقيع | `build/ios/ipa/` | مكان IPA الناتج من أمر التصدير، أو ارفع الأرشيف الموقّع من Xcode Organizer |

أُنشئ مفتاح رفع Android محلي خاص بطمأنينة في `~/.android/tamanina-release/` لحالة الإصدار الأول. ملف `android/key.properties` المحلي يشير إلى إعدادات التوقيع هناك. احتفظ بنسخة محمية من المفتاح وكلمات المرور ضمن حساب الناشر. إذا كان للمعرّف سجل موجود بالفعل في Play Console، قارن شهادة الرفع بالسجل واستبدل الإعدادات بالمفتاح المعتمد عند اختلافها.

لم يتوفر ملف توزيع iOS خاص بالتطبيق أو الويدجت على الجهاز. الأرشيف مبني لجهاز حقيقي، وتصدير IPA للرفع يتطلب توقيع الهدفين ضمن فريق Apple الذي يمتلك سجل التطبيق.

## بيانات تحتاج تأكيد مالك الحساب

| الحقل | المطلوب قبل إرسال التطبيق |
| --- | --- |
| سجل التطبيق والتوقيع | تأكيد سجل Play Console وApp Store Connect ومعرفاتهما. استخدم مفتاح الرفع المعتمد إن كان سجل Google Play موجودًا |
| اسم الناشر وصاحب الحقوق | الاسم القانوني الموافق لحساب المطوّر وحقوله العامة. استخدمه في حقوق النشر وسياسة الخصوصية |
| الدعم | بريد يستقبل الرسائل وصفحة HTTPS عامة للدعم. سجّل بريد المراجعة ورقم هاتفها في App Store Connect |
| رابط الخصوصية | صفحة HTTPS عامة قابلة للفتح بدون تسجيل دخول. ضع نص السياسة أدناه بعد استبدال بيانات الناشر والدعم |
| السوق والعمر | تأكيد البلدان واللغات والفئة العمرية وبيانات التاجر إذا طلبها المتجر. أكمل استبياني العمر والمحتوى من النسخة المرفوعة |
| الوسائط | لقطات حقيقية من النسخة نفسها، وأيقونة وFeature Graphic للمتجر. راجع حقوق المحتوى والملفات القابلة للتنزيل |
| Firebase وAPNs | راجع ملكية مشروع FCM، استخدام الرسائل الفعلي، ومفتاح APNs المرتبط بمعرّف iOS إذا ستُستخدم رسائل التطبيق |

في الفحص العام من الجهاز، أعاد رابط Play للمعرّف HTTP 404، ولم يرجع البحث بالمعرّف في متجر Apple المصري نتيجة. العناوين التجريبية السابقة للدعم لم تُحل في DNS. سجلات الاختبار والسجلات الخاصة تحتاج تحققًا داخل حساب الناشر.

## نصوص المتجر بالعربية

| الحقل | النص |
| --- | --- |
| الاسم | طمأنينة |
| العنوان الفرعي في Apple | القرآن والأذكار ومواقيت الصلاة |
| وصف Google Play المختصر | اقرأ القرآن دون إنترنت وتابع مواقيت الصلاة والأذكار اليومية في مكان واحد. |
| كلمات Apple المفتاحية | مصحف,أذكار,قبلة,أذان,تسبيح,ورد,صلاة |

**الوصف الكامل**

طمأنينة يجمع المصحف والأذكار ومواقيت الصلاة في تطبيق واحد. اقرأ المصحف بترتيب صفحاته، وابحث في القرآن، واحفظ موضع قراءتك حتى تكمل وردك بسهولة.

- اطّلع على مواقيت الصلاة والعدّ التنازلي للصلاة التالية، واضبط طريقة الحساب بحسب موقعك أو المدينة التي تختارها.
- فعّل تنبيهات مواقيت الصلاة والأذان حسب أذونات جهازك وإعدادات التنبيهات.
- اقرأ أذكار الصباح والمساء، واستخدم السبحة، وتابع وردك وعباداتك اليومية.
- أضف ويدجت طمأنينة إلى الشاشة الرئيسية للوصول إلى المواقيت والأذكار والسبحة والقرآن.
- استمع إلى التلاوة، ونزّل ما تريد سماعه لاحقًا أثناء التنقّل.

المصحف والأذكار وحساب المواقيت تعمل دون اتصال. يحتاج تنزيل التلاوات إلى الإنترنت أول مرة، وتُشغّل الملفات المحفوظة بعدها من جهازك.

**ملاحظات الإصدار**

مصحف كامل للقراءة دون إنترنت، ومواقيت صلاة محسوبة على جهازك، وتنبيهات للأذان والأذكار، وويدجت للشاشة الرئيسية.

## Store listing in English

| Field | Copy |
| --- | --- |
| Name | Tamanina |
| Apple subtitle | Quran, Prayer Times & Adhkar |
| Google Play short description | Read Quran offline and follow local prayer times, adhkar and tasbeeh. |
| Apple keywords | mushaf,qibla,adhan,dhikr,tasbih,salah,islamic,offline,recitation,reminders |

**Full description**

Keep Quran reading, daily remembrance and prayer times together with Tamanina. Read the Quran in Mushaf page order, search the text and bookmark where you left off.

- See the next prayer and count down to its time. Choose your city or use your location and preferred calculation method.
- Set prayer reminders and adhan alerts according to your device permissions and notification settings.
- Read morning and evening adhkar, use the tasbeeh counter and follow your daily worship progress.
- Add Tamanina widgets to your Home Screen for prayer times, remembrance, tasbeeh and the Quran.
- Listen to recitations and download them ahead of a trip.

Quran reading, adhkar and prayer calculations work offline. Download recitations with an internet connection to listen offline afterward.

**Release notes**

Read the full Quran offline, follow locally calculated prayer times, set adhan and adhkar reminders, and add worship widgets to your Home Screen.

Apple allows a name and subtitle of up to 30 characters each. Google Play allows 30 for the name, 80 for the short description and 4,000 for the full description. Use an ASCII comma between keywords when pasting into App Store Connect. [Apple app information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/) · [Play store listing](https://support.google.com/googleplay/android-developer/answer/9859152)

## سياسة الخصوصية للنشر

استبدل الحقول بين أقواس مربعة. طابق النص مع بناء الإنتاج والنطاقات التي يستخدمها، ثم انشر العربية والإنجليزية على صفحة عامة. نسخة السياسة داخل التطبيق متاحة محليًا تحت الإعدادات. يمكن تمرير البريد المعتمد عند البناء باستخدام `TAMANINA_SUPPORT_EMAIL`.

### العربية

سياسة خصوصية طمأنينة. بدء السريان [تاريخ النشر]. يتولى [اسم الناشر القانوني] تشغيل التطبيق. للاستفسارات وطلبات الخصوصية تواصل على [بريد الدعم المعتمد].

يعمل التطبيق بدون حساب. تُحفظ الإعدادات وعلامات المصحف وتقدم القراءة والعبادات والمحادثات والملفات التي تنزّلها على جهازك. قد تحتفظ خدمات النسخ الاحتياطي التي يديرها جهازك بنسخ من البيانات الأخرى وفقًا لإعداداتك. تُستثنى ملفات التلاوة ونموذج المساعد القابلة لإعادة التنزيل من النسخ الاحتياطي.

إذا سمحت بالوصول إلى الموقع أثناء الاستخدام، تُستخدم الإحداثيات على جهازك لحساب مواقيت الصلاة واتجاه القبلة. قد تعالج خدمة الموقع في نظام التشغيل الإحداثيات للبحث عن اسم المدينة. يمكنك اختيار المدينة يدويًا وإدارة إذن الموقع من إعدادات الجهاز.

تُجدول تنبيهات الصلاة والأذكار على الجهاز. تستعمل رسائل التطبيق عبر Firebase Cloud Messaging معرّف تثبيت التطبيق لتوصيل الرسائل وقد تربطه برمز إشعارات جهاز Apple. يرسل SDK بيانات فنية عن النظام والتطبيق لتشغيل الخدمة. تنطبق على المعالجة مدد الاحتفاظ الموضحة لدى [Firebase](https://firebase.google.com/support/privacy). يمكن تغيير صلاحيات عرض الإشعارات من إعدادات الجهاز.

قد يتحقق التطبيق من التحديثات عبر متجر جهازك. يتصل التطبيق بخادم التلاوات عند الاستماع عبر الإنترنت أو التنزيل، ويتصل بمزوّد ملفات النموذج عندما تطلب تنزيل مساعد الاستخدام المحلي. قد تتلقى هذه الخدمات عنوان IP وبيانات الاتصال لأداء الطلب. يعمل بحث القرآن والمساعدة داخل التطبيق على الجهاز، ويعالج النموذج المحلي الأسئلة بعد تنزيله. إذا فعّل الناشر خدمة الإجابة عبر الإنترنت واخترت استخدامها، يُرسل سؤالك وبعض الرسائل الأخيرة إلى مزوّد الإجابة. الخدمة عبر الإنترنت غير مفعّلة في هذا الإصدار.

يمكنك حذف نموذج المساعد من التطبيق، وإدارة إذن الموقع والإشعارات من إعدادات الجهاز، ومسح بيانات التطبيق المحلية أو حذف التطبيق. إذا أردت الاستفسار عن البيانات لدى أي خدمة أو طلب حذف معرّف التثبيت، تواصل معنا عبر بريد الخصوصية أعلاه. تُنشر تحديثات السياسة على هذه الصفحة.

### English

Tamanina Privacy Policy. Effective [publication date]. Tamanina is operated by [legal publisher name]. Contact [verified support email] with privacy questions or requests.

You can use Tamanina without an account. Settings, Quran bookmarks, reading and worship progress, conversations and downloaded files are stored on your device. Device-managed backups may retain copies of other data according to your settings. Downloaded recitations and the assistant model are excluded from backups.

If you allow location access while using the app, Tamanina uses coordinates on your device to calculate prayer times and Qibla direction. Your operating system's location service may process coordinates to look up the city name. You can select a city manually and manage location permission in device settings.

Prayer and adhkar reminders are scheduled on your device. Firebase Cloud Messaging uses an app installation identifier for app messages and may associate it with an Apple push notification token. The SDK sends technical app and system information to operate the service. Firebase describes its retention practices in its [privacy documentation](https://firebase.google.com/support/privacy). You can manage permission to show notifications in device settings.

Tamanina may check your app store for updates. Streaming or downloading recitations contacts the recitation provider. If you download the optional local assistant model, the app contacts the model provider. These providers may receive your IP address and connection information to fulfill requests. Quran search and app help run on your device, and the downloaded model processes questions on your device. If an online answer provider is enabled and you choose to use it, the provider receives your question and some recent messages. The online answer service is disabled in this release.

You can remove the assistant model in the app, manage permissions in device settings, clear locally stored app data or uninstall the app. Contact us using the privacy email above for requests about data processed by providers or deletion of the app installation identifier. Updates to this policy are posted on this page.

## الخصوصية وتصريحات المتجر

تعكس المراجعة البناء الافتراضي الذي يترك `TAMANINA_GUIDE_URL` فارغًا. استخدم إفصاحات هذا الجدول كنقطة بدء وقارنها بتقرير Privacy في Xcode وسجل إعدادات Firebase وسياسات مزودي الشبكة قبل الإرسال. [Apple App Privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/) · [Google Play Data safety](https://support.google.com/googleplay/android-developer/answer/10787469) · [إفصاح Firebase لـ Apple](https://firebase.google.com/docs/ios/app-store-data-collection) · [إفصاح Firebase لـ Google Play](https://firebase.google.com/docs/android/play-data-disclosure)

| البيانات أو الإذن | السلوك في البناء وما يجب مراجعته |
| --- | --- |
| Firebase Cloud Messaging | راجع `Device ID` في Apple و`Device or other IDs` في Google بناءً على معرّف التثبيت ورمز إيصال الإشعار. الغرض الأساسي App Functionality، ويبدأ التكامل تلقائيًا عند تشغيل التطبيق. راجع أيضًا Other Diagnostic Data وOther Data Types المذكورتين في ملف الخصوصية المرفق لـ FirebaseMessaging، ونطاق بيانات SDK على Android. حسم الارتباط بالهوية وتصنيف المشاركة يعتمد على الإعدادات وعلاقة مزود الخدمة |
| الموقع | يسمح النظام بالموقع أثناء الاستخدام. حساب الصلاة والقبلة محلي. راجع أي إرسال من خدمة تحويل الإحداثيات إلى اسم مدينة، نوع الدقة، معالجة البيانات واحتفاظ مزوّد النظام بها. المدينة اليدوية متاحة |
| القراءة والعبادات والمحادثات المحلية | التخزين المحلي يشمل العلامات، التقدم، الإعدادات، ومحادثات المساعد المحلي. يستثني التطبيق مجلدي التلاوات ونموذج المساعد القابلَين لإعادة التنزيل من النسخ الاحتياطي في النظامين |
| طلبات المتجر وCDN | مراجعة بيانات الطلب وسياسة احتفاظ `cdn.islamic.network` وHugging Face ومزودي الشبكة، بما فيها IP وبيانات الجهاز حسب الاستخدام. طلبات التنزيل يبدأها المستخدم |
| المساعد عبر الإنترنت | غير مفعّل بدون `TAMANINA_GUIDE_URL`. تشغيله يتطلب مراجعة إفصاح الأسئلة وسجل الرسائل والاحتفاظ والمزوّد قبل إصدار مختلف |
| الإعلانات والتتبّع والتحليلات | البناء الحالي لا يدمج SDK للإعلانات أو Firebase Analytics أو Crashlytics. جهّز إجابات الإعلان والتتبّع بحسب تكاملات نسخة الرفع الفعلية |
| الحساب والحذف | جميع الشاشات العامة مفتوحة بدون تسجيل دخول. اشرح حذف البيانات المحلية ومسار طلب حذف البيانات التي يعالجها المزود في سياسة الخصوصية |
| Android exact alarms | `SCHEDULE_EXACT_ALARM` وصول خاص يوافق عليه المستخدم لتوقيت الصلاة. يعرض التطبيق تنبيهات بديلة عند غياب الموافقة. راجع التصريح الظاهر في Console للمانيفست المرفوع |
| Android foreground media | `FOREGROUND_SERVICE_MEDIA_PLAYBACK` للصوت الذي يسمعه المستخدم. إذا طلبت Console فيديو التصريح، صوّر بدء تشغيل التلاوة، استمرار الصوت بعد إغلاق الشاشة، ثم إيقافه من أدوات التحكم. أظهر أيضًا إذن المنبّهات وطريقة إيقاف الأذان من الإشعار |
| iOS background modes | `audio` للتلاوة، `fetch` لتجديد طابور التنبيهات حين يتيح النظام الوقت، و`remote-notification` لتكامل FCM. الأذان المحلي يستخدم ملف صوت 21 ثانية مع التنبيه |
| iOS export compliance | راجع أسئلة التشفير بناءً على HTTPS عبر النظام والتحقق SHA-256 وSDKs المرفقة. أثبت إجابة الناشر قبل تثبيت قيمة `ITSAppUsesNonExemptEncryption` |
| الأذونات المرفقة من التبعيات | افحص المانيفست النهائي بعد دمج التبعيات. خدمتا الموقع والمساعد المحلي تعملان بالربط من التطبيق، وخدمات foreground المعلنة مخصصة للصوت. سجّل أي تصريح إضافي تطلبه Console قبل الإرسال |

حُفظت ملفات التلاوة والنموذج داخل مساحة التطبيق مع استثنائها من النسخ الاحتياطي، وفق آليات التخزين على النظامين. [Android Auto Backup](https://developer.android.com/identity/data/autobackup) · [Apple file storage](https://developer.apple.com/documentation/foundation/using-the-file-system-effectively)

تمت إضافة Privacy Manifest للتطبيق وامتداد WidgetKit لاستخدام UserDefaults وApp Group. أدرج بيانات جميع حزم SDK ضمن إفصاح الناشر. [Apple required-reason APIs](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api) · [SDKs المدرجة لدى Apple](https://developer.apple.com/support/third-party-SDK-requirements/) · [Google Play واستخدام Foreground Services](https://support.google.com/googleplay/android-developer/answer/13409147) · [تشفير Apple والتصدير](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/)

## الملفات التسويقية وحقوق المحتوى

- جهّز لقطات من بناء الاختبار بالعربية والإنجليزية. الترتيب المقترح هو الرئيسية وتركيز اليوم، المصحف، الأذكار والسبحة، ثم الويدجت. أظهر الواجهة الفعلية على الجهاز بالحجم المطلوب. في Apple جهّز مقاس iPhone المسموح في Media Manager مثل 1320 × 2868، ولقطات iPad لأن التطبيق يدعمه، مثل 2064 × 2752 إذا ظهر في فئة الجهاز المدعوم. [مقاسات Apple](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)
- جهّز لـ Google Play أيقونة PNG ‏512 × 512، وFeature Graphic ‏1024 × 500، ولقطتين على الأقل للأجهزة المطلوبة. راجع عرض المتجر على الهاتف والتابلت. رمز المتجر في Apple يأتي من أصل الأيقونة في iOS. [مواصفات Google Play](https://support.google.com/googleplay/android-developer/answer/9866151)
- صور المصحف من مصحف المدينة برواية حفص. احتفظ بإسناد المجمع وشروط الاستخدام الموضحة في [ملف المصدر](assets/mushaf/SOURCE.md). ملف الأذان المضمّن تحت CC0 بحسب [ملف الإسناد](assets/audio/adhan/README.md). احتفظ بإشعارات OFL للخطوط المرفقة في [`assets/fonts`](assets/fonts/).
- وثّق حقوق التلاوات البعيدة قبل الإرسال، بما فيها السماح بالبث والتنزيل للاستخدام دون اتصال وبلدان الإتاحة. راجع أيضًا مصادر النصوص الدينية وترخيص نموذج Qwen القابل للتنزيل. [Qwen2.5-0.5B-Instruct-GGUF](https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF)

## إدارة المكتبات قبل كل إصدار

احتفظ بـ `pubspec.lock` و`ios/Podfile.lock` مع المصدر. أُزيلت Supabase ومكتبة المراجعات المدمجة لعدم استخدامها، ونُقلت أدوات الأيقونة وشاشة البدء إلى تبعيات التطوير، وثُبّت التحديث المحدد لـ `crypto`. يستخدم Android تقليص الكود R8 مع قواعد للتكامل المؤجل الاختياري لمحرك Flutter.

راجع تقرير `flutter pub outdated` عند التخطيط لترقيات كبيرة. بناء هذا الإصدار يستخدم Gradle 8.14.5 وAGP 8.13.1 وKotlin 2.2.20. يتطلب ترحيل هذه الأدوات في إصدار Flutter لاحق إعادة اختبار الإشعارات والخدمات والتلاوة والمساعد. يستخدم iOS CocoaPods ما دامت بعض الإضافات تعتمد عليه.

## الحجم والأداء

تستخدم صفحات المصحف المطبوع ملفات WebP مضغوطة بحد أقصى 1440 بكسل في الارتفاع. كل الصفحات الـ604 جزء من التطبيق، ويختار القارئ دقة فك الصورة بحسب مساحة العرض. يظل وضع النص القابل لتغيير حجم الخط متاحًا.

يفتح التطبيق وجهة البداية فور جاهزيتها، ويهيئ التخزين والإعدادات المتاحة بالتوازي. يبدأ تحديث بيانات الويدجت بعد أول إطار للرئيسية، ويعيد حساب الصلاة استخدام نتائج الأيام الأخيرة للمدينة وطريقة الحساب الحالية.

يولّد أمر APK ملفًا منفصلًا لكل معمارية مع إصدار التطبيق نفسه. يختار المتجر ملفات المعمارية تلقائيًا عند التوزيع من AAB. تستثني حزمة Gradle المدمجة ملفات رموز التشخيص الأصلية من مرفقات الرفع. للبناء المعتاد مع رموز Android Vitals، استخدم `flutter build appbundle --release`. [Flutter Android releases](https://docs.flutter.dev/deployment/android) · [Android native debug symbols](https://developer.android.com/build/include-native-symbols)

## بناء Android بتوقيع الرفع

ضع ملف `android/key.properties` محليًا. احتفظ بالكلمات والمفتاح في مدير أسرار أو على جهاز مخوّل. يحل Gradle المسار النسبي لـ `storeFile` من مجلد `android/`. استخدم مفتاح الرفع الموجود للتطبيق المسجّل، أو أنشئ مفتاح رفع خاصًا بالناشر إذا كان تطبيقًا جديدًا فعلًا.

```properties
storeFile=/absolute/path/to/tamanina-upload.jks
storePassword=...
keyAlias=...
keyPassword=...
```

```bash
TAMANINA_SUPPORT_EMAIL='owner@example.org'
flutter pub get --enforce-lockfile
flutter build apk --release --split-per-abi --dart-define=TAMANINA_SUPPORT_EMAIL="$TAMANINA_SUPPORT_EMAIL"
(
  cd android
  TAMANINA_COMPACT_BUNDLE=1 ./gradlew :app:bundleRelease \
    "-Ptarget=$PWD/../lib/main.dart" \
    -Ptarget-platform=android-arm,android-arm64,android-x64 \
    -Pbase-application-name=android.app.Application -Ptree-shake-icons=true \
    "-Pdart-defines=$(printf '%s' "TAMANINA_SUPPORT_EMAIL=$TAMANINA_SUPPORT_EMAIL" | base64 | tr -d '\n')"
)
jarsigner -verify build/app/outputs/bundle/release/app-release.aab
apksigner verify --verbose --print-certs build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

استبدل `owner@example.org` بعنوان الدعم الحقيقي قبل التنفيذ. اضبط مسار Android build-tools على `PATH` لاستخدام `apksigner`. قارن SHA-256 للشهادة بسجل Upload key certificate في Play Console. مفتاح التطبيق الذي تستخدمه Google لتوقيع نسخ Play قد يختلف عن مفتاح الرفع، لذلك وزّع تحديثات مستخدمي Play عبر Play. افحص محاذاة APK ومكتبات 64-bit وأكّد تقرير الحجم والتوافق بعد الرفع لمسار الاختبار. [Android app signing](https://developer.android.com/studio/publish/app-signing) · [فحص 16 KB](https://developer.android.com/guide/practices/page-sizes) · [حدود حجم Google Play](https://support.google.com/googleplay/android-developer/answer/9859372)

## بناء iOS بتوقيع App Store

1. سجّل المعرّفين `com.abdalluh.tamanina` و`com.abdalluh.tamanina.Widgets` تحت الفريق الذي يمتلك سجل التطبيق. فعّل App Groups على الاثنين وأضف `group.com.abdalluh.tamanina` إلى الاثنين. فعّل Push Notifications على Runner إذا أبقيت رسائل Firebase.
2. في `ios/Runner.xcworkspace` اختر الفريق الصحيح لتوقيع Runner والويدجت. أتح شهادة Apple Distribution مع مفتاحها الخاص وملفات توزيع للهدفين، أو استخدم توقيع Xcode التلقائي من حساب مخوّل. راجع Release في الاثنين.
3. ابنِ IPA باستخدام نسخة SDK المناسبة. إذا كنت تستخدم Xcode Organizer فافتح الأرشيف الموقّع واختر Distribute App ثم App Store Connect. يمكن رفع IPA الموقّع عبر Transporter أيضًا. [رفع البناء إلى Apple](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/)

```bash
TAMANINA_SUPPORT_EMAIL='owner@example.org'
flutter pub get --enforce-lockfile
flutter build ipa --release --export-method app-store --dart-define=TAMANINA_SUPPORT_EMAIL="$TAMANINA_SUPPORT_EMAIL"
```

احفظ `.xcarchive` وdSYM للإصدار في مكان محمي. عند فحص الأرشيف تأكد من وجود `Runner.app/PlugIns/TamaninaWidgets.appex` ومن صلاحيات App Group بعد التوقيع وإصدار ملحق الويدجت المطابق.

## اختبار التسليم ثم الرفع

| الاختبار | النتيجة المطلوبة من بناء الإصدار الموقّع |
| --- | --- |
| تثبيت نظيف بدون شبكة | المقدمة، فتح الرئيسية، اختيار مدينة يدويًا، مواقيت الصلاة، صفحات المصحف والبحث والعلامات، الأذكار، السبحة، والقبلة تعمل محليًا حسب دعم مستشعر الجهاز |
| بعد آخر صلاة | تظهر صلاة الفجر لليوم التالي في الرئيسية والويدجت. اختبر تبدّل اليوم والمنطقة الزمنية وتوقيت الصيف |
| إذن التنبيه | افحص الرفض ثم الموافقة من إعدادات الجهاز. تأكد من نجاح الجدولة بعد الموافقة وعدم تكرار الطلبات المعلقة |
| Android بالخلفية | جرّب تشغيل الأذان الكامل بعد إغلاق الواجهة وقفل الجهاز وبعد إعادة التشغيل، مع تفعيل وقت التنبيه الدقيق. جرّب بديل التنبيه عند رفضه، واختبر التحكم في تشغيل التلاوة خارج التطبيق |
| iOS بالخلفية | جرّب الأذان المحلي على iPhone حقيقي في وضع الطيران مع قفل الجهاز، وجرّب أصوات التطبيق وFocus والوضع الصامت وتجديد التنبيهات بعد مرور عدة أيام. النظام يحدد وقت تحديث الخلفية؛ افحص إعادة تعبئة طابور التنبيهات عند فتح التطبيق |
| الويدجت | أضف الأحجام المتوفرة، وجرّب الوضع الداكن والفاتح والعربية والإنجليزية والضغط على كل اختصار. افحص مشاركة بيانات التطبيق مع الويدجت في البناء الموقع |
| تنزيل واستخدام التلاوة والمساعد | نزّل التلاوة والنموذج اختياريًا، اقطع الشبكة، ثم شغّلهما وافحص حذف النموذج والتعامل مع فشل التنزيل. ثبّت حدود استخدام وملاءمة إجابات المساعد قبل إرسال الاستبيان العمري |
| تحديث فوق إصدار سابق | تحقق من بقاء الإعدادات وموقع المدينة والعلامات والقراءة والصلاة بعد الاستبدال. استخدم مفتاح التوقيع الصحيح لنفس قناة التوزيع |
| توافق الأجهزة | Android arm64 وجهاز يدعم صفحات 16 KB، وiPhone وiPad بحجمين على الأقل. راجع شاشات العربية وRTL وتكبير النص |

**Google Play**

1. جهّز سجل التطبيق والصفحة الرئيسية للمتجر ومعلومات الدعم، وأكمل App content وData safety وتصريحات الأذونات والعمر والإعلانات والوصول.
2. ارفع AAB الموقّع إلى Internal testing. افحص App Bundle Explorer والحجم لكل جهاز وأذونات النسخة وPre-launch report. الحساب الشخصي المنشأ بعد 13 نوفمبر 2023 يحتاج اختبارًا مغلقًا بـ 12 مختبرًا لمدة 14 يومًا متصلة قبل طلب الوصول إلى Production. تحقّق من حالة الحساب. [متطلبات الاختبار المغلق](https://support.google.com/googleplay/android-developer/answer/14151465)
3. أرسل للمراجعة بعد نجاح التحقق، واحتفظ بإصدار الاختبار وبصمات ملفات الرفع وملفات الرموز. اختر طرحًا تدريجيًا عند توفره للإصدارات اللاحقة.

**App Store Connect**

1. جهّز سجل iOS والاسم واللغات وحقوق المحتوى والاستبيان العمري وApp Privacy وروابط الدعم والخصوصية وملاحظات المراجع.
2. ارفع البناء الموقّع، أجب عن Export Compliance، ثم جرّبه على أجهزة فعلية عبر TestFlight. اختر نفس رقم البناء للإرسال بعد اجتياز الاختبار.
3. راجع صلاحيات الدفع والتاجر والبلدان إذا ظهرت في حسابك، وحدد طريقة الإصدار ثم أرسل البناء للمراجعة.

**ملاحظة مقترحة للمراجع في المتجرين**

> No sign-in is required. On first launch, continue from onboarding and choose a city manually in Prayer Times if you prefer to review without sharing location. Quran, daily adhkar and local prayer calculations work without a connection. Notification permission enables prayer and adhkar reminders. Android’s optional exact alarm permission enables the full locally scheduled adhan. On iOS, adhan is delivered as a local notification sound. Recitations can be downloaded for offline playback. Home-screen widgets are available via the system widget picker.

## التحقق المحلي لهذا البناء

| الفحص | النتيجة |
| --- | --- |
| Flutter tests | نجحت 94 حالة، منها الجدولة بعد رفض إذن الإشعار، الصلاة التالية بعد العشاء، والمصحف والواجهة دون اتصال |
| Flutter analyzer | صفر أخطاء. أبلغ الفحص عن 57 تحذيرًا وملاحظة، منها ملاحظات في الاختبارات وأدوات التوليد |
| Android AAB | 176.2 MB. نجح `bundletool validate` و`jarsigner -verify`. مجلدات النسخ الاحتياطي وسياسات الاستثناء موجودة في الحزمة |
| Android APK | 188.5 MB. نجح `apksigner verify` و`zipalign -c -P 16 4`. يوجد دعم `arm64-v8a` و`armeabi-v7a` و`x86_64` |
| Android 16 KB | الحزمة تطلب `PAGE_ALIGNMENT_16K`. محاذاة مقاطع التحميل في جميع مكتبات ELF داخل AAB وAPK لا تقل عن 16 KB |
| Android دون اتصال | ثُبّتت حزم arm64 المولّدة من AAB على المحاكي. فُتح التطبيق بعد إيقافه مع عدم وجود شبكة افتراضية، وظهرت المواقيت، وفتح اختصار القرآن صفحة 1 من 604 |
| Android تنزيل المتجر | تقدير `bundletool` لحجم تنزيل حزم arm64 على المحاكي بلغ 107.8 MB. اعتمد تقرير Play Console لكل جهاز عند رفع نسخة الاختبار |
| iOS | أرشيف جهاز arm64 بحجم 307.5 MB وZIP بحجم 148.3 MB. تم التحقق من امتداد WidgetKit وملفات Privacy Manifest وإذن الموقع بالعربية والإنجليزية. تصدير IPA الموقّع واختبار iPhone الفعلي ينتظران إعداد توزيع Apple |
| أصول القراءة | 604 صفحة مصحف موجودة في ملفات Android وفي أرشيف iOS |

بصمة SHA-256 لشهادة الرفع المحلية على Android. هذه بصمة عامة للتحقق من الحساب.

```text
68:99:AD:D7:55:A2:4A:6F:FA:05:99:2D:5E:7E:4A:A1:07:41:30:34:09:50:74:E4:7C:D2:59:EC:81:87:BD:C7
```

بصمات ملفات التسليم.

```text
2bdccfb2b437a5a362c93d4576b489138d6fb14544b98ca4ed327ee87f98a187  app-release.aab
49b329c6fdbd29a37ab5dc0d5a74f3bc97b0753e2ddd4f96e0fb3a40b8cfd0f7  app-release.apk
7938cafb5e174c16f86c9fa7463f2073186842190a6b494c8a121eef38b47c82  Tamanina-1.0.1+2-iOS-unsigned.xcarchive.zip
```
