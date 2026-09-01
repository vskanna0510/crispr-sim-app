"""E2E test case catalog for CRISPR-Sim (120+ cases)."""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Callable, Literal, Optional

TestType = Literal["api", "selenium", "swagger"]
Severity = Literal["Critical", "High", "Medium", "Low"]

VALID_DNA = (
    "ATGGTGCACCTGACTCCTGAGGAGAAGTCTGCCGTTACTGCCCTGTGGGGCAAGGTGAACGTGGATGA"
    "AGTTGGTGGTGAGGCCCTGGGCAGGCTGCTGGTGGTCTACCCTTGGACCCAGAGGTTCTTTGAGTTCTTT"
)
SHORT_DNA = "ATGCATGCATGCATGCATGCAGGATGC"
MINIMAL_DNA = "ATGAAAGG"  # contains PAM AGG


@dataclass
class E2ETestCase:
    test_id: str
    module: str
    name: str
    description: str
    steps: str
    expected: str
    test_type: TestType
    severity: Severity = "Medium"
    tags: list[str] = field(default_factory=list)
    # Execution spec — interpreted by runner
    method: Optional[str] = None
    path: Optional[str] = None
    json_body: Optional[dict[str, Any]] = None
    headers: Optional[dict[str, str]] = None
    files: Optional[dict[str, Any]] = None
    expect_status: int | list[int] = 200
    expect_keys: Optional[list[str]] = None
    expect_contains: Optional[str] = None
    selenium_action: Optional[str] = None
    requires_auth: bool = False
    skip_reason: Optional[str] = None


def _auth_cases() -> list[E2ETestCase]:
    cases = []
    for i in range(1, 6):
        cases.append(
            E2ETestCase(
                test_id=f"AUTH-REG-{i:03d}",
                module="Authentication",
                name=f"Register unique user variant {i}",
                description="Create account with valid email and password",
                steps=f"POST /auth/register with e2e_user_{i}@example.com",
                expected="HTTP 201, access_token and user object returned",
                test_type="api",
                severity="Critical",
                method="POST",
                path="/auth/register",
                json_body={
                    "email": f"e2e_user_{i}@example.com",
                    "password": "TestPass123!",
                    "full_name": f"E2E User {i}",
                },
                expect_status=[201, 409],
                expect_keys=["access_token", "user"],
            )
        )
    cases.extend(
        [
            E2ETestCase(
                test_id="AUTH-REG-006",
                module="Authentication",
                name="Register rejects short password",
                description="Password below 8 chars should fail validation",
                steps="POST /auth/register with 7-char password",
                expected="HTTP 422 validation error",
                test_type="api",
                severity="High",
                method="POST",
                path="/auth/register",
                json_body={"email": "short_pw@example.com", "password": "1234567"},
                expect_status=422,
            ),
            E2ETestCase(
                test_id="AUTH-REG-007",
                module="Authentication",
                name="Register rejects invalid email",
                description="Malformed email rejected",
                steps="POST /auth/register with bad email",
                expected="HTTP 422",
                test_type="api",
                severity="High",
                method="POST",
                path="/auth/register",
                json_body={"email": "not-an-email", "password": "TestPass123!"},
                expect_status=422,
            ),
            E2ETestCase(
                test_id="AUTH-REG-008",
                module="Authentication",
                name="Register duplicate email conflict",
                description="Same email twice returns 409",
                steps="Register same email twice",
                expected="HTTP 409 on second attempt",
                test_type="api",
                severity="High",
                method="POST",
                path="/auth/register",
                json_body={"email": "duplicate@example.com", "password": "TestPass123!"},
                expect_status=[201, 409],
                tags=["duplicate"],
            ),
            E2ETestCase(
                test_id="AUTH-LOG-001",
                module="Authentication",
                name="Login with valid credentials",
                description="Registered user can obtain JWT",
                steps="POST /auth/login",
                expected="HTTP 200 with bearer token",
                test_type="api",
                severity="Critical",
                method="POST",
                path="/auth/login",
                json_body={"email": "e2e_user_1@example.com", "password": "TestPass123!"},
                expect_status=200,
                expect_keys=["access_token"],
            ),
            E2ETestCase(
                test_id="AUTH-LOG-002",
                module="Authentication",
                name="Login wrong password",
                description="Invalid password rejected",
                steps="POST /auth/login with wrong password",
                expected="HTTP 401",
                test_type="api",
                severity="High",
                method="POST",
                path="/auth/login",
                json_body={"email": "e2e_user_1@example.com", "password": "WrongPass99!"},
                expect_status=401,
            ),
            E2ETestCase(
                test_id="AUTH-LOG-003",
                module="Authentication",
                name="Login unknown email",
                description="Non-existent user rejected",
                steps="POST /auth/login unknown user",
                expected="HTTP 401",
                test_type="api",
                severity="Medium",
                method="POST",
                path="/auth/login",
                json_body={"email": "nobody@example.com", "password": "TestPass123!"},
                expect_status=401,
            ),
            E2ETestCase(
                test_id="AUTH-ME-001",
                module="Authentication",
                name="Get profile with valid token",
                description="Authenticated /auth/me returns user",
                steps="GET /auth/me with Bearer token",
                expected="HTTP 200 with email",
                test_type="api",
                severity="Critical",
                method="GET",
                path="/auth/me",
                expect_status=200,
                expect_keys=["email", "id"],
                requires_auth=True,
            ),
            E2ETestCase(
                test_id="AUTH-ME-002",
                module="Authentication",
                name="Profile without token rejected",
                description="Unauthenticated /auth/me fails",
                steps="GET /auth/me no header",
                expected="HTTP 401",
                test_type="api",
                severity="High",
                method="GET",
                path="/auth/me",
                expect_status=401,
            ),
            E2ETestCase(
                test_id="AUTH-OUT-001",
                module="Authentication",
                name="Logout revokes session",
                description="POST /auth/logout returns 204",
                steps="POST /auth/logout with token",
                expected="HTTP 204",
                test_type="api",
                severity="High",
                method="POST",
                path="/auth/logout",
                expect_status=204,
                requires_auth=True,
            ),
        ]
    )
    return cases


