import 'package:flutter/foundation.dart';

import 'word_timing_model.dart';

/// Represents a single ayah with text, audio metadata, and word timings.
@immutable
class AyahModel {
  const AyahModel({
    required this.number,
    required this.text,
    required this.audioUrl,
    required this.wordTimings,
  });

  /// Sequential ayah number within the surah.
  final int number;

  /// Arabic text of the ayah.
  final String text;

  /// Remote audio URL for recitation.
  final String audioUrl;

  /// Word-level timing metadata used for highlighting.
  final List<WordTimingModel> wordTimings;

  /// Builds an instance from JSON data.
  factory AyahModel.fromJson(Map<String, dynamic> json) {
    final words = (json['words'] as List<dynamic>? ?? <dynamic>[])
        .map((dynamic item) =>
            WordTimingModel.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    return AyahModel(
      number: json['number'] as int,
      text: json['text'] as String,
      audioUrl: json['audio_url'] as String,
      wordTimings: words,
    );
  }

  /// Serialises the instance into JSON.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'number': number,
      'text': text,
      'audio_url': audioUrl,
      'words': wordTimings.map((word) => word.toJson()).toList(),
    };
  }
}
