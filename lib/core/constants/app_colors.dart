import 'package:flutter/material.dart';

/// Ilovadagi ranglar - "Deep Professional Navy" Premium Palette
class AppColors {
  AppColors._();

  // ─── Primary (Midnight Navy & Slate) ───
  static const Color slate950 = Color(0xFF020617);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);

  // ─── Primary Accent (Sky Blue) ───
  static const Color primary = skyBlue600;
  static const Color primaryLight = skyBlue400;
  static const Color primaryBlue = skyBlue600; // Legacy — use `primary` instead


  // ─── Liquid Glass Accent Palette ───
  static const Color aqua50 = Color(0xFFE8FBFF);
  static const Color aqua100 = Color(0xFFCFF8FF);
  static const Color aqua200 = Color(0xFFA5F3FC);
  static const Color aqua300 = Color(0xFF67E8F9);
  static const Color aqua400 = Color(0xFF22D3EE);
  static const Color aqua500 = Color(0xFF06B6D4);
  static const Color aqua700 = Color(0xFF0E7490);
  static const Color violet300 = Color(0xFFC4B5FD);
  static const Color rose300 = Color(0xFFFDA4AF);

  // ─── Sky Blue Palette ───
  static const Color skyBlue50 = Color(0xFFF0F9FF);
  static const Color skyBlue100 = Color(0xFFE0F2FE);
  static const Color skyBlue200 = Color(0xFFBAE6FD);
  static const Color skyBlue400 = Color(0xFF38BDF8);
  static const Color skyBlue500 = Color(0xFF0EA5E9);
  static const Color skyBlue600 = Color(0xFF0284C7);
  static const Color skyBlue700 = Color(0xFF0369A1);

  // ─── Background & Surface (Slate) ───
  static const Color background = skyBlue50;
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);

  // ─── Glass & Steel (Premium Surface) ───
  static const Color silver = Color(0xFF94A3B8);
  static const Color steel = Color(0xFF64748B);

  static const Color glassSurfaceLight = Color(0xBFFFFFFF);
  static const Color glassSurfaceDark = Color(0x661E293B);
  static const Color glassBorderLight = Color(0x99FFFFFF);
  static const Color glassBorderDark = Color(0x33FFFFFF);
  static const Color glassHighlight = Color(0xCCFFFFFF);

  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassWhiteBorder = Color(0x1A0F172A);
  static const Color softSlate = Color(0xFFF1F5F9);

  // ─── Status ───
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFF10B981);
  static const Color warning = Color(0xFFD97706);
  static const Color amber = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color error = danger;
  static const Color info = Color(0xFF2563EB);
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue500 = Color(0xFF3B82F6);

  // ─── Attendance ───
  static const Color present = success;
  static const Color absent = danger;
  static const Color late = amber;
  static const Color excused = skyBlue500;

  // ─── Grades ───
  static const Color grade5 = Color(0xFF059669);
  static const Color grade4 = Color(0xFF0EA5E9);
  static const Color grade3 = Color(0xFFD97706);
  static const Color grade2 = Color(0xFFEA580C);
  static const Color grade1 = Color(0xFFDC2626);
  static const Color gradeExcellent = grade5;
  static const Color gradeGood = grade3;
  static const Color gradeAverage = grade2;
  static const Color gradePoor = grade1;

  // ─── Assignment Status ───
  static const Color assignmentPending = amber;
  static const Color assignmentSubmitted = blue500;
  static const Color assignmentGraded = successLight;
  static const Color assignmentOverdue = Color(0xFFEF4444);

  // ─── Gamification ───
  static const Color gold = Color(0xFFFFD700);
  static const Color silverMedal = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color coinAmber = amber;

  // ─── Decorative Accent ───
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color violet600 = Color(0xFF7C3AED);
  static const Color purple500 = Color(0xFF8B5CF6);
  static const Color pink500 = Color(0xFFEC4899);
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald900 = Color(0xFF064E3B);

  // ─── Neutral ───
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // ─── Semantic Mappings ───
  static const Color textPrimary = slate900;
  static const Color textSecondary = slate500;
  static const Color divider = slate200;

  // ─── Gradients ───
  static const List<Color> liquidIndigo = [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  static const List<Color> liquidEmerald = [Color(0xFF10B981), Color(0xFF14B8A6)];
  static const List<Color> liquidRose = [Color(0xFFF43F5E), Color(0xFFEC4899)];
  static const List<Color> liquidAmber = [Color(0xFFF59E0B), Color(0xFFD97706)];
  static const List<Color> skyGradientLight = [Color(0xFFE0F2FE), Color(0xFFBAE6FD)];
  static const List<Color> emeraldGradientLight = [Color(0xFF10B981), Color(0xFF059669)];
  static const List<Color> emeraldGradientDark = [Color(0xFF065F46), Color(0xFF064E3B)];
  static const List<Color> loginGradient = [indigo600, violet600];
}