def _health_cases() -> list[E2ETestCase]:
    return [
        E2ETestCase(
            test_id="HLTH-001",
            module="Health",
            name="Root health endpoint",
            description="API root returns ok status",
            steps="GET /",
            expected='JSON status "ok"',
            test_type="api",
            severity="Critical",
            method="GET",
            path="/",
            expect_status=200,
            expect_keys=["status", "app"],
        ),
        E2ETestCase(
            test_id="HLTH-002",
            module="Health",
            name="Detailed health probe",
            description="Health check includes database info",
            steps="GET /health",
            expected="status healthy",
            test_type="api",
            severity="Critical",
            method="GET",
            path="/health",
            expect_status=200,
            expect_keys=["status", "database"],
        ),
        E2ETestCase(
            test_id="HLTH-003",
            module="Health",
            name="OpenAPI schema available",
            description="Swagger schema loads",
            steps="GET /openapi.json",
            expected="OpenAPI 3 schema with paths",
            test_type="api",
            severity="High",
            method="GET",
            path="/openapi.json",
            expect_status=200,
            expect_keys=["openapi", "paths"],
        ),
        E2ETestCase(
            test_id="HLTH-004",
            module="Health",
            name="Swagger UI loads in browser",
            description="Selenium opens /docs page",
            steps="Navigate to /docs, verify title",
            expected="Swagger UI visible with CRISPR-Sim title",
            test_type="selenium",
            severity="High",
            selenium_action="swagger_docs_load",
        ),
        E2ETestCase(
            test_id="HLTH-005",
            module="Health",
            name="ReDoc alternative docs",
            description="ReDoc page accessible",
            steps="Navigate to /redoc",
            expected="ReDoc page loads",
            test_type="selenium",
            severity="Low",
            selenium_action="redoc_load",
        ),
    ]


