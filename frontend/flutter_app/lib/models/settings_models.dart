class UserSettings {
  final bool saveHistory;
  final String themeMode;
  final bool analyticsEnabled;

  UserSettings({
    required this.saveHistory,
    this.themeMode = 'system',
    this.analyticsEnabled = true,
  });

  factory UserSettings.fromJson(Map<String, dynamic> j) => UserSettings(
        saveHistory: j['save_history'] as bool? ?? true,
        themeMode: j['theme_mode'] as String? ?? 'system',
        analyticsEnabled: j['analytics_enabled'] as bool? ?? true,
      );
}

class UsageAnalytics {
  final int totalSequences;
  final int totalPamScans;
  final int totalSimulations;
  final int frameshiftCount;
  final int nhejCount;
  final int hdrCount;
  final double? averageGcPercent;
  final String? lastSequenceAt;
  final String? lastSimulationAt;
  final Map<String, int> inputSources;

  UsageAnalytics({
    required this.totalSequences,
    required this.totalPamScans,
    required this.totalSimulations,
    required this.frameshiftCount,
    required this.nhejCount,
    required this.hdrCount,
    this.averageGcPercent,
    this.lastSequenceAt,
    this.lastSimulationAt,
    this.inputSources = const {},
  });

  factory UsageAnalytics.fromJson(Map<String, dynamic> j) => UsageAnalytics(
        totalSequences: j['total_sequences'] as int? ?? 0,
        totalPamScans: j['total_pam_scans'] as int? ?? 0,
        totalSimulations: j['total_simulations'] as int? ?? 0,
        frameshiftCount: j['frameshift_count'] as int? ?? 0,
        nhejCount: j['nhej_count'] as int? ?? 0,
        hdrCount: j['hdr_count'] as int? ?? 0,
        averageGcPercent: (j['average_gc_percent'] as num?)?.toDouble(),
        lastSequenceAt: j['last_sequence_at'] as String?,
        lastSimulationAt: j['last_simulation_at'] as String?,
        inputSources: (j['input_sources'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as int)) ??
            {},
      );
}

class HistorySession {
  final String id;
  final int length;
  final double? gcPercent;
  final String? accession;
  final String source;
  final String createdAt;

  HistorySession({
    required this.id,
    required this.length,
    this.gcPercent,
    this.accession,
    required this.source,
    required this.createdAt,
  });

  factory HistorySession.fromJson(Map<String, dynamic> j) => HistorySession(
        id: j['id'] as String,
        length: j['length'] as int,
        gcPercent: (j['gc_percent'] as num?)?.toDouble(),
        accession: j['accession'] as String?,
        source: j['source'] as String,
        createdAt: j['created_at'] as String,
      );
}

class HistorySimulation {
  final int id;
  final String sessionId;
  final String repairType;
  final int cutPosition;
  final bool frameshift;
  final bool prematureStop;
  final String createdAt;

  HistorySimulation({
    required this.id,
    required this.sessionId,
    required this.repairType,
    required this.cutPosition,
    required this.frameshift,
    required this.prematureStop,
    required this.createdAt,
  });

  factory HistorySimulation.fromJson(Map<String, dynamic> j) => HistorySimulation(
        id: j['id'] as int,
        sessionId: j['session_id'] as String,
        repairType: j['repair_type'] as String,
        cutPosition: j['cut_position'] as int,
        frameshift: j['frameshift'] as bool,
        prematureStop: j['premature_stop'] as bool,
        createdAt: j['created_at'] as String,
      );
}

class AppRating {
  final int stars;
  final String? comment;
  final String? updatedAt;

  AppRating({required this.stars, this.comment, this.updatedAt});

  factory AppRating.fromJson(Map<String, dynamic> j) => AppRating(
        stars: j['stars'] as int,
        comment: j['comment'] as String?,
        updatedAt: j['updated_at'] as String?,
      );
}
