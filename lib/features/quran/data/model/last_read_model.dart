import 'package:flutter/foundation.dart';

/// Represents the last ayah interacted with by the user.
@immutable
class LastReadModel {
  const LastReadModel({required this.surahId, required this.ayahNumber});

  final int surahId;

  final int ayahNumber;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'surah_id': surahId,
      'ayah_number': ayahNumber,
    };
  }

  factory LastReadModel.fromJson(Map<String, dynamic> json) {
    return LastReadModel(
      surahId: json['surah_id'] as int,
      ayahNumber: json['ayah_number'] as int,
    );
  }
}
