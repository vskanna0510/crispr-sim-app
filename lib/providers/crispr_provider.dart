// Central state management for the CRISPR-Sim workflow.
//
// Each simulation step updates the provider; screens read from it via
// `context.watch<CrisprProvider>()`.

import 'package:flutter/foundation.dart';
import '../models/crispr_models.dart';
import '../services/api_service.dart';

class CrisprProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // ─── State ────────────────────────────────────────────────────────────────

  bool isLoading = false;
  String? error;

  // Step 1 – sequence
  SequenceResult? sequenceResult;

  // Step 2 – PAM scan
  ScanResult? scanResult;
  PamSite? selectedPamSite;

  // Step 3 – cut
  CutResult? cutResult;

  // Step 4 – repair
  RepairResult? repairResult;

  // Step 5 – analysis
  CompareResult? compareResult;

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _setLoading(bool v) {
    isLoading = v;
    error = null;
    notifyListeners();
  }

  void _setError(Object e) {
    isLoading = false;
    error = e.toString();
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  /// Full reset – start a new simulation.
  void reset() {
    isLoading   = false;
    error       = null;
    sequenceResult = null;
    scanResult     = null;
    selectedPamSite = null;
    cutResult    = null;
    repairResult = null;
    compareResult = null;
    notifyListeners();
  }

  // ─── Step 1: load sequence ─────────────────────────────────────────────────

  Future<bool> loadSequence(String rawSequence) async {
    _setLoading(true);
    try {
      sequenceResult = await _api.pasteSequence(rawSequence);
      // Reset downstream state
      scanResult = null;
      selectedPamSite = null;
      cutResult = null;
      repairResult = null;
      compareResult = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> fetchNcbiSequence(String accession) async {
    _setLoading(true);
    try {
      sequenceResult = await _api.fetchNcbi(accession);
      scanResult = null;
      selectedPamSite = null;
      cutResult = null;
      repairResult = null;
      compareResult = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // ─── Step 2: scan PAM sites ────────────────────────────────────────────────

  Future<bool> scanPamSites() async {
    if (sequenceResult == null) return false;
    _setLoading(true);
    try {
      scanResult = await _api.scanPam(sequenceResult!.sequence);
      selectedPamSite = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  void selectPamSite(PamSite site) {
    selectedPamSite = site;
    cutResult = null;
    repairResult = null;
    compareResult = null;
    notifyListeners();
  }

  // ─── Step 3: simulate cut ─────────────────────────────────────────────────

  Future<bool> simulateCut() async {
    if (sequenceResult == null || selectedPamSite == null) return false;
    _setLoading(true);
    try {
      cutResult = await _api.simulateCut(
        sequenceResult!.sequence,
        selectedPamSite!.start,
      );
      repairResult = null;
      compareResult = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // ─── Step 4: repair ───────────────────────────────────────────────────────

  Future<bool> applyNhej({int? deletionSize}) async {
    if (sequenceResult == null || cutResult == null) return false;
    _setLoading(true);
    try {
      repairResult = await _api.applyNhej(
        sequenceResult!.sequence,
        cutResult!.cutPosition,
        deletionSize: deletionSize,
      );
      compareResult = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> applyHdr({
    required String donorTemplate,
    int replacementLength = 0,
  }) async {
    if (sequenceResult == null || cutResult == null) return false;
    _setLoading(true);
    try {
      repairResult = await _api.applyHdr(
        sequenceResult!.sequence,
        cutResult!.cutPosition,
        donorTemplate,
        replacementLength: replacementLength,
      );
      compareResult = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  // ─── Step 5: analyse ──────────────────────────────────────────────────────

  Future<bool> runAnalysis() async {
    if (sequenceResult == null || repairResult == null) return false;
    _setLoading(true);
    try {
      compareResult = await _api.compare(
        sequenceResult!.sequence,
        repairResult!.repairedSequence,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }
}
