# Optimized Record Linkage: Hybrid Cascade Approach

## Overview

A high-performance deterministic-first cascade strategy combining exact matching with hybrid fuzzy fallback. Uses adaptive blocking and hybrid similarity to maximize both speed and accuracy.

## Key Design Principles

1. **Exact matching first** — Prioritize high-confidence exact matches
2. **Fuzzy only as fallback** — Only for records that didn't match exactly
3. **Hybrid similarity** — Edit distance for short names, Q-grams for long names
4. **Adaptive blocking** — Block size caps prevent O(N²) blowup on common dates

## Cascade Levels

| Level | Rule | Confidence | Purpose |
|-------|------|------------|---------|
| 1 | EGK exact | Highest | Insurance number is unique identifier |
| 2 | Name + DOB exact | Very High | Full identity match |
| 3 | Name fuzzy (≥0.8) + DOB exact | High | Handle typos with same birthdate |
| 4 | EGK + Last name | Medium | Handle first name changes |
| 5 | Name fuzzy + PLZ + year | Lower | Catch remaining with location |

## Hybrid Similarity

Uses a switching strategy based on name length:

**Short names (< 5 chars):** Edit distance
- Single typo tolerance (Levenshtein ≤ 1)
- Handles cases like LISA ↔ LSIA, FRANK ↔ FRSNK

**Long names (≥ 5 chars):** Q-gram Jaccard similarity
```
MUELLER → {MU, UE, EL, LL, LE, ER}
MULLER  → {MU, UL, LL, LE, ER}
Similarity: 4/7 = 0.57
```

## Performance

The cascade approach is efficient because:

1. **Level 1** (EGK) uses hash-based grouping — O(n)
2. **Levels 2, 4** use exact key grouping — O(n)
3. **Level 3** groups by DOB, capped at 100 records per block
4. **Level 5** groups by PLZ+year, capped at 50 records per block

Configuration constants for tuning:
- `MAX_BLOCK_SIZE_DOB = 100`
- `MAX_BLOCK_SIZE_PLZ = 50`
- `SHORT_NAME_THRESHOLD = 5`

## Results

| Metric | Value |
|--------|-------|
| Precision | 99.91% |
| Recall | 81.95% |
| F1 Score | 90.04% |
| Predicted clusters | 147,530 |
| Perfect clusters | 61,804 (41.9%) |
| Split clusters | 85,664 (58.1%) |
| Merged (false positives) | 62 |
| Split entities (false negatives) | 38,139 |

### Matches by Cascade Level

| Level | Rule | Matches |
|-------|------|---------|
| L1 | EGK exact | 247,497 |
| L2 | Name + DOB exact | 98,834 |
| L3 | Name fuzzy + DOB exact | 5,139 |
| L4 | EGK + Last name | 0 |
| L5 | Name fuzzy + PLZ + year | 720 |

## Comparison with Current Model

### Metrics Comparison

| Metric | Current Model | Hybrid Cascade | Δ |
|--------|---------------|----------------|---|
| **Precision** | 100.00% | 99.91% | -0.09% |
| **Recall** | 69.35% | **81.95%** | **+12.60%** |
| **F1 Score** | 81.90% | **90.04%** | **+8.14%** |
| Perfect clusters | 24.2% | 41.9% | **+17.7%** |
| Merged clusters | 0 | 62 | +62 |

### Feature Comparison

| Aspect | Current Model | Hybrid Cascade |
|--------|---------------|----------------|
| Approach | Deterministic | Deterministic + Fuzzy |
| EGK priority | ✅ Yes | ✅ Yes (Level 1) |
| Fuzzy names | ❌ No | ✅ Fallback only |
| Handles typos | ❌ No | ✅ Hybrid similarity |
| Short name typos | ❌ No | ✅ Edit distance |
| Blocking caps | N/A | ✅ Prevents slowdowns |

### Key Improvement

The hybrid cascade achieves **+12.6% higher recall** than the current model while maintaining near-perfect precision (99.91%). This means we correctly link significantly more duplicate records with minimal false matches.

The improvement comes from:
- **Level 3:** Fuzzy name matching catches typos with same birthdate
- **Hybrid similarity:** Edit distance for short names, Q-grams for long names
- **Level 5:** PLZ + birth year matching links some records with missing EGK
