import 'package:flutter/material.dart';

class ReaderThemes {
  static const Map<String, ReaderTheme> themes = {
    'light': ReaderTheme(
      name: 'Light',
      backgroundColor: Colors.white,
      textColor: Colors.black87,
    ),
    'sepia': ReaderTheme(
      name: 'Sepia',
      backgroundColor: Color(0xFFF4ECD8),
      textColor: Color(0xFF5C4B37),
    ),
    'dark': ReaderTheme(
      name: 'Dark',
      backgroundColor: Color(0xFF1E1E1E),
      textColor: Color(0xFFE0E0E0),
    ),
    'night': ReaderTheme(
      name: 'Night',
      backgroundColor: Color(0xFF0A0A0A),
      textColor: Color(0xFFB0B0B0),
    ),
  };

  static ReaderTheme getTheme(String key) {
    return themes[key] ?? themes['light']!;
  }

  static List<String> get themeKeys => themes.keys.toList();
}

class ReaderTheme {
  final String name;
  final Color backgroundColor;
  final Color textColor;

  const ReaderTheme({
    required this.name,
    required this.backgroundColor,
    required this.textColor,
  });
}

