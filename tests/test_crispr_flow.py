"""End-to-end tests for the full CRISPR simulation pipeline."""

import pytest

VALID_DNA = (
    "ATGGTGCACCTGACTCCTGAGGAGAAGTCTGCCGTTACTGCCCTGTGGGGCAAGGTGAACGTGGATGAA"
    "GTTGGTGGTGAGGCCCTGGGCAGGCTGCTGGTGGTCTACCCTTGGACCCAGAGGTTCTTTGAGTTCTTT"
)
SHORT_DNA = "ATGCATGCATGCATGCATGCAGGATGC"


# ─── Unit: PAM scanner ────────────────────────────────────────────────────────

def test_pam_scanner_finds_ngg():
    from services.pam_scanner import scan_pam_sites

    # Embedded PAMs: AGG at pos 5, TGG at pos 10
    seq = "ATGCAAGGATGCATGGCATGC"
    sites = scan_pam_sites(seq)
    pams = [s["pam"] for s in sites]
    assert any(p.endswith("GG") for p in pams)


def test_pam_scanner_returns_correct_positions():
    from services.pam_scanner import scan_pam_sites

    seq = "AAAAGGG"           # AGG at index 3, GGG at index 4
    sites = scan_pam_sites(seq)
    starts = [s["start"] for s in sites]
    assert 3 in starts or 4 in starts


def test_pam_scanner_empty_sequence():
    from services.pam_scanner import scan_pam_sites

    assert scan_pam_sites("ATATATA") == []


# ─── Unit: gRNA generator ─────────────────────────────────────────────────────

def test_grna_extracts_20bp():
    from services.grna_generator import extract_grna

    seq = "A" * 20 + "AGG"
    result = extract_grna(seq, 20)
    assert result is not None
    assert len(result["grna"]) == 20
    assert result["gc_percent"] == 0.0     # all A


def test_grna_gc_recommended_range():
    from services.grna_generator import extract_grna

    # 50 % GC: 10 G/C out of 20
    grna_seq = "GCGCGCGCGCATATATATAT"  # 10 G/C, 10 A/T
    seq = grna_seq + "AGG"
    result = extract_grna(seq, 20)
    assert result["recommended"] is True
    assert 40.0 <= result["gc_percent"] <= 60.0


def test_grna_returns_none_when_too_close_to_start():
    from services.grna_generator import extract_grna

    seq = "ATCGAGG"
    result = extract_grna(seq, 4)   # only 4 nt upstream, need 20
    assert result is None


# ─── Unit: cut engine ────────────────────────────────────────────────────────

def test_cut_position_formula():
    from services.cut_engine import simulate_cut

    seq = "A" * 30 + "AGG"
    pam_start = 30
    result = simulate_cut(seq, pam_start)
    assert result["cut_position"] == pam_start - 3   # == 27


def test_cut_splits_sequence():
    from services.cut_engine import simulate_cut

    seq = "ATCGATCGATCGATCGATCGATCGATCGAGG"   # 31 chars, PAM at 28
    result = simulate_cut(seq, 28)
    assert result["upstream"] + result["downstream"] == seq


# ─── Unit: NHEJ repair ───────────────────────────────────────────────────────

def test_nhej_shortens_sequence():
    from services.repair_engine import nhej_repair

    seq = "ATGCATGCATGCATGCATGC"
    result = nhej_repair(seq, cut_position=10, deletion_size=3)
    assert result["repaired_length"] == len(seq) - 3
    assert result["repair_type"] == "NHEJ"
    assert result["deletion_size"] == 3


def test_nhej_random_deletion_in_range():
    from services.repair_engine import nhej_repair

    seq = "ATGCATGCATGCATGCATGC"
    result = nhej_repair(seq, cut_position=10)
    diff = len(seq) - result["repaired_length"]
    assert 1 <= diff <= 4


# ─── Unit: HDR repair ────────────────────────────────────────────────────────

def test_hdr_inserts_donor():
    from services.repair_engine import hdr_repair

    seq    = "AAAAAAAAAA" + "TTTTTTTTTT"
    donor  = "GCGCGCGCGC"
    result = hdr_repair(seq, cut_position=10, donor_template=donor, replacement_length=0)
    assert donor in result["repaired_sequence"]
    assert result["repair_type"] == "HDR"


