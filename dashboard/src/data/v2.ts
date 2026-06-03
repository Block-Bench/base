// Data layer for BlockBench dashboard v2.
// Loads static JSON bundles produced by scripts/build_dashboard_data.py
// served from /data/v2/.

const BASE = `${import.meta.env.BASE_URL.replace(/\/$/, '')}/data/v2`

/* ────────────────────────────────────────────────────────────────────
   Types
   ──────────────────────────────────────────────────────────────────── */

export type Subset = 'gs' | 'ds' | 'tc' | 'negative'
export type Severity = 'high' | 'medium' | 'low' | 'unknown'

export interface Manifest {
  version: string
  paper: { title: string; venue: string }
  counts: {
    gs: number; ds: number; tc: number; negative: number
    models: number; judges: number; tc_variants: number
    detection_bundles: number; judge_bundles: number; traditional_bundles: number
  }
  transformations: { id: string; label: string; kind: 'baseline' | 'realistic' | 'adversarial'; desc: string }[]
}

export interface ModelInfo {
  id: string
  display: string
  vendor: string
  color: string
  cite: string
}

export interface GsSample {
  id: string
  vuln_type: string
  severity: Severity | string
  title: string
  tier?: number | null
  source?: string
  blockchain?: string
  has_protocol_doc: boolean
  has_knowledge_doc: boolean
  loc: number
}

export interface DsSample {
  id: string; tier: string
  vuln_type: string; severity: string
  title: string; loc: number
}

export interface TcSample {
  id: string
  vuln_type: string; severity: string; title: string
  variants: string[]
  codeacts_variants: string[]
}

export interface NegSample {
  id: string; title: string; source: string; loc: number
}

export interface DatasetIndex<S> {
  subset: string; label: string; description: string
  count: number
  samples: S[]
  variants?: { id: string; label: string; kind: string; desc: string }[]
}

export interface DetectionResult {
  sample_id: string
  verdict: string | null
  confidence: number | null
  vulnerabilities: any[]
  ground_truth: any
  context_info: any
  api_metrics: any
  parsing: { success: boolean }
}

export interface DetectionBundle {
  model: string; subset: string; strategy: string
  results: DetectionResult[]
}

export interface JudgeResult {
  sample_id: string
  overall_verdict: { said_vulnerable?: boolean; confidence_expressed?: number } | null
  target_assessment: any
  findings: any[]
}

export interface JudgeBundle {
  judge: string; detector: string; subset: string; strategy: string
  results: JudgeResult[]
}

export interface TraditionalResult {
  sample_id: string; subset: string
  success: boolean; execution_time_ms: number
  finding_count: number; findings: any[]
}

export interface TraditionalBundle {
  tool: 'slither' | 'mythril' | string; subset: string
  results: TraditionalResult[]
}

export interface TdrRow {
  model: string; subset: string; strategy: string
  n: number; detected: number; tdr: number
}

/* ────────────────────────────────────────────────────────────────────
   Cache + fetch
   ──────────────────────────────────────────────────────────────────── */

const cache = new Map<string, unknown>()

async function getJSON<T>(path: string): Promise<T> {
  const url = `${BASE}${path}`
  if (cache.has(url)) return cache.get(url) as T
  const res = await fetch(url)
  if (!res.ok) throw new Error(`fetch ${url} -> ${res.status}`)
  const data = await res.json()
  cache.set(url, data)
  return data as T
}

async function getText(path: string): Promise<string> {
  const url = `${BASE}${path}`
  if (cache.has(url)) return cache.get(url) as string
  const res = await fetch(url)
  if (!res.ok) throw new Error(`fetch ${url} -> ${res.status}`)
  const text = await res.text()
  cache.set(url, text)
  return text
}

/* ────────────────────────────────────────────────────────────────────
   Public API
   ──────────────────────────────────────────────────────────────────── */

export const Data = {
  manifest: () => getJSON<Manifest>('/manifest.json'),
  models:   () => getJSON<ModelInfo[]>('/models/index.json'),
  judges:   () => getJSON<ModelInfo[]>('/models/judges.json'),

  gsIndex:  () => getJSON<DatasetIndex<GsSample>>('/datasets/gs/index.json'),
  dsIndex:  () => getJSON<DatasetIndex<DsSample>>('/datasets/ds/index.json'),
  tcIndex:  () => getJSON<DatasetIndex<TcSample>>('/datasets/tc/index.json'),
  negIndex: () => getJSON<DatasetIndex<NegSample>>('/datasets/negative/index.json'),

  gsContract: (id: string) => getText(`/datasets/gs/contracts/${id}.sol`),
  dsContract: (id: string) => getText(`/datasets/ds/contracts/${id}.sol`),
  tcContract: (id: string, variant: string) => getText(`/datasets/tc/variants/${variant}/${id}.sol`),
  negContract: (id: string) => getText(`/datasets/negative/contracts/${id}.sol`),

  gsMeta:  (id: string) => getJSON<any>(`/datasets/gs/metadata/${id}.json`).catch(() => null),
  dsMeta:  (id: string) => getJSON<any>(`/datasets/ds/metadata/${id}.json`).catch(() => null),
  tcMeta:  (id: string) => getJSON<any>(`/datasets/tc/metadata/${id}.json`).catch(() => null),
  negMeta: (id: string) => getJSON<any>(`/datasets/negative/metadata/${id}.json`).catch(() => null),

  gsContext: (id: string, kind: 'protocol' | 'knowledge') =>
    getText(`/datasets/gs/context/${id}.${kind}.${kind === 'protocol' ? 'txt' : 'md'}`).catch(() => ''),

  codeacts: (id: string) => getJSON<any>(`/datasets/tc/codeacts/${id}.json`).catch(() => null),

  detectionSummary: () => getJSON<any[]>('/results/detection/summary.json'),
  judgeSummary:     () => getJSON<any[]>('/results/judges/summary.json'),
  traditionalSummary: () => getJSON<any[]>('/results/traditional/summary.json'),

  detection:   (file: string) => getJSON<DetectionBundle>(`/results/detection/${file}`),
  judge:       (file: string) => getJSON<JudgeBundle>(`/results/judges/${file}`),
  traditional: (file: string) => getJSON<TraditionalBundle>(`/results/traditional/${file}`),

  tdrMatrix:        () => getJSON<TdrRow[]>('/aggregates/tdr_matrix.json'),
  fpRates:          () => getJSON<TdrRow[]>('/aggregates/fp_rates.json'),
  judgeAgreement:   () => getJSON<any[]>('/aggregates/judge_agreement.json'),
  temporalDecay:    () => getJSON<any[]>('/aggregates/temporal_decay.json'),
}

/* ────────────────────────────────────────────────────────────────────
   Helpers
   ──────────────────────────────────────────────────────────────────── */

export function severityClass(s: string | undefined | null): string {
  const v = (s || '').toLowerCase()
  if (v === 'high' || v === 'critical') return 'chip-severity-high'
  if (v === 'medium' || v === 'med') return 'chip-severity-med'
  if (v === 'low') return 'chip-severity-low'
  return 'chip'
}

export function formatPct(v: number | null | undefined, digits = 1): string {
  if (v == null || isNaN(v)) return '—'
  return `${(v * 100).toFixed(digits)}%`
}

export function formatNum(v: number | null | undefined): string {
  if (v == null || isNaN(v)) return '—'
  return v.toLocaleString()
}
