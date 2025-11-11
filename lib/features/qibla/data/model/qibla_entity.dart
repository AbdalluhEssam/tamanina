import 'package:equatable/equatable.dart';
import '../../../prayer/data/model/prayer_entity.dart';

/// نموذج البيانات الخاص باتجاه القبلة
/// Qibla Direction Data Model
class QiblaEntity extends Equatable {
  final double qiblaDirection; // اتجاه القبلة بالدرجات (0-360)
  final LocationEntity currentLocation; // الموقع الحالي
  final LocationEntity kaabaLocation; // موقع الكعبة المشرفة
  final double distanceToKaaba; // المسافة إلى الكعبة (بالكيلومتر)
  final bool isCalibrated; // هل البوصلة معايرة
  final double currentBearing; // الاتجاه الحالي للجهاز
  final double magneticDeclination; // الانحراف المغناطيسي
  final int accuracy; // دقة القياس (1-5)
  final DateTime lastUpdated; // آخر تحديث
  final QiblaCalculationMethod calculationMethod; // طريقة الحساب المستخدمة

  const QiblaEntity({
    required this.qiblaDirection,
    required this.currentLocation,
    required this.kaabaLocation,
    required this.distanceToKaaba,
    this.isCalibrated = false,
    this.currentBearing = 0.0,
    this.magneticDeclination = 0.0,
    this.accuracy = 3,
    required this.lastUpdated,
    this.calculationMethod = QiblaCalculationMethod.greatCircle,
  });

  QiblaEntity copyWith({
    double? qiblaDirection,
    LocationEntity? currentLocation,
    LocationEntity? kaabaLocation,
    double? distanceToKaaba,
    bool? isCalibrated,
    double? currentBearing,
    double? magneticDeclination,
    int? accuracy,
    DateTime? lastUpdated,
    QiblaCalculationMethod? calculationMethod,
  }) {
    return QiblaEntity(
      qiblaDirection: qiblaDirection ?? this.qiblaDirection,
      currentLocation: currentLocation ?? this.currentLocation,
      kaabaLocation: kaabaLocation ?? this.kaabaLocation,
      distanceToKaaba: distanceToKaaba ?? this.distanceToKaaba,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      currentBearing: currentBearing ?? this.currentBearing,
      magneticDeclination: magneticDeclination ?? this.magneticDeclination,
      accuracy: accuracy ?? this.accuracy,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      calculationMethod: calculationMethod ?? this.calculationMethod,
    );
  }

  /// تحديث اتجاه الجهاز الحالي
  QiblaEntity updateCurrentBearing(double bearing) {
    return copyWith(
      currentBearing: bearing,
      lastUpdated: DateTime.now(),
    );
  }

  /// تعيين حالة المعايرة
  QiblaEntity setCalibrated(bool calibrated) {
    return copyWith(isCalibrated: calibrated);
  }

  /// تحديث الدقة
  QiblaEntity updateAccuracy(int newAccuracy) {
    return copyWith(accuracy: newAccuracy.clamp(1, 5));
  }

  /// الفرق بين الاتجاه الحالي واتجاه القبلة
  double get deviationFromQibla {
    double difference = (qiblaDirection - currentBearing).abs();
    if (difference > 180) {
      difference = 360 - difference;
    }
    return difference;
  }

  /// هل الجهاز موجه نحو القبلة (ضمن نطاق مقبول)
  bool get isPointingToQibla {
    return deviationFromQibla <= 5.0; // دقة 5 درجات
  }

  /// مستوى دقة التوجه
  QiblaAccuracyLevel get accuracyLevel {
    final deviation = deviationFromQibla;
    if (deviation <= 2.0) return QiblaAccuracyLevel.excellent;
    if (deviation <= 5.0) return QiblaAccuracyLevel.good;
    if (deviation <= 10.0) return QiblaAccuracyLevel.fair;
    return QiblaAccuracyLevel.poor;
  }

  /// المسافة بالوحدات المختلفة
  String get formattedDistance {
    if (distanceToKaaba < 1) {
      return '${(distanceToKaaba * 1000).toStringAsFixed(0)} متر';
    } else if (distanceToKaaba < 1000) {
      return '${distanceToKaaba.toStringAsFixed(1)} كم';
    } else {
      return '${(distanceToKaaba / 1000).toStringAsFixed(1)} ألف كم';
    }
  }

  /// اتجاه القبلة كنص (شمال، شمال شرق، إلخ)
  String get qiblaDirectionText {
    return _getDirectionText(qiblaDirection);
  }

  /// الاتجاه الحالي كنص
  String get currentBearingText {
    return _getDirectionText(currentBearing);
  }

  String _getDirectionText(double degrees) {
    const directions = [
      'شمال',
      'شمال شرق',
      'شرق',
      'جنوب شرق',
      'جنوب',
      'جنوب غرب',
      'غرب',
      'شمال غرب'
    ];

    final index = ((degrees + 22.5) / 45) % 8;
    return directions[index.floor()];
  }

  /// هل البيانات حديثة (أقل من 5 دقائق)
  bool get isDataFresh {
    return DateTime.now().difference(lastUpdated).inMinutes < 5;
  }

  @override
  List<Object?> get props => [
        qiblaDirection,
        currentLocation,
        kaabaLocation,
        distanceToKaaba,
        isCalibrated,
        currentBearing,
        magneticDeclination,
        accuracy,
        lastUpdated,
        calculationMethod,
      ];
}