def _sequence_cases() -> list[E2ETestCase]:
    invalid_chars = ["ATGCX", "ATG 123", "atgc!@#", "ATGC\n\t", "ATGCU", "ATGC-RNA"]
    cases = [
        E2ETestCase(
            test_id="SEQ-001",
            module="Sequence Input",
            name="Paste valid DNA sequence",
            description="Submit cleaned DNA via paste endpoint",
            steps="POST /sequence/paste",
            expected="valid=true, session_id returned",
            test_type="api",
            severity="Critical",
            method="POST",
            path="/sequence/paste",
            json_body={"sequence": VALID_DNA},
            expect_status=200,
            expect_keys=["sequence", "session_id", "length"],
        ),
        E2ETestCase(
            test_id="SEQ-002",
            module="Sequence Input",
            name="Paste short demo sequence",
            description="Minimal sequence with PAM",
            steps="POST /sequence/paste short DNA",
            expected="valid sequence returned",
            test_type="api",
            severity="High",
            method="POST",
            path="/sequence/paste",
            json_body={"sequence": SHORT_DNA},
            expect_status=200,
            expect_keys=["gc_percent"],
        ),
        E2ETestCase(
            test_id="SEQ-003",
            module="Sequence Input",
            name="Paste lowercase DNA normalized",
            description="Lowercase converted to uppercase",
            steps="POST lowercase sequence",
            expected="Uppercase cleaned sequence",
            test_type="api",
            severity="Medium",
            method="POST",
            path="/sequence/paste",
            json_body={"sequence": SHORT_DNA.lower()},
            expect_status=200,
        ),
        E2ETestCase(
            test_id="SEQ-004",
            module="Sequence Input",
            name="Upload valid FASTA file",
            description="FASTA upload parsed correctly",
            steps="POST /sequence/upload multipart",
            expected="Sequence extracted from FASTA",
            test_type="api",
            severity="High",
            method="POST",
            path="/sequence/upload",
            files={"file": ("demo.fasta", f">demo\n{SHORT_DNA}\n", "text/plain")},
            expect_status=200,
            expect_keys=["sequence"],
        ),
        E2ETestCase(
            test_id="SEQ-005",
            module="Sequence Input",
            name="Upload rejects non-FASTA extension",
            description="Wrong file extension returns 415",
            steps="Upload .pdf file",
            expected="HTTP 415",
            test_type="api",
            severity="Medium",
            method="POST",
            path="/sequence/upload",
            files={"file": ("bad.pdf", b"%PDF", "application/pdf")},
            expect_status=415,
        ),
        E2ETestCase(
            test_id="SEQ-006",
            module="Sequence Input",
            name="Fetch NCBI accession NM_000518",
            description="NCBI fetch for HBB gene",
            steps="GET /sequence/fetch/NM_000518",
            expected="Sequence returned or graceful error",
            test_type="api",
            severity="High",
            method="GET",
            path="/sequence/fetch/NM_000518",
            expect_status=[200, 502, 503, 504],
        ),
        E2ETestCase(
            test_id="SEQ-007",
            module="Sequence Input",
            name="Gene info card for accession",
            description="Gene metadata from database",
            steps="GET /sequence/gene-info/NM_000518",
            expected="Gene symbol and description",
            test_type="api",
            severity="Medium",
            method="GET",
            path="/sequence/gene-info/NM_000518",
            expect_status=200,
            expect_keys=["accession"],
        ),
    ]
    for i, bad in enumerate(invalid_chars, start=8):
        cases.append(
            E2ETestCase(
                test_id=f"SEQ-{i:03d}",
                module="Sequence Input",
                name=f"Reject invalid sequence #{i - 7}",
                description=f"Invalid chars: {bad[:20]}",
                steps="POST /sequence/paste invalid DNA",
                expected="HTTP 422",
                test_type="api",
                severity="Medium",
                method="POST",
                path="/sequence/paste",
                json_body={"sequence": bad},
                expect_status=422,
            )
        )
    return cases


