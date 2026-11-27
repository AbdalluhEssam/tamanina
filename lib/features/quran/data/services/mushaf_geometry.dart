import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart' show rootBundle;

/// Where each verse sits on the printed Mushaf page images.
///
/// `assets/data/mushaf_geometry.json` holds, for each page, the pixel bounds of
/// its text lines and, for each verse, which lines it covers and the part of
/// each line (in thousandths, from the right edge). The lines come from the
/// Quran.com page layout and the pixel bounds from analysing the page images
/// (see `tool/build_geometry.py`). Positions inside a line are estimated from
/// word lengths, so they are close but not exact.
class PageGeometry {
  const PageGeometry._(this.width, this.height, this._lines, this._verses);

  /// Size of the page image the coordinates refer to.
  final double width;
  final double height;
  final List<dynamic> _lines;
  final Map<String, dynamic> _verses;

  /// Rectangles (in image pixels) covering [verse] on this page, or empty.
  List<Rect> rectsFor(int verse) {
    final segments = _verses['$verse'] as List<dynamic>?;
    if (segments == null) return const [];
    return [
      for (final segment in segments.cast<List<dynamic>>())
        _rect(
          _lines[(segment[0] as int) - 1] as List<dynamic>,
          segment[1] as int,
          segment[2] as int,
        ),
    ];
  }

  static Rect _rect(List<dynamic> line, int from, int to) {
    final top = (line[0] as num).toDouble();
    final bottom = (line[1] as num).toDouble();
    final left = (line[2] as num).toDouble();
    final right = (line[3] as num).toDouble();
    final span = right - left;
    return Rect.fromLTRB(
      right - span * to / 1000,
      top,
      right - span * from / 1000,
      bottom,
    );
  }

  /// Every verse number that has a position on this page.
  Iterable<int> get verses => _verses.keys.map(int.parse);
}

class MushafGeometry {
  MushafGeometry._();

  static final instance = MushafGeometry._();

  Map<String, dynamic>? _pages;
  Future<void>? _loading;

  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    try {
      // Decoded here rather than with loadString, which hands large assets to
      // another isolate.
      final data = await rootBundle.load('assets/data/mushaf_geometry.json');
      final text = utf8.decode(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      _pages = jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      _loading = null;
    }
  }

  /// The geometry of [page], or null before it is loaded.
  PageGeometry? page(int page) {
    final data = _pages?['$page'] as Map<String, dynamic>?;
    if (data == null) return null;
    return PageGeometry._(
      (data['w'] as num).toDouble(),
      (data['h'] as num).toDouble(),
      data['l'] as List<dynamic>,
      data['v'] as Map<String, dynamic>,
    );
  }
}
