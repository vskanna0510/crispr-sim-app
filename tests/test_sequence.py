"""Tests for sequence input, validation, and the /sequence/* endpoints."""

import io
import pytest

VALID_DNA = (
    "ATGGTGCACCTGACTCCTGAGGAGAAGTCTGCCGTTACTGCCCTGTGGGGCAAGGTGAACGTGGATGAA"
    "GTTGGTGGTGAGGCCCTGGGCAGGCTGCTGGTGGTCTACCCTTGGACCCAGAGGTTCTTTGAGTTCTTT"
)
SHORT_DNA  = "ATGCATGCATGCATGCATGCAGGATGC"
INVALID_DNA = "ATGCATGXYZ"


# ─── Unit tests: validator ────────────────────────────────────────────────────

def test_validator_accepts_clean_dna():
    from services.validator import validate_and_clean

    result = validate_and_clean(VALID_DNA)
    assert result["valid"] is True
    assert result["cleaned"] == VALID_DNA.upper()
    assert result["errors"] == []
    assert result["gc_percent"] is not None


def test_validator_cleans_whitespace_and_newlines():
    from services.validator import validate_and_clean

    messy = "  ATCG\nATCG\r\nATCG  "
    result = validate_and_clean(messy)
    assert result["valid"] is True
    assert result["cleaned"] == "ATCGATCGATCG"


def test_validator_uppercases_input():
    from services.validator import validate_and_clean

    result = validate_and_clean("atgc")
    assert result["valid"] is True
    assert result["cleaned"] == "ATGC"


def test_validator_rejects_invalid_chars():
    from services.validator import validate_and_clean

    result = validate_and_clean(INVALID_DNA)
    assert result["valid"] is False
    assert result["cleaned"] is None
    assert len(result["errors"]) > 0


def test_validator_rejects_empty():
    from services.validator import validate_and_clean

    result = validate_and_clean("")
    assert result["valid"] is False


def test_validator_gc_percent():
    from services.validator import validate_and_clean

    # GCGC → 100% GC
    result = validate_and_clean("GCGC")
    assert result["gc_percent"] == 100.0

    # ATAT → 0% GC
    result = validate_and_clean("ATAT")
    assert result["gc_percent"] == 0.0


# ─── Unit tests: FASTA parser ─────────────────────────────────────────────────

def test_fasta_parser_single_record():
    from services.sequence_input import parse_fasta_content

    fasta = ">seq1 description\nATGCATGC\nATGCATGC\n"
    result = parse_fasta_content(fasta)
    assert result == "ATGCATGCATGCATGC"


def test_fasta_parser_returns_none_for_bad_input():
    from services.sequence_input import parse_fasta_content

    result = parse_fasta_content("not a fasta file!!!")
    assert result is None


# ─── API tests: POST /sequence/paste ─────────────────────────────────────────

def test_paste_valid_sequence(client):
    response = client.post("/sequence/paste", json={"sequence": VALID_DNA})
    assert response.status_code == 200
    data = response.json()
    assert data["valid"] is True
    assert data["length"] == len(VALID_DNA)
    assert "session_id" in data
    assert "gc_percent" in data


def test_paste_invalid_sequence(client):
    response = client.post("/sequence/paste", json={"sequence": INVALID_DNA})
    assert response.status_code == 422


def test_paste_empty_sequence(client):
    response = client.post("/sequence/paste", json={"sequence": ""})
    assert response.status_code == 422


# ─── API tests: POST /sequence/upload ─────────────────────────────────────────

def test_upload_valid_fasta(client):
    fasta_content = b">test_seq Demo FASTA\nATGCATGCATGCATGCATGC\nATGCATGCATGCATGCATGC\n"
    response = client.post(
        "/sequence/upload",
        files={"file": ("test.fasta", io.BytesIO(fasta_content), "text/plain")},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["valid"] is True


def test_upload_wrong_extension(client):
    response = client.post(
        "/sequence/upload",
        files={"file": ("test.csv", io.BytesIO(b"ATGC"), "text/plain")},
    )
    assert response.status_code == 415
