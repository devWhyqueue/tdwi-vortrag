# FlexRL: Flexible Record Linkage with Latent Variable Model

Implementation based on the paper: **Robach et al. "A Flexible Model for Record Linkage"** (2024)

## Overview

FlexRL is a probabilistic record linkage method that uses a **latent variable model** with a **Stochastic Expectation-Maximisation (EM)** algorithm to identify matching records across data sources without a unique identifier.

## Key Concepts

### Partially Identifying Variables (PIVs)
Variables used to identify matching records when no unique identifier exists:
- First name, last name
- Date of birth
- Postal code (PLZ)
- Insurance number (EGK)

### Latent Variable Model

The model assumes that observed PIV comparisons are generated from two underlying processes:

1. **True Links**: Records belonging to the same entity
   - P(agreement | link) = 1 - α (where α is the error probability)
   - Errors occur due to typos, data entry mistakes, or changes over time

2. **Non-Links**: Records belonging to different entities
   - P(agreement | non-link) = β (coincidental match probability)
   - Agreement occurs by chance (e.g., common names, same birthday)

### EM Algorithm

The algorithm alternates between:

1. **E-step**: Compute posterior probability P(link | comparison) for each pair
2. **M-step**: Update parameters (π, α, β) based on expected links

Parameters learned:
- **π**: Prior probability that a random pair is a link
- **α**: Error rate for each PIV (disagreement probability for true links)
- **β**: Coincidental agreement rate for each PIV (agreement probability for non-links)

## Implementation Details

### Blocking Strategy

To make the comparison tractable (avoid O(N²) comparisons):
- Records must share at least one blocking key
- Keys: EGK, DOB, PLZ+birth year, Name prefix (3 chars)
- Maximum block size capped to prevent blowup on common values

### Comparison Vectors

For each candidate pair, compute similarity scores:
- **EGK**: Exact match (1.0 or 0.0)
- **Names**: Q-gram Jaccard similarity (0.0 to 1.0)
- **DOB, PLZ**: Exact match (1.0 or 0.0)
- Missing values handled as NaN (ignored in likelihood calculation)

### Linkage Decision

Final clustering uses Union-Find with greedy matching:
1. Sort pairs by link probability (highest first)
2. Accept links with probability > threshold
3. Merge accepted pairs into clusters

### Threshold Configuration (Precision-Recall Tradeoff)

The link probability threshold controls the precision-recall tradeoff:

| Threshold | Behavior | Use Case |
|-----------|----------|----------|
| 0.5 | Balanced (default) | General linkage |
| 0.7-0.8 | Moderately conservative | Balanced patient matching |
| **0.9** | **Conservative (recommended)** | **Patient data - minimize false merges** |
| 0.95+ | Very conservative | High-stakes scenarios |

⚠️ **For patient data**: Use `thresh=0.9` or higher to minimize the risk of incorrectly merging different patients' records.

## Advantages

1. **Probabilistic Interpretation**: Provides uncertainty quantification through link probabilities
2. **Automatic Parameter Learning**: No manual threshold tuning required
3. **Missing Value Handling**: Naturally handles incomplete data
4. **Error Modeling**: Explicitly models registration errors and coincidental matches
5. **Flexible PIV Support**: Accommodates different variable types and quality levels

## Results on Patient Dataset

### Dataset Statistics
- **Records**: 499,720
- **Ground truth entities**: 100,000
- **Candidate pairs evaluated**: 5,211,830

### Learned Parameters
The EM algorithm converged after 7 iterations:

| Parameter | EGK | VORNAME | NACHNAME | DOB | PLZ |
|-----------|-----|---------|----------|-----|-----|
| α (error rate) | 0.025 | 0.152 | 0.153 | 0.021 | 0.353 |
| β (coincidental) | 0.001 | 0.038 | 0.057 | 0.500 | 0.021 |

- **Prior π**: 0.2139 (probability a random candidate pair is a link)

### Performance Metrics (threshold=0.9)

| Metric | FlexRL | Cascade |
|--------|--------|---------|
| **Precision** | **99.89%** | 100.00% |
| **Recall** | **92.11%** | 69.35% |
| **F1 Score** | **95.85%** | 81.90% |

### Cluster Analysis

| Metric | FlexRL | Cascade |
|--------|--------|---------|
| **Predicted clusters** | 120,999 | 182,358 |
| **Perfect clusters** | 80,909 (66.9%) | 44,194 (24.2%) |
| **Split clusters** | 40,021 (33.1%) | 138,164 (75.8%) |
| **Merged clusters** | **69 (0.1%)** | 0 (0.0%) |

### Error Analysis
- **False Positives** (merged): Only 69 clusters with different entities incorrectly linked
- **False Negatives** (split): Some entities split across multiple clusters (tradeoff for safety)

### Key Observations
1. **Near-Perfect Precision**: FlexRL achieves 99.89% precision (only 69 false merges!)
2. **High Recall**: Maintains 92.11% recall—significantly better than cascade's 69.35%
3. **Best F1 Score**: FlexRL achieves 95.85% F1, beating the cascade approach
4. **Safe for Patient Data**: Minimal risk of incorrectly merging different patients' records
5. **Learned Error Rates**: DOB has lowest error rate (0.021), PLZ has highest (0.353) due to address changes
6. **Coincidental Matches**: DOB has high coincidental match rate (0.50), EGK remains unique (0.001)

## Comparison with Deterministic Cascade

| Aspect | FlexRL | Cascade |
|--------|--------|---------|
| Approach | Probabilistic | Deterministic |
| Parameters | Learned from data | Hand-tuned thresholds |
| Speed | Slower (EM iterations) | Faster |
| Interpretability | Link probabilities | Binary decisions |
| Missing values | Explicit handling (NaN) | Requires all fields present |
| Typo tolerance | Q-gram similarity | Exact match only |
| **Precision** | **99.89%** | 100.00% |
| **Recall** | **92.11%** | 69.35% |
| **F1 Score** | **95.85%** | 81.90% |
| **False Merges** | **69** | 0 |

## References

- Robach, K., van der Pas, S. L., van de Wiel, M. A., & Hof, M. H. (2024). A Flexible Model for Record Linkage. *arXiv preprint*.
- GitHub: [https://github.com/robachowyk/FlexRL](https://github.com/robachowyk/FlexRL)

## Files

- `flexrl_validation.ipynb`: Complete implementation and validation notebook
- `Robach et al.; Flexible Model for Record Linkeage.pdf`: Original paper

