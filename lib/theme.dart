import 'package:flutter/material.dart';

/// Warna tiap type pokemon.
const Map<String, Color> typeColors = {
  'normal': Color(0xFF9A9A78),
  'fire': Color(0xFFF08030),
  'water': Color(0xFF5B8DEF),
  'electric': Color(0xFFF2C51D),
  'grass': Color(0xFF4FB65A),
  'ice': Color(0xFF5CC6C6),
  'fighting': Color(0xFFC03028),
  'poison': Color(0xFFA040A0),
  'ground': Color(0xFFD1A94A),
  'flying': Color(0xFF8E7CE8),
  'psychic': Color(0xFFF85888),
  'bug': Color(0xFF9AB01E),
  'rock': Color(0xFFB09A30),
  'ghost': Color(0xFF6B5A9B),
  'dragon': Color(0xFF6038F8),
  'dark': Color(0xFF6B5444),
  'steel': Color(0xFF8E9BB8),
  'fairy': Color(0xFFE07FB0),
};

/// Warna lembut untuk kartu di halaman utama (belum tahu type-nya).
const List<Color> cardTints = [
  Color(0xFFBFE8D2),
  Color(0xFFFFD6B0),
  Color(0xFFBFD7FF),
  Color(0xFFFFC6D0),
  Color(0xFFE2D4FF),
  Color(0xFFFFF0A8),
];

Color tintFor(int id) => cardTints[id % cardTints.length];

/// Versi lebih gelap dari [c], dipakai untuk teks di atas warna lembut.
Color deepen(Color c, [double amount = 0.45]) {
  final hsl = HSLColor.fromColor(c);
  return hsl
      .withLightness((hsl.lightness * (1 - amount)).clamp(0.0, 1.0))
      .withSaturation((hsl.saturation * 0.9).clamp(0.0, 1.0))
      .toColor();
}

const Color inkColor = Color(0xFF1B1F2A);
const Color mutedColor = Color(0xFF6B7280);
const Color pageColor = Color(0xFFF5F5F0);