def test_hdr_replaces_bases():
    from services.repair_engine import hdr_repair

    seq    = "AAAAAAAAAA" + "TTTTTTTTTT"
    donor  = "GCGCGCGCGC"
    result = hdr_repair(seq, cut_position=10, donor_template=donor, replacement_length=5)
    # 5 Ts replaced with donor
    assert result["repaired_length"] == len(seq) - 5 + len(donor)


# ─── Unit: translation ───────────────────────────────────────────────────────

def test_translation_produces_protein():
    from services.translation import translate_sequence

    # ATG = Met, AAA = Lys, TAA = Stop (*)
    result = translate_sequence("ATGAAATAA")
    assert result["protein"].startswith("MK")
    assert result["mrna"] == "AUGAAAUAA"


def test_translation_trims_partial_codon():
    from services.translation import translate_sequence

    # 10 bases – trim to 9 (3 codons)
    result = translate_sequence("ATGCATGCAT")
    assert result["trimmed_length"] == 9


# ─── Unit: comparison / mutation analysis ─────────────────────────────────────

def test_frameshift_detected():
    from services.analysis import compare_sequences

    original = "ATGCATGCATGC"           # 12 bp (4 codons)
    edited   = "ATGCATGCATG"            # 11 bp (1-bp deletion → frameshift)
    result = compare_sequences(original, edited)
    assert result["frameshift"] is True


def test_no_frameshift_for_in_frame_deletion():
    from services.analysis import compare_sequences

    original = "ATGCATGCATGC"           # 12 bp
    edited   = "ATGCATGC"               # 8 bp? No – 8 bp is not -3 from 12
    # Remove exactly 3 bp
    edited   = "ATGCATGCAT"             # 10 bp – but 10 ≠ 12-3
    # Use 9 bp (12 - 3 = 9) for true in-frame
    edited   = "ATGCATGCA"              # 9 bp (in-frame)
    result = compare_sequences(original, edited)
    assert result["frameshift"] is False


# ─── API: full pipeline ───────────────────────────────────────────────────────

def test_api_scan_returns_pam_sites(client):
    response = client.post("/crispr/scan", json={"sequence": VALID_DNA})
    assert response.status_code == 200
    data = response.json()
    assert "pam_sites" in data
    assert data["count"] >= 0


def test_api_cut_and_nhej(client):
    # First scan to get a PAM site
    scan = client.post("/crispr/scan", json={"sequence": VALID_DNA}).json()
    pam_sites = scan["pam_sites"]

    # Need a site with a gRNA (pam_start >= 20)
    valid_site = next((s for s in pam_sites if s.get("grna")), None)
    if valid_site is None:
        pytest.skip("No PAM site with valid gRNA in test sequence")

    pam_start = valid_site["start"]

    # Cut
    cut = client.post(
        "/crispr/cut",
        json={"sequence": VALID_DNA, "pam_start": pam_start},
    ).json()
    assert cut["cut_position"] == pam_start - 3

    # NHEJ
    nhej = client.post(
        "/crispr/nhej",
        json={"sequence": VALID_DNA, "cut_position": cut["cut_position"], "deletion_size": 2},
    ).json()
    assert nhej["repaired_length"] == len(VALID_DNA) - 2

    # Compare
    compare = client.post(
        "/analysis/compare",
        json={"original_sequence": VALID_DNA, "edited_sequence": nhej["repaired_sequence"]},
    ).json()
    assert compare["frameshift"] is True   # 2-bp deletion = frameshift


def test_api_hdr_repair(client):
    scan  = client.post("/crispr/scan", json={"sequence": VALID_DNA}).json()
    site  = next((s for s in scan["pam_sites"] if s.get("grna")), None)
    if site is None:
        pytest.skip("No valid PAM site found")

    cut = client.post(
        "/crispr/cut",
        json={"sequence": VALID_DNA, "pam_start": site["start"]},
    ).json()

    donor   = "GCGCGCGCGCGCGCGCGCGC"
    hdr_res = client.post(
        "/crispr/hdr",
        json={
            "sequence":            VALID_DNA,
            "cut_position":        cut["cut_position"],
            "donor_template":      donor,
            "replacement_length":  0,
        },
    ).json()
    assert donor in hdr_res["repaired_sequence"]
    assert hdr_res["repair_type"] == "HDR"


def test_api_translate(client):
    response = client.post("/analysis/translate", json={"sequence": "ATGAAATAA"})
    assert response.status_code == 200
    data = response.json()
    assert data["protein"].startswith("MK")
