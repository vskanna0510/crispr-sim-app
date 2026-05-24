// Central state management for the CRISPR-Sim workflow.

import 'package:flutter/foundation.dart';
import '../models/crispr_models.dart';
import '../services/api_service.dart';

class CrisprProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool isLoading = false;
  String? error;

  String casType = 'cas9';
  String? ncbiAccession;

  SequenceResult? sequenceResult;
  GeneInfo? geneInfo;
  List<CasSystemInfo> casSystems = const [];

  ScanResult? scanResult;
  PamSite? selectedPamSite;
  OffTargetResult? offTargetResult;
  SafetyScoreResult? safetyScoreResult;

  CutResult? cutResult;
  RepairResult? repairResult;
  CompareResult? compareResult;

  List<LiteratureCase> literatureCases = const [];
  LiteratureValidationResult? literatureValidation;

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

  void setCasType(String type) {
    casType = type;
    scanResult = null;
    selectedPamSite = null;
    offTargetResult = null;
    safetyScoreResult = null;
    cutResult = null;
    repairResult = null;
    compareResult = null;
    notifyListeners();
  }

  void reset() {
    isLoading = false;
    error = null;
    casType = 'cas9';
    ncbiAccession = null;
    sequenceResult = null;
    geneInfo = null;
    scanResult = null;
    selectedPamSite = null;
    offTargetResult = null;
    safetyScoreResult = null;
    cutResult = null;
    repairResult = null;
    compareResult = null;
    literatureValidation = null;
    notifyListeners();
  }

  Future<void> loadCasSystems() async {
    try {
      casSystems = await _api.fetchCasSystems();
      notifyListeners();
    } catch (_) {
      // Non-fatal; UI falls back to defaults.
    }
  }

  Future<bool> loadSequence(String rawSequence) async {
    _setLoading(true);
    try {
      sequenceResult = await _api.pasteSequence(rawSequence);
      ncbiAccession = null;
      geneInfo = null;
      _clearDownstream();
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
      ncbiAccession = accession;
      _clearDownstream();
      try {
        geneInfo = await _api.fetchGeneInfo(accession);
      } catch (_) {
        geneInfo = null;
      }
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  void _clearDownstream() {
    scanResult = null;
    selectedPamSite = null;
    offTargetResult = null;
    safetyScoreResult = null;
    cutResult = null;
    repairResult = null;
    compareResult = null;
    literatureValidation = null;
  }

  Future<bool> scanPamSites() async {
    if (sequenceResult == null) return false;
    _setLoading(true);
    try {
      scanResult = await _api.scanPam(sequenceResult!.sequence, casType: casType);
      selectedPamSite = null;
      offTargetResult = null;
      safetyScoreResult = null;

      final rec = scanResult!.recommendation;
      if (rec != null) {
        selectedPamSite = scanResult!.pamSites.firstWhere(
          (s) => s.start == rec.pamStart,
          orElse: () => scanResult!.pamSites.firstWhere(
            (s) => s.grna != null,
            orElse: () => scanResult!.pamSites.first,
          ),
        );
      }
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<void> selectPamSite(PamSite site) async {
    selectedPamSite = site;
    cutResult = null;
    repairResult = null;
    compareResult = null;
    offTargetResult = null;
    safetyScoreResult = null;
    notifyListeners();

    if (sequenceResult == null || site.grna == null) return;
    try {
      offTargetResult = await _api.predictOffTargets(
        sequenceResult!.sequence,
        site.grna!,
        site.start,
      );
      safetyScoreResult = await _api.fetchSafetyScore(
        sequenceResult!.sequence,
        site.grna!,
        site.start,
        gcPercent: site.gcPercent,
      );
      notifyListeners();
    } catch (_) {
      // Off-target/safety are optional enrichments.
    }
  }

  Future<bool> simulateCut() async {
    if (sequenceResult == null || selectedPamSite == null) return false;
    _setLoading(true);
    try {
      cutResult = await _api.simulateCut(
        sequenceResult!.sequence,
        selectedPamSite!.start,
        casType: casType,
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

  Future<bool> loadLiteratureCases() async {
    try {
      literatureCases = await _api.fetchLiteratureCases();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    }
  }

  Future<bool> runLiteratureValidation(String caseId) async {
    if (sequenceResult == null) return false;
    _setLoading(true);
    try {
      literatureValidation = await _api.validateLiterature(
        caseId: caseId,
        originalSequence: sequenceResult!.sequence,
        editedSequence: repairResult?.repairedSequence,
        cutPosition: cutResult?.cutPosition,
        deletionSize: repairResult?.deletionSize,
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
