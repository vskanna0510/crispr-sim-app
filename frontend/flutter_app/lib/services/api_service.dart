// HTTP client that wraps every CRISPR-Sim backend endpoint.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crispr_models.dart';
import '../models/chat_models.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  final String baseUrl;
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? kBaseUrl;

  // ─── helpers ────────────────────────────────────────────────────────────────

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final response = await http
        .post(_uri(path), headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 30));
    return _handle(response);
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await http
        .get(_uri(path), headers: _headers)
        .timeout(const Duration(seconds: 30));
    return _handle(response);
  }

  Map<String, dynamic> _handle(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    final detail = body['detail'] ?? response.reasonPhrase ?? 'Unknown error';
    throw ApiException(response.statusCode, detail.toString());
  }

  // ─── Sequence endpoints ─────────────────────────────────────────────────────

  Future<SequenceResult> pasteSequence(String sequence) async {
    final json = await _post('/sequence/paste', {'sequence': sequence});
    return SequenceResult.fromJson(json);
  }

  Future<SequenceResult> fetchNcbi(String accession) async {
    final json = await _get('/sequence/fetch/$accession');
    return SequenceResult.fromJson(json);
  }

  // ─── CRISPR endpoints ───────────────────────────────────────────────────────

  Future<ScanResult> scanPam(String sequence, {String casType = 'cas9'}) async {
    final json = await _post('/crispr/scan', {
      'sequence': sequence,
      'cas_type': casType,
    });
    return ScanResult.fromJson(json);
  }

  Future<CutResult> simulateCut(
    String sequence,
    int pamStart, {
    String casType = 'cas9',
  }) async {
    final json = await _post('/crispr/cut', {
      'sequence': sequence,
      'pam_start': pamStart,
      'cas_type': casType,
    });
    return CutResult.fromJson(json);
  }

  Future<RepairResult> applyNhej(
    String sequence,
    int cutPosition, {
    int? deletionSize,
  }) async {
    final body = <String, dynamic>{
      'sequence':      sequence,
      'cut_position':  cutPosition,
    };
    if (deletionSize != null) body['deletion_size'] = deletionSize;
    final json = await _post('/crispr/nhej', body);
    return RepairResult.fromJson(json);
  }

  Future<RepairResult> applyHdr(
    String sequence,
    int cutPosition,
    String donorTemplate, {
    int replacementLength = 0,
  }) async {
    final json = await _post('/crispr/hdr', {
      'sequence':           sequence,
      'cut_position':       cutPosition,
      'donor_template':     donorTemplate,
      'replacement_length': replacementLength,
    });
    return RepairResult.fromJson(json);
  }

  // ─── Analysis endpoints ─────────────────────────────────────────────────────

  Future<TranslateResult> translate(String sequence) async {
    final json = await _post('/analysis/translate', {'sequence': sequence});
    return TranslateResult.fromJson(json);
  }

  Future<CompareResult> compare(
    String originalSequence,
    String editedSequence,
  ) async {
    final json = await _post('/analysis/compare', {
      'original_sequence': originalSequence,
      'edited_sequence':   editedSequence,
    });
    return CompareResult.fromJson(json);
  }

  // ─── RAG chat ───────────────────────────────────────────────────────────────

  Future<RagChatResponse> ragChat(String message, {int topK = 4}) async {
    final json = await _post('/chat/rag', {
      'message': message,
      'top_k':   topK,
    });
    return RagChatResponse.fromJson(json);
  }

  // ─── Advanced endpoints ─────────────────────────────────────────────────────

  Future<List<CasSystemInfo>> fetchCasSystems() async {
    final response = await http
        .get(_uri('/advanced/cas-systems'), headers: _headers)
        .timeout(const Duration(seconds: 30));
    final list = jsonDecode(response.body) as List;
    return list
        .map((e) => CasSystemInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<GeneInfo> fetchGeneInfo(String accession) async {
    final json = await _get('/sequence/gene-info/$accession');
    return GeneInfo.fromJson(json);
  }

  Future<OffTargetResult> predictOffTargets(
    String sequence,
    String grna,
    int pamStart,
  ) async {
    final json = await _post('/crispr/off-target', {
      'sequence': sequence,
      'grna': grna,
      'pam_start': pamStart,
    });
    return OffTargetResult.fromJson(json);
  }

  Future<SafetyScoreResult> fetchSafetyScore(
    String sequence,
    String grna,
    int pamStart, {
    double? gcPercent,
  }) async {
    final body = <String, dynamic>{
      'sequence': sequence,
      'grna': grna,
      'pam_start': pamStart,
    };
    if (gcPercent != null) body['gc_percent'] = gcPercent;
    final json = await _post('/crispr/safety-score', body);
    return SafetyScoreResult.fromJson(json);
  }

  Future<List<LiteratureCase>> fetchLiteratureCases() async {
    final response = await http
        .get(_uri('/validation/cases'), headers: _headers)
        .timeout(const Duration(seconds: 30));
    final list = jsonDecode(response.body) as List;
    return list
        .map((e) => LiteratureCase.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LiteratureValidationResult> validateLiterature({
    required String caseId,
    required String originalSequence,
    String? editedSequence,
    int? cutPosition,
    int? deletionSize,
  }) async {
    final body = <String, dynamic>{
      'case_id': caseId,
      'original_sequence': originalSequence,
    };
    if (editedSequence != null) body['edited_sequence'] = editedSequence;
    if (cutPosition != null) body['cut_position'] = cutPosition;
    if (deletionSize != null) body['deletion_size'] = deletionSize;
    final json = await _post('/validation/literature', body);
    return LiteratureValidationResult.fromJson(json);
  }
}
