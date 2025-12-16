import type {
  DatasetType,
  ViewMode,
  DatasetIndex,
  IndexSample,
  SampleMetadata,
  FullSample,
  DatasetConfig
} from '../types';

// Base paths for data
const DATA_BASE = '/data';
const LABELLED_BASE = '/labelled_data';

// Cache for loaded data
const indexCache: Map<string, DatasetIndex> = new Map();
const metadataCache: Map<string, SampleMetadata> = new Map();
const codeCache: Map<string, string> = new Map();

// Available datasets configuration
export const DATASETS: DatasetConfig[] = [
  {
    id: 'difficulty_stratified',
    name: 'Difficulty Stratified',
    description: '235 samples across 4 difficulty tiers',
    icon: 'layers',
    sampleCount: 235,
  },
  {
    id: 'temporal_contamination',
    name: 'Temporal Contamination',
    description: '50 famous pre-cutoff DeFi exploits',
    icon: 'clock',
    sampleCount: 50,
  },
];

// Get base path based on view mode
function getBasePath(viewMode: ViewMode): string {
  return viewMode === 'data' ? DATA_BASE : LABELLED_BASE;
}

// Load dataset index
export async function loadDatasetIndex(
  datasetType: DatasetType,
  viewMode: ViewMode = 'data'
): Promise<DatasetIndex | null> {
  const basePath = getBasePath(viewMode);
  const cacheKey = `${viewMode}:${datasetType}`;

  if (indexCache.has(cacheKey)) {
    return indexCache.get(cacheKey)!;
  }

  try {
    // For labelled_data, we don't have index.json, so we use data's index
    const indexPath = viewMode === 'data'
      ? `${basePath}/${datasetType}/index.json`
      : `${DATA_BASE}/${datasetType}/index.json`;

    const response = await fetch(indexPath);
    if (!response.ok) throw new Error(`Failed to load index: ${response.status}`);

    const index: DatasetIndex = await response.json();
    indexCache.set(cacheKey, index);
    return index;
  } catch (error) {
    console.error(`Error loading dataset index for ${datasetType}:`, error);
    return null;
  }
}

// Load sample metadata
export async function loadSampleMetadata(
  datasetType: DatasetType,
  sampleId: string,
  viewMode: ViewMode = 'data'
): Promise<SampleMetadata | null> {
  const basePath = getBasePath(viewMode);
  const cacheKey = `${viewMode}:${datasetType}:${sampleId}:meta`;

  if (metadataCache.has(cacheKey)) {
    return metadataCache.get(cacheKey)!;
  }

  try {
    const metaPath = `${basePath}/${datasetType}/metadata/${sampleId}.json`;
    const response = await fetch(metaPath);
    if (!response.ok) throw new Error(`Failed to load metadata: ${response.status}`);

    const metadata: SampleMetadata = await response.json();
    metadataCache.set(cacheKey, metadata);
    return metadata;
  } catch (error) {
    console.error(`Error loading metadata for ${sampleId}:`, error);
    return null;
  }
}

// Load sample code
export async function loadSampleCode(
  datasetType: DatasetType,
  sampleId: string,
  viewMode: ViewMode = 'data'
): Promise<string | null> {
  const basePath = getBasePath(viewMode);
  const cacheKey = `${viewMode}:${datasetType}:${sampleId}:code`;

  if (codeCache.has(cacheKey)) {
    return codeCache.get(cacheKey)!;
  }

  // Try both .sol and .rs
  const extensions = ['.sol', '.rs'];

  for (const extension of extensions) {
    try {
      const codePath = `${basePath}/${datasetType}/contracts/${sampleId}${extension}`;
      const response = await fetch(codePath);
      if (response.ok) {
        const code = await response.text();
        // Vite returns HTML for 404s in dev mode, so check content
        if (code.startsWith('<!DOCTYPE') || code.startsWith('<html')) {
          continue;
        }
        codeCache.set(cacheKey, code);
        return code;
      }
    } catch {
      continue;
    }
  }

  console.error(`Could not load code for ${sampleId}`);
  return null;
}

// Load full sample with metadata and code
export async function loadFullSample(
  datasetType: DatasetType,
  sampleId: string,
  viewMode: ViewMode = 'data'
): Promise<FullSample | null> {
  const [index, metadata, code] = await Promise.all([
    loadDatasetIndex(datasetType, 'data'), // Always use data index for sample info
    loadSampleMetadata(datasetType, sampleId, viewMode),
    loadSampleCode(datasetType, sampleId, viewMode),
  ]);

  if (!index || !metadata || !code) return null;

  const indexSample = index.samples.find(s => s.id === sampleId);
  if (!indexSample) return null;

  return {
    ...indexSample,
    code,
    metadata,
  };
}

// Load all samples for a dataset (just index info, not full content)
export async function loadDatasetSamples(
  datasetType: DatasetType
): Promise<IndexSample[]> {
  const index = await loadDatasetIndex(datasetType, 'data');
  return index?.samples || [];
}

// Filter samples
export function filterSamples(
  samples: IndexSample[],
  filters: {
    language?: string;
    tier?: number;
    severity?: string;
    type?: string;
    chain?: string;
    search?: string;
  }
): IndexSample[] {
  return samples.filter(sample => {
    if (filters.language && sample.language !== filters.language) return false;
    if (filters.tier && sample.difficulty_tier !== filters.tier) return false;
    if (filters.severity && sample.severity !== filters.severity) return false;
    if (filters.type && sample.vulnerability_type !== filters.type) return false;
    if (filters.search) {
      const searchLower = filters.search.toLowerCase();
      const searchFields = [
        sample.id,
        sample.vulnerability_type,
        sample.protocol_name,
      ].filter(Boolean).map(s => s!.toLowerCase());

      return searchFields.some(field => field.includes(searchLower));
    }
    return true;
  });
}

// Get unique values for filters
export function getFilterOptions(samples: IndexSample[]): {
  languages: string[];
  tiers: number[];
  severities: string[];
  types: string[];
  chains: string[];
} {
  return {
    languages: [...new Set(samples.map(s => s.language).filter(Boolean))] as string[],
    tiers: [...new Set(samples.map(s => s.difficulty_tier).filter(Boolean))] as number[],
    severities: [...new Set(samples.map(s => s.severity).filter(Boolean))] as string[],
    types: [...new Set(samples.map(s => s.vulnerability_type).filter(Boolean))] as string[],
    chains: [...new Set(samples.map(s => (s as any).chain).filter(Boolean))] as string[],
  };
}

// Format currency
export function formatCurrency(value: number): string {
  if (value >= 1e9) return `$${(value / 1e9).toFixed(1)}B`;
  if (value >= 1e6) return `$${(value / 1e6).toFixed(0)}M`;
  if (value >= 1e3) return `$${(value / 1e3).toFixed(0)}K`;
  return `$${value}`;
}

// Get language from file extension or sample
export function getLanguage(sample: IndexSample | FullSample): string {
  if (sample.language) return sample.language;
  if (sample.contract_file?.endsWith('.rs')) return 'rust';
  return 'solidity';
}
