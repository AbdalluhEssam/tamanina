import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// صفحة شروط الاستخدام
/// Terms of Service Screen
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'شروط الاستخدام',
          style: AppTypography.appBarTitle.copyWith(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان الرئيسي
            _buildHeader(isDark),
            SizedBox(height: 24.h),

            // آخر تحديث
            _buildLastUpdated(isDark),
            SizedBox(height: 24.h),

            // المقدمة
            _buildSection(
              title: 'مقدمة',
              content: '''
مرحباً بك في تطبيق "طمأنينة"، تطبيقك الإسلامي الشامل للأذكار والقرآن الكريم.

تحدد شروط الاستخدام هذه القواعد والأحكام التي تحكم استخدامك لتطبيقنا. باستخدامك للتطبيق، فإنك توافق على الالتزام بهذه الشروط.
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'قبول الشروط',
              content: '''
باستخدام تطبيق "طمأنينة"، فإنك توافق على:

• الالتزام بجميع الشروط والأحكام المذكورة في هذه الوثيقة
• استخدام التطبيق للأغراض المشروعة فقط
• عدم إساءة استخدام التطبيق أو محتواه
• احترام حقوق الملكية الفكرية

إذا كنت لا توافق على أي من هذه الشروط، يرجى عدم استخدام التطبيق.
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'وصف الخدمة',
              content: '''
يوفر تطبيق "طمأنينة" الخدمات التالية:

• 📖 **قراءة القرآن الكريم**: مصحف إلكتروني كامل مع إمكانية البحث
• 🤲 **الأذكار والأدعية**: أذكار الصباح والمساء والنوم وبعد الصلاة
• 🧭 **اتجاه القبلة**: تحديد اتجاه القبلة باستخدام الموقع الجغرافي
• ⏰ **أوقات الصلاة**: عرض مواقيت الصلاة حسب موقعك
• 🔔 **التذكيرات**: إشعارات بأوقات الصلاة والأذكار
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'الاستخدام المقبول',
              content: '''
يُسمح لك باستخدام التطبيق للأغراض التالية:

✅ القراءة والتعلم والتدبر
✅ التذكير بالأذكار وأوقات الصلاة
✅ مشاركة المحتوى الديني مع الآخرين
✅ استخدام التطبيق لأغراض شخصية غير تجارية

يُحظر استخدام التطبيق في:

❌ نشر محتوى مخالف للإسلام أو الأخلاق
❌ التلاعب بالمحتوى القرآني أو تحريفه
❌ استخدام التطبيق لأغراض تجارية بدون إذن
❌ محاولة اختراق أو إتلاف التطبيق
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'المحتوى الديني',
              content: '''
• يحتوي التطبيق على نص القرآن الكريم والأذكار والأدعية من مصادر موثوقة
• نبذل قصارى جهدنا لضمان دقة المحتوى، ولكن قد تحدث أخطاء غير مقصودة
• يُنصح بالرجوع إلى المصادر الأصلية والعلماء الموثوقين عند الشك
• لا نتحمل مسؤولية أي تفسيرات خاطئة للنصوص الدينية
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'الملكية الفكرية',
              content: '''
• جميع حقوق التصميم والبرمجة محفوظة لفريق تطبيق "طمأنينة"
• نص القرآن الكريم ملك للبشرية جمعاء ولا يخضع لحقوق الملكية
• الأذكار والأدعية من التراث الإسلامي المشترك
• يُسمح بمشاركة المحتوى الديني مع ذكر المصدر

لا يجوز:
• نسخ أو توزيع التطبيق بدون إذن
• استخدام العلامة التجارية أو الشعار بدون تصريح
• بيع أو إعادة توزيع التطبيق تجارياً
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'إخلاء المسؤولية',
              content: '''
• يُقدم التطبيق "كما هو" بدون أي ضمانات صريحة أو ضمنية
• لا نضمن عمل التطبيق بشكل مستمر أو خالٍ من الأخطاء
• لا نتحمل مسؤولية أي أضرار ناتجة عن استخدام التطبيق
• قد تتطلب بعض المميزات اتصالاً بالإنترنت
• دقة أوقات الصلاة واتجاه القبلة تعتمد على دقة موقع جهازك
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'التحديثات والتغييرات',
              content: '''
نحتفظ بالحق في:

• تحديث التطبيق وإضافة مميزات جديدة
• تعديل أو إزالة بعض المميزات
• تغيير شروط الاستخدام في أي وقت
• إيقاف التطبيق أو بعض خدماته

سيتم إعلامك بأي تغييرات جوهرية عبر التطبيق أو البريد الإلكتروني.
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'حسابات المستخدمين',
              content: '''
• التطبيق لا يتطلب إنشاء حساب للاستخدام الأساسي
• يتم حفظ إعداداتك وتقدمك محلياً على جهازك
• أنت مسؤول عن الحفاظ على أمان جهازك
• حذف التطبيق سيؤدي إلى فقدان البيانات المحفوظة محلياً
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'الفئة العمرية',
              content: '''
• التطبيق مناسب لجميع الأعمار
• يحتوي على محتوى ديني إسلامي فقط
• لا يحتوي على إعلانات أو محتوى غير مناسب
• يُنصح بإشراف الوالدين للأطفال الصغار
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'القانون الساري',
              content: '''
• تخضع هذه الشروط وتُفسر وفقاً للقوانين السارية
• أي نزاع ينشأ عن استخدام التطبيق يخضع للاختصاص القضائي المناسب
• في حال وجود تعارض، تُعطى الأولوية للنسخة العربية من الشروط
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'اتصل بنا',
              content: '''
لأي استفسارات أو شكاوى تتعلق بشروط الاستخدام:

📧 البريد الإلكتروني: support@tamanina-app.com
🌐 الموقع الإلكتروني: www.tamanina-app.com
📱 التواصل عبر التطبيق: قسم المساعدة في الإعدادات
''',
              isDark: isDark,
            ),

            SizedBox(height: 32.h),

            // قبول الشروط
            _buildAcceptance(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withOpacity(0.1),
            AppColors.primaryGreen.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.description_outlined,
              color: AppColors.primaryBlue,
              size: 32.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'شروط الاستخدام',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'يرجى قراءة الشروط بعناية قبل الاستخدام',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.update,
            color: AppColors.info,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            'آخر تحديث: ديسمبر 2024',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.info,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content.trim(),
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptance(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.creamAccent,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.handshake_outlined,
            color: AppColors.primaryGreen,
            size: 40.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            'شكراً لك على استخدام تطبيق طمأنينة',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'باستمرارك في استخدام التطبيق، فإنك توافق على شروط الاستخدام هذه.',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
