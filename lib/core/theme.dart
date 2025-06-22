import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.cyan,  // Celeste eléctrico
      scaffoldBackgroundColor: Colors.white,
      textTheme: TextTheme(
        bodyMedium: TextStyle(fontSize: 16),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.cyan[800],  // Celeste eléctrico para el AppBar
        elevation: 0,
        titleTextStyle: TextStyle(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.redAccent,  // Rojo para los botones
          foregroundColor: Colors.white,  // Texto en blanco
        ),
      ),
      iconTheme: IconThemeData(
        color: Colors.white,  // Para los iconos dentro de AppBar y botones
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white24,  // Fondo de los campos de texto
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
