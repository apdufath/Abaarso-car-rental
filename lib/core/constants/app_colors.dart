import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand color: Deep Forest Green (#2D6A4F)
  static const Color primary = Color(0xFF2D6A4F);
  
  // Secondary brand color: Deep forest dark / navy
  static const Color secondary = Color(0xFF1E4634);
  
  // Neutral backgrounds and surfaces
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF121212);
  
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E2F);
  
  // Accent & functional colors (Sandy Yellow #E8C96A)
  static const Color accent = Color(0xFFE8C96A);
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFE8C96A);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1976D2);
  
  // Status-specific shades
  static const Color pending = Color(0xFFFFB300);
  static const Color confirmed = Color(0xFF1E88E5);
  static const Color active = Color(0xFF43A047);
  static const Color completed = Color(0xFF757575);
  static const Color cancelled = Color(0xFFE53935);

  // Border & divider colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF2C2C3C);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFAFAF8);
  static const Color textSecondaryDark = Color(0xFFB0B0C0);
}
