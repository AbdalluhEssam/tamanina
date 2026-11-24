import 'dart:async';

import 'package:app_links/app_links.dart';

import '../constants/app_constants.dart';
import 'navigation_service.dart';

class WorshipShortcuts {
  WorshipShortcuts._();
  static final instance = WorshipShortcuts._();

  bool _homeReady = false;
  String? _pending;
  StreamSubscription<Uri>? _subscription;

  void start() {
    if (_subscription != null) return;
    final links = AppLinks();
    // The stream delivers both the initial link and subsequent links.
    _subscription = links.uriLinkStream.listen(_handleLink, onError: (_) {});
  }

  void _handleLink(Uri link) {
    if (link.scheme == 'tamanina' && link.host == 'open') open(link.path);
  }

  void open(String? route) {
    if (route == null) return;
    if (route.startsWith(AppRoutes.adhan)) {
      _pending = route;
      _flush();
      return;
    }
    if (!const {
      AppRoutes.prayerTimes,
      AppRoutes.azkar,
      AppRoutes.morningAdhkar,
      AppRoutes.eveningAdhkar,
      AppRoutes.sebha,
      AppRoutes.quran,
      AppRoutes.alKahfReader,
      AppRoutes.adhan,
    }.contains(route)) {
      return;
    }
    _pending = route;
    _flush();
  }

  void setHomeReady(bool ready) {
    _homeReady = ready;
    _flush();
  }

  void _flush() {
    final navigator = NavigationService.navigatorKey.currentState;
    final route = _pending;
    if (!_homeReady || navigator == null || route == null) return;
    _pending = null;
    // Replace a previously opened shortcut screen instead of building a stack
    // each time the widget or a notification is tapped.
    navigator.popUntil(
      (route) => route.settings.name == AppRoutes.home || route.isFirst,
    );
    unawaited(navigator.pushNamed<void>(route));
  }
}
