# CRISPR-Sim

**Interactive CRISPR-Cas9 Gene Editing Simulator**

A full-stack bioinformatics application that simulates the complete CRISPR-Cas9 editing pipeline — from DNA sequence input to protein-level mutation analysis — built with Flutter (mobile frontend), FastAPI (backend), and BioPython.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
  - [Backend](#backend-setup)
  - [Frontend](#frontend-setup)
- [API Reference](#api-reference)
- [Simulation Pipeline](#simulation-pipeline)
- [Datasets](#datasets)
- [Testing](#testing)
- [DNA Colour Scheme](#dna-colour-scheme)
- [ML Module](#ml-module-placeholder)
- [Tech Stack](#tech-stack)

---

## Overview

CRISPR-Sim walks users through every step of Cas9 gene editing:

1. **Input** – paste DNA, upload FASTA, or fetch from NCBI
2. **Validate** – enforce A/T/C/G-only sequences
3. **Scan** – locate all NGG PAM sites via regex
4. **Guide RNA** – extract 20 bp upstream, calculate GC %
5. **Cut** – simulate Cas9 DSB at PAM_start − 3
6. **Repair** – NHEJ (random indels) or HDR (donor template)
7. **Translate** – DNA → mRNA → Protein via BioPython
8. **Analyse** – detect frameshift mutations and premature stop codons

---

## Architecture

```
Flutter App (Mobile UI)
        │  HTTPS / JSON REST
        ▼
FastAPI Gateway  (Python)
        │
  ┌─────┴──────────────────────┐
  │  Services                  │
  │  ├── validator.py          │
  │  ├── pam_scanner.py        │
  │  ├── grna_generator.py     │
  │  ├── cut_engine.py         │
  │  ├── repair_engine.py      │
  │  ├── translation.py        │
  │  └── analysis.py           │
  └─────────────────────────── ┘
        │
  BioPython + NCBI E-Utils
        │
  SQLite (history / sessions)
```

---

## Project Structure

```
crispr_sim/
├── backend/
│   ├── main.py                   # FastAPI app entry point
│   ├── requirements.txt
│   ├── api/
│   │   ├── sequence.py           # /sequence/* routes
│   │   ├── crispr.py             # /crispr/*  routes
│   │   └── analysis.py           # /analysis/* routes
│   ├── services/
│   │   ├── validator.py
│   │   ├── pam_scanner.py
│   │   ├── grna_generator.py
│   │   ├── cut_engine.py
│   │   ├── repair_engine.py
│   │   ├── translation.py
│   │   ├── analysis.py
│   │   └── sequence_input.py
│   ├── models/
│   │   └── schemas.py            # Pydantic request/response models
│   ├── utils/
│   │   └── database.py           # SQLite init & helpers
│   ├── data/
│   │   ├── download_datasets.py  # NCBI downloader script
│   │   └── datasets/             # FASTA files (HBB, TP53, BRCA1, demo)
│   └── ml/
│       └── guide_scoring.py      # gRNA efficiency scorer (heuristic + RF scaffold)
├── frontend/
│   └── flutter_app/
│       ├── pubspec.yaml
│       └── lib/
│           ├── main.dart
│           ├── utils/constants.dart
│           ├── models/crispr_models.dart
│           ├── services/api_service.dart
│           ├── providers/crispr_provider.dart
│           ├── widgets/
│           │   ├── dna_text_widget.dart
│           │   └── gc_content_bar.dart
│           └── screens/
│               ├── home_screen.dart
│               ├── input_screen.dart
│               ├── dna_viewer_screen.dart
│               ├── pam_scanner_screen.dart
│               ├── cut_simulation_screen.dart
│               ├── repair_selection_screen.dart
│               └── analysis_screen.dart
└── tests/
    ├── conftest.py
    ├── test_sequence.py
    └── test_crispr_flow.py
```

---

## Prerequisites

| Tool | Minimum version |
|---|---|
| Python | 3.10+ |
| pip | 23+ |
| Flutter SDK | 3.4+ |
| Dart SDK | 3.4+ (bundled with Flutter) |

---

## Quick Start

### Backend Setup

```bash
# 1. Navigate to the backend directory
cd crispr_sim/backend

# 2. (Recommended) create a virtual environment
python -m venv .venv
source .venv/bin/activate        # Linux / macOS
.venv\Scripts\activate           # Windows PowerShell

# 3. Install dependencies
pip install -r requirements.txt

# 4. (Optional) download real gene datasets from NCBI
python data/download_datasets.py

# 5. Start the API server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

> Interactive API docs: http://localhost:8000/docs  
> ReDoc: http://localhost:8000/redoc

---

### Frontend Setup

```bash
# 1. Navigate to the Flutter app directory
cd crispr_sim/frontend/flutter_app

# 2. Initialise Flutter project (first time only)
#    This generates platform-specific files (android/, ios/, etc.)
flutter create . --project-name crispr_sim

# 3. Install Dart/Flutter packages
flutter pub get

# 4. Run the app (choose your target device)
flutter run                      # auto-selects a connected device
flutter run -d chrome            # web
flutter run -d android           # Android emulator / device
flutter run -d ios               # iOS simulator (macOS only)
```

> The app calls `http://localhost:8000` by default.  
> To change the backend URL, edit `lib/utils/constants.dart` → `kBaseUrl`.

---

## API Reference

### Sequence Endpoints

| Method | Path | Description |
|---|---|---|
| POST | `/sequence/paste` | Submit raw DNA string |
| POST | `/sequence/upload` | Upload a `.fasta` file |
| GET  | `/sequence/fetch/{accession}` | Fetch from NCBI |

### CRISPR Endpoints

| Method | Path | Description |
|---|---|---|
| POST | `/crispr/scan` | Find all NGG PAM sites |
| POST | `/crispr/cut`  | Simulate Cas9 DSB |
| POST | `/crispr/nhej` | Apply NHEJ repair |
| POST | `/crispr/hdr`  | Apply HDR repair |

### Analysis Endpoints

| Method | Path | Description |
|---|---|---|
| POST | `/analysis/translate` | DNA → mRNA → Protein |
| POST | `/analysis/compare`   | Compare original vs edited |

### Example: full pipeline with `curl`

```bash
# Validate and set sequence
curl -X POST http://localhost:8000/sequence/paste \
  -H "Content-Type: application/json" \
  -d '{"sequence":"ATGCATGCATGCATGCATGCAGGATGCATGCATGCATGCATGCAGG"}'

# Scan PAM sites
curl -X POST http://localhost:8000/crispr/scan \
  -H "Content-Type: application/json" \
  -d '{"sequence":"ATGCATGCATGCATGCATGCAGGATGCATGCATGCATGCATGCAGG"}'

# Cut at PAM position 20
curl -X POST http://localhost:8000/crispr/cut \
  -H "Content-Type: application/json" \
  -d '{"sequence":"ATGCATGCATGCATGCATGCAGGATGCATGCATGCATGCATGCAGG","pam_start":20}'

# NHEJ repair (2-bp deletion)
curl -X POST http://localhost:8000/crispr/nhej \
  -H "Content-Type: application/json" \
  -d '{"sequence":"ATGCATGCATGCATGCATGCAGGATGCATGCATGCATGCATGCAGG","cut_position":17,"deletion_size":2}'

# Translate + compare
curl -X POST http://localhost:8000/analysis/compare \
  -H "Content-Type: application/json" \
  -d '{"original_sequence":"ATGCATGCATGCATGCATGCAGG","edited_sequence":"ATGCATGCATGCATGCAGG"}'
```

---

## Simulation Pipeline

```
User Input
    │
    ▼
┌─────────────────────┐
│  1. Sequence Input  │  paste / FASTA / NCBI
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│  2. Validation      │  A/T/C/G only, strip whitespace
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│  3. PAM Scan        │  regex: [ATCG]GG
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│  4. gRNA Extraction │  20 bp upstream, GC % 40–60 %
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│  5. Cas9 Cut        │  cut = PAM_start − 3
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│  6. Repair          │  NHEJ (indels) │ HDR (donor)
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│  7. Translation     │  DNA→mRNA→Protein (BioPython)
└──────────┬──────────┘
           ▼
┌─────────────────────┐
│  8. Mutation Detect │  frameshift, premature stop codon
└─────────────────────┘
```

---

## Datasets

Pre-included synthetic fragments (no internet required):

| File | Gene | Length |
|---|---|---|
| `hbb_fragment.fasta` | Hemoglobin beta (HBB) | ~280 bp |
| `tp53_fragment.fasta` | Tumor protein p53 (TP53) | ~260 bp |
| `brca1_fragment.fasta` | BRCA1 DNA repair | ~270 bp |
| `sample_sequences.fasta` | All four above | combined |

Run `python data/download_datasets.py` to also fetch real mRNA sequences from NCBI (NM_000518.5, NM_000546.6, NM_007294.4).

---

## Testing

```bash
# From crispr_sim/ root
cd crispr_sim
pip install -r backend/requirements.txt
pytest tests/ -v
```

Test files:
- `tests/test_sequence.py` – validator, FASTA parser, sequence API
- `tests/test_crispr_flow.py` – PAM scan, gRNA, cut, NHEJ, HDR, translation, compare

---

## DNA Colour Scheme

| Base | Colour |
|---|---|
| **A** | Blue `#1565C0` |
| **T** | Red `#C62828` |
| **G** | Amber `#F9A825` |
| **C** | Green `#2E7D32` |

---

## ML Module (Placeholder)

`backend/ml/guide_scoring.py` provides a heuristic gRNA efficiency scorer today. It is structured for a drop-in Random Forest replacement:

```python
from ml.guide_scoring import score_grna

result = score_grna("GCACTGAGCTAGCTAGCTAG")
# {'score': 0.72, 'grade': 'A', 'gc_content': 55.0, ...}
```

To train a real model, collect gRNA efficiency data (Doench 2016 / Azimuth dataset) and call `train_and_save_model()`.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile Frontend | Flutter 3.4+ (Dart) |
| State Management | Provider |
| Backend API | FastAPI + Uvicorn |
| Bioinformatics | BioPython |
| HTTP Client (backend) | httpx (async) |
| HTTP Client (Flutter) | http |
| Database | SQLite (aiosqlite) |
| PAM Scanning | Python `re` module |
| ML Scaffold | scikit-learn (optional) |
| Testing | pytest + FastAPI TestClient |

---

## Licence

MIT — free to use for education and research.
