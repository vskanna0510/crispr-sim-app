import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ─── API ──────────────────────────────────────────────────────────────────────

const String _envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

String get kBaseUrl {
  if (_envUrl.isNotEmpty) return _envUrl;
  if (kIsWeb) return 'http://127.0.0.1:8000';
  // On Android/iOS APK, connect directly to the live Render production backend
  return 'https://crispr-sim-backend.onrender.com';
}

// ─── DNA base colours ─────────────────────────────────────────────────────────

const Color kColourA = Color(0xFF1565C0); // Blue 800
const Color kColourT = Color(0xFFC62828); // Red  800
const Color kColourG = Color(0xFFF9A825); // Amber 800
const Color kColourC = Color(0xFF2E7D32); // Green 800

Color dnaBaseColour(String base) {
  switch (base.toUpperCase()) {
    case 'A':
      return kColourA;
    case 'T':
      return kColourT;
    case 'G':
      return kColourG;
    case 'C':
      return kColourC;
    default:
      return Colors.grey;
  }
}

// ─── Theme ────────────────────────────────────────────────────────────────────

const Color kPrimary    = Color(0xFF006B76);
const Color kSecondary  = Color(0xFF7B1FA2);
const Color kAccentTeal = Color(0xFF78D1D2);
const Color kDarkTeal   = Color(0xFF004D4D);
const Color kRecommendBgDark = Color(0xFF1B3D3D);

// ─── Sizes / paddings ─────────────────────────────────────────────────────────

const double kPadMd  = 16.0;
const double kPadLg  = 24.0;
const double kPadSm  =  8.0;
const double kRadius = 12.0;

// ─── Sample sequences for quick demo ─────────────────────────────────────────

const String kDemoSequence =
    'ATGGTGCACCTGACTCCTGAGGAGAAGTCTGCCGTTACTGCCCTGTGGGGCAAGGTGAACGTGGATGAA'
    'GTTGGTGGTGAGGCCCTGGGCAGGCTGCTGGTGGTCTACCCTTGGACCCAGAGGTTCTTTGAGTTCTTT'
    'GGGGATCTGTCCACTCCTGATGCTGTTATGGGCAACCCTAAGGTGAAGGCTCATGGCAAGAAAGTGCTC'
    'GGTGCCTTTAGTGATGGCCTGGCTCACCTGGACAACCTCAAGGGCACCTTTGCCACACTGAGTGAGCTG';

const String kDemoShortSequence =
    'ATGCATGCATGCATGCATGCAGGATGCATGCATGCATGCATGCATGCATGCAGGATGCATGCATGCATG';
