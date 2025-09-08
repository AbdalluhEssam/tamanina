# App Restructure Summary

## الهيكل الجديد للتطبيق

تم إعادة تنظيم التطبيق بحيث يكون كل feature مستقل داخل مجلده الخاص:

### 📁 الهيكل الجديد

```
lib/
  features/
    home/
      presentation/
        screens/
          home_layout.dart       # الشاشة الرئيسية مع التنقل
        view/
          home_screen.dart       # محتوى شاشة الرئيسية
        cubit/
          home_navigation_cubit.dart  # إدارة التنقل
    
    tasbeeh/
      presentation/
        screens/
          tasbeeh_screen.dart
          tasbeeh_tab_screen.dart
    
    quran/
      presentation/
        screens/
          quran_screen.dart
          quran_tab_screen.dart
    
    settings/
      presentation/
        screens/
          settings_screen.dart
          settings_tab_screen.dart
```

### 🎯 الميزات الجديدة

1. **HomeLayout**: الشاشة الرئيسية التي تحتوي على:
   - AppBar احترافي مع عنوان ديناميكي
   - BottomNavigationBar للتنقل بين الشاشات
   - FloatingActionButton للمساعد الذكي (Chatbot)
   - إدارة الشاشات باستخدام HomeNavigationCubit

2. **شاشات مستقلة**: 
   - كل feature له شاشة مستقلة داخل مجلده
   - يستخدم نفس التصميم من tab_screens الأصلية
   - إمكانية توسع كل feature بشكل مستقل

3. **إدارة الحالة**:
   - HomeNavigationCubit لإدارة التنقل بين التبويبات
   - HomeCubit لإدارة بيانات الشاشة الرئيسية
   - كل cubit مستقل ومنظم

### 🔄 التنقل بين الشاشات

```dart
// للانتقال لتبويب معين
context.read<HomeNavigationCubit>().navigateToTab(1); // Tasbeeh
context.read<HomeNavigationCubit>().navigateToTasbeeh(); // مباشرة
```

### 📱 الاستخدام

الآن يمكن الوصول للتطبيق من خلال:
- الصفحة الرئيسية: محتوى مع features وstatistics
- التسبيح: شاشة العداد الإلكتروني
- القرآن: شاشة قراءة القرآن
- الإعدادات: إعدادات التطبيق

جميع الشاشات تحتفظ بنفس التصميم الأصلي ولكن مع تنظيم أفضل للكود.
