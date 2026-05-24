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
  final int? rank;
  final String? guideId;
  final double? efficiencyPercent;
  final double? specificityPercent;
  final double? safetyPercent;
  final int? offTargetCount;
  final String? overallRisk;

  PamSite({
    required this.pam,
    required this.start,
    required this.end,
    this.grna,
    this.gcPercent,
    this.recommended,
    this.rank,
    this.guideId,
    this.efficiencyPercent,
    this.specificityPercent,
    this.safetyPercent,
    this.offTargetCount,
    this.overallRisk,
  });

  factory PamSite.fromJson(Map<String, dynamic> j) => PamSite(
        pam: j['pam'] as String,
        start: j['start'] as int,
        end: j['end'] as int,
        grna: j['grna'] as String?,
        gcPercent: (j['gc_percent'] as num?)?.toDouble(),
        recommended: j['recommended'] as bool?,
        rank: j['rank'] as int?,
        guideId: j['guide_id'] as String?,
        efficiencyPercent: (j['efficiency_percent'] as num?)?.toDouble(),
        specificityPercent: (j['specificity_percent'] as num?)?.toDouble(),
        safetyPercent: (j['safety_percent'] as num?)?.toDouble(),
        offTargetCount: j['off_target_count'] as int?,
        overallRisk: j['overall_risk'] as String?,
      );
}

class RankedGuide {
  final int rank;
  final String guideId;
  final String grna;
  final String pam;
  final int pamStart;
  final double efficiencyPercent;
  final double specificityPercent;
  final double safetyPercent;
  final String grade;
  final int offTargetCount;
  final String overallRisk;
  final bool? recommended;
  final double? gcPercent;

  RankedGuide({
    required this.rank,
    required this.guideId,
    required this.grna,
    required this.pam,
    required this.pamStart,
    required this.efficiencyPercent,
    required this.specificityPercent,
    required this.safetyPercent,
    required this.grade,
    required this.offTargetCount,
    required this.overallRisk,
    this.recommended,
    this.gcPercent,
  });

  factory RankedGuide.fromJson(Map<String, dynamic> j) => RankedGuide(
        rank: j['rank'] as int,
        guideId: j['guide_id'] as String,
        grna: j['grna'] as String,
        pam: j['pam'] as String,
        pamStart: j['pam_start'] as int,
        efficiencyPercent: (j['efficiency_percent'] as num).toDouble(),
        specificityPercent: (j['specificity_percent'] as num).toDouble(),
        safetyPercent: (j['safety_percent'] as num).toDouble(),
        grade: j['grade'] as String,
        offTargetCount: j['off_target_count'] as int,
        overallRisk: j['overall_risk'] as String,
        recommended: j['recommended'] as bool?,
        gcPercent: (j['gc_percent'] as num?)?.toDouble(),
      );
}

class GuideRecommendation {
  final String guideId;
  final String grna;
  final int pamStart;
  final double efficiencyPercent;
  final double specificityPercent;
  final double safetyPercent;
  final List<String> reasons;

  GuideRecommendation({
    required this.guideId,
    required this.grna,
    required this.pamStart,
    required this.efficiencyPercent,
    required this.specificityPercent,
    required this.safetyPercent,
    required this.reasons,
  });

  factory GuideRecommendation.fromJson(Map<String, dynamic> j) =>
      GuideRecommendation(
        guideId: j['guide_id'] as String,
        grna: j['grna'] as String,
        pamStart: j['pam_start'] as int,
        efficiencyPercent: (j['efficiency_percent'] as num).toDouble(),
        specificityPercent: (j['specificity_percent'] as num).toDouble(),
        safetyPercent: (j['safety_percent'] as num).toDouble(),
        reasons: (j['reasons'] as List).cast<String>(),
      );
}

class ScanResult {
  final String sequence;
  final List<PamSite> pamSites;
  final int count;
  final String? casType;
  final String? casName;
  final String? pamMotif;
  final String? targetMolecule;
  final String? application;
  final List<RankedGuide> rankedGuides;
  final GuideRecommendation? recommendation;

  ScanResult({
    required this.sequence,
    required this.pamSites,
    required this.count,
    this.casType,
    this.casName,
    this.pamMotif,
    this.targetMolecule,
    this.application,
    this.rankedGuides = const [],
    this.recommendation,
  });

