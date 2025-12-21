import type {
  DatasetType,
  DatasetIndex,
  IndexSample,
  SampleMetadata,
  FullSample,
  DatasetConfig,
  SubsetType
} from '../types'

// Base paths for data
const DATA_BASE = `${import.meta.env.BASE_URL}data`.replace(/\/\//g, '/')

// Cache for loaded data
const indexCache: Map<string, DatasetIndex> = new Map()
const metadataCache: Map<string, SampleMetadata> = new Map()
const codeCache: Map<string, string> = new Map()

// Available datasets configuration
export const DATASETS: DatasetConfig[] = [
  {
    id: 'base',
    name: 'Base Dataset',
    description: '319 vulnerable smart contracts from all sources',
    icon: 'database',
    sampleCount: 319,
  },
  {
    id: 'annotated',
    name: 'Annotated Dataset',
    description: 'Rich vulnerability annotations with line locations',
    icon: 'tag',
    sampleCount: 319,
  },
  {
    id: 'sanitized',
    name: 'Sanitized',
    description: 'Vulnerability hints removed from identifiers',
    icon: 'eraser',
    isTransformed: true,
  },
  {
    id: 'nocomments',
    name: 'No Comments',
    description: 'All comments stripped from code',
    icon: 'message-slash',
    isTransformed: true,
  },
  {
    id: 'chameleon',
    name: 'Chameleon',
    description: 'Themed identifier renaming (gaming, medical, etc.)',
    icon: 'palette',
    isTransformed: true,
  },
  {
    id: 'mirror',
    name: 'Mirror',
    description: 'Different code formatting styles',
    icon: 'flip-horizontal',
    isTransformed: true,
  },
]

// Transform datasets (strategies applied)
export const TRANSFORM_DATASETS: DatasetConfig[] = [
  {
    id: 'sanitized',
    name: 'Sanitized',
    description: 'Vulnerability hints removed from identifiers',
    icon: 'eraser',
    isTransformed: true,
  },
  {
    id: 'nocomments',
    name: 'No Comments',
    description: 'All comments stripped from code',
    icon: 'message-slash',
    isTransformed: true,
  },
  {
    id: 'chameleon',
    name: 'Chameleon',
    description: 'Themed identifier renaming',
    icon: 'palette',
    isTransformed: true,
  },
  {
    id: 'mirror',
    name: 'Mirror',
    description: 'Different formatting styles',
    icon: 'flip-horizontal',
    isTransformed: true,
  },
  {
    id: 'crossdomain',
    name: 'Cross Domain',
    description: 'Cross-domain transformations',
    icon: 'globe',
    isTransformed: true,
  },
  {
    id: 'guardianshield',
    name: 'Guardian Shield',
    description: 'Protective patterns inserted',
    icon: 'shield',
    isTransformed: true,
  },
  {
    id: 'hydra',
    name: 'Hydra',
    description: 'Multi-headed transformations',
    icon: 'git-branch',
    isTransformed: true,
  },
]

// Load dataset index
export async function loadDatasetIndex(
  datasetType: DatasetType
): Promise<DatasetIndex | null> {
  const cacheKey = datasetType

  if (indexCache.has(cacheKey)) {
    console.log(`[Loader] Cache hit for ${datasetType}`)
    return indexCache.get(cacheKey)!
  }

  try {
    const indexPath = `${DATA_BASE}/${datasetType}/index.json`
    console.log(`[Loader] Fetching ${indexPath}`)
    const response = await fetch(indexPath)

    if (!response.ok) {
      console.warn(`[Loader] Index not found for ${datasetType}, status: ${response.status}`)
      return null
    }

    const index: DatasetIndex = await response.json()
    console.log(`[Loader] Loaded ${index.statistics?.total_samples || 0} samples for ${datasetType}`)
    indexCache.set(cacheKey, index)
    return index
  } catch (error) {
    console.error(`[Loader] Error loading dataset index for ${datasetType}:`, error)
    return null
  }
}

// Load sample metadata
export async function loadSampleMetadata(
  datasetType: DatasetType,
  sampleId: string
): Promise<SampleMetadata | null> {
  const cacheKey = `${datasetType}:${sampleId}:meta`

  if (metadataCache.has(cacheKey)) {
    return metadataCache.get(cacheKey)!
  }

  try {
    const metaPath = `${DATA_BASE}/${datasetType}/metadata/${sampleId}.json`
    const response = await fetch(metaPath)

    if (!response.ok) {
      console.warn(`Metadata not found: ${metaPath}`)
      return null
    }

    const metadata: SampleMetadata = await response.json()
    metadataCache.set(cacheKey, metadata)
    return metadata
  } catch (error) {
    console.error(`Error loading metadata for ${sampleId}:`, error)
    return null
  }
}

// Load sample code
export async function loadSampleCode(
  datasetType: DatasetType,
  sampleId: string
): Promise<string | null> {
  const cacheKey = `${datasetType}:${sampleId}:code`

  if (codeCache.has(cacheKey)) {
    return codeCache.get(cacheKey)!
  }

  // Try different extensions
  const extensions = ['.sol', '.rs']

  for (const extension of extensions) {
    try {
      const codePath = `${DATA_BASE}/${datasetType}/contracts/${sampleId}${extension}`
      const response = await fetch(codePath)

      if (response.ok) {
        const code = await response.text()
        // Vite returns HTML for 404s in dev mode
        if (code.startsWith('<!DOCTYPE') || code.startsWith('<html')) {
          continue
        }
        codeCache.set(cacheKey, code)
        return code
      }
    } catch {
      continue
    }
  }

  console.warn(`Could not load code for ${sampleId} in ${datasetType}`)
  return null
}

// Load full sample with metadata and code
export async function loadFullSample(
  datasetType: DatasetType,
  sampleId: string
): Promise<FullSample | null> {
  const [index, metadata, code] = await Promise.all([
    loadDatasetIndex(datasetType),
    loadSampleMetadata(datasetType, sampleId),
    loadSampleCode(datasetType, sampleId),
  ])

  if (!index || !code) {
    console.warn(`Missing index or code for ${sampleId}`)
    return null
  }

  const indexSample = index.samples.find(s => s.id === sampleId)
  if (!indexSample) {
    console.warn(`Sample ${sampleId} not found in index`)
    return null
  }

  // Create a default metadata if not available
  const safeMetadata = metadata || createDefaultMetadata(indexSample)

  return {
    ...indexSample,
    code,
    metadata: safeMetadata,
  }
}

// Create default metadata from index sample
function createDefaultMetadata(sample: IndexSample): SampleMetadata {
  return {
    id: sample.id,
    contract_file: sample.contract_file,
    subset: sample.original_subset || 'unknown',
    ground_truth: {
      is_vulnerable: sample.is_vulnerable,
      vulnerability_type: sample.vulnerability_type,
      severity: sample.severity,
      vulnerable_location: null,
      root_cause: null,
      attack_vector: null,
      impact: null,
      correct_fix: null,
    },
    provenance: {
      source: 'unknown',
      original_id: null,
      url: null,
      date_discovered: null,
      date_added: new Date().toISOString().split('T')[0],
      added_by: null,
    },
    code_metadata: {
      solidity_version: '^0.8.0',
      num_lines: 0,
      num_contracts: 1,
      contract_names: [],
      num_functions: 0,
      has_imports: false,
      has_inheritance: false,
      has_modifiers: false,
      has_events: false,
      has_assembly: false,
      compilation_verified: false,
    },
    tags: [],
    notes: null,
    evaluation_support: {
      annotated_contract: '',
      detailed_metadata: '',
    },
  }
}

// Load all samples for a dataset (just index info, not full content)
export async function loadDatasetSamples(
  datasetType: DatasetType
): Promise<IndexSample[]> {
  const index = await loadDatasetIndex(datasetType)
  return index?.samples || []
}

// Filter samples by subset
export function filterBySubset(
  samples: IndexSample[],
  subset: SubsetType
): IndexSample[] {
  if (subset === 'all') return samples

  const prefixMap: Record<SubsetType, string> = {
    difficulty_stratified: 'ds_',
    temporal_contamination: 'tc_',
    gold_standard: 'gs_',
    all: '',
  }

  const prefix = prefixMap[subset]
  return samples.filter(s => s.id?.startsWith(prefix))
}

// Filter samples
export function filterSamples(
  samples: IndexSample[],
  filters: {
    language?: string
    tier?: number
    severity?: string
    type?: string
    chain?: string
    search?: string
    subset?: SubsetType
  }
): IndexSample[] {
  return samples.filter(sample => {
    // Skip samples without ID
    if (!sample.id) return false

    // Subset filter
    if (filters.subset && filters.subset !== 'all') {
      const prefixMap: Record<string, string> = {
        difficulty_stratified: 'ds_',
        temporal_contamination: 'tc_',
        gold_standard: 'gs_',
      }
      const prefix = prefixMap[filters.subset]
      if (prefix && !sample.id.startsWith(prefix)) return false
    }

    if (filters.language && sample.language !== filters.language) return false
    if (filters.tier && sample.difficulty_tier !== filters.tier) return false
    if (filters.severity && sample.severity !== filters.severity) return false
    if (filters.type && sample.vulnerability_type !== filters.type) return false
    if (filters.chain && (sample as any).chain !== filters.chain) return false

    if (filters.search) {
      const searchLower = filters.search.toLowerCase()
      const searchFields = [
        sample.id,
        sample.vulnerability_type,
        sample.protocol_name,
        sample.finding_title,
        sample.original_subset,
      ].filter(Boolean).map(s => s!.toLowerCase())

      return searchFields.some(field => field.includes(searchLower))
    }

    return true
  })
}

// Get unique values for filters
export function getFilterOptions(samples: IndexSample[]): {
  languages: string[]
  tiers: number[]
  severities: string[]
  types: string[]
  chains: string[]
  subsets: string[]
} {
  return {
    languages: [...new Set(samples.map(s => s.language).filter(Boolean))] as string[],
    tiers: [...new Set(samples.map(s => s.difficulty_tier).filter(Boolean))].sort((a, b) => a! - b!) as number[],
    severities: [...new Set(samples.map(s => s.severity).filter(Boolean))] as string[],
    types: [...new Set(samples.map(s => s.vulnerability_type).filter(Boolean))] as string[],
    chains: [...new Set(samples.map(s => (s as any).chain).filter(Boolean))] as string[],
    subsets: [...new Set(samples.map(s => s.original_subset).filter(Boolean))] as string[],
  }
}

// Format currency
export function formatCurrency(value: number): string {
  if (value >= 1e9) return `$${(value / 1e9).toFixed(1)}B`
  if (value >= 1e6) return `$${(value / 1e6).toFixed(0)}M`
  if (value >= 1e3) return `$${(value / 1e3).toFixed(0)}K`
  return `$${value}`
}

// Get language from file extension or sample
export function getLanguage(sample: IndexSample | FullSample): string {
  if (sample.language) return sample.language
  if (sample.contract_file?.endsWith('.rs')) return 'rust'
  return 'solidity'
}

// Get subset display name
export function getSubsetDisplayName(subset: string): string {
  const names: Record<string, string> = {
    difficulty_stratified: 'Difficulty Stratified',
    temporal_contamination: 'Temporal Contamination',
    gold_standard: 'Gold Standard',
  }
  return names[subset] || subset
}

// Get severity color class
export function getSeverityClass(severity: string | null): string {
  const classes: Record<string, string> = {
    critical: 'bg-neutral-900 text-white dark:bg-white dark:text-neutral-900',
    high: 'bg-neutral-700 text-white dark:bg-neutral-300 dark:text-neutral-900',
    medium: 'bg-neutral-400 text-white dark:bg-neutral-500 dark:text-white',
    low: 'bg-neutral-200 text-neutral-700 dark:bg-neutral-700 dark:text-neutral-300',
  }
  return classes[severity || ''] || 'badge-neutral'
}
