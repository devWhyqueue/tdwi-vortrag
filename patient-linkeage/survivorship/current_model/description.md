# Patient Consolidation: Current Model

**Procedure**: `M20_HIS_P_01AB000_BUILD_PATIENTEN_STAMM`

## Overview

This stored procedure builds a consolidated **Patient Master Record** (Patienten_Stamm) by selecting the "best" record variant for each patient from multiple source systems. It implements a **two-tier survivorship strategy** that prioritizes verified data over frequency-based selection.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         INPUT SOURCES                                    │
├─────────────────────────────────────────────────────────────────────────┤
│  SCHEINE (processed)    SCHEINE_UNB (unprocessed)    SCHEINE_UNB_KVUEPP │
│  KS_SK_PATIENT          PATID_MASTER (historical)                        │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    TIER 1: VSDM Verification                             │
│  ─────────────────────────────────────────────────────────────────────  │
│  • Filter: Records with successful online card verification              │
│  • Selection: Most recent VSDM check date (ONLINEPRUEFUNGSDATUM)        │
│  • Trust: HIGHEST (insurance card verified against central registry)    │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                    Patients NOT in Tier 1
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    TIER 2: Score-Based Selection                         │
│  ─────────────────────────────────────────────────────────────────────  │
│  • Scoring: Time-weighted frequency + completeness                       │
│  • Ranking: Score DESC → NullCols ASC → maxZeitraum DESC                │
│  • Trust: MEDIUM (statistical best guess)                                │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    POST-PROCESSING                                       │
│  ─────────────────────────────────────────────────────────────────────  │
│  • PLZ-City normalization (progressive fuzzy matching)                   │
│  • German umlaut normalization (ä→AE, ö→OE, ü→UE, ß→SS)                 │
│  • ORTSKENNZAHL / OKZ enrichment from reference table                   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    OUTPUT: PATIENTEN_STAMM                               │
│  ─────────────────────────────────────────────────────────────────────  │
│  One "golden record" per patient with consolidated demographics          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Tier 1: VSDM Verification (Highest Trust)

**VSDM** = Versichertenstammdatenmanagement (Insurance Master Data Management)

### What is VSDM?
When a patient's electronic health insurance card (eGK) is read at a healthcare provider, the system performs an **online verification** against the central insurance registry. This confirms that the patient data on the card matches the authoritative insurance database.

### Selection Logic
1. Filter records with successful VSDM check: `ERGEBNISONLINEPRUEFUNG IN (1,2)` and no errors
2. For each patient, find the **most recent verification date**
3. Select the record associated with that verification

### Why Highest Trust?
- Data verified against authoritative government/insurance registry
- Most recent verification = most current official data
- Bypasses need for statistical inference

## Tier 2: Score-Based Selection (Fallback)

For patients without VSDM verification, uses a **weighted scoring algorithm**.

### Scoring Formula

```sql
Score = SUM(EXP(-0.25 * quarters_ago))
```

Where `quarters_ago` is the number of quarters between the record and current date.

| Quarters Ago | Weight |
|--------------|--------|
| 0 (current)  | 1.000  |
| 1            | 0.779  |
| 2            | 0.607  |
| 4            | 0.368  |
| 8            | 0.135  |

This gives exponentially higher weight to recent records.

### Completeness Penalty

```sql
NullCols = AVG(count of NULL fields per record)
```

Records with fewer missing fields are preferred.

### Ranking Priority
1. **Highest Score** (time-weighted frequency)
2. **Fewest NullCols** (completeness)
3. **Most Recent maxZeitraum** (tiebreaker)

### Grouping Strategy
Records are grouped by **exact match on all demographic fields**:
- EGKVERSICHERTENNUMMER, VORNAME, NACHNAME, GEBURTSDATUM
- GESCHLECHT, PLZ, WOHNORT, STRASSE, LAENDERCODE

The variant with the highest score wins.

## PLZ-City Normalization

City names are matched against a reference table (`PLZ_STADT`) using **progressive fuzzy matching**:

| Step | Match Strategy |
|------|----------------|
| 1 | Unique PLZ (only one city for that PLZ) |
| 2 | Exact match on normalized city name |
| 3 | First 15 characters of city name |
| 4 | First 11 characters |
| 5 | First 7 characters |
| 6 | First 3 characters |
| 7 | Keep original WOHNORT |

This handles variations like "MÜNSTER" vs "MUENSTER" vs "MÜNSTER (WESTF)".

## Data Sources

| Table | Description | Datenkoerper |
|-------|-------------|--------------|
| `SCHEINE` | Processed billing records | BEARBEITET |
| `SCHEINE_UNB` | Unprocessed billing records | UNBEARBEITET |
| `SCHEINE_UNB_KVUEPP` | KVUEPP records | KVUEPP |
| `KS_SK_PATIENT` | Different patient schema | N/A |
| `PATID_MASTER` | Historical master data | Fallback for pre-2020 |

### Pre-2020 Fallback
For records with `DWH_ZEITRAUM <= 20200`, the procedure falls back to `PATID_MASTER` fields (suffixed with `_AKT`) instead of raw billing data.

## Output Schema

| Field | Description |
|-------|-------------|
| `PAT_ID` | Patient pseudo ID (from linkage) |
| `EGKVNR` | Health insurance number |
| `NAME` | Last name |
| `VORNAME` | First name |
| `GEB_DATUM` | Date of birth |
| `GESCHLECHT` | Gender (0=unknown, 1=male, 2=female) |
| `PLZ` | Postal code |
| `ORT` | City (normalized) |
| `STRASSE` | Street address |
| `LAENDERCODE` | Country code |
| `ORTSKENNZAHL` | Regional code |
| `OKZ` | Extended regional code |
| `GEO_X`, `GEO_Y` | Coordinates (currently NULL) |
| `Quartal` | Processing quarter (YYYYQ) |

## Limitations & Improvement Opportunities

### Current Limitations
1. **Record-level selection**: Picks entire records, not field-by-field best values
2. **No source reliability weighting**: All sources treated equally (except VSDM)
3. **No conflict detection**: Doesn't flag contradictory data across records
4. **Binary VSDM trust**: Either verified or not, no partial trust
5. **Grouping sensitivity**: Slight variations create separate groups

### Potential Improvements
1. **Field-level survivorship**: Pick best value per field independently
2. **Source reliability scores**: Weight different source systems
3. **Probabilistic consolidation**: Model uncertainty in value selection
4. **Conflict reporting**: Surface cases where values disagree significantly
5. **Fuzzy grouping**: Allow near-matches to compete for survivorship

## Relation to Record Linkage

This consolidation procedure **assumes linkage is already complete**:
- Input: `PATID_MAPPING` tables provide the `Pat_pseudo_ID` (linked entity ID)
- This procedure doesn't perform linkage—it consolidates linked records

The linkage is handled by a separate process (see `patient_linkeage/flex_rl`).

## Files

- `procedure.sql`: SQL Server stored procedure implementation
- `description.md`: This documentation