  factory ScanResult.fromJson(Map<String, dynamic> j) => ScanResult(
        sequence: j['sequence'] as String,
        pamSites: (j['pam_sites'] as List)
            .map((e) => PamSite.fromJson(e as Map<String, dynamic>))
            .toList(),
        count: j['count'] as int,
        casType: j['cas_type'] as String?,
        casName: j['cas_name'] as String?,
        pamMotif: j['pam_motif'] as String?,
        targetMolecule: j['target_molecule'] as String?,
        application: j['application'] as String?,
        rankedGuides: j['ranked_guides'] != null
            ? (j['ranked_guides'] as List)
                .map((e) => RankedGuide.fromJson(e as Map<String, dynamic>))
                .toList()
            : const [],
        recommendation: j['recommendation'] != null
            ? GuideRecommendation.fromJson(
                j['recommendation'] as Map<String, dynamic>)
            : null,
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

// ─── Advanced modules ─────────────────────────────────────────────────────────

class CasSystemInfo {
  final String id;
  final String name;
  final String pamMotif;
  final int grnaLength;
  final String targetMolecule;
  final String application;
  final String description;

  CasSystemInfo({
    required this.id,
    required this.name,
    required this.pamMotif,
    required this.grnaLength,
    required this.targetMolecule,
    required this.application,
    required this.description,
  });

  factory CasSystemInfo.fromJson(Map<String, dynamic> j) => CasSystemInfo(
        id: j['id'] as String,
        name: j['name'] as String,
        pamMotif: j['pam_motif'] as String,
        grnaLength: j['grna_length'] as int,
        targetMolecule: j['target_molecule'] as String,
        application: j['application'] as String,
        description: j['description'] as String,
      );
}

class OffTargetSite {
  final String location;
  final int mismatches;
  final String risk;
  final String riskColor;
  final String sequenceContext;
  final String source;

  OffTargetSite({
    required this.location,
    required this.mismatches,
    required this.risk,
    required this.riskColor,
    required this.sequenceContext,
    required this.source,
  });

  factory OffTargetSite.fromJson(Map<String, dynamic> j) => OffTargetSite(
        location: j['location'] as String,
        mismatches: j['mismatches'] as int,
        risk: j['risk'] as String,
        riskColor: j['risk_color'] as String,
        sequenceContext: j['sequence_context'] as String,
        source: j['source'] as String,
      );
}

class OffTargetResult {
  final String grna;
  final int offTargetCount;
  final List<OffTargetSite> sites;
  final String overallRisk;
  final String overallRiskColor;

  OffTargetResult({
    required this.grna,
    required this.offTargetCount,
    required this.sites,
    required this.overallRisk,
    required this.overallRiskColor,
  });

  factory OffTargetResult.fromJson(Map<String, dynamic> j) => OffTargetResult(
        grna: j['grna'] as String,
        offTargetCount: j['off_target_count'] as int,
        sites: (j['sites'] as List)
            .map((e) => OffTargetSite.fromJson(e as Map<String, dynamic>))
            .toList(),
        overallRisk: j['overall_risk'] as String,
        overallRiskColor: j['overall_risk_color'] as String,
      );
}

class SafetyScoreResult {
  final int score;
  final int maxScore;
  final String label;
  final Map<String, dynamic> factors;
  final String overallRisk;

  SafetyScoreResult({
    required this.score,
    required this.maxScore,
    required this.label,
    required this.factors,
    required this.overallRisk,
  });

  factory SafetyScoreResult.fromJson(Map<String, dynamic> j) =>
      SafetyScoreResult(
        score: j['score'] as int,
        maxScore: j['max_score'] as int,
        label: j['label'] as String,
        factors: j['factors'] as Map<String, dynamic>,
        overallRisk: j['overall_risk'] as String,
      );
}

class GeneInfo {
  final String? accession;
  final bool found;
  final String geneSymbol;
  final String geneName;
  final String chromosome;
  final String function;
  final List<String> associatedDiseases;
  final List<String> supportingStudies;

  GeneInfo({
    this.accession,
    required this.found,
    required this.geneSymbol,
    required this.geneName,
    required this.chromosome,
    required this.function,
    this.associatedDiseases = const [],
    this.supportingStudies = const [],
  });

  factory GeneInfo.fromJson(Map<String, dynamic> j) => GeneInfo(
        accession: j['accession'] as String?,
        found: j['found'] as bool,
        geneSymbol: j['gene_symbol'] as String,
        geneName: j['gene_name'] as String,
        chromosome: j['chromosome'] as String,
        function: j['function'] as String,
        associatedDiseases:
            (j['associated_diseases'] as List?)?.cast<String>() ?? const [],
        supportingStudies:
            (j['supporting_studies'] as List?)?.cast<String>() ?? const [],
      );
}

class LiteratureCase {
  final String id;
  final String title;
  final String? accession;
  final String description;

  LiteratureCase({
    required this.id,
    required this.title,
    this.accession,
    required this.description,
  });

  factory LiteratureCase.fromJson(Map<String, dynamic> j) => LiteratureCase(
        id: j['id'] as String,
        title: j['title'] as String,
        accession: j['accession'] as String?,
        description: j['description'] as String,
      );
}

class LiteratureComparisonRow {
  final String parameter;
  final dynamic literature;
  final dynamic application;
  final bool match;

  LiteratureComparisonRow({
    required this.parameter,
    required this.literature,
    required this.application,
    required this.match,
  });

  factory LiteratureComparisonRow.fromJson(Map<String, dynamic> j) =>
      LiteratureComparisonRow(
        parameter: j['parameter'] as String,
        literature: j['literature'],
        application: j['application'],
        match: j['match'] as bool,
      );
}

class LiteratureValidationResult {
  final String caseId;
  final String title;
  final Map<String, dynamic> literature;
  final Map<String, dynamic> predicted;
  final List<LiteratureComparisonRow> comparisonRows;
  final double validationScorePercent;
  final String summary;
  final List<String> supportingStudies;

  LiteratureValidationResult({
    required this.caseId,
    required this.title,
    required this.literature,
    required this.predicted,
    required this.comparisonRows,
    required this.validationScorePercent,
    required this.summary,
    required this.supportingStudies,
  });

  factory LiteratureValidationResult.fromJson(Map<String, dynamic> j) =>
      LiteratureValidationResult(
        caseId: j['case_id'] as String,
        title: j['title'] as String,
        literature: j['literature'] as Map<String, dynamic>,
        predicted: j['predicted'] as Map<String, dynamic>,
        comparisonRows: (j['comparison_rows'] as List)
            .map((e) =>
                LiteratureComparisonRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        validationScorePercent:
            (j['validation_score_percent'] as num).toDouble(),
        summary: j['summary'] as String,
        supportingStudies: (j['supporting_studies'] as List).cast<String>(),
      );
}
