import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/adhkar_model.dart';

part 'adhkar_state.dart';

enum AdhkarCategory { morning, evening, sleep, postPrayer, misc }

class AdhkarCubit extends Cubit<AdhkarState> {
  final SharedPreferences _prefs;

  AdhkarCubit(this._prefs) : super(AdhkarInitial());

  Future<void> loadAdhkar(AdhkarCategory category) async {
    try {
      emit(AdhkarLoading());

      final String fileName = _getFileName(category);
      final String jsonString = await rootBundle.loadString(
        'assets/data/adhkar/$fileName',
      );
      final List<dynamic> jsonList = json.decode(jsonString);

      List<AdhkarModel> adhkarList = jsonList
          .map((json) => AdhkarModel.fromJson(json))
          .toList();

      // Load favorites
      final Set<int> favorites = _loadFavorites(category);
      adhkarList = adhkarList.map((adhkar) {
        return adhkar.copyWith(isFavorite: favorites.contains(adhkar.id));
      }).toList();

      if (isClosed) return;
      emit(AdhkarLoaded(adhkarList: adhkarList, category: category));
    } catch (e) {
      if (isClosed) return;
      emit(AdhkarError(message: 'فشل تحميل الأذكار: ${e.toString()}'));
    }
  }

  Future<void> toggleFavorite(int adhkarId) async {
    final currentState = state;
    if (currentState is! AdhkarLoaded) return;

    try {
      final Set<int> favorites = _loadFavorites(currentState.category);

      if (favorites.contains(adhkarId)) {
        favorites.remove(adhkarId);
      } else {
        favorites.add(adhkarId);
      }

      await _saveFavorites(currentState.category, favorites);

      final updatedList = currentState.adhkarList.map((adhkar) {
        if (adhkar.id == adhkarId) {
          return adhkar.copyWith(isFavorite: !adhkar.isFavorite);
        }
        return adhkar;
      }).toList();

      if (isClosed) return;
      emit(
        AdhkarLoaded(adhkarList: updatedList, category: currentState.category),
      );
    } catch (e) {
      if (isClosed) return;
      emit(AdhkarError(message: 'فشل تحديث المفضلة: ${e.toString()}'));
    }
  }

  String _getFileName(AdhkarCategory category) {
    switch (category) {
      case AdhkarCategory.morning:
        return 'morning_adhkar.json';
      case AdhkarCategory.evening:
        return 'evening_adhkar.json';
      case AdhkarCategory.sleep:
        return 'sleep_adhkar.json';
      case AdhkarCategory.postPrayer:
        return 'post_prayer_adhkar.json';
      case AdhkarCategory.misc:
        return 'misc_adhkar.json';
    }
  }

  Set<int> _loadFavorites(AdhkarCategory category) {
    final List<String>? favoritesString =
        _prefs.getStringList('favorite_adhkar_${category.name}') ??
        _prefs.getStringList('favorite_adhkar');
    if (favoritesString == null) return {};
    return favoritesString.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> _saveFavorites(
    AdhkarCategory category,
    Set<int> favorites,
  ) async {
    final List<String> favoritesString = favorites
        .map((id) => id.toString())
        .toList();
    await _prefs.setStringList(
      'favorite_adhkar_${category.name}',
      favoritesString,
    );
  }

  String getCategoryTitle(AdhkarCategory category) {
    switch (category) {
      case AdhkarCategory.morning:
        return 'أذكار الصباح';
      case AdhkarCategory.evening:
        return 'أذكار المساء';
      case AdhkarCategory.sleep:
        return 'أذكار النوم';
      case AdhkarCategory.postPrayer:
        return 'أذكار بعد الصلاة';
      case AdhkarCategory.misc:
        return 'أذكار متنوعة';
    }
  }
}
