# Patient Record Linkage Model

## Overview

The stored procedure `M20_HIS_P_01AB000_PATIENTENBILDUNG` implements a deterministic record linkage algorithm to assign consistent pseudo-IDs to patients across medical billing records (Scheine). The goal is to identify when multiple records belong to the same patient, even when identifiers vary.

## Input Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `@Abr` | INT | Billing type: `1` = Abrechnung 1, `2` = Abrechnung 2 |
| `@Abr1Case` | VARCHAR(50) | Data variant for Abr 1: `BEARBEITET`, `UNBEARBEITET`, or `KVUEPP` |
| `@Quartal` | INT | Quarter identifier (e.g., `20233` for Q3 2023) |

## Data Sources

### Billing Type 1 (Abr = 1)
- `M20_HIS_T_01AB100_SCHEINE` — processed records (BEARBEITET)
- `M20_HIS_T_01AB100_SCHEINE_UNB` — unprocessed records (UNBEARBEITET)
- `M20_HIS_T_01AB100_SCHEINE_UNB_KVUEPP` — KV transfer records (KVUEPP)
- `M20_HIS_T_01AB100_PATID_MAPPING` — output mapping table

### Billing Type 2 (Abr = 2)
- `M20_HIS_T_01AB200_KS_SK_PATIENT` — patient records
- `M20_HIS_T_01AB200_PATID_MAPPING` — output mapping table

### Shared Lookup
- `M20_HIS_T_01AB000_PATIENTEN_LOOKUP` — patient variants for matching

## Matching Attributes

| Attribute | Field Name | Description |
|-----------|------------|-------------|
| Insurance Number | `EGKVERSICHERTENNUMMER` / `EGKVNR` | Electronic health card number |
| First Name | `VORNAME` | Patient's first name |
| Last Name | `NACHNAME` / `NAME` | Patient's last name |
| Date of Birth | `GEBURTSDATUM` / `GEB_DATUM` | Birth date |
| Postal Code | `PLZ` | Postal/ZIP code |

## Linkage Algorithm

The algorithm uses a **cascading deterministic matching** strategy with three matching rules, applied sequentially. Records that match in an earlier phase are not re-evaluated in later phases.

```
┌─────────────────────────────────────────────────────────────────┐
│                     New Records (Scheine)                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 1: Match by EGK Number + Date of Birth                   │
│  ─────────────────────────────────────────────────────────────  │
│  Matches existing patients in lookup table using:               │
│  • EGKVERSICHERTENNUMMER (exact)                                │
│  • GEBURTSDATUM (exact, with normalization)                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                    Unmatched records
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 2: Match by EGK Number + Full Name                       │
│  ─────────────────────────────────────────────────────────────  │
│  Matches remaining records using:                               │
│  • EGKVERSICHERTENNUMMER (exact)                                │
│  • VORNAME (exact)                                              │
│  • NACHNAME (exact)                                             │
└─────────────────────────────────────────────────────────────────┘
                              │
                    Unmatched records
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 3: Match by Name + Date of Birth + Postal Code           │
│  ─────────────────────────────────────────────────────────────  │
│  Matches remaining records using:                               │
│  • VORNAME (exact)                                              │
│  • NACHNAME (exact)                                             │
│  • GEBURTSDATUM (exact)                                         │
│  • PLZ (exact)                                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                    Unmatched records
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 4: Grouping of New Patients                              │
│  ─────────────────────────────────────────────────────────────  │
│  Groups remaining unmatched records into new patient clusters   │
│  using transitive closure across all three matching criteria    │
└─────────────────────────────────────────────────────────────────┘
```

## Date Normalization

Birth dates with missing day or month components are normalized:
- `YYYYMM00` → `YYYYMM01` (missing day → set to 1st)
- `YYYY0000` → `YYYY0101` (missing month & day → set to Jan 1st)

## New Patient Grouping

For records that don't match any existing patient, the algorithm groups them into new patient clusters:

### Step 1: Compute Candidate Group IDs
For each unmatched record, three candidate group IDs are computed:
- **ID_AKT1**: Minimum ID among records sharing `EGK + Geburtsdatum`
- **ID_AKT2**: Minimum ID among records sharing `EGK + Vorname + Nachname`
- **ID_AKT3**: Minimum ID among records sharing `Vorname + Nachname + Geburtsdatum + PLZ`

### Step 2: Select Best ID
The minimum of (ID_AKT1, ID_AKT2, ID_AKT3) becomes the provisional patient ID.

### Step 3: Transitive Closure
Three iterative passes propagate the minimum ID through connected groups:
1. Propagate via ID_AKT1 connections
2. Propagate via ID_AKT2 connections
3. Propagate via ID_AKT3 connections

This ensures that if record A links to B via one criterion, and B links to C via another, all three receive the same patient ID.

### Step 4: Assign Final IDs
New patient IDs are assigned by adding a sequential number to the current maximum ID across all mapping tables.

## Output Tables

### Mapping Tables
Store the relationship between records and patient pseudo-IDs:

**Abr 1:** `M20_HIS_T_01AB100_PATID_MAPPING`
| Column | Type | Description |
|--------|------|-------------|
| SCHEINID | bigint | Record identifier |
| MENGENID | bigint | Quantity identifier |
| DWH_ZEITRAUM | bigint | Time period (quarter) |
| Pat_Pseudo_ID | bigint | Assigned patient pseudo-ID |
| Datenkoerper | varchar | Data variant |

**Abr 2:** `M20_HIS_T_01AB200_PATID_MAPPING`
| Column | Type | Description |
|--------|------|-------------|
| SK_IDENT | bigint | Record identifier |
| DWH_ZEITRAUM | bigint | Time period (quarter) |
| AUSFUHR_ID | int | Export identifier |
| Pat_Pseudo_ID | bigint | Assigned patient pseudo-ID |

### Lookup Table
`M20_HIS_T_01AB000_PATIENTEN_LOOKUP` stores known patient attribute combinations for future matching:

| Column | Type | Description |
|--------|------|-------------|
| PAT_PSEUDO_ID | bigint | Patient pseudo-ID |
| EGKVERSICHERTENNUMMER | varchar(20) | Insurance number |
| VORNAME | varchar(100) | First name |
| NACHNAME | varchar(100) | Last name |
| GEBURTSDATUM | date | Date of birth |
| PLZ | varchar(20) | Postal code |

New attribute combinations are added after each run to improve future matching.

## Matching Hierarchy Summary

| Priority | Matching Rule | Required Fields |
|----------|--------------|-----------------|
| 1 | EGK + DOB | EGKVERSICHERTENNUMMER, GEBURTSDATUM |
| 2 | EGK + Name | EGKVERSICHERTENNUMMER, VORNAME, NACHNAME |
| 3 | Name + DOB + PLZ | VORNAME, NACHNAME, GEBURTSDATUM, PLZ |

## Data Quality Considerations

- Records with `Pat_Pseudo_ID` of 0 or -1 are excluded from the lookup table
- At least one identifier combination must be present:
  - EGK number + at least one other attribute, OR
  - Full name + date of birth + postal code
- Collation is case-sensitive and accent-sensitive (`Latin1_General_100_CI_AS_KS_WS`)

