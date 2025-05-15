import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme Events
abstract class ThemeEvent {}

class InitThemeEvent extends ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class UpdateAccentColorEvent extends ThemeEvent {
  final int colorValue;
  UpdateAccentColorEvent(this.colorValue);
}

// Theme State
class ThemeState {
  final bool isDarkMode;
  final int accentColorValue;

  ThemeState({
    required this.isDarkMode,
    required this.accentColorValue,
  });

  // Fix: Return the correct ThemeMode instead of null
  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Create a copy of the current state with updated values
  ThemeState copyWith({
    bool? isDarkMode,
    int? accentColorValue,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      accentColorValue: accentColorValue ?? this.accentColorValue,
    );
  }
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String isDarkModeKey = 'is_dark_mode';
  static const String accentColorKey = 'accent_color_value';

  // Default accent color value (blue)
  static const int defaultAccentColor = 0xFF2196F3;

  ThemeBloc() : super(ThemeState(isDarkMode: false, accentColorValue: defaultAccentColor)) {
    on<InitThemeEvent>(_onInitTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
    on<UpdateAccentColorEvent>(_onUpdateAccentColor);

    // Initialize the theme
    add(InitThemeEvent());
  }

  Future<void> _onInitTheme(InitThemeEvent event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(isDarkModeKey) ?? false;
    final accentColorValue = prefs.getInt(accentColorKey) ?? defaultAccentColor;

    emit(ThemeState(isDarkMode: isDarkMode, accentColorValue: accentColorValue));
  }

  Future<void> _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final newIsDarkMode = !state.isDarkMode;

    await prefs.setBool(isDarkModeKey, newIsDarkMode);
    emit(state.copyWith(isDarkMode: newIsDarkMode));
  }

  Future<void> _onUpdateAccentColor(UpdateAccentColorEvent event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(accentColorKey, event.colorValue);
    emit(state.copyWith(accentColorValue: event.colorValue));
  }
}