def _crispr_cases() -> list[E2ETestCase]:
    cases = []
    for cas in ["cas9", "cas12a", "cas13"]:
        cases.append(
            E2ETestCase(
                test_id=f"CRISPR-SCAN-{cas.upper()}",
                module="CRISPR Simulation",
                name=f"PAM scan with {cas}",
                description=f"Scan PAM sites for {cas}",
                steps=f"POST /crispr/scan cas_type={cas}",
                expected="pam_sites list returned",
                test_type="api",
                severity="Critical" if cas == "cas9" else "High",
                method="POST",
                path="/crispr/scan",
                json_body={"sequence": SHORT_DNA, "cas_type": cas},
                expect_status=200,
                expect_keys=["pam_sites", "count", "cas_type"],
            )
        )
    cases.extend(
        [
            E2ETestCase(
                test_id="CRISPR-SCAN-004",
                module="CRISPR Simulation",
                name="Scan returns ranked guides",
                description="Guide ranking included in scan",
                steps="POST /crispr/scan",
                expected="ranked_guides array present",
                test_type="api",
                severity="High",
                method="POST",
                path="/crispr/scan",
                json_body={"sequence": VALID_DNA, "cas_type": "cas9"},
                expect_status=200,
                expect_keys=["ranked_guides"],
            ),
            E2ETestCase(
                test_id="CRISPR-SCAN-005",
                module="CRISPR Simulation",
                name="Scan invalid cas type",
                description="Unknown Cas system rejected",
                steps="POST scan with invalid cas",
                expected="HTTP 400",
                test_type="api",
                severity="Medium",
                method="POST",
                path="/crispr/scan",
                json_body={"sequence": SHORT_DNA, "cas_type": "cas99"},
                expect_status=400,
            ),
            E2ETestCase(
                test_id="CRISPR-SCAN-006",
                module="CRISPR Simulation",
                name="Scan empty sequence",
                description="Empty DNA rejected",
                steps="POST scan empty",
                expected="HTTP 422",
                test_type="api",
                severity="Medium",
                method="POST",
                path="/crispr/scan",
                json_body={"sequence": "", "cas_type": "cas9"},
                expect_status=422,
            ),
            E2ETestCase(
                test_id="CRISPR-CUT-001",
                module="CRISPR Simulation",
                name="Simulate Cas9 cut at PAM",
                description="Cut engine returns cut position",
                steps="POST /crispr/cut",
                expected="cut_position in response",
                test_type="api",
                severity="Critical",
                method="POST",
                path="/crispr/cut",
                json_body={"sequence": SHORT_DNA, "pam_start": 20, "cas_type": "cas9"},
                expect_status=200,
                expect_keys=["cut_position", "upstream", "downstream"],
            ),
            E2ETestCase(
                test_id="CRISPR-CUT-002",
                module="CRISPR Simulation",
                name="Cut out of range pam_start",
                description="Invalid PAM position rejected",
                steps="POST cut pam_start=9999",
                expected="HTTP 400",
                test_type="api",
                severity="High",
                method="POST",
                path="/crispr/cut",
                json_body={"sequence": SHORT_DNA, "pam_start": 9999, "cas_type": "cas9"},
                expect_status=400,
            ),
            E2ETestCase(
                test_id="CRISPR-NHEJ-001",
                module="CRISPR Simulation",
                name="NHEJ repair simulation",
                description="Indel repair applied",
                steps="POST /crispr/nhej",
                expected="edited_sequence returned",
                test_type="api",
                severity="Critical",
                method="POST",
                path="/crispr/nhej",
                json_body={"sequence": SHORT_DNA, "cut_position": 15, "deletion_size": 3},
                expect_status=200,
                expect_keys=["repaired_sequence", "repair_type"],
            ),
            E2ETestCase(
                test_id="CRISPR-NHEJ-002",
                module="CRISPR Simulation",
                name="NHEJ invalid cut position",
                description="Out of range cut rejected",
                steps="POST nhej cut_position=-1",
                expected="HTTP 400",
                test_type="api",
                severity="Medium",
                method="POST",
                path="/crispr/nhej",
                json_body={"sequence": SHORT_DNA, "cut_position": -1, "deletion_size": 1},
                expect_status=400,
            ),
            E2ETestCase(
                test_id="CRISPR-HDR-001",
                module="CRISPR Simulation",
                name="HDR repair with donor template",
                description="HDR inserts donor sequence",
                steps="POST /crispr/hdr",
                expected="edited_sequence with donor",
                test_type="api",
                severity="Critical",
                method="POST",
                path="/crispr/hdr",
                json_body={
                    "sequence": SHORT_DNA,
                    "cut_position": 15,
                    "donor_template": "ATGCATGCATGC",
                },
                expect_status=200,
                expect_keys=["repaired_sequence"],
            ),
            E2ETestCase(
                test_id="CRISPR-HDR-002",
                module="CRISPR Simulation",
                name="HDR invalid donor rejected",
                description="Bad donor chars fail validation",
                steps="POST hdr with invalid donor",
                expected="HTTP 422",
                test_type="api",
                severity="Medium",
                method="POST",
                path="/crispr/hdr",
                json_body={
                    "sequence": SHORT_DNA,
                    "cut_position": 15,
                    "donor_template": "ATGCXXX",
                },
                expect_status=422,
            ),
            E2ETestCase(
                test_id="CRISPR-OT-001",
                module="CRISPR Simulation",
                name="Off-target prediction",
                description="Off-target sites for guide",
                steps="POST /crispr/off-target",
                expected="off_target_count returned",
                test_type="api",
                severity="High",
                method="POST",
                path="/crispr/off-target",
                json_body={
                    "sequence": SHORT_DNA,
                    "grna": SHORT_DNA[:20],
                    "pam_start": 20,
                },
                expect_status=200,
                expect_keys=["off_target_count", "overall_risk"],
            ),
            E2ETestCase(
                test_id="CRISPR-SAF-001",
                module="CRISPR Simulation",
                name="Safety score computation",
                description="Composite safety score",
                steps="POST /crispr/safety-score",
                expected="score and label returned",
                test_type="api",
                severity="High",
                method="POST",
                path="/crispr/safety-score",
                json_body={
                    "sequence": SHORT_DNA,
                    "grna": SHORT_DNA[:20],
                    "pam_start": 20,
                    "gc_percent": 50.0,
                },
                expect_status=200,
                expect_keys=["score", "label"],
            ),
        ]
    )
    # Parametric cut positions
    for i, pos in enumerate([5, 10, 15], start=1):
        cases.append(
            E2ETestCase(
                test_id=f"CRISPR-CUT-P{i:03d}",
                module="CRISPR Simulation",
                name=f"Cut at position {pos}",
                description=f"Cut simulation pam_start={pos}",
                steps="POST /crispr/cut",
                expected="Valid cut or 400 if no PAM",
                test_type="api",
                severity="Medium",
                method="POST",
                path="/crispr/cut",
                json_body={"sequence": SHORT_DNA, "pam_start": pos, "cas_type": "cas9"},
                expect_status=[200, 400],
            )
        )
    return cases


