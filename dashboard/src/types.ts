export interface VulnerabilitySample {
  id: string;
  source_dataset: string;
  language: string;
  chain: string;
  file_name: string;
  file_content: string;
  vulnerable_function: string;
  vulnerable_lines: number[];
  vulnerability_type: string;
  severity: string;
  difficulty_tier: number;
  description: string;
  fix_description: string;
  is_vulnerable: boolean;
  has_poc?: boolean;
  has_remediation?: boolean;
  context_level: string;
  [key: string]: any;
}

export interface DatasetSummary {
  total: number;
  by_language: Record<string, number>;
  by_tier: Record<number, number>;
  by_severity: Record<string, number>;
  by_type: Record<string, number>;
}
