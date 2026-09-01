// HTTP client that wraps every CRISPR-Sim backend endpoint.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../models/crispr_models.dart';
import '../models/chat_models.dart';
import '../models/settings_models.dart';
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
  String? _accessToken;

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? kBaseUrl;

  void setAccessToken(String? token) => _accessToken = token;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> get _headers {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_accessToken';
    }
    return h;
  }

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

  Future<Map<String, dynamic>> _patch(String path, Map<String, dynamic> body) async {
    final response = await http
        .patch(_uri(path), headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 30));
    return _handle(response);
  }

  Future<List<Map<String, dynamic>>> _getList(String path) async {
    final response = await http
        .get(_uri(path), headers: _headers)
        .timeout(const Duration(seconds: 30));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
    }
    throw ApiException(response.statusCode, response.body);
  }

  Map<String, dynamic> _handle(http.Response response) {
    if (response.statusCode == 204) return {};
    final body = response.body.trim();
    if (body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) return {};
      throw ApiException(
        response.statusCode,
        response.reasonPhrase ?? 'Server returned an empty response.',
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      final snippet = body.length > 120 ? '${body.substring(0, 120)}…' : body;
      if (response.statusCode >= 500) {
        throw ApiException(
          response.statusCode,
          'Server error ($response.statusCode). The API may be down or the database '
          'is not connected. Try again later or contact support.',
        );
      }
      throw ApiException(response.statusCode, snippet);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    }
    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail'] ?? response.reasonPhrase ?? 'Unknown error';
      throw ApiException(response.statusCode, detail.toString());
    }
    throw ApiException(response.statusCode, body);
  }

  // ─── Auth ───────────────────────────────────────────────────────────────────

  Future<AuthTokenResponse> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final json = await _post('/auth/register', {
      'email': email,
      'password': password,
      if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
    });
    return AuthTokenResponse.fromJson(json);
  }

  Future<AuthTokenResponse> login({
    required String email,
    required String password,
  }) async {
    final json = await _post('/auth/login', {
      'email': email,
      'password': password,
    });
    return AuthTokenResponse.fromJson(json);
  }

  Future<AuthTokenResponse> googleAuth({
    String? idToken,
    String? accessToken,
    String? email,
    String? fullName,
    String? photoUrl,
  }) async {
    final json = await _post('/auth/google', {
      if (idToken != null) 'id_token': idToken,
      if (accessToken != null) 'access_token': accessToken,
      if (email != null) 'email': email,
      if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
      if (photoUrl != null) 'photo_url': photoUrl,
    });
    return AuthTokenResponse.fromJson(json);
  }

  Future<void> logout() async {
    await http
        .post(_uri('/auth/logout'), headers: _headers)
        .timeout(const Duration(seconds: 15));
  }

  Future<AuthUser> fetchMe() async {
    final json = await _get('/auth/me');
    return AuthUser.fromJson(json);
  }

  Future<void> deleteAccount() async {
    final response = await http
        .delete(_uri('/auth/delete-account'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    _handle(response);
  }

  // ─── Settings & history ───────────────────────────────────────────────────────

  Future<UserSettings> fetchSettings() async {
    final json = await _get('/settings');
    return UserSettings.fromJson(json);
  }

  Future<UserSettings> updateSettings({
    bool? saveHistory,
    String? themeMode,
    bool? analyticsEnabled,
  }) async {
    final body = <String, dynamic>{};
    if (saveHistory != null) body['save_history'] = saveHistory;
    if (themeMode != null) body['theme_mode'] = themeMode;
    if (analyticsEnabled != null) body['analytics_enabled'] = analyticsEnabled;
    final json = await _patch('/settings', body);
    return UserSettings.fromJson(json);
  }

  Future<UsageAnalytics> fetchAnalytics() async {
    final json = await _get('/settings/analytics');
    return UsageAnalytics.fromJson(json);
  }

  Future<AppRating?> fetchRating() async {
    final response = await http
        .get(_uri('/settings/rating'), headers: _headers)
        .timeout(const Duration(seconds: 30));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded == null) return null;
      return AppRating.fromJson(decoded as Map<String, dynamic>);
    }
    throw ApiException(response.statusCode, response.body);
  }

  Future<AppRating> submitRating({required int stars, String? comment}) async {
    final json = await _post('/settings/rating', {
      'stars': stars,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    });
    return AppRating.fromJson(json);
  }

  Future<List<HistorySession>> fetchHistorySessions() async {
    final list = await _getList('/history/sessions');
    return list.map(HistorySession.fromJson).toList();
  }

  Future<List<HistorySimulation>> fetchHistorySimulations() async {
    final list = await _getList('/history/simulations');
    return list.map(HistorySimulation.fromJson).toList();
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

  Future<ScanResult> scanPam(
    String sequence, {
    String casType = 'cas9',
    String? sessionId,
  }) async {
    final json = await _post('/crispr/scan', {
      'sequence': sequence,
      'cas_type': casType,
      if (sessionId != null) 'session_id': sessionId,
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
    String? sessionId,
    String? casType,
  }) async {
    final body = <String, dynamic>{
      'sequence': sequence,
      'cut_position': cutPosition,
    };
    if (deletionSize != null) body['deletion_size'] = deletionSize;
    if (sessionId != null) body['session_id'] = sessionId;
    if (casType != null) body['cas_type'] = casType;
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
      'sequence': sequence,
      'cut_position': cutPosition,
      'donor_template': donorTemplate,
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
    String editedSequence, {
    String? sessionId,
    String? repairType,
    int? cutPosition,
    String? casType,
  }) async {
    final body = <String, dynamic>{
      'original_sequence': originalSequence,
      'edited_sequence': editedSequence,
    };
    if (sessionId != null) body['session_id'] = sessionId;
    if (repairType != null) body['repair_type'] = repairType;
    if (cutPosition != null) body['cut_position'] = cutPosition;
    if (casType != null) body['cas_type'] = casType;
    final json = await _post('/analysis/compare', body);
    return CompareResult.fromJson(json);
  }

  // ─── RAG chat ───────────────────────────────────────────────────────────────

  Future<RagChatResponse> ragChat(String message, {int topK = 4}) async {
    final json = await _post('/chat/rag', {
      'message': message,
      'top_k': topK,
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
