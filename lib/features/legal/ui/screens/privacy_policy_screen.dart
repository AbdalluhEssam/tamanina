import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// صفحة سياسة الخصوصية
/// Privacy Policy Screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'سياسة الخصوصية',
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
مرحباً بك في تطبيق "طمأنينة" للأذكار والقرآن الكريم. نحن نقدر ثقتك بنا ونلتزم بحماية خصوصيتك وبياناتك الشخصية.

توضح سياسة الخصوصية هذه كيفية جمع واستخدام وحماية المعلومات التي قد نحصل عليها منك أثناء استخدام تطبيقنا.
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'المعلومات التي نجمعها',
              content: '''
• **معلومات الاستخدام**: نجمع معلومات حول كيفية استخدامك للتطبيق، مثل الأذكار المفضلة وآخر موضع قراءة في القرآن الكريم.

• **بيانات الجهاز**: قد نجمع معلومات عامة عن جهازك مثل نوع الجهاز ونظام التشغيل لتحسين تجربة المستخدم.

• **بيانات الموقع**: نستخدم موقعك الجغرافي فقط لتحديد اتجاه القبلة وأوقات الصلاة، ولا نخزن هذه البيانات على خوادمنا.

• **الإشعارات**: إذا سمحت بذلك، نرسل إشعارات لتذكيرك بالأذكار وأوقات الصلاة.
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'كيف نستخدم معلوماتك',
              content: '''
نستخدم المعلومات التي نجمعها للأغراض التالية:

• تحسين تجربة المستخدم وتخصيص المحتوى
• حفظ تقدمك في قراءة القرآن والأذكار
• إرسال تذكيرات بأوقات الصلاة والأذكار
• تحليل استخدام التطبيق لتحسين خدماتنا
• الامتثال للمتطلبات القانونية
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'حماية البيانات',
              content: '''
نتخذ إجراءات أمنية مناسبة لحماية بياناتك من الوصول غير المصرح به أو التعديل أو الإفصاح أو الإتلاف.

• **التخزين المحلي**: معظم بياناتك تُخزن محلياً على جهازك فقط
• **التشفير**: نستخدم تقنيات التشفير لحماية البيانات المنقولة
• **عدم المشاركة**: لا نبيع أو نشارك بياناتك الشخصية مع أطراف ثالثة
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'خدمات الطرف الثالث',
              content: '''
قد يستخدم التطبيق خدمات من أطراف ثالثة لبعض الوظائف:

• **Firebase**: لخدمات الإشعارات والتحليلات
• **خدمات الموقع**: لتحديد اتجاه القبلة وأوقات الصلاة

هذه الخدمات لها سياسات خصوصية خاصة بها، وننصحك بمراجعتها.
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'حقوقك',
              content: '''
لديك الحق في:

• الوصول إلى بياناتك الشخصية المخزنة
• طلب تصحيح أو حذف بياناتك
• إلغاء الاشتراك في الإشعارات في أي وقت
• حذف التطبيق وجميع البيانات المرتبطة به
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'خصوصية الأطفال',
              content: '''
تطبيق "طمأنينة" مناسب لجميع الأعمار ولا نجمع معلومات شخصية بشكل متعمد من الأطفال دون سن 13 عاماً بدون موافقة الوالدين.
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'التغييرات على السياسة',
              content: '''
قد نقوم بتحديث سياسة الخصوصية هذه من وقت لآخر. سنقوم بإعلامك بأي تغييرات جوهرية عن طريق نشر السياسة الجديدة في التطبيق.

ننصحك بمراجعة هذه السياسة بشكل دوري للاطلاع على أي تحديثات.
''',
              isDark: isDark,
            ),

            _buildSection(
              title: 'اتصل بنا',
              content: '''
إذا كان لديك أي أسئلة أو استفسارات حول سياسة الخصوصية هذه، يرجى التواصل مع فريق الدعم في شركة Achievement Digital Solutions عبر الوسائل التالية:
📧 البريد الإلكتروني: info@engaztechnology.net
🌐 الموقع الإلكتروني: www.engaztechnology.net
''',
              isDark: isDark,
            ),

            SizedBox(height: 32.h),

            // التأكيد
            _buildConfirmation(isDark),
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
            AppColors.primaryGreen.withOpacity(0.1),
            AppColors.primaryBlue.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.privacy_tip_outlined,
              color: AppColors.primaryGreen,
              size: 32.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خصوصيتك تهمنا',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'نلتزم بحماية بياناتك الشخصية',
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
            'آخر تحديث: مايو 2026',
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
              color: AppColors.primaryGreen,
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

  Widget _buildConfirmation(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.creamAccent,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.primaryGreen,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'باستخدامك لتطبيق طمأنينة، فإنك توافق على سياسة الخصوصية هذه.',
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
