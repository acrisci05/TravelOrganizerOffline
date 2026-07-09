import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1565C0);
  static const primaryDark = Color(0xFF003c8f);
  static const primaryLight = Color(0xFF5e92f3);
  static const accent = Color(0xFFFF7043);
  static const accentLight = Color(0xFFFFCCBC);

  static const background = Color(0xFFF5F7FA);
  static const surface = Colors.white;
  static const cardShadow = Color(0x1A000000);

  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFFBDBDBD);

  static const success = Color(0xFF43A047);
  static const warning = Color(0xFFFB8C00);
  static const error = Color(0xFFE53935);
  static const info = Color(0xFF1E88E5);

  static const statusFuture = Color.fromARGB(255, 0, 0, 255);
  static const statusOngoing = Color.fromARGB(255, 255, 165, 0);
  static const statusCompleted = Color.fromARGB(255, 0, 255, 0);
  static const statusArchived = Color(0xFFBDBDBD);

  static Color forTripStatus(String status) {
    switch (status) {
      case 'Futuro':
        return statusFuture;
      case 'In corso':
        return statusOngoing;
      case 'Completato':
        return statusCompleted;
      default:
        return statusArchived;
    }
  }
}
