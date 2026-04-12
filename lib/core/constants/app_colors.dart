import 'package:flutter/material.dart';

/// Ilovadagi ranglar - "Deep Professional Navy" Premium Palette
class AppColors {
  AppColors._();

  // ─── Primary (Midnight Navy & Slate) ───
  static const Color slate950 = Color(0xFF020617);    // Deepest Navy
  static const Color slate900 = Color(0xFF0F172A);    // Midnight Navy
  static const Color slate800 = Color(0xFF1E293B);    // Slate Navy
  static const Color primaryBlue = slate900;          // Legacy mapping

  // ─── Sky Blue Palette (For Light Theme) ───
  static const Color skyBlue50 = Color(0xFFF0F9FF);
  static const Color skyBlue400 = Color(0xFF38BDF8);
  static const Color skyBlue500 = Color(0xFF0EA5E9);
  static const Color skyBlue600 = Color(0xFF0284C7);
  static const Color skyBlue700 = Color(0xFF0369A1);
  
  // ─── Background & Surface (Slate) ───
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);

  // ─── Premium Accent (Silver & Steel) ───
  static const Color silver = Color(0xFF94A3B8);
  static const Color steel = Color(0xFF64748B);
  static const Color glassWhite = Color(0x1AFFFFFF); // 10% White
  static const Color glassWhiteBorder = Color(0x1A0F172A); // 10% Navy Border
  static const Color softSlate = Color(0xFFF1F5F9);

  // ─── Status (Refined) ───
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color amber = Color(0xFFF59E0B);   // Amber 500
  static const Color danger = Color(0xFFDC2626);  // Red 600
  static const Color info = Color(0xFF2563EB);    // Blue 600

  // ─── Grades (Professional) ───
  static const Color gradeExcellent = Color(0xFF059669); 
  static const Color gradeGood = Color(0xFFD97706);      
  static const Color gradeAverage = Color(0xFFEA580C);   
  static const Color gradePoor = Color(0xFFDC2626);      

  // ─── Neutral ───
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // ─── Semantic Mappings ───
  static const Color textSecondary = slate500;

  // ─── Liquid Gradients (2025 Premium Tokens) ───
  static const List<Color> liquidIndigo = [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  static const List<Color> liquidEmerald = [Color(0xFF10B981), Color(0xFF14B8A6)];
  static const List<Color> liquidRose = [Color(0xFFF43F5E), Color(0xFFEC4899)];
  static const List<Color> liquidAmber = [Color(0xFFF59E0B), Color(0xFFD97706)];
}
