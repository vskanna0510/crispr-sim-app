// Data models for CRISPR-Sim.  All are deserialized from the FastAPI JSON responses.

// ─── Sequence ─────────────────────────────────────────────────────────────────

class SequenceResult {
  final String sequence;
  final int length;
  final bool valid;
  final String? sessionId;
  final double? gcPercent;
  final Map<String, double>? composition;

  SequenceResult({
    required this.sequence,
    required this.length,
    required this.valid,
    this.sessionId,
    this.gcPercent,
    this.composition,
  });

  factory SequenceResult.fromJson(Map<String, dynamic> j) {
    Map<String, double>? comp;
    if (j['composition'] != null) {
      comp = (j['composition'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble()));
    }
    return SequenceResult(
      sequence:    j['sequence'] as String,
      length:      j['length']   as int,
      valid:       j['valid']    as bool,
      sessionId:   j['session_id'] as String?,
      gcPercent:   (j['gc_percent'] as num?)?.toDouble(),
      composition: comp,
    );
  }
}

// ─── PAM / gRNA ───────────────────────────────────────────────────────────────

class PamSite {
  final String pam;
  final int start;
  final int end;
  final String? grna;
  final double? gcPercent;
  final bool? recommended;

  PamSite({
    required this.pam,
    required this.start,
    required this.end,
    this.grna,
    this.gcPercent,
    this.recommended,
  });

  factory PamSite.fromJson(Map<String, dynamic> j) => PamSite(
        pam:         j['pam']   as String,
        start:       j['start'] as int,
        end:         j['end']   as int,
        grna:        j['grna']  as String?,
        gcPercent:   (j['gc_percent'] as num?)?.toDouble(),
        recommended: j['recommended'] as bool?,
      );
}

class ScanResult {
  final String sequence;
  final List<PamSite> pamSites;
  final int count;

  ScanResult({required this.sequence, required this.pamSites, required this.count});

  factory ScanResult.fromJson(Map<String, dynamic> j) => ScanResult(
        sequence: j['sequence'] as String,
        pamSites: (j['pam_sites'] as List).map((e) => PamSite.fromJson(e as Map<String, dynamic>)).toList(),
        count:    j['count'] as int,
      );
}

// ─── Cut ──────────────────────────────────────────────────────────────────────

class CutResult {
  final int cutPosition;
  final String upstream;
  final String downstream;
  final int pamStart;
  final String sequence;

  CutResult({
    required this.cutPosition,
    required this.upstream,
    required this.downstream,
    required this.pamStart,
    required this.sequence,
  });

  factory CutResult.fromJson(Map<String, dynamic> j) => CutResult(
        cutPosition: j['cut_position'] as int,
        upstream:    j['upstream']     as String,
        downstream:  j['downstream']   as String,
        pamStart:    j['pam_start']    as int,
        sequence:    j['sequence']     as String,
      );
}

// ─── Repair ───────────────────────────────────────────────────────────────────

class RepairResult {
  final String repairedSequence;
  final String repairType;
  final int cutPosition;
  final int? deletionSize;
  final String? donorTemplate;
  final int originalLength;
  final int repairedLength;

  RepairResult({
    required this.repairedSequence,
    required this.repairType,
    required this.cutPosition,
    this.deletionSize,
    this.donorTemplate,
    required this.originalLength,
    required this.repairedLength,
  });

  factory RepairResult.fromJson(Map<String, dynamic> j) => RepairResult(
        repairedSequence: j['repaired_sequence'] as String,
        repairType:       j['repair_type']       as String,
        cutPosition:      j['cut_position']      as int,
        deletionSize:     j['deletion_size']     as int?,
        donorTemplate:    j['donor_template']    as String?,
        originalLength:   j['original_length']   as int,
        repairedLength:   j['repaired_length']   as int,
      );
}

// ─── Translation ──────────────────────────────────────────────────────────────

class TranslateResult {
  final String dna;
  final String mrna;
  final String protein;
  final int codonCount;
  final int trimmedLength;

  TranslateResult({
    required this.dna,
    required this.mrna,
    required this.protein,
    required this.codonCount,
    required this.trimmedLength,
  });

  factory TranslateResult.fromJson(Map<String, dynamic> j) => TranslateResult(
        dna:           j['dna']            as String,
        mrna:          j['mrna']           as String,
        protein:       j['protein']        as String,
        codonCount:    j['codon_count']    as int,
        trimmedLength: j['trimmed_length'] as int,
      );
}

// ─── Comparison ───────────────────────────────────────────────────────────────

class CompareResult {
  final String originalProtein;
  final String editedProtein;
  final String originalMrna;
  final String editedMrna;
  final bool frameshift;
  final bool prematureStop;
  final int lengthDiff;
  final int originalLength;
  final int editedLength;
  final String summary;

  CompareResult({
    required this.originalProtein,
    required this.editedProtein,
    required this.originalMrna,
    required this.editedMrna,
    required this.frameshift,
    required this.prematureStop,
    required this.lengthDiff,
    required this.originalLength,
    required this.editedLength,
    required this.summary,
  });

  factory CompareResult.fromJson(Map<String, dynamic> j) => CompareResult(
        originalProtein: j['original_protein'] as String,
        editedProtein:   j['edited_protein']   as String,
        originalMrna:    j['original_mrna']    as String,
        editedMrna:      j['edited_mrna']      as String,
        frameshift:      j['frameshift']       as bool,
        prematureStop:   j['premature_stop']   as bool,
        lengthDiff:      j['length_diff']      as int,
        originalLength:  j['original_length']  as int,
        editedLength:    j['edited_length']    as int,
        summary:         j['summary']          as String,
      );
}