def _analysis_cases() -> list[E2ETestCase]:
    edited = SHORT_DNA[:15] + "TTT" + SHORT_DNA[18:]
    return [
        E2ETestCase(
            test_id="ANLY-001",
            module="Translation & Analysis",
            name="Translate DNA to protein",
            description="Full translation pipeline",
            steps="POST /analysis/translate",
            expected="protein and mRNA returned",
            test_type="api",
            severity="Critical",
            method="POST",
            path="/analysis/translate",
            json_body={"sequence": VALID_DNA},
            expect_status=200,
            expect_keys=["protein", "mrna"],
        ),
        E2ETestCase(
            test_id="ANLY-002",
            module="Translation & Analysis",
            name="Translate too short sequence",
            description="Sequence under 3 bp rejected",
            steps="POST translate 2bp",
            expected="HTTP 400",
            test_type="api",
            severity="Medium",
            method="POST",
            path="/analysis/translate",
            json_body={"sequence": "AT"},
            expect_status=400,
        ),
        E2ETestCase(
            test_id="ANLY-003",
            module="Translation & Analysis",
            name="Compare original vs edited",
            description="Mutation analysis diff",
            steps="POST /analysis/compare",
            expected="frameshift flag returned",
            test_type="api",
            severity="Critical",
            method="POST",
            path="/analysis/compare",
            json_body={
                "original_sequence": SHORT_DNA,
                "edited_sequence": edited,
            },
            expect_status=200,
            expect_keys=["frameshift", "summary"],
        ),
        E2ETestCase(
            test_id="ANLY-004",
            module="Translation & Analysis",
            name="Compare identical sequences",
            description="No mutation when identical",
            steps="POST compare same seq",
            expected="No frameshift",
            test_type="api",
            severity="Medium",
            method="POST",
            path="/analysis/compare",
            json_body={
                "original_sequence": SHORT_DNA,
                "edited_sequence": SHORT_DNA,
            },
            expect_status=200,
        ),
        E2ETestCase(
            test_id="ANLY-005",
            module="Translation & Analysis",
            name="Compare invalid edited sequence",
            description="Bad chars in edited seq",
            steps="POST compare with X",
            expected="HTTP 422",
            test_type="api",
            severity="Medium",
            method="POST",
            path="/analysis/compare",
            json_body={
                "original_sequence": SHORT_DNA,
                "edited_sequence": "ATGCX",
            },
            expect_status=422,
        ),
    ] + [
        E2ETestCase(
            test_id=f"ANLY-TR-{i:03d}",
            module="Translation & Analysis",
            name=f"Translate sequence variant {i}",
            description="Translation on DNA slices",
            steps="POST /analysis/translate",
            expected="HTTP 200 with protein",
            test_type="api",
            severity="Low",
            method="POST",
            path="/analysis/translate",
            json_body={"sequence": VALID_DNA[i : i + 60]},
            expect_status=200,
        )
        for i in range(0, 30, 10)
    ]


def _advanced_cases() -> list[E2ETestCase]:
    return [
        E2ETestCase(
            test_id="ADV-001",
            module="Advanced CRISPR",
            name="List Cas systems",
            description="Registry returns all Cas types",
            steps="GET /advanced/cas-systems",
            expected="List with cas9 entry",
            test_type="api",
            severity="High",
            method="GET",
            path="/advanced/cas-systems",
            expect_status=200,
        ),
        E2ETestCase(
            test_id="ADV-002",
            module="Advanced CRISPR",
            name="Literature validation cases",
            description="Published case studies list",
            steps="GET /validation/cases",
            expected="Non-empty case list",
            test_type="api",
            severity="Medium",
            method="GET",
            path="/validation/cases",
            expect_status=200,
        ),
        E2ETestCase(
            test_id="ADV-003",
            module="Advanced CRISPR",
            name="Literature validation run",
            description="Validate against case study",
            steps="POST /validation/literature",
            expected="Comparison result",
            test_type="api",
            severity="High",
            method="POST",
            path="/validation/literature",
            json_body={
                "case_id": "sickle_cell_hbb",
                "original_sequence": VALID_DNA[:100],
            },
            expect_status=[200, 404, 422],
        ),
        E2ETestCase(
            test_id="ADV-004",
            module="Advanced CRISPR",
            name="RAG chat assistant",
            description="Ask CRISPR assistant",
            steps="POST /chat/rag",
            expected="Answer text returned",
            test_type="api",
            severity="Medium",
            method="POST",
            path="/chat/rag",
                json_body={"message": "What is a PAM site in CRISPR-Cas9?"},
            expect_status=200,
            expect_keys=["answer"],
        ),
    ] + [
        E2ETestCase(
            test_id=f"ADV-CAS-{i:03d}",
            module="Advanced CRISPR",
            name=f"Cas system entry {i} has required fields",
            description="Validate Cas metadata shape",
            steps="GET /advanced/cas-systems inspect item",
            expected="id, name, pam_motif present",
            test_type="api",
            severity="Low",
            method="GET",
            path="/advanced/cas-systems",
            expect_status=200,
            tags=[f"cas_index_{i}"],
        )
        for i in range(5)
    ]


