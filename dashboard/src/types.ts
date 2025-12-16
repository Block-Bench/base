// Dataset types - now includes all data folders
export type DatasetType =
  | 'base'
  | 'annotated'
  | 'sanitized'
  | 'nocomments'
  | 'chameleon'
  | 'mirror'
  | 'crossdomain'
  | 'guardianshield'
  | 'hydra'

export type ViewMode = 'base' | 'annotated'

// Subset types within a dataset
export type SubsetType = 'difficulty_stratified' | 'temporal_contamination' | 'gold_standard' | 'all'

// Base sample from index.json
export interface IndexSample {
  id: string
  contract_file: string
  metadata_file: string
  original_subset?: string
  is_vulnerable: boolean
  vulnerability_type: string | null
  severity: string | null
  // Difficulty stratified specific
  difficulty_tier?: number
  difficulty_tier_name?: string
  language?: string
  // Temporal contamination specific
  protocol_name?: string
  exploit_date?: string
  funds_lost_usd?: number
  chain?: string
  // Gold standard specific
  source_platform?: string
  finding_title?: string
}

// Full metadata from metadata/*.json
export interface SampleMetadata {
  id: string
  contract_file: string
  subset: string
  ground_truth: {
    is_vulnerable: boolean
    vulnerability_type: string | null
    severity: string | null
    vulnerable_location: {
      contract_name: string
      function_name: string | null
      line_numbers: number[]
    } | null
    root_cause: string | null
    attack_vector: string | null
    impact: string | null
    correct_fix: string | null
  }
  provenance: {
    source: string
    original_id: string | null
    url: string | null
    date_discovered: string | null
    date_added: string
    added_by: string | null
  }
  code_metadata: {
    solidity_version: string
    num_lines: number
    num_contracts: number
    contract_names: string[]
    num_functions: number
    has_imports: boolean
    has_inheritance: boolean
    has_modifiers: boolean
    has_events: boolean
    has_assembly: boolean
    compilation_verified: boolean
  }
  tags: string[]
  notes: string | null
  // Difficulty stratified fields
  difficulty_fields?: {
    difficulty_tier: number
    difficulty_tier_name: string
    complexity_analysis: {
      complexity_factors: string[]
      detection_hints: string | null
      detection_challenges: string | null
    }
    canonical_example: boolean
  }
  // Temporal contamination fields
  temporal_fields?: {
    temporal_split: {
      split: string
      cutoff_date: string
      model_cutoffs: Record<string, string>
    }
    exploit_info: {
      exploit_date: string | null
      protocol_name: string
      chain: string
      funds_lost_usd: number
    }
    public_exposure: {
      news_coverage: boolean
      twitter_viral: boolean
      likely_in_training: boolean
      exposure_notes: string | null
    }
  }
  // Gold standard fields
  gold_standard_fields?: {
    source_platform: string
    audit_date: string
    finding_title: string
    context_level: string
    has_context: boolean
  }
  evaluation_support: {
    annotated_contract: string
    detailed_metadata: string
    original_id?: string
    original_exploit_name?: string
  }
}

// Dataset composition info
export interface DatasetComposition {
  [key: string]: {
    prefix: string
    description: string
    count: number
  }
}

// Dataset index
export interface DatasetIndex {
  dataset_name: string
  version: string
  created_date: string
  last_updated: string
  description: string
  composition?: DatasetComposition
  statistics: {
    total_samples: number
    vulnerable_count: number
    safe_count: number
    by_vulnerability_type: Record<string, number>
    by_severity: Record<string, number>
    by_source?: Record<string, number>
    by_original_subset?: Record<string, number>
    // Difficulty stratified
    by_tier?: Record<string, number>
    by_tier_name?: Record<string, number>
    by_language?: Record<string, number>
    // Temporal contamination
    pre_cutoff_count?: number
    post_cutoff_count?: number
    by_chain?: Record<string, number>
    total_funds_lost_usd?: number
  }
  samples: IndexSample[]
}

// Combined sample with code content
export interface FullSample extends IndexSample {
  code: string
  metadata: SampleMetadata
}

// Summary for landing page
export interface DatasetSummary {
  total: number
  by_vulnerability_type: Record<string, number>
  by_severity: Record<string, number>
  by_tier?: Record<string, number>
  by_language?: Record<string, number>
  by_chain?: Record<string, number>
  total_funds_lost_usd?: number
}

// Available datasets config
export interface DatasetConfig {
  id: DatasetType
  name: string
  description: string
  icon: string
  isTransformed?: boolean
  sampleCount?: number
}
