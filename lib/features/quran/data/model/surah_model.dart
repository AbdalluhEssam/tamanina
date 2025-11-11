import 'package:flutter/foundation.dart';

import 'ayah_model.dart';

/// Data transfer object holding a complete surah payload.
@immutable
class SurahModel {
  const SurahModel({
    required this.id,
    required this.name,
    required this.englishName,
    required this.ayahs,
  });

  /// Surah index as defined in the Mushaf (1-114).
  final int id;

  /// Arabic name of the surah.
  final String name;

  /// English transliterated name used for UI subtitles.
  final String englishName;

  /// Ordered ayah list of the surah.
  final List<AyahModel> ayahs;

  /// Constructs the model from JSON data.
  factory SurahModel.fromJson(Map<String, dynamic> json) {
    final ayahs = (json['ayahs'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic item) => AyahModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    return SurahModel(
      id: json['id'] as int,
      name: json['name'] as String,
      englishName: json['english_name'] as String,
      ayahs: ayahs,
    );
  }

  /// Serialises to JSON for caching.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'english_name': englishName,
      'ayahs': ayahs.map((ayah) => ayah.toJson()).toList(),
    };
  }
}
