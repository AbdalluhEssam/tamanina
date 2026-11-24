# صفحات طمأنينة العامة (للرفع على السيرفر)

هذا المجلد جاهز للرفع مباشرةً على أي استضافة أو خادم ويب (Nginx، Apache، cPanel، Cloudflare Pages، GitHub Pages) بدون أي خطوات بناء أو اعتماديات خارجية.

## الملفات المتضمنة

- `index.html` — الصفحة التعريفية الرئيسية وبوابة الروابط
- `privacy.html` — **سياسة الخصوصية** (متوافقة مع إفصاحات Google Play وApp Store في `PRODUCTION_RELEASE.md`)
- `help.html` — **صفحة المساعدة والدعم** (FAQ + إدارة البيانات + التواصل)
- `terms.html` — **شروط الاستخدام**
- `assets/` — الشعار الرسمي (`logo.png`, `brand_mark.svg`, `brand_mark.png`)، خلفية الهيرو، ملف التنسيق `styles.css`، والخطوط المحلية (`Reem Kufi`, `Cairo`, `Amiri`, `Poppins` مع ملفات ترخيص OFL).

## تعديل بيانات الناشر أو البريد الإلكتروني قبل الرفع

افتح ملف [`assets/app.js`](assets/app.js) وعدّل كائن `TAMANINA_SITE_CONFIG` في أعلى الملف فقط، وسيتم تحديث الاسم والبريد وتاريخ السريان تلقائيًا في جميع الصفحات:

```js
window.TAMANINA_SITE_CONFIG = {
  publisherAr: 'عبدالله عصام',
  publisherEn: 'Abdalluh Essam',
  supportEmail: 'abdallhesam100@gmail.com',
  effectiveDateAr: '25 نوفمبر 2026',
  effectiveDateEn: 'November 25, 2026',
  appVersion: '1.0.1',
};
```

## الروابط المقترحة للمتاجر بعد الرفع

إذا رفعت محتويات مجلد `website/` إلى جذر الدومين `https://example.com/`:

- **رابط سياسة الخصوصية (Privacy Policy URL):** `https://example.com/privacy.html`
- **رابط الدعم والمساعدة (Support / Help URL):** `https://example.com/help.html`
- **رابط اللغة الإنجليزية مباشرة (اختياري):** أضف `?lang=en` مثل `https://example.com/privacy.html?lang=en`