/// طرق حساب اتجاه القبلة
enum QiblaCalculationMethod {
  greatCircle('الدائرة العظمى', 'Great Circle'),
  rhumbLine('خط الاتجاه', 'Rhumb Line');

  const QiblaCalculationMethod(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;
}

/// مستويات دقة التوجه للقبلة
enum QiblaAccuracyLevel {
  excellent('ممتاز', 'Excellent'),
  good('جيد', 'Good'),
  fair('مقبول', 'Fair'),
  poor('ضعيف', 'Poor');

  const QiblaAccuracyLevel(this.arabicName, this.englishName);

  final String arabicName;
  final String englishName;

  /// اللون المناسب لكل مستوى
  int get colorValue {
    switch (this) {
      case QiblaAccuracyLevel.excellent:
        return 0xFF4CAF50; // أخضر
      case QiblaAccuracyLevel.good:
        return 0xFF8BC34A; // أخضر فاتح
      case QiblaAccuracyLevel.fair:
        return 0xFFFF9800; // برتقالي
      case QiblaAccuracyLevel.poor:
        return 0xFFF44336; // أحمر
    }
  }
}

/// نموذج إعدادات القبلة
class QiblaSettings extends Equatable {
  final bool enableVibration; // تفعيل الاهتزاز عند التوجه الصحيح
  final bool enableSound; // تفعيل الصوت
  final bool showDistance; // عرض المسافة إلى الكعبة
  final bool useHighAccuracy; // استخدام دقة عالية في الـ GPS
  final QiblaCalculationMethod calculationMethod; // طريقة الحساب
  final int calibrationReminder; // تذكير المعايرة (بالدقائق)
  final bool showDirectionText; // عرض نص الاتجاه
  final bool nightMode; // الوضع الليلي للبوصلة

  const QiblaSettings({
    this.enableVibration = true,
    this.enableSound = true,
    this.showDistance = true,
    this.useHighAccuracy = true,
    this.calculationMethod = QiblaCalculationMethod.greatCircle,
    this.calibrationReminder = 30,
    this.showDirectionText = true,
    this.nightMode = false,
  });

  QiblaSettings copyWith({
    bool? enableVibration,
    bool? enableSound,
    bool? showDistance,
    bool? useHighAccuracy,
    QiblaCalculationMethod? calculationMethod,
    int? calibrationReminder,
    bool? showDirectionText,
    bool? nightMode,
  }) {
    return QiblaSettings(
      enableVibration: enableVibration ?? this.enableVibration,
      enableSound: enableSound ?? this.enableSound,
      showDistance: showDistance ?? this.showDistance,
      useHighAccuracy: useHighAccuracy ?? this.useHighAccuracy,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      calibrationReminder: calibrationReminder ?? this.calibrationReminder,
      showDirectionText: showDirectionText ?? this.showDirectionText,
      nightMode: nightMode ?? this.nightMode,
    );
  }

  @override
  List<Object> get props => [
        enableVibration,
        enableSound,
        showDistance,
        useHighAccuracy,
        calculationMethod,
        calibrationReminder,
        showDirectionText,
        nightMode,
      ];
}

/// معلومات معايرة البوصلة
class CompassCalibration extends Equatable {
  final bool isCalibrated; // هل تم المعايرة
  final DateTime? lastCalibrationDate; // تاريخ آخر معايرة
  final int calibrationQuality; // جودة المعايرة (1-5)
  final List<String> calibrationSteps; // خطوات المعايرة
  final bool needsRecalibration; // يحتاج إعادة معايرة

  const CompassCalibration({
    this.isCalibrated = false,
    this.lastCalibrationDate,
    this.calibrationQuality = 0,
    this.calibrationSteps = const [],
    this.needsRecalibration = true,
  });

  CompassCalibration copyWith({
    bool? isCalibrated,
    DateTime? lastCalibrationDate,
    int? calibrationQuality,
    List<String>? calibrationSteps,
    bool? needsRecalibration,
  }) {
    return CompassCalibration(
      isCalibrated: isCalibrated ?? this.isCalibrated,
      lastCalibrationDate: lastCalibrationDate ?? this.lastCalibrationDate,
      calibrationQuality: calibrationQuality ?? this.calibrationQuality,
      calibrationSteps: calibrationSteps ?? this.calibrationSteps,
      needsRecalibration: needsRecalibration ?? this.needsRecalibration,
    );
  }

  /// هل تحتاج معايرة (بناءً على الوقت)
  bool get needsCalibrationByTime {
    if (lastCalibrationDate == null) return true;

    final daysSinceCalibration =
        DateTime.now().difference(lastCalibrationDate!).inDays;
    return daysSinceCalibration > 7; // معايرة كل أسبوع
  }

  /// جودة المعايرة كنص
  String get qualityText {
    switch (calibrationQuality) {
      case 5:
        return 'ممتاز';
      case 4:
        return 'جيد جداً';
      case 3:
        return 'جيد';
      case 2:
        return 'مقبول';
      case 1:
        return 'ضعيف';
      default:
        return 'غير مُعايَر';
    }
  }

  @override
  List<Object?> get props => [
        isCalibrated,
        lastCalibrationDate,
        calibrationQuality,
        calibrationSteps,
        needsRecalibration,
      ];
}