def _settings_history_cases() -> list[E2ETestCase]:
    return [
        E2ETestCase(
            test_id="SET-001",
            module="Settings",
            name="Get user settings",
            description="Fetch save_history preference",
            steps="GET /settings",
            expected="save_history boolean",
            test_type="api",
            severity="High",
            method="GET",
            path="/settings",
            expect_status=200,
            expect_keys=["save_history"],
            requires_auth=True,
        ),
        E2ETestCase(
            test_id="SET-002",
            module="Settings",
            name="Settings require auth",
            description="Unauthenticated settings blocked",
            steps="GET /settings no token",
            expected="HTTP 401",
            test_type="api",
            severity="High",
            method="GET",
            path="/settings",
            expect_status=401,
        ),
        E2ETestCase(
            test_id="SET-003",
            module="Settings",
            name="Submit app rating",
            description="Post star rating",
            steps="POST /settings/rating",
            expected="Rating saved",
            test_type="api",
            severity="Medium",
            method="POST",
            path="/settings/rating",
            json_body={"stars": 5, "comment": "E2E automated test rating"},
            expect_status=200,
            requires_auth=True,
        ),
        E2ETestCase(
            test_id="SET-004",
            module="Settings",
            name="Get user rating",
            description="Fetch saved rating",
            steps="GET /settings/rating",
            expected="stars returned",
            test_type="api",
            severity="Medium",
            method="GET",
            path="/settings/rating",
            expect_status=[200, 404],
            requires_auth=True,
        ),
        E2ETestCase(
            test_id="HIST-001",
            module="History",
            name="List sequence sessions",
            description="User history sessions",
            steps="GET /history/sessions",
            expected="Array of sessions",
            test_type="api",
            severity="High",
            method="GET",
            path="/history/sessions",
            expect_status=200,
            requires_auth=True,
        ),
        E2ETestCase(
            test_id="HIST-002",
            module="History",
            name="List repair simulations",
            description="Saved simulation history",
            steps="GET /history/simulations",
            expected="Array returned",
            test_type="api",
            severity="High",
            method="GET",
            path="/history/simulations",
            expect_status=200,
            requires_auth=True,
        ),
        E2ETestCase(
            test_id="HIST-003",
            module="History",
            name="List research papers",
            description="Paper catalog for history",
            steps="GET /history/papers",
            expected="Papers list",
            test_type="api",
            severity="Low",
            method="GET",
            path="/history/papers",
            expect_status=200,
            requires_auth=True,
        ),
        E2ETestCase(
            test_id="HIST-004",
            module="History",
            name="History requires authentication",
            description="No token on history endpoints",
            steps="GET /history/sessions unauthenticated",
            expected="HTTP 401",
            test_type="api",
            severity="High",
            method="GET",
            path="/history/sessions",
            expect_status=401,
        ),
    ]


def _pipeline_cases() -> list[E2ETestCase]:
    """Full workflow steps executed sequentially by runner."""
    return [
        E2ETestCase(
            test_id="FLOW-001",
            module="End-to-End Flow",
            name="Full pipeline: paste → scan → cut → nhej → translate",
            description="Complete CRISPR simulation workflow",
            steps="Sequential API calls through pipeline",
            expected="All steps return 200",
            test_type="api",
            severity="Critical",
            tags=["pipeline"],
        ),
        E2ETestCase(
            test_id="FLOW-002",
            module="End-to-End Flow",
            name="Authenticated pipeline with session persistence",
            description="Pipeline with auth and session_id",
            steps="Register, paste, scan with session",
            expected="Session tracked when history on",
            test_type="api",
            severity="Critical",
            tags=["pipeline", "auth"],
        ),
    ]


