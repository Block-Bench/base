// Authoritative chart data from the paper (final numbers).
// Used by the home-page rich charts. Kept separate from the live /data/v2
// aggregates (which are an older snapshot).

export const COLLAPSE = {
  contaminated: 86.5, // DS — likely-contaminated
  postCutoff: 27.6, // GS — full post-cutoff set
  newest: 0.8, // GS — newest disclosed slice
};

export const EXPOSURE = { early: 5.9, late: 84.7 }; // same GS-Orig contracts, re-evaluated

// Figure 9 rebuild — Decoy Sensitivity Index vs ROOT_CAUSE Match Rate.
// Decoy Sensitivity Index = (MS_rate - TR_rate) / MS_rate  (drop when DECOY segments added).
export type ReliancePoint = {
  key: string;
  label: string;
  color: string;
  ci: number; // contamination index (%)
  rc: number; // ROOT_CAUSE match rate (%)
};

export const RELIANCE: ReliancePoint[] = [
  { key: "llama", label: "Llama 4 Maverick", color: "#0668E1", ci: 6.7, rc: 60.9 },
  { key: "gpt", label: "GPT-5.2", color: "#10A37F", ci: 14.8, rc: 50.0 },
  { key: "grok", label: "Grok 4.3", color: "#A1A1A1", ci: 16.7, rc: 32.6 },
  { key: "qwen", label: "Qwen3-Coder+", color: "#8b7bff", ci: 26.5, rc: 54.3 },
  { key: "gemini", label: "Gemini 3 Pro", color: "#4285F4", ci: 31.0, rc: 43.5 },
  { key: "deepseek", label: "DeepSeek v3.2", color: "#4D6BFE", ci: 33.3, rc: 56.5 },
  { key: "claude", label: "Claude Opus 4.5", color: "#D97757", ci: 36.6, rc: 56.5 },
];

export const RELIANCE_THRESHOLD = 25; // x >= 25 = high pattern reliance

// Transformation families (Figure 5 data) — avg TDR across models.
export const TRANSFORMS = [
  { key: "MinS", name: "MinSan", tier: "realistic", avg: 55.9 },
  { key: "San", name: "Sanitized", tier: "realistic", avg: 37.3 },
  { key: "NoC", name: "NoComment", tier: "realistic", avg: 34.5 },
  { key: "Cha", name: "Chameleon", tier: "adversarial", avg: 26.1 },
  { key: "Shp", name: "ShapeShifter", tier: "adversarial", avg: 26.7 },
  { key: "Tro", name: "Trojan", tier: "adversarial", avg: 33.5 },
  { key: "FalP", name: "FalseProphet", tier: "adversarial", avg: 34.8 },
];

export const PARADOX = { model: "Llama 4 Maverick", rootCause: 60.9, tdr: 31.7, gap: 29.2 };
