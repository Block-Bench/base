# Benchmark Data Schema & Structure Specification

## Unified Data Architecture for Smart Contract AI Evaluation

**Version:** 1.0  
**Created:** December 2025  
**Purpose:** Define consistent data structure across all benchmark datasets

---

## Table of Contents

1. [Overview](#1-overview)
2. [Directory Structure](#2-directory-structure)
3. [File Naming Conventions](#3-file-naming-conventions)
4. [ID System](#4-id-system)
5. [Base Schema (Universal)](#5-base-schema-universal)
6. [Dataset-Specific Schemas](#6-dataset-specific-schemas)
7. [Index File Schema](#7-index-file-schema)
8. [Complete Examples](#8-complete-examples)
9. [Validation Rules](#9-validation-rules)
10. [Implementation Checklist](#10-implementation-checklist)

---

## 1. Overview

### 1.1 Design Principles

1. **Separation of Code and Metadata:** Solidity files (.sol) are separate from metadata (.json)
2. **Compilable Contracts:** All .sol files must be directly compilable with solc
3. **Consistent Base Schema:** All datasets share common fields
4. **Dataset-Specific Extensions:** Each dataset adds relevant fields
5. **Index Files:** Quick dataset overview without loading all files
6. **Unique IDs:** Every sample has a globally unique identifier

### 1.2 Datasets Covered

| Dataset                 | Code | Purpose                                     |
| ----------------------- | ---- | ------------------------------------------- |
| Gold Standard           | `gs` | Post-cutoff high-quality vulnerabilities    |
| Difficulty Stratified   | `ds` | Vulnerabilities organized by complexity     |
| Temporal Contamination  | `tc` | Pre/post cutoff for memorization testing    |
| Adversarial Contrastive | `ac` | Transformed variants for robustness testing |

---

## 2. Directory Structure

### 2.1 Top-Level Structure

```
benchmark/
├── README.md
├── schema/
│   ├── base_schema.json
│   ├── gold_standard_schema.json
│   ├── difficulty_stratified_schema.json
│   ├── temporal_contamination_schema.json
│   └── adversarial_contrastive_schema.json
│
├── gold_standard/
│   ├── index.json
│   ├── contracts/
│   │   ├── gs_001.sol
│   │   ├── gs_002.sol
│   │   └── ...
│   └── metadata/
│       ├── gs_001.json
│       ├── gs_002.json
│       └── ...
│
├── difficulty_stratified/
│   ├── index.json
│   ├── contracts/
│   │   ├── ds_001.sol
│   │   └── ...
│   └── metadata/
│       ├── ds_001.json
│       └── ...
│
├── temporal_contamination/
│   ├── index.json
│   ├── contracts/
│   │   ├── tc_001.sol
│   │   └── ...
│   └── metadata/
│       ├── tc_001.json
│       └── ...
│
└── adversarial_contrastive/
    ├── index.json
    ├── groups/
    │   └── groups.json           # Maps group_id to all variant IDs
    ├── contracts/
    │   ├── ac_001_original.sol
    │   ├── ac_001_chameleon_gaming.sol
    │   ├── ac_001_guardian_reentrancy.sol
    │   └── ...
    └── metadata/
        ├── ac_001_original.json
        ├── ac_001_chameleon_gaming.json
        ├── ac_001_guardian_reentrancy.json
        └── ...
```

### 2.2 Directory Descriptions

| Directory                         | Contents                                   |
| --------------------------------- | ------------------------------------------ |
| `schema/`                         | JSON Schema files for validation           |
| `*/contracts/`                    | Solidity source files (.sol)               |
| `*/metadata/`                     | JSON metadata files (.json)                |
| `*/index.json`                    | Dataset summary and sample listing         |
| `adversarial_contrastive/groups/` | Grouping information for contrastive pairs |

---

## 3. File Naming Conventions

### 3.1 Solidity Files

**Pattern:** `{id}.sol`

**Examples:**

- `gs_001.sol`
- `ds_042.sol`
- `tc_017.sol`
- `ac_001_original.sol`
- `ac_001_chameleon_gaming.sol`

**Rules:**

- Filename matches the sample ID exactly
- All lowercase
- Underscores as separators
- `.sol` extension

### 3.2 Metadata Files

**Pattern:** `{id}.json`

**Examples:**

- `gs_001.json`
- `ac_001_chameleon_gaming.json`

**Rules:**

- Filename matches the sample ID exactly
- Same name as corresponding .sol file (different extension)

### 3.3 Multi-Contract Files

If a sample contains multiple contracts in one file, keep them in a single .sol file:

- Filename: `{id}.sol` (contains all contracts)
- Metadata: List all contract names in `code_metadata.contract_names`

If contracts must be separate files (rare):

```
contracts/
├── ds_050/
│   ├── Main.sol
│   ├── Library.sol
│   └── Interface.sol
```

- Metadata: Set `contract_file` to `"contracts/ds_050/"` (directory)
- Add `code_metadata.entry_point` field

---

## 4. ID System

### 4.1 ID Format

**Pattern:** `{dataset_prefix}_{number}[_{variant_info}]`

| Dataset                 | Prefix | Number Format         | Variant Suffix |
| ----------------------- | ------ | --------------------- | -------------- |
| Gold Standard           | `gs`   | 3 digits, zero-padded | None           |
| Difficulty Stratified   | `ds`   | 3 digits, zero-padded | None           |
| Temporal Contamination  | `tc`   | 3 digits, zero-padded | None           |
| Adversarial Contrastive | `ac`   | 3 digits, zero-padded | Required       |

### 4.2 Adversarial Contrastive ID Variants

**Pattern:** `ac_{number}_{variant_type}[_{parameter}]`

| Variant Type     | Parameters      | Example                         |
| ---------------- | --------------- | ------------------------------- |
| `original`       | None            | `ac_001_original`               |
| `patched`        | None            | `ac_001_patched`                |
| `chameleon`      | Theme name      | `ac_001_chameleon_gaming`       |
| `mirror`         | Mode name       | `ac_001_mirror_compressed`      |
| `crossdomain`    | Target domain   | `ac_001_crossdomain_nft`        |
| `guardian`       | Protection type | `ac_001_guardian_reentrancy`    |
| `hydra`          | None            | `ac_001_hydra`                  |
| `chimera`        | None            | `ac_001_chimera`                |
| `shapeshifter`   | Level           | `ac_001_shapeshifter_L5`        |
| `falseprophet`   | Claim type      | `ac_001_falseprophet_safeclaim` |
| `confidencetrap` | Trap type       | `ac_001_confidencetrap_nomiss`  |
| `trojanhorse`    | None            | `ac_001_trojanhorse`            |

### 4.3 Group IDs (Adversarial Only)

Contrastive variants share a `group_id`:

**Pattern:** `group_{number}`

**Example:**

```
group_001:
  - ac_001_original
  - ac_001_patched
  - ac_001_chameleon_gaming
  - ac_001_guardian_reentrancy
```

### 4.4 ID Uniqueness

- Every ID must be unique across the ENTIRE benchmark (not just within dataset)
- The prefix ensures uniqueness across datasets
- Never reuse IDs, even if a sample is deleted

---

## 5. Base Schema (Universal)

Every sample in every dataset MUST have these fields.

### 5.1 Complete Base Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Base Sample Schema",
  "type": "object",
  "required": [
    "id",
    "contract_file",
    "subset",
    "ground_truth",
    "provenance",
    "code_metadata"
  ],
  "properties": {
    "id": {
      "type": "string",
      "description": "Unique identifier for this sample",
      "pattern": "^(gs|ds|tc|ac)_[0-9]{3}.*$"
    },

    "contract_file": {
      "type": "string",
      "description": "Relative path to .sol file from dataset root",
      "pattern": "^contracts/.+\\.sol$"
    },

    "subset": {
      "type": "string",
      "enum": [
        "gold_standard",
        "difficulty_stratified",
        "temporal_contamination",
        "adversarial_contrastive"
      ],
      "description": "Which dataset this sample belongs to"
    },

    "ground_truth": {
      "type": "object",
      "required": ["is_vulnerable"],
      "properties": {
        "is_vulnerable": {
          "type": "boolean",
          "description": "Whether the contract contains an exploitable vulnerability"
        },

        "vulnerability_type": {
          "type": ["string", "null"],
          "enum": [
            "reentrancy",
            "access_control",
            "integer_overflow",
            "integer_underflow",
            "unchecked_return",
            "tx_origin",
            "timestamp_dependency",
            "front_running",
            "denial_of_service",
            "logic_error",
            "oracle_manipulation",
            "flash_loan",
            "price_manipulation",
            "signature_replay",
            "delegate_call",
            "self_destruct",
            "uninitialized_storage",
            "other",
            null
          ],
          "description": "Primary vulnerability type (null if not vulnerable)"
        },

        "severity": {
          "type": ["string", "null"],
          "enum": ["critical", "high", "medium", "low", null],
          "description": "Severity rating (null if not vulnerable)"
        },

        "vulnerable_location": {
          "type": ["object", "null"],
          "properties": {
            "contract_name": {
              "type": "string",
              "description": "Name of the contract containing vulnerability"
            },
            "function_name": {
              "type": ["string", "null"],
              "description": "Function where vulnerability exists"
            },
            "line_numbers": {
              "type": "array",
              "items": { "type": "integer" },
              "description": "Line numbers of vulnerable code"
            }
          },
          "description": "Location details of the vulnerability"
        },

        "root_cause": {
          "type": ["string", "null"],
          "description": "Technical explanation of why the vulnerability exists"
        },

        "attack_vector": {
          "type": ["string", "null"],
          "description": "How an attacker would exploit this vulnerability"
        },

        "impact": {
          "type": ["string", "null"],
          "description": "Consequences of successful exploitation"
        },

        "correct_fix": {
          "type": ["string", "null"],
          "description": "How to remediate the vulnerability"
        }
      }
    },

    "provenance": {
      "type": "object",
      "required": ["source"],
      "properties": {
        "source": {
          "type": "string",
          "enum": [
            "code4rena",
            "sherlock",
            "immunefi",
            "solodit",
            "rekt_news",
            "trail_of_bits",
            "spearbit",
            "cyfrin",
            "pashov",
            "guardian",
            "openzeppelin",
            "consensys",
            "dedaub",
            "synthetic",
            "manual",
            "other"
          ],
          "description": "Origin of this sample"
        },

        "original_id": {
          "type": ["string", "null"],
          "description": "ID from the original source (e.g., contest ID)"
        },

        "url": {
          "type": ["string", "null"],
          "format": "uri",
          "description": "URL to original report/finding"
        },

        "date_discovered": {
          "type": ["string", "null"],
          "format": "date",
          "description": "When the vulnerability was discovered/reported"
        },

        "date_added": {
          "type": "string",
          "format": "date",
          "description": "When this sample was added to the benchmark"
        },

        "added_by": {
          "type": ["string", "null"],
          "description": "Who added this sample (team member name/ID)"
        }
      }
    },

    "code_metadata": {
      "type": "object",
      "required": ["solidity_version", "num_lines"],
      "properties": {
        "solidity_version": {
          "type": "string",
          "description": "Solidity pragma version",
          "pattern": "^\\^?[0-9]+\\.[0-9]+\\.[0-9]+$"
        },

        "num_lines": {
          "type": "integer",
          "minimum": 1,
          "description": "Total lines of code"
        },

        "num_contracts": {
          "type": "integer",
          "minimum": 1,
          "default": 1,
          "description": "Number of contracts in the file"
        },

        "contract_names": {
          "type": "array",
          "items": { "type": "string" },
          "description": "Names of all contracts in the file"
        },

        "num_functions": {
          "type": "integer",
          "minimum": 0,
          "description": "Total number of functions"
        },

        "has_imports": {
          "type": "boolean",
          "description": "Whether the contract has import statements"
        },

        "imports": {
          "type": "array",
          "items": { "type": "string" },
          "description": "List of imported files/packages"
        },

        "has_inheritance": {
          "type": "boolean",
          "description": "Whether any contract uses inheritance"
        },

        "inherits_from": {
          "type": "array",
          "items": { "type": "string" },
          "description": "List of inherited contracts"
        },

        "has_modifiers": {
          "type": "boolean",
          "description": "Whether custom modifiers are defined"
        },

        "has_events": {
          "type": "boolean",
          "description": "Whether events are defined"
        },

        "has_assembly": {
          "type": "boolean",
          "description": "Whether inline assembly is used"
        },

        "compilation_verified": {
          "type": "boolean",
          "description": "Whether this compiles successfully"
        },

        "compiler_version_used": {
          "type": ["string", "null"],
          "description": "Exact compiler version used for verification"
        }
      }
    },

    "tags": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Additional categorization tags",
      "default": []
    },

    "notes": {
      "type": ["string", "null"],
      "description": "Any additional notes about this sample"
    }
  }
}
```

---

## 6. Dataset-Specific Schemas

Each dataset extends the base schema with additional required fields.

### 6.1 Gold Standard Extension

```json
{
  "gold_standard_fields": {
    "type": "object",
    "required": ["audit_info", "cutoff_status"],
    "properties": {
      "audit_info": {
        "type": "object",
        "required": ["auditor", "audit_date"],
        "properties": {
          "auditor": {
            "type": "string",
            "description": "Name of audit firm or platform"
          },

          "audit_date": {
            "type": "string",
            "format": "date",
            "description": "Date of the audit"
          },

          "audit_report_url": {
            "type": ["string", "null"],
            "format": "uri",
            "description": "URL to full audit report"
          },

          "contest_name": {
            "type": ["string", "null"],
            "description": "Name of audit contest if applicable"
          },

          "finding_id": {
            "type": ["string", "null"],
            "description": "Finding ID within the audit"
          }
        }
      },

      "cutoff_status": {
        "type": "object",
        "required": ["is_post_cutoff", "reference_date"],
        "properties": {
          "is_post_cutoff": {
            "type": "boolean",
            "description": "Whether this is after model knowledge cutoffs"
          },

          "reference_date": {
            "type": "string",
            "format": "date",
            "description": "Date used for cutoff determination"
          },

          "models_excluded": {
            "type": "array",
            "items": { "type": "string" },
            "description": "Models whose cutoff is before this sample",
            "default": []
          }
        }
      },

      "quality_score": {
        "type": ["number", "null"],
        "minimum": 0,
        "maximum": 5,
        "description": "Manual quality rating (0-5)"
      }
    }
  }
}
```

### 6.2 Difficulty Stratified Extension

```json
{
  "difficulty_fields": {
    "type": "object",
    "required": ["difficulty_tier", "complexity_analysis"],
    "properties": {
      "difficulty_tier": {
        "type": "integer",
        "enum": [1, 2, 3, 4, 5],
        "description": "Difficulty level (1=easiest, 5=hardest)"
      },

      "difficulty_tier_name": {
        "type": "string",
        "enum": [
          "textbook",
          "clear_audit",
          "subtle_audit",
          "multi_contract",
          "emergent"
        ],
        "description": "Human-readable tier name"
      },

      "complexity_analysis": {
        "type": "object",
        "properties": {
          "complexity_factors": {
            "type": "array",
            "items": {
              "type": "string",
              "enum": [
                "single_function",
                "multi_function",
                "cross_contract",
                "requires_state_analysis",
                "requires_math_analysis",
                "hidden_in_modifier",
                "hidden_in_library",
                "proxy_pattern",
                "assembly_involved",
                "state_conditional",
                "time_dependent",
                "economic_analysis_needed",
                "requires_external_context"
              ]
            },
            "description": "Factors contributing to difficulty"
          },

          "detection_hints": {
            "type": ["string", "null"],
            "description": "What makes this detectable"
          },

          "detection_challenges": {
            "type": ["string", "null"],
            "description": "What makes this hard to detect"
          },

          "estimated_human_time_minutes": {
            "type": ["integer", "null"],
            "description": "Estimated time for human auditor to find"
          }
        }
      },

      "canonical_example": {
        "type": "boolean",
        "default": false,
        "description": "Whether this is a canonical/textbook example of its type"
      }
    }
  }
}
```

### 6.3 Temporal Contamination Extension

```json
{
  "temporal_fields": {
    "type": "object",
    "required": ["temporal_split", "exploit_info"],
    "properties": {
      "temporal_split": {
        "type": "object",
        "required": ["split", "cutoff_date"],
        "properties": {
          "split": {
            "type": "string",
            "enum": ["pre_cutoff", "post_cutoff"],
            "description": "Whether this is before or after knowledge cutoff"
          },

          "cutoff_date": {
            "type": "string",
            "format": "date",
            "description": "The cutoff date used for splitting"
          },

          "days_from_cutoff": {
            "type": "integer",
            "description": "Days before (negative) or after (positive) cutoff"
          },

          "model_cutoffs": {
            "type": "object",
            "additionalProperties": {
              "type": "string",
              "format": "date"
            },
            "description": "Mapping of model names to their cutoff dates",
            "example": {
              "claude_sonnet_4.5": "2025-03-01",
              "gpt4_turbo": "2024-12-01"
            }
          }
        }
      },

      "exploit_info": {
        "type": "object",
        "required": ["exploit_date"],
        "properties": {
          "exploit_date": {
            "type": "string",
            "format": "date",
            "description": "When the exploit occurred"
          },

          "protocol_name": {
            "type": "string",
            "description": "Name of the exploited protocol"
          },

          "chain": {
            "type": "string",
            "enum": [
              "ethereum",
              "bsc",
              "polygon",
              "arbitrum",
              "optimism",
              "avalanche",
              "other"
            ],
            "description": "Blockchain where exploit occurred"
          },

          "funds_lost_usd": {
            "type": ["number", "null"],
            "minimum": 0,
            "description": "Estimated funds lost in USD"
          },

          "rekt_news_url": {
            "type": ["string", "null"],
            "format": "uri",
            "description": "Rekt.news article URL"
          },

          "transaction_hash": {
            "type": ["string", "null"],
            "description": "Transaction hash of the exploit"
          },

          "attacker_address": {
            "type": ["string", "null"],
            "description": "Attacker's address"
          }
        }
      },

      "public_exposure": {
        "type": "object",
        "properties": {
          "news_coverage": {
            "type": "boolean",
            "description": "Whether this received significant news coverage"
          },

          "twitter_viral": {
            "type": "boolean",
            "description": "Whether this went viral on Twitter/X"
          },

          "likely_in_training": {
            "type": "boolean",
            "description": "Whether this is likely in model training data"
          },

          "exposure_notes": {
            "type": ["string", "null"],
            "description": "Notes on public exposure"
          }
        }
      }
    }
  }
}
```

### 6.4 Adversarial Contrastive Extension

```json
{
  "adversarial_fields": {
    "type": "object",
    "required": ["group_id", "variant_info", "transformation"],
    "properties": {
      "group_id": {
        "type": "string",
        "pattern": "^group_[0-9]{3}$",
        "description": "Links this to other variants of the same base vulnerability"
      },

      "variant_info": {
        "type": "object",
        "required": ["variant_type", "is_original"],
        "properties": {
          "variant_type": {
            "type": "string",
            "enum": [
              "original",
              "patched",
              "chameleon",
              "mirror",
              "crossdomain",
              "guardian",
              "hydra",
              "chimera",
              "shapeshifter",
              "falseprophet",
              "confidencetrap",
              "trojanhorse",
              "counterfactual",
              "reconstruction",
              "statemaze"
            ],
            "description": "Type of variant/transformation"
          },

          "is_original": {
            "type": "boolean",
            "description": "Whether this is the original (non-transformed) version"
          },

          "strategy_category": {
            "type": "string",
            "enum": [
              "baseline",
              "surface",
              "structural",
              "semantic",
              "reasoning"
            ],
            "description": "Category of adversarial strategy"
          }
        }
      },

      "transformation": {
        "type": "object",
        "properties": {
          "source_id": {
            "type": ["string", "null"],
            "description": "ID of the original sample this was transformed from"
          },

          "strategy": {
            "type": ["string", "null"],
            "description": "Transformation strategy applied"
          },

          "strategy_parameters": {
            "type": "object",
            "description": "Parameters used for the transformation",
            "additionalProperties": true
          },

          "transformation_description": {
            "type": ["string", "null"],
            "description": "Human-readable description of what was changed"
          },

          "automated": {
            "type": "boolean",
            "default": false,
            "description": "Whether transformation was automated"
          },

          "transformation_tool": {
            "type": ["string", "null"],
            "description": "Tool used for transformation if automated"
          }
        }
      },

      "vulnerability_status": {
        "type": "object",
        "required": ["vulnerability_preserved"],
        "properties": {
          "vulnerability_preserved": {
            "type": ["boolean", "null"],
            "description": "Whether transformation preserved vulnerability status"
          },

          "status_change_reason": {
            "type": ["string", "null"],
            "description": "Why vulnerability status changed (for guardian, patched)"
          },

          "original_vulnerable": {
            "type": "boolean",
            "description": "Whether the source was vulnerable"
          },

          "expected_detection_change": {
            "type": ["string", "null"],
            "enum": [
              "should_still_detect",
              "may_miss",
              "should_not_detect",
              null
            ],
            "description": "Expected change in AI detection"
          }
        }
      },

      "expected_model_behavior": {
        "type": "object",
        "properties": {
          "pattern_matcher_prediction": {
            "type": ["string", "null"],
            "enum": ["vulnerable", "safe", "uncertain", null],
            "description": "What a pattern-matching model would likely predict"
          },

          "reasoning_model_prediction": {
            "type": ["string", "null"],
            "enum": ["vulnerable", "safe", "uncertain", null],
            "description": "What a reasoning model should predict"
          },

          "tests_hypothesis": {
            "type": ["string", "null"],
            "description": "What hypothesis this variant tests"
          }
        }
      }
    }
  }
}
```

---

## 7. Index File Schema

Each dataset has one `index.json` at its root.

### 7.1 Index File Structure

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Dataset Index Schema",
  "type": "object",
  "required": [
    "dataset_name",
    "version",
    "created_date",
    "last_updated",
    "statistics",
    "samples"
  ],
  "properties": {
    "dataset_name": {
      "type": "string",
      "enum": [
        "gold_standard",
        "difficulty_stratified",
        "temporal_contamination",
        "adversarial_contrastive"
      ]
    },

    "version": {
      "type": "string",
      "pattern": "^[0-9]+\\.[0-9]+\\.[0-9]+$",
      "description": "Semantic version of this dataset"
    },

    "created_date": {
      "type": "string",
      "format": "date"
    },

    "last_updated": {
      "type": "string",
      "format": "date"
    },

    "description": {
      "type": "string",
      "description": "Human-readable description of this dataset"
    },

    "statistics": {
      "type": "object",
      "properties": {
        "total_samples": {
          "type": "integer",
          "minimum": 0
        },

        "vulnerable_count": {
          "type": "integer",
          "minimum": 0
        },

        "safe_count": {
          "type": "integer",
          "minimum": 0
        },

        "by_vulnerability_type": {
          "type": "object",
          "additionalProperties": { "type": "integer" }
        },

        "by_severity": {
          "type": "object",
          "additionalProperties": { "type": "integer" }
        },

        "by_source": {
          "type": "object",
          "additionalProperties": { "type": "integer" }
        }
      }
    },

    "samples": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["id", "contract_file", "metadata_file", "is_vulnerable"],
        "properties": {
          "id": {
            "type": "string"
          },

          "contract_file": {
            "type": "string",
            "description": "Relative path to .sol file"
          },

          "metadata_file": {
            "type": "string",
            "description": "Relative path to .json file"
          },

          "is_vulnerable": {
            "type": "boolean"
          },

          "vulnerability_type": {
            "type": ["string", "null"]
          },

          "severity": {
            "type": ["string", "null"]
          }
        }
      }
    }
  }
}
```

### 7.2 Dataset-Specific Index Extensions

**Adversarial Contrastive Index** adds:

```json
{
  "statistics": {
    "...base stats...": "...",

    "by_strategy": {
      "chameleon": 50,
      "mirror": 50,
      "guardian": 30,
      "...": "..."
    },

    "by_strategy_category": {
      "baseline": 40,
      "surface": 100,
      "structural": 60,
      "semantic": 50,
      "reasoning": 30
    },

    "num_groups": 40,
    "avg_variants_per_group": 5
  }
}
```

**Temporal Contamination Index** adds:

```json
{
  "statistics": {
    "...base stats...": "...",

    "pre_cutoff_count": 75,
    "post_cutoff_count": 75,

    "by_chain": {
      "ethereum": 100,
      "bsc": 30,
      "...": "..."
    },

    "total_funds_lost_usd": 500000000
  },

  "cutoff_date": "2025-03-01",
  "model_cutoffs": {
    "claude_sonnet_4.5": "2025-03-01",
    "gpt4_turbo": "2024-12-01"
  }
}
```

**Difficulty Stratified Index** adds:

```json
{
  "statistics": {
    "...base stats...": "...",

    "by_tier": {
      "1": 30,
      "2": 40,
      "3": 35,
      "4": 25,
      "5": 20
    },

    "by_tier_name": {
      "textbook": 30,
      "clear_audit": 40,
      "subtle_audit": 35,
      "multi_contract": 25,
      "emergent": 20
    }
  }
}
```

---

## 8. Complete Examples

### 8.1 Gold Standard Sample

**File:** `gold_standard/metadata/gs_001.json`

```json
{
  "id": "gs_001",
  "contract_file": "contracts/gs_001.sol",
  "subset": "gold_standard",

  "ground_truth": {
    "is_vulnerable": true,
    "vulnerability_type": "reentrancy",
    "severity": "critical",
    "vulnerable_location": {
      "contract_name": "LendingPool",
      "function_name": "withdraw",
      "line_numbers": [45, 48, 51]
    },
    "root_cause": "External call to msg.sender occurs before state variable update, allowing recursive calls to drain funds",
    "attack_vector": "Attacker deploys contract with malicious fallback that re-enters withdraw() before balance is decremented",
    "impact": "Complete drainage of pool funds",
    "correct_fix": "Apply checks-effects-interactions pattern or use ReentrancyGuard"
  },

  "provenance": {
    "source": "code4rena",
    "original_id": "2025-01-example-H01",
    "url": "https://code4rena.com/reports/2025-01-example#H-01",
    "date_discovered": "2025-01-15",
    "date_added": "2025-01-20",
    "added_by": "researcher_1"
  },

  "code_metadata": {
    "solidity_version": "^0.8.19",
    "num_lines": 87,
    "num_contracts": 1,
    "contract_names": ["LendingPool"],
    "num_functions": 5,
    "has_imports": true,
    "imports": ["@openzeppelin/contracts/token/ERC20/IERC20.sol"],
    "has_inheritance": false,
    "inherits_from": [],
    "has_modifiers": false,
    "has_events": true,
    "has_assembly": false,
    "compilation_verified": true,
    "compiler_version_used": "0.8.19"
  },

  "tags": ["defi", "lending", "high_impact"],
  "notes": null,

  "gold_standard_fields": {
    "audit_info": {
      "auditor": "Code4rena",
      "audit_date": "2025-01-15",
      "audit_report_url": "https://code4rena.com/reports/2025-01-example",
      "contest_name": "Example Protocol",
      "finding_id": "H-01"
    },
    "cutoff_status": {
      "is_post_cutoff": true,
      "reference_date": "2025-01-15",
      "models_excluded": ["claude_sonnet_4.5", "gpt4_turbo"]
    },
    "quality_score": 5
  }
}
```

**File:** `gold_standard/contracts/gs_001.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LendingPool {
    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // VULNERABLE: External call before state update
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        balances[msg.sender] -= amount;
        emit Withdrawal(msg.sender, amount);
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }
}
```

---

### 8.2 Adversarial Contrastive Sample (Original)

**File:** `adversarial_contrastive/metadata/ac_001_original.json`

```json
{
  "id": "ac_001_original",
  "contract_file": "contracts/ac_001_original.sol",
  "subset": "adversarial_contrastive",

  "ground_truth": {
    "is_vulnerable": true,
    "vulnerability_type": "reentrancy",
    "severity": "critical",
    "vulnerable_location": {
      "contract_name": "Vault",
      "function_name": "withdraw",
      "line_numbers": [15, 18]
    },
    "root_cause": "External call before state update",
    "attack_vector": "Reentrant call through fallback",
    "impact": "Fund drainage",
    "correct_fix": "Move balance update before external call"
  },

  "provenance": {
    "source": "manual",
    "original_id": null,
    "url": null,
    "date_discovered": null,
    "date_added": "2025-12-15",
    "added_by": "benchmark_team"
  },

  "code_metadata": {
    "solidity_version": "^0.8.0",
    "num_lines": 25,
    "num_contracts": 1,
    "contract_names": ["Vault"],
    "num_functions": 3,
    "has_imports": false,
    "imports": [],
    "has_inheritance": false,
    "inherits_from": [],
    "has_modifiers": false,
    "has_events": true,
    "has_assembly": false,
    "compilation_verified": true,
    "compiler_version_used": "0.8.19"
  },

  "tags": ["base_case", "reentrancy_canonical"],
  "notes": "Canonical reentrancy example for adversarial testing",

  "adversarial_fields": {
    "group_id": "group_001",

    "variant_info": {
      "variant_type": "original",
      "is_original": true,
      "strategy_category": "baseline"
    },

    "transformation": {
      "source_id": null,
      "strategy": null,
      "strategy_parameters": {},
      "transformation_description": "Original untransformed contract",
      "automated": false,
      "transformation_tool": null
    },

    "vulnerability_status": {
      "vulnerability_preserved": null,
      "status_change_reason": null,
      "original_vulnerable": true,
      "expected_detection_change": null
    },

    "expected_model_behavior": {
      "pattern_matcher_prediction": "vulnerable",
      "reasoning_model_prediction": "vulnerable",
      "tests_hypothesis": "Baseline detection capability"
    }
  }
}
```

---

### 8.3 Adversarial Contrastive Sample (Chameleon Variant)

**File:** `adversarial_contrastive/metadata/ac_001_chameleon_gaming.json`

```json
{
  "id": "ac_001_chameleon_gaming",
  "contract_file": "contracts/ac_001_chameleon_gaming.sol",
  "subset": "adversarial_contrastive",

  "ground_truth": {
    "is_vulnerable": true,
    "vulnerability_type": "reentrancy",
    "severity": "critical",
    "vulnerable_location": {
      "contract_name": "LootVault",
      "function_name": "claimLoot",
      "line_numbers": [15, 18]
    },
    "root_cause": "External call before state update",
    "attack_vector": "Reentrant call through fallback",
    "impact": "Fund drainage",
    "correct_fix": "Move balance update before external call"
  },

  "provenance": {
    "source": "synthetic",
    "original_id": "ac_001_original",
    "url": null,
    "date_discovered": null,
    "date_added": "2025-12-15",
    "added_by": "transformation_toolkit"
  },

  "code_metadata": {
    "solidity_version": "^0.8.0",
    "num_lines": 25,
    "num_contracts": 1,
    "contract_names": ["LootVault"],
    "num_functions": 3,
    "has_imports": false,
    "imports": [],
    "has_inheritance": false,
    "inherits_from": [],
    "has_modifiers": false,
    "has_events": true,
    "has_assembly": false,
    "compilation_verified": true,
    "compiler_version_used": "0.8.19"
  },

  "tags": ["chameleon", "gaming_theme", "renamed"],
  "notes": "Gaming-themed rename of canonical reentrancy",

  "adversarial_fields": {
    "group_id": "group_001",

    "variant_info": {
      "variant_type": "chameleon",
      "is_original": false,
      "strategy_category": "surface"
    },

    "transformation": {
      "source_id": "ac_001_original",
      "strategy": "chameleon",
      "strategy_parameters": {
        "theme": "gaming",
        "renames": {
          "Vault": "LootVault",
          "withdraw": "claimLoot",
          "deposit": "storeLoot",
          "balances": "playerLoot",
          "amount": "lootAmount",
          "Withdrawal": "LootClaimed",
          "Deposit": "LootStored"
        },
        "comments_removed": true
      },
      "transformation_description": "All identifiers renamed to gaming terminology",
      "automated": true,
      "transformation_tool": "adversarial_toolkit_v1"
    },

    "vulnerability_status": {
      "vulnerability_preserved": true,
      "status_change_reason": null,
      "original_vulnerable": true,
      "expected_detection_change": "may_miss"
    },

    "expected_model_behavior": {
      "pattern_matcher_prediction": "safe",
      "reasoning_model_prediction": "vulnerable",
      "tests_hypothesis": "Does model rely on keywords like 'withdraw' and 'balance'?"
    }
  }
}
```

---

### 8.4 Adversarial Contrastive Sample (Guardian Shield Variant)

**File:** `adversarial_contrastive/metadata/ac_001_guardian_reentrancy.json`

```json
{
  "id": "ac_001_guardian_reentrancy",
  "contract_file": "contracts/ac_001_guardian_reentrancy.sol",
  "subset": "adversarial_contrastive",

  "ground_truth": {
    "is_vulnerable": false,
    "vulnerability_type": null,
    "severity": null,
    "vulnerable_location": null,
    "root_cause": null,
    "attack_vector": null,
    "impact": null,
    "correct_fix": null
  },

  "provenance": {
    "source": "synthetic",
    "original_id": "ac_001_original",
    "url": null,
    "date_discovered": null,
    "date_added": "2025-12-15",
    "added_by": "transformation_toolkit"
  },

  "code_metadata": {
    "solidity_version": "^0.8.0",
    "num_lines": 28,
    "num_contracts": 1,
    "contract_names": ["Vault"],
    "num_functions": 3,
    "has_imports": true,
    "imports": ["@openzeppelin/contracts/security/ReentrancyGuard.sol"],
    "has_inheritance": true,
    "inherits_from": ["ReentrancyGuard"],
    "has_modifiers": true,
    "has_events": true,
    "has_assembly": false,
    "compilation_verified": true,
    "compiler_version_used": "0.8.19"
  },

  "tags": ["guardian_shield", "protected", "decoy"],
  "notes": "Protected version - looks vulnerable but isn't",

  "adversarial_fields": {
    "group_id": "group_001",

    "variant_info": {
      "variant_type": "guardian",
      "is_original": false,
      "strategy_category": "semantic"
    },

    "transformation": {
      "source_id": "ac_001_original",
      "strategy": "guardian_shield",
      "strategy_parameters": {
        "protection_type": "reentrancy_guard",
        "import_added": "@openzeppelin/contracts/security/ReentrancyGuard.sol",
        "inheritance_added": "ReentrancyGuard",
        "modifier_added": {
          "function": "withdraw",
          "modifier": "nonReentrant"
        }
      },
      "transformation_description": "Added ReentrancyGuard protection while preserving vulnerable-looking pattern",
      "automated": true,
      "transformation_tool": "adversarial_toolkit_v1"
    },

    "vulnerability_status": {
      "vulnerability_preserved": false,
      "status_change_reason": "ReentrancyGuard mutex prevents recursive calls",
      "original_vulnerable": true,
      "expected_detection_change": "should_not_detect"
    },

    "expected_model_behavior": {
      "pattern_matcher_prediction": "vulnerable",
      "reasoning_model_prediction": "safe",
      "tests_hypothesis": "Can model recognize that nonReentrant modifier neutralizes the vulnerability?"
    }
  }
}
```

---

### 8.5 Groups File (Adversarial Only)

**File:** `adversarial_contrastive/groups/groups.json`

```json
{
  "description": "Maps group IDs to their variant sample IDs",
  "total_groups": 2,

  "groups": {
    "group_001": {
      "base_vulnerability": "reentrancy",
      "description": "Canonical reentrancy and variants",
      "variants": [
        {
          "id": "ac_001_original",
          "variant_type": "original",
          "is_vulnerable": true
        },
        {
          "id": "ac_001_patched",
          "variant_type": "patched",
          "is_vulnerable": false
        },
        {
          "id": "ac_001_chameleon_gaming",
          "variant_type": "chameleon",
          "is_vulnerable": true
        },
        {
          "id": "ac_001_chameleon_resource",
          "variant_type": "chameleon",
          "is_vulnerable": true
        },
        {
          "id": "ac_001_mirror_compressed",
          "variant_type": "mirror",
          "is_vulnerable": true
        },
        {
          "id": "ac_001_guardian_reentrancy",
          "variant_type": "guardian",
          "is_vulnerable": false
        }
      ],
      "expected_correct_answers": {
        "all_vulnerable_detected": [
          "ac_001_original",
          "ac_001_chameleon_gaming",
          "ac_001_chameleon_resource",
          "ac_001_mirror_compressed"
        ],
        "all_safe_detected": ["ac_001_patched", "ac_001_guardian_reentrancy"]
      }
    },

    "group_002": {
      "base_vulnerability": "access_control",
      "description": "Access control vulnerability and variants",
      "variants": [
        {
          "id": "ac_002_original",
          "variant_type": "original",
          "is_vulnerable": true
        }
      ]
    }
  }
}
```

---

### 8.6 Dataset Index Example

**File:** `adversarial_contrastive/index.json`

```json
{
  "dataset_name": "adversarial_contrastive",
  "version": "1.0.0",
  "created_date": "2025-12-15",
  "last_updated": "2025-12-15",

  "description": "Adversarial variants of vulnerable contracts for testing model robustness. Includes surface transformations (renaming, reformatting), structural transformations (splitting, merging), and semantic decoys (protection injection, near-miss patterns).",

  "statistics": {
    "total_samples": 150,
    "vulnerable_count": 100,
    "safe_count": 50,

    "by_vulnerability_type": {
      "reentrancy": 40,
      "access_control": 30,
      "integer_overflow": 20,
      "unchecked_return": 15,
      "other": 45
    },

    "by_severity": {
      "critical": 50,
      "high": 40,
      "medium": 35,
      "low": 25
    },

    "by_source": {
      "synthetic": 140,
      "manual": 10
    },

    "by_strategy": {
      "original": 30,
      "patched": 30,
      "chameleon": 25,
      "mirror": 20,
      "guardian": 20,
      "crossdomain": 15,
      "hydra": 10
    },

    "by_strategy_category": {
      "baseline": 60,
      "surface": 45,
      "structural": 10,
      "semantic": 35,
      "reasoning": 0
    },

    "num_groups": 30,
    "avg_variants_per_group": 5.0
  },

  "samples": [
    {
      "id": "ac_001_original",
      "contract_file": "contracts/ac_001_original.sol",
      "metadata_file": "metadata/ac_001_original.json",
      "is_vulnerable": true,
      "vulnerability_type": "reentrancy",
      "severity": "critical",
      "group_id": "group_001",
      "variant_type": "original"
    },
    {
      "id": "ac_001_chameleon_gaming",
      "contract_file": "contracts/ac_001_chameleon_gaming.sol",
      "metadata_file": "metadata/ac_001_chameleon_gaming.json",
      "is_vulnerable": true,
      "vulnerability_type": "reentrancy",
      "severity": "critical",
      "group_id": "group_001",
      "variant_type": "chameleon"
    },
    {
      "id": "ac_001_guardian_reentrancy",
      "contract_file": "contracts/ac_001_guardian_reentrancy.sol",
      "metadata_file": "metadata/ac_001_guardian_reentrancy.json",
      "is_vulnerable": false,
      "vulnerability_type": null,
      "severity": null,
      "group_id": "group_001",
      "variant_type": "guardian"
    }
  ]
}
```

---

## 9. Validation Rules

### 9.1 File Existence Validation

```
For each entry in index.json["samples"]:
  - contracts/{entry.contract_file} MUST exist
  - metadata/{entry.metadata_file} MUST exist
  - ID in metadata file MUST match entry.id
```

### 9.2 Schema Validation

```
For each metadata file:
  - MUST validate against base_schema.json
  - MUST validate against {dataset}_schema.json
  - All required fields MUST be present
  - All enum values MUST be valid
```

### 9.3 Compilation Validation

```
For each contract file:
  - MUST compile with specified solidity_version
  - code_metadata.compilation_verified MUST be true
```

### 9.4 Referential Integrity

```
For adversarial_contrastive:
  - transformation.source_id MUST reference existing sample
  - group_id MUST exist in groups/groups.json
  - All IDs in groups.json MUST exist as samples
```

### 9.5 Consistency Validation

```
For each sample:
  - index.json entry.is_vulnerable MUST match metadata.ground_truth.is_vulnerable
  - index.json entry.vulnerability_type MUST match metadata.ground_truth.vulnerability_type
  - contract_names in metadata MUST match actual contract names in .sol file
```

---

## 10. Implementation Checklist

### 10.1 Initial Setup

- [ ] Create top-level `benchmark/` directory
- [ ] Create `schema/` directory with all JSON schema files
- [ ] Create subdirectory for each dataset
- [ ] Create `contracts/` and `metadata/` subdirectories in each

### 10.2 Per Dataset

- [ ] Create `index.json` with proper schema
- [ ] Ensure all samples listed in index
- [ ] Ensure all referenced files exist
- [ ] Validate all metadata against schema
- [ ] Verify all contracts compile
- [ ] Update statistics in index

### 10.3 For Adversarial Contrastive

- [ ] Create `groups/groups.json`
- [ ] Ensure all group_ids are valid
- [ ] Ensure all variants reference correct source_id
- [ ] Verify vulnerability_preserved field is accurate

### 10.4 Validation Script

Create a validation script that:

- [ ] Loads each index.json
- [ ] Validates all metadata files against schema
- [ ] Checks file existence
- [ ] Verifies referential integrity
- [ ] Attempts compilation of all contracts
- [ ] Reports any errors

---

## Appendix A: Quick Reference

### A.1 ID Prefixes

| Dataset                 | Prefix |
| ----------------------- | ------ |
| Gold Standard           | `gs_`  |
| Difficulty Stratified   | `ds_`  |
| Temporal Contamination  | `tc_`  |
| Adversarial Contrastive | `ac_`  |

### A.2 Required Files Per Sample

| File          | Location                       |
| ------------- | ------------------------------ |
| Solidity code | `{dataset}/contracts/{id}.sol` |
| Metadata      | `{dataset}/metadata/{id}.json` |

### A.3 Key Paths

```
benchmark/
├── {dataset}/index.json           # Dataset summary
├── {dataset}/contracts/{id}.sol   # Solidity files
├── {dataset}/metadata/{id}.json   # Metadata files
└── adversarial_contrastive/groups/groups.json  # Groupings
```

---

**Document Version:** 1.0  
**Status:** Ready for Implementation