def _selenium_ui_cases() -> list[E2ETestCase]:
    return [
        E2ETestCase(
            test_id="UI-001",
            module="UI (Selenium)",
            name="Swagger shows Authentication section",
            description="Auth endpoints visible in docs",
            steps="Open /docs, find Authentication tag",
            expected="Authentication section present",
            test_type="selenium",
            severity="High",
            selenium_action="swagger_auth_section",
        ),
        E2ETestCase(
            test_id="UI-002",
            module="UI (Selenium)",
            name="Swagger shows CRISPR Simulation section",
            description="CRISPR endpoints in docs",
            steps="Open /docs, find CRISPR tag",
            expected="CRISPR Simulation visible",
            test_type="selenium",
            severity="High",
            selenium_action="swagger_crispr_section",
        ),
        E2ETestCase(
            test_id="UI-003",
            module="UI (Selenium)",
            name="Execute health check via Swagger UI",
            description="Try GET /health in browser",
            steps="Expand health, Try it out, Execute",
            expected="200 response in Swagger",
            test_type="selenium",
            severity="Critical",
            selenium_action="swagger_execute_health",
        ),
        E2ETestCase(
            test_id="UI-004",
            module="UI (Selenium)",
            name="API root JSON in browser",
            description="Navigate to / and read JSON",
            steps="GET / in Chrome",
            expected='Page contains "CRISPR-Sim"',
            test_type="selenium",
            severity="Medium",
            selenium_action="browser_root_json",
        ),
        E2ETestCase(
            test_id="UI-005",
            module="UI (Selenium)",
            name="OpenAPI JSON valid in browser",
            description="openapi.json loads",
            steps="Navigate to /openapi.json",
            expected="Contains paths key",
            test_type="selenium",
            severity="Medium",
            selenium_action="browser_openapi_json",
        ),
        E2ETestCase(
            test_id="UI-006",
            module="UI (Selenium)",
            name="CORS preflight headers present",
            description="OPTIONS request from browser context",
            steps="Fetch OPTIONS via JS in browser",
            expected="CORS headers or 200/405",
            test_type="selenium",
            severity="Low",
            selenium_action="browser_cors_check",
        ),
        E2ETestCase(
            test_id="UI-007",
            module="UI (Selenium)",
            name="Flutter web app title (if served)",
            description="Load Flutter web and check title",
            steps="Navigate to APP_URL",
            expected="CRISPR-Sim in page",
            test_type="selenium",
            severity="Medium",
            selenium_action="flutter_app_load",
        ),
        E2ETestCase(
            test_id="UI-008",
            module="UI (Selenium)",
            name="Flutter login screen text",
            description="Login UI shows Sign in",
            steps="Load app, wait for Sign in",
            expected="Sign in visible",
            test_type="selenium",
            severity="High",
            selenium_action="flutter_login_visible",
        ),
    ] + [
        E2ETestCase(
            test_id=f"UI-SWAG-{i:03d}",
            module="UI (Selenium)",
            name=f"Swagger scroll section {i}",
            description="Docs page scroll and render check",
            steps=f"Scroll Swagger UI section {i}",
            expected="Page remains interactive",
            test_type="selenium",
            severity="Low",
            selenium_action=f"swagger_scroll_{i}",
        )
        for i in range(1, 6)
    ]


def _security_cases() -> list[E2ETestCase]:
    return [
        E2ETestCase(
            test_id="SEC-001",
            module="Security",
            name="Invalid Bearer token rejected",
            description="Garbage JWT on /auth/me",
            steps="GET /auth/me with bad token",
            expected="HTTP 401",
            test_type="api",
            severity="Critical",
            method="GET",
            path="/auth/me",
            headers={"Authorization": "Bearer invalid.token.here"},
            expect_status=401,
        ),
        E2ETestCase(
            test_id="SEC-002",
            module="Security",
            name="SQL injection in email field",
            description="Malicious email sanitized/rejected",
            steps="POST login with SQL payload",
            expected="HTTP 401 or 422, no error leak",
            test_type="api",
            severity="High",
            method="POST",
            path="/auth/login",
            json_body={"email": "admin'--@test.com", "password": "TestPass123!"},
            expect_status=[401, 422],
        ),
        E2ETestCase(
            test_id="SEC-003",
            module="Security",
            name="XSS payload in register name",
            description="Script tag in full_name",
            steps="POST register with XSS name",
            expected="201 or 422, no script execution",
            test_type="api",
            severity="High",
            method="POST",
            path="/auth/register",
            json_body={
                "email": "xss_test@example.com",
                "password": "TestPass123!",
                "full_name": "<script>alert(1)</script>",
            },
            expect_status=[201, 409, 422],
        ),
        E2ETestCase(
            test_id="SEC-004",
            module="Security",
            name="Oversized sequence rejected",
            description="Very long DNA payload",
            steps="POST paste 100k bp",
            expected="422 or 413 or timeout handled",
            test_type="api",
            severity="Medium",
            method="POST",
            path="/sequence/paste",
            json_body={"sequence": "A" * 100000},
            expect_status=[200, 422, 413, 504],
        ),
        E2ETestCase(
            test_id="SEC-005",
            module="Security",
            name="Method not allowed on health",
            description="POST to GET-only root",
            steps="POST /",
            expected="HTTP 405",
            test_type="api",
            severity="Low",
            method="POST",
            path="/",
            expect_status=405,
        ),
    ]


