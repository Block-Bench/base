import type { VulnerabilitySample, DatasetSummary } from '../types';

const DATASET_URL = '/dataset/difficulty_stratified_master.json';

let cachedData: VulnerabilitySample[] | null = null;

export async function loadDataset(): Promise<VulnerabilitySample[]> {
  if (cachedData) return cachedData;

  try {
    const response = await fetch(DATASET_URL);
    if (!response.ok) throw new Error('Failed to load dataset');
    cachedData = await response.json();
    return cachedData;
  } catch (error) {
    console.error('Error loading dataset:', error);
    return [];
  }
}

export function generateSummary(data: VulnerabilitySample[]): DatasetSummary {
  const summary: DatasetSummary = {
    total: data.length,
    by_language: {},
    by_tier: {},
    by_severity: {},
    by_type: {},
  };

  data.forEach(sample => {
    // Language
    summary.by_language[sample.language] = (summary.by_language[sample.language] || 0) + 1;

    // Tier
    summary.by_tier[sample.difficulty_tier] = (summary.by_tier[sample.difficulty_tier] || 0) + 1;

    // Severity
    summary.by_severity[sample.severity] = (summary.by_severity[sample.severity] || 0) + 1;

    // Type
    summary.by_type[sample.vulnerability_type] = (summary.by_type[sample.vulnerability_type] || 0) + 1;
  });

  return summary;
}

export function filterSamples(
  data: VulnerabilitySample[],
  filters: {
    language?: string;
    tier?: number;
    severity?: string;
    type?: string;
    search?: string;
  }
): VulnerabilitySample[] {
  return data.filter(sample => {
    if (filters.language && sample.language !== filters.language) return false;
    if (filters.tier && sample.difficulty_tier !== filters.tier) return false;
    if (filters.severity && sample.severity !== filters.severity) return false;
    if (filters.type && sample.vulnerability_type !== filters.type) return false;
    if (filters.search) {
      const searchLower = filters.search.toLowerCase();
      return (
        sample.id.toLowerCase().includes(searchLower) ||
        sample.vulnerability_type.toLowerCase().includes(searchLower) ||
        sample.description.toLowerCase().includes(searchLower)
      );
    }
    return true;
  });
}
