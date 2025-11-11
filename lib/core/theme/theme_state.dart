part of 'theme_cubit.dart';

/// Immutable state for the [ThemeCubit].
class ThemeState extends Equatable {
  const ThemeState(this.themeMode);

  final ThemeMode themeMode;

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode ?? this.themeMode);
  }

  @override
  List<Object?> get props => <Object?>[themeMode];
}
