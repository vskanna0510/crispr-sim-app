// App-wide constants for CRISPR-Sim.

import 'package:flutter/material.dart';

// ─── API ──────────────────────────────────────────────────────────────────────

// Android emulator  → use 10.0.2.2  (maps to host PC's localhost)
// Android physical  → use your PC's LAN IP, e.g. 192.168.1.100
// Windows / Chrome  → localhost works fine
const String kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

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

const Color kPrimary   = Color(0xFF006B76);
const Color kSecondary = Color(0xFF7B1FA2);

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
