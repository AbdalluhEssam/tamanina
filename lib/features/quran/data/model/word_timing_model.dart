import 'package:flutter/foundation.dart';

/// Represents a single word inside an ayah alongside its playback timing.
@immutable
class WordTimingModel {
  const WordTimingModel({
    required this.word,
    required this.start,
    required this.duration,
  });

  /// The actual Arabic word text.
  final String word;

  /// The start offset of the word from the beginning of the ayah audio.
  final Duration start;

  /// The expected duration for pronouncing the word.
  final Duration duration;

  /// Hydrates a [WordTimingModel] instance from JSON data.
  factory WordTimingModel.fromJson(Map<String, dynamic> json) {
    return WordTimingModel(
      word: json['word'] as String,
      start: Duration(milliseconds: json['start_ms'] as int),
      duration: Duration(milliseconds: json['duration_ms'] as int),
    );
  }

  /// Persists the instance into a JSON encodable map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'word': word,
      'start_ms': start.inMilliseconds,
      'duration_ms': duration.inMilliseconds,
    };
  }
}
