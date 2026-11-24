import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service_enhanced.dart';
import '../../../../core/services/prayer_service_enhanced.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/settings/settings_cubit.dart';
import '../../../../core/theme/worship_palette.dart';
import '../../../../core/widgets/tamanina_ui.dart';
import '../../../prayer_times/ui/screens/prayer_times_screen.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  static const _kaabaLat = 21.4225;
  static const _kaabaLng = 39.8262;
  late Future<LocationResult> _location;
  late final Stream<CompassEvent>? _compass;
  bool _requesting = false;

  @override
  void initState() {
    super.initState();
    _compass = FlutterCompass.events;
    _location = _loadLocation();
  }

  Future<LocationResult> _loadLocation() async {
    final settings = context
        .read<SettingsCubit>()
        .currentSettings
        .locationSettings;
    final lat = settings.manualLatitude;
    final lng = settings.manualLongitude;
    if (!settings.useAutoLocation && lat != null && lng != null) {
      return LocationResult.success(
        latitude: lat,
        longitude: lng,
        cityName: settings.cityName,
      );
    }
    return LocationService().getLastKnownLocation() ??
        LocationResult.failure(
          errorMessage: '',
          errorType: LocationErrorType.unknown,
        );
  }

  Future<void> _requestLocation() async {
    final settings = context.read<SettingsCubit>();
    setState(() => _requesting = true);
    final result = await LocationService().getCurrentLocation(
      forceRefresh: true,
    );
    if (!mounted) return;
    if (result.isSuccess) {
      await settings.useAutoLocation();
      sl<PrayerServiceEnhanced>().refreshLocation();
      await sl<NotificationServiceEnhanced>().refresh();
    }
    if (!mounted) return;
    setState(() {
      _requesting = false;
      if (result.isSuccess) _location = Future.value(result);
    });
    if (!result.isSuccess) {
      final service = result.errorType == LocationErrorType.serviceDisabled;
      final denied =
          result.errorType == LocationErrorType.permissionDeniedForever;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appText(
              context,
              'الموقع غير متاح. يمكنك اختيار مدينتك.',
              'Location is unavailable. You can choose a city.',
            ),
          ),
          action: service || denied
              ? SnackBarAction(
                  label: appText(context, 'الإعدادات', 'Settings'),
                  onPressed: service
                      ? Geolocator.openLocationSettings
                      : Geolocator.openAppSettings,
                )
              : null,
        ),
      );
    }
  }

  Future<void> _chooseCity() async {
    await choosePrayerCity(context);
    if (mounted) {
      setState(() {
        _location = _loadLocation();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appText(context, 'اتجاه القبلة', 'Qibla'))),
      body: SafeArea(
        top: false,
        child: ContentFrame(
          maxWidth: 540,
          child: FutureBuilder<LocationResult>(
            future: _location,
            builder: (context, snapshot) {
              if (_requesting ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const ListSkeleton(rows: 4);
              }
              final location = snapshot.data;
              final valid = location != null && location.isSuccess;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (valid)
                    _direction(context, location)
                  else ...[
                    Text(
                      appText(
                        context,
                        'حدد موقعك أولًا',
                        'Set your location first',
                      ),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appText(
                        context,
                        'تُحسب القبلة على جهازك بعد تحديد موقعك أو مدينتك.',
                        'The Qibla is calculated on your device after you set your location or city.',
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.my_location),
                        label: Text(
                          appText(context, 'استخدم موقعي', 'Use my location'),
                        ),
                        onPressed: _requestLocation,
                      ),
                      OutlinedButton(
                        onPressed: _chooseCity,
                        child: Text(
                          appText(context, 'تغيير المدينة', 'Change city'),
                        ),
                      ),
                    ],
                  ),
                  if (valid)
                    TextButton(
                      onPressed: () async {
                        final opened = await launchUrl(
                          Uri.https('www.google.com', '/maps/search/', {
                            'api': '1',
                            'query': '$_kaabaLat,$_kaabaLng',
                          }),
                          mode: LaunchMode.externalApplication,
                        );
                        if (!opened && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                appText(
                                  context,
                                  'تعذّر فتح الخريطة.',
                                  'The map could not be opened.',
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        appText(
                          context,
                          'عرض الكعبة على الخريطة',
                          'View the Kaaba on a map',
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _direction(BuildContext context, LocationResult location) {
    final lat = location.latitude!;
    final lng = location.longitude!;
    final double bearing =
        (Geolocator.bearingBetween(lat, lng, _kaabaLat, _kaabaLng) + 360) % 360;
    final kilometers =
        Geolocator.distanceBetween(lat, lng, _kaabaLat, _kaabaLng) / 1000;
    final theme = Theme.of(context);
    final manual = !context
        .read<SettingsCubit>()
        .currentSettings
        .locationSettings
        .useAutoLocation;
    final angle = bearing.round() % 360;
    final directions = [
      appText(context, 'الشمال', 'North'),
      appText(context, 'الشمال الشرقي', 'Northeast'),
      appText(context, 'الشرق', 'East'),
      appText(context, 'الجنوب الشرقي', 'Southeast'),
      appText(context, 'الجنوب', 'South'),
      appText(context, 'الجنوب الغربي', 'Southwest'),
      appText(context, 'الغرب', 'West'),
      appText(context, 'الشمال الغربي', 'Northwest'),
    ];
    final direction = directions[((bearing + 22.5) ~/ 45) % 8];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (location.cityName case final String city when city.isNotEmpty)
          Text(
            localizedCityName(
              city,
              arabic: Localizations.localeOf(context).languageCode == 'ar',
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        const SizedBox(height: 8),
        if (kilometers < .1)
          Text(
            appText(
              context,
              'أنت بالقرب من الكعبة.',
              'You are near the Kaaba.',
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          )
        else ...[
          Text(
            '$direction ($angle°)',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Card(
            color: WorshipPalette.pine,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: StreamBuilder<CompassEvent>(
                stream: manual ? null : _compass,
                builder: (context, snapshot) {
                  final heading = snapshot.data?.heading;
                  final live =
                      heading != null &&
                      heading.isFinite &&
                      snapshot.data?.accuracy != -1;
                  final radians = (live ? heading : 0) * math.pi / 180;
                  return Column(
                    children: [
                      Text(
                        live
                            ? appText(context, 'البوصلة الحية', 'Live compass')
                            : appText(
                                context,
                                'الزاوية من الشمال الحقيقي',
                                'Bearing from true north',
                              ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: WorshipPalette.paleSky,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 224),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Semantics(
                            label: '$direction, $angle°',
                            child: CustomPaint(
                              painter: _CompassDial(heading: radians),
                              child: Center(
                                child: Transform.rotate(
                                  angle: bearing * math.pi / 180 - radians,
                                  child: Icon(
                                    platformIcon(
                                      context,
                                      Icons.navigation_rounded,
                                      CupertinoIcons.location_north_fill,
                                    ),
                                    color: WorshipPalette.warmGold,
                                    size: 68,
                                    textDirection: TextDirection.ltr,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        live
                            ? appText(
                                context,
                                'امسك الهاتف أفقيًا بعيدًا عن المعادن.',
                                'Hold the phone flat and away from metal.',
                              )
                            : appText(
                                context,
                                'اتبع زاوية القبلة من الشمال الحقيقي.',
                                'Use this angle from true north.',
                              ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: WorshipPalette.ivory,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            appText(
              context,
              'المسافة إلى الكعبة ${kilometers.round()} كم',
              '${kilometers.round()} km to the Kaaba',
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (manual)
            Text(
              appText(
                context,
                'محسوبة من وسط المدينة',
                'Calculated from the city center',
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall,
            ),
        ],
      ],
    );
  }
}

class _CompassDial extends CustomPainter {
  const _CompassDial({required this.heading});

  final double heading;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 3;
    final ring = Paint()
      ..color = WorshipPalette.paleSky.withValues(alpha: .42)
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, ring);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading);
    final tick = Paint()..strokeWidth = 1.5;
    for (var index = 0; index < 36; index++) {
      final cardinal = index % 9 == 0;
      tick.color = index == 0
          ? WorshipPalette.warmGold
          : WorshipPalette.paleSky.withValues(alpha: cardinal ? .85 : .38);
      canvas.drawLine(
        Offset(0, -radius + 4),
        Offset(0, -radius + (cardinal ? 16 : 9)),
        tick,
      );
      canvas.rotate(math.pi / 18);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CompassDial oldDelegate) =>
      heading != oldDelegate.heading;
}