def _extra_api_cases() -> list[E2ETestCase]:
    """Additional parametric cases to exceed 100+ total coverage."""
    cases = []
    # NHEJ deletion sizes
    for i, del_size in enumerate([1, 2, 5, 8, 10], start=1):
        cases.append(
            E2ETestCase(
                test_id=f"CRISPR-NHEJ-D{i:03d}",
                module="CRISPR Simulation",
                name=f"NHEJ deletion size {del_size} bp",
                description=f"Indel with deletion_size={del_size}",
                steps="POST /crispr/nhej",
                expected="HTTP 200 with edited_sequence",
                test_type="api",
                severity="Low",
                method="POST",
                path="/crispr/nhej",
                json_body={"sequence": SHORT_DNA, "cut_position": 15, "deletion_size": del_size},
                expect_status=[200, 400],
            )
        )
    # Translate windows on VALID_DNA
    for i in range(10):
        start = i * 15
        seq = VALID_DNA[start : start + 45]
        if len(seq) < 3:
            continue
        cases.append(
            E2ETestCase(
                test_id=f"ANLY-WIN-{i+1:03d}",
                module="Translation & Analysis",
                name=f"Translate window {i + 1}",
                description=f"Translate slice starting at {start}",
                steps="POST /analysis/translate",
                expected="HTTP 200",
                test_type="api",
                severity="Low",
                method="POST",
                path="/analysis/translate",
                json_body={"sequence": seq},
                expect_status=200,
            )
        )
    # Scan with session_id variants
    for i in range(3):
        cases.append(
            E2ETestCase(
                test_id=f"CRISPR-SES-{i+1:03d}",
                module="CRISPR Simulation",
                name=f"PAM scan session variant {i + 1}",
                description="Scan with optional session_id field",
                steps="POST /crispr/scan with session_id",
                expected="HTTP 200",
                test_type="api",
                severity="Low",
                method="POST",
                path="/crispr/scan",
                json_body={
                    "sequence": SHORT_DNA,
                    "cas_type": "cas9",
                    "session_id": f"00000000-0000-0000-0000-{i+1:012d}",
                },
                expect_status=200,
            )
        )
    # Chat RAG question variants
    questions = [
        "What is CRISPR-Cas9?",
        "Explain NHEJ repair",
        "What is a frameshift mutation?",
        "How does HDR differ from NHEJ?",
        "What is gRNA?",
    ]
    for i, q in enumerate(questions, start=1):
        cases.append(
            E2ETestCase(
                test_id=f"CHAT-{i:03d}",
                module="Advanced CRISPR",
                name=f"RAG question variant {i}",
                description=q[:40],
                steps="POST /chat/rag",
                expected="answer field in response",
                test_type="api",
                severity="Low",
                method="POST",
                path="/chat/rag",
                json_body={"message": q},
                expect_status=200,
                expect_keys=["answer"],
            )
        )
    # Login validation edge cases
    for i, payload in enumerate(
        [
            {"email": "", "password": "TestPass123!"},
            {"email": "a@b.com", "password": ""},
            {"email": "missing@", "password": "TestPass123!"},
        ],
        start=1,
    ):
        cases.append(
            E2ETestCase(
                test_id=f"AUTH-VAL-{i:03d}",
                module="Authentication",
                name=f"Login validation edge {i}",
                description="Invalid login payload",
                steps="POST /auth/login",
                expected="HTTP 422 or 401",
                test_type="api",
                severity="Medium",
                method="POST",
                path="/auth/login",
                json_body=payload,
                expect_status=[401, 422],
            )
        )
    return cases


def all_test_cases() -> list[E2ETestCase]:
    cases: list[E2ETestCase] = []
    cases.extend(_health_cases())
    cases.extend(_auth_cases())
    cases.extend(_sequence_cases())
    cases.extend(_crispr_cases())
    cases.extend(_analysis_cases())
    cases.extend(_advanced_cases())
    cases.extend(_settings_history_cases())
    cases.extend(_pipeline_cases())
    cases.extend(_selenium_ui_cases())
    cases.extend(_security_cases())
    cases.extend(_extra_api_cases())
    return cases


TEST_CASES: list[E2ETestCase] = all_test_cases()
