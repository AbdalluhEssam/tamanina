import 'package:equatable/equatable.dart';

class AdhkarModel extends Equatable {
  final int id;
  final String arabicText;
  final String transliteration;
  final String translation;
  final int count;
  final String reference;
  final String benefits;
  final bool isFavorite;

  const AdhkarModel({
    required this.id,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    required this.count,
    required this.reference,
    required this.benefits,
    this.isFavorite = false,
  });

  factory AdhkarModel.fromJson(Map<String, dynamic> json) {
    return AdhkarModel(
      id: json['id'] as int,
      arabicText: json['arabicText'] as String,
      transliteration: json['transliteration'] as String,
      translation: json['translation'] as String,
      count: json['count'] as int,
      reference: json['reference'] as String,
      benefits: json['benefits'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arabicText': arabicText,
      'transliteration': transliteration,
      'translation': translation,
      'count': count,
      'reference': reference,
      'benefits': benefits,
      'isFavorite': isFavorite,
    };
  }

  AdhkarModel copyWith({
    int? id,
    String? arabicText,
    String? transliteration,
    String? translation,
    int? count,
    String? reference,
    String? benefits,
    bool? isFavorite,
  }) {
    return AdhkarModel(
      id: id ?? this.id,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      count: count ?? this.count,
      reference: reference ?? this.reference,
      benefits: benefits ?? this.benefits,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        arabicText,
        transliteration,
        translation,
        count,
        reference,
        benefits,
        isFavorite,
      ];
}
