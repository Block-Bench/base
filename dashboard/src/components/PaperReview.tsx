import { useState } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import { ChevronDown, ChevronRight, X, PanelRightOpen } from 'lucide-react'
import Navigation from './Navigation'

const PDF_URL = import.meta.env.BASE_URL + '10562_Do_Frontier_LLMs_Truly_U.pdf#navpanes=0&scrollbar=1&view=FitH'

// --- Types ---
interface Score { label: string; value: number | string; max?: number }
interface Weakness { title: string; detail: string }
interface Response { title: string; content: string }
interface ReviewData {
  id: string; reviewer: string; date: string; modified: string
  role: 'meta' | 'reviewer'; scores: Score[]; recommendation: string
  summary: string; reasonsToPublish?: string[]; suggestedRevisions?: string[]
  strengths: string[]; weaknesses: Weakness[]; suggestions: string[]
  authorResponse: Response[]
  overallAssessment?: string; reportedIssues?: string; ethicsCompliance?: string
  ethics?: string; limitations?: string
  confidence?: string; reproducibility?: string; datasets?: string; software?: string
}

// --- Data ---
const DECISION = {
  status: 'Reject',
  detail: 'Borderline',
  date: '5 April 2026',
  venue: 'ACL 2026',
  cycle: 'ARR February 2026',
  submission: '10562',
  comment: 'Your submission was recognized as a borderline case, but given the high volume of similarly recommended papers, it could not be accommodated in the final program.',
  chairNote: {
    date: '4 February 2026',
    text: 'The limitation section should be separated from future work. This violation could result in a desk rejection. We are not desk-rejecting your submission because by examining the paper, we found that the future work content contains only one paragraph and can be fit into page 8, if a standalone limitation section is put on page 9. However, please kindly fix the issue in your revision.',
  },
}

const REVIEWS: ReviewData[] = [
  {
    id: 'nY22',
    reviewer: 'Area Chair nY22',
    date: '22 March 2026',
    modified: '6 April 2026',
    role: 'meta',
    scores: [
      { label: 'Rating', value: 5, max: 10 },
      { label: 'Confidence', value: 4, max: 5 },
    ],
    recommendation: 'Borderline Findings',
    summary: 'This paper addresses smart contract vulnerability understanding. Reviewer scores are consistently below threshold across all dimensions, and validly so. Basically, while the application area has practical relevance (and I appreciate it quite a bit), reviewers found significant limitations in the methodology and contribution to the NLP community. The work would benefit from substantial revision.',
    strengths: [], weaknesses: [], suggestions: [], authorResponse: [],
    overallAssessment: '5: Marginally below acceptance threshold',
    ethicsCompliance: 'I did not use any generative AI tools for this review',
  },
  {
    id: 'YyFW',
    reviewer: 'Area Chair YyFW',
    date: '6 March 2026',
    modified: '17 March 2026',
    role: 'meta',
    scores: [{ label: 'Overall', value: 3, max: 5 }],
    recommendation: 'Findings',
    summary: 'To evaluate whether LLMs can reason about vulnerabilities, or merely pattern-match against memorized exploits, they introduce BlockBench, a contamination-controlled benchmark. They reveal that best-case detection (86.5%) degrades sharply to just 25.3% on uncontaminated samples, suggesting possibilities of substantial surface pattern dependence.',
    reasonsToPublish: [
      'They have a clear research question: whether LLMs can reason about vulnerabilities, or merely pattern-match against memorized exploits.',
      'They also introduce BlockBench, which is a well designed benchmark along with human validation.',
      'They also evaluate seven models covering both open weight and closed weight models.',
      'The result is also interesting, suggesting surface pattern dependence.',
    ],
    suggestedRevisions: [
      'Limited post-cutoff sample size (GS n=34)',
      'Concerns about LLM-judge reliability (but reviewers analyzed the reliability)',
      'Missing a true negative sets. The benchmark is centered on vulnerable contracts and variants; without a substantial set of clean contracts, it is hard to assess false positives.',
      'Limited scope (only solidity smart contract) \u2192 But I think given Solidity\'s dominance in smart contracts, it\'s reasonable.',
    ],
    strengths: [], weaknesses: [], suggestions: [], authorResponse: [],
    overallAssessment: '3 = Findings: I think this paper could be accepted to the Findings of the ACL.',
    reportedIssues: 'No',
    ethicsCompliance: 'I did not use any generative AI tools for this review',
  },
  {
    id: 'ZECX',
    reviewer: 'Reviewer ZECX',
    date: '10 February 2026',
    modified: '17 March 2026',
    role: 'reviewer',
    scores: [
      { label: 'Soundness', value: 2, max: 5 },
      { label: 'Excitement', value: 2, max: 5 },
      { label: 'Overall', value: 2, max: 5 },
    ],
    recommendation: 'Resubmit next cycle',
    confidence: '3: Pretty sure, but there\'s a chance I missed something.',
    reproducibility: '3',
    datasets: '2: Documentary',
    software: '3: Potentially useful',
    summary: 'This paper investigates whether frontier LLMs truly understand smart contract vulnerabilities or largely rely on surface-level pattern recognition and memorized exploit templates. The authors introduce BlockBench, a contamination-controlled benchmark of 290 vulnerable Solidity contracts with 322 semantic-preserving transformation variants, designed to progressively remove recognition cues while preserving exploit semantics. They further propose CodeActs, a taxonomy that annotates code segments by security function to test whether models can identify causal mechanisms rather than merely highlighting suspicious tokens. Evaluating seven frontier models shows strong best-case performance on difficulty-stratified samples (up to 86.5% TDR) but sharp degradation under transformations and on a post-cutoff subset (down to 25.3% average TDR).',
    strengths: [
      'Well-motivated and carefully engineered evaluation targeting a real failure mode in LLM security analysis: contamination and superficial cue reliance.',
    ],
    weaknesses: [
      { title: 'Limited post-cutoff sample size (GS n=34)', detail: 'Conclusions about "true" generalization are directionally convincing but statistically fragile due to small n and wide CIs.' },
      { title: 'Reliance on LLM-as-judge', detail: 'Evaluation depends heavily on model-based grading, which can systematically mis-score nuanced security reasoning.' },
      { title: 'Ecological validity', detail: 'Detection setting appears largely single-contract and code-only. Real audits require protocol intent, invariants, cross-contract interactions.' },
      { title: 'Transformation realism', detail: 'Some transformations are excellent stress tests, but it\'s not always clear how frequently such conditions occur in practice.' },
      { title: 'Annotation scalability', detail: 'CodeActs is insightful but annotation is expensive; coverage is limited, which may limit generalizability.' },
    ],
    suggestions: [
      'Expand the post-cutoff GS set or provide repeated sampling/variance analysis.',
      'Report more details on judge failure modes; include more human-validated slices on GS.',
      'Add a "real audit" evaluation mode with multi-contract context and protocol intent.',
      'Categorize transformations into realistic perturbations vs adversarial stress tests.',
      'Outline a plan for semi-automated CodeActs annotation or provide inter-annotator agreement.',
    ],
    authorResponse: [
      { title: 'GS Size', content: 'We acknowledge n=34 appears small. However, this represents a substantial portion of high-severity vulnerabilities disclosed from top-tier protocols during our 4-month post-cutoff window. Bootstrap CIs are reported (Table 3). In revision, we will add variance analysis and frame GS results as indicative.' },
      { title: 'LLM-as-Judge', content: 'We use a 3-judge ensemble and validated reliability against 1,000 human-annotated stratified samples and 31 expert-reviewed cases (\u03BA=0.84). In revision, we will expand failure mode analysis and include GS-specific human validation.' },
      { title: 'Ecological Validity', content: 'BlockBench provides multi-file dependencies, protocol documentation, and intended behavior descriptions (Appendix H.2). The controlled scope is intentional \u2014 it isolates detection capability to test reasoning vs pattern-matching.' },
      { title: 'Transformation Realism', content: 'Production protocols often feature complex, dense code that shares characteristics with our transformations. In revision, we will categorize by transformation intensity and analyze separately.' },
      { title: 'CodeActs Scalability', content: 'We explored static analysis for pre-labeling, but existing tools exhibit high failure rates. In revision, we will report inter-annotator agreement and outline a hybrid annotation pipeline.' },
    ],
    ethicsCompliance: 'I did not use any generative AI tools for this review',
  },
  {
    id: 'e5XU',
    reviewer: 'Reviewer e5XU',
    date: '8 February 2026',
    modified: '17 March 2026',
    role: 'reviewer',
    scores: [
      { label: 'Soundness', value: 3.5, max: 5 },
      { label: 'Excitement', value: 3, max: 5 },
      { label: 'Overall', value: 2.5, max: 5 },
    ],
    recommendation: 'Borderline Findings',
    confidence: '3: Pretty sure, but there\'s a chance I missed something.',
    reproducibility: '4',
    datasets: '4: Useful',
    software: '4: Useful',
    summary: 'This paper introduces BlockBench, a benchmark designed to test whether frontier LLMs genuinely understand smart-contract vulnerabilities or are mainly pattern-matching/memorizing. BlockBench contains three subsets: DS (210 contracts), TC (46 contracts from real-world DeFi hacks), and a "contamination-controlled" GS subset (34 contracts). The authors create a transformation suite generating 322 variants and propose CodeActs, a line-level annotation scheme. The key finding is a sharp drop from "best-case" detection on DS (86.5%) to adversarial variants (50.9%) and to post-cutoff GS (25.3%).',
    strengths: [
      'Clear, well-motivated benchmark design for memorization vs. understanding. The DS/TC/GS split is conceptually useful.',
      'Thoughtful adversarial transformation suite. Trojan and False-Prophet are particularly good stress tests.',
      'CodeActs is a promising analysis lens. Separation of ROOT_CAUSE vs BENIGN/DECOY helps diagnose model behavior.',
      'Reproducibility intentions are strong. Anonymous release of benchmark data, variants, prompts, and evaluation scripts.',
    ],
    weaknesses: [
      { title: '"Zero contamination guarantee" is overstated', detail: 'Training data cutoffs are rarely precise/verified. Should use softer language and cite authoritative cutoff evidence per model.' },
      { title: 'GS is small (n=34)', detail: 'Headline "25.3%" is striking, but with 34 samples needs confidence intervals and per-category breakdowns.' },
      { title: 'Missing true negative set', detail: 'Without clean contracts, hard to assess false positives. Design would be stronger with non-derived negatives.' },
      { title: 'Transformations may conflate robustness with distribution shift', detail: 'Heavy semantic renaming or domain swapping can create artifacts not representative of real scenarios.' },
      { title: 'LLM-as-judge bias', detail: 'Judges share the same LLM priors as evaluated systems. Need more details on expert-validated cases.' },
      { title: 'Limited scope', detail: 'Solidity-only. Framing sometimes reads broader than evidence supports.' },
    ],
    suggestions: [
      'Replace "guarantees zero contamination" with "substantially reduces contamination risk".',
      'Include CIs for all metrics and significance tests (especially GS n=34).',
      'Add a clean-contract negative set to quantify false positives.',
      'Include Slither/Mythril baseline comparisons on BlockBench.',
      'Expand judge calibration details and error analysis.',
      'Standardize model naming (e.g., "MIMO v2" vs "MIMO-v2-Flash").',
      'Summarize prompt strategy differences in main text, not only appendix.',
      'Add a "Broader Impacts / Dual Use & Mitigations" paragraph.',
    ],
    authorResponse: [
      { title: 'Zero Contamination', content: 'We agree "guarantees" is too strong. We will soften to "substantially reduces contamination risk" and add model-specific cutoff citations.' },
      { title: 'GS Size', content: 'Bootstrap CIs are in Table 3. We will add per-category breakdowns, variance analysis, and clarify results as indicative.' },
      { title: 'True Negatives', content: 'Differential variants act as true negatives by providing patched versions (Sections 4.1, 5.6). Additional clean contracts planned as future work.' },
      { title: 'LLM-as-Judge', content: 'Judges evaluate outputs against ground-truth annotations. 3-judge ensemble with architectural diversity. Validated with 1,000 stratified samples + 31 expert-reviewed cases (\u03BA=0.84). Will analyze error modes by vulnerability type.' },
      { title: 'Baselines', content: 'We cite prior work reporting 27\u201342% detection rates with high false positives. Slither/Mythril detect some DS samples but perform poorly on TC and GS. Will include explicitly.' },
      { title: 'Minor Fixes', content: 'Will standardize model naming, expand prompt strategy summary, and expand ethics discussion.' },
    ],
    ethics: 'Potential dual-use risk and risk of overreliance by non-experts. Recommend adding a dedicated mitigations paragraph.',
    limitations: 'Societal/dual-use discussion is not sufficiently explicit. Releasing transformed exploit variants could lower barriers for malicious actors.',
    ethicsCompliance: 'I did not use any generative AI tools for this review',
  },
  {
    id: 'qS1T',
    reviewer: 'Reviewer qS1T',
    date: '4 February 2026',
    modified: '17 March 2026',
    role: 'reviewer',
    scores: [
      { label: 'Soundness', value: 3, max: 5 },
      { label: 'Excitement', value: 2.5, max: 5 },
      { label: 'Overall', value: 2.5, max: 5 },
    ],
    recommendation: 'Borderline Findings',
    confidence: '3: Pretty sure, but there\'s a chance I missed something.',
    reproducibility: '4',
    datasets: '3: Potentially useful',
    software: '3: Potentially useful',
    summary: 'This paper addresses a critical gap in evaluating whether frontier large language models genuinely understand smart contract vulnerabilities or merely rely on pattern matching against memorized exploit examples. The study introduces BlockBench, a contamination-controlled benchmark with semantic-preserving transformation variants, and proposes the CodeActs taxonomy to assess causal reasoning ability.',
    strengths: [
      'CodeActs taxonomy enables precise classification of code segments by security function.',
      'Comprehensive evaluation: seven LLMs, multiple prompt strategies, three-LLM judge ensemble with human validation.',
      'Composite SUI metric balances detection rate, reasoning quality, and precision.',
    ],
    weaknesses: [
      { title: 'Prompt mechanism analysis missing', detail: 'Does not delve into why certain prompts work better for specific models.' },
      { title: 'No hybrid pipeline experiments', detail: 'Mentions complementary strengths of LLMs and traditional tools but does not explore integration.' },
      { title: 'No model scaling/fine-tuning analysis', detail: 'Does not investigate how model size or domain-specific fine-tuning affects results.' },
      { title: 'Solidity-only scope', detail: 'No evaluation on contracts in other languages.' },
    ],
    suggestions: [
      'Conduct ablation studies on prompt components.',
      'Evaluate models with different sizes and fine-tuning strategies.',
      'Increase post-cutoff GS samples.',
      'Expand to other smart contract languages.',
    ],
    authorResponse: [
      { title: 'Prompts', content: 'Investigating prompt mechanisms requires deeper mechanistic analysis beyond current scope. Planned as future work.' },
      { title: 'Hybrid Pipelines', content: 'Slither/Mythril detected some DS samples but failed on most TC and GS. Systematic hybrid evaluation planned as future work.' },
      { title: 'Scaling', content: 'We evaluated closed-source flagship models from seven labs. Fine-tuning analysis requires open-weight model families \u2014 beyond current scope.' },
      { title: 'Solidity', content: 'Solidity dominates smart contract programming. Multi-language support planned as future work.' },
      { title: 'GS Size', content: 'Reflects genuine scarcity of major vulnerabilities in the 4-month post-cutoff window. We prioritized quality over inflating n.' },
    ],
    ethicsCompliance: 'I used a privacy-preserving tool exclusively for the use case(s) approved by PEC policy, such as language edits',
  },
]

const ACTION_ITEMS = [
  { label: 'Expand GS dataset with new post-cutoff findings', priority: 'must' as const, raised: ['ZECX', 'e5XU', 'qS1T', 'YyFW'] },
  { label: 'Separate Limitations from Future Work', priority: 'must' as const, raised: ['Chairs'] },
  { label: 'Soften "zero contamination" language', priority: 'must' as const, raised: ['e5XU'] },
  { label: 'Add true negative / clean contract set', priority: 'must' as const, raised: ['e5XU', 'YyFW'] },
  { label: 'Include Slither/Mythril baselines', priority: 'must' as const, raised: ['e5XU'] },
  { label: 'Expand LLM-judge failure mode analysis', priority: 'should' as const, raised: ['ZECX', 'e5XU', 'YyFW'] },
  { label: 'Categorize transformations by realism level', priority: 'should' as const, raised: ['ZECX', 'e5XU'] },
  { label: 'Add ethics / dual-use statement', priority: 'should' as const, raised: ['e5XU'] },
  { label: 'Report CodeActs inter-annotator agreement', priority: 'should' as const, raised: ['ZECX'] },
  { label: 'Summarize prompt strategies in main text', priority: 'should' as const, raised: ['e5XU'] },
  { label: 'Multi-language support', priority: 'later' as const, raised: ['e5XU', 'qS1T', 'YyFW'] },
  { label: 'Prompt ablation studies', priority: 'later' as const, raised: ['qS1T'] },
  { label: 'Model scaling / fine-tuning analysis', priority: 'later' as const, raised: ['qS1T'] },
]

interface WorkItem { task: string; detail: string }
interface WorkSection { title: string; description: string; items: WorkItem[] }

const WORK_PLAN: WorkSection[] = [
  {
    title: 'Data & Experiments',
    description: 'Blocking issues \u2014 without these, reviewers will give the same scores.',
    items: [
      { task: 'Expand Gold Standard (GS) to n=60\u201380', detail: 'Collect post-cutoff vulnerabilities from Code4rena, Sherlock, Spearbit, Immunefi (Jan\u2013Aug 2026). Maintain quality bar: high/medium severity from top-tier protocols only. Run all 7 models \u00D7 5 prompt strategies. Report per-category TDR with CIs.' },
      { task: 'Add true negative clean contract set (n=40\u201350)', detail: 'Curate audited contracts with no known vulnerabilities (OpenZeppelin, Uniswap v4, Aave v3 core). Not fixed/patched code \u2014 contracts that were never vulnerable. Measure false positive rate per model.' },
      { task: 'Run Slither/Mythril baselines on all subsets', detail: 'Run both tools on DS, TC, and GS. Report TDR, precision, FP rates using same metrics. Key finding: traditional tools detect some DS samples but fail on TC transformations and GS logic bugs.' },
      { task: 'Full expert validation on GS outputs', detail: 'Expert review of all GS model outputs (not just stratified sample). Report GS-specific \u03BA, error mode breakdown, judge failure clustering by vulnerability type.' },
    ],
  },
  {
    title: 'Strengthen NLP Framing',
    description: 'AC nY22 flagged "contribution to NLP community." This is the hidden blocker.',
    items: [
      { task: 'Reframe introduction as NLP-first', detail: 'Lead with the NLP problem (contamination, memorization vs generalization) not crypto losses. Position security as the demonstration domain, not the contribution.' },
      { task: 'Position contamination methodology as general-purpose', detail: 'The DS\u2192TC\u2192GS pipeline is a transferable method for measuring memorization in any domain. Connect to benchmark contamination literature (Dodge et al., Jacovi et al., Oren et al.).' },
      { task: 'Frame transformations as robustness probes', detail: 'Map to NLP adversarial robustness: Chameleon = domain transfer, ShapeShifter = syntactic paraphrase, NoComments = information removal, Trojan = distractor injection. The 30\u201350% drops tell us about LLM representations, not just security.' },
      { task: 'Connect pattern matching paradox to reasoning faithfulness', detail: 'Llama\u2019s 60.9% ROOT_CAUSE match but 31.7% TDR is about explanation faithfulness. Links to CoT faithfulness literature, reasoning shortcuts, and whether LLMs use the reasoning they produce.' },
      { task: 'Show prompt sensitivity only visible without contamination', detail: 'GS prompt results (0%\u219241.2%) reveal true prompt effects invisible on contaminated benchmarks. Implication: prompt engineering gains measured on contaminated data are overstated.' },
      { task: 'Discuss implications for other code benchmarks', detail: 'What does the 86.5%\u219225.3% curve imply for HumanEval, SWE-bench, and other code benchmarks likely contaminated in training data?' },
    ],
  },
  {
    title: 'Paper Revisions',
    description: 'Writing and framing changes addressing specific reviewer concerns.',
    items: [
      { task: 'Separate Limitations from Future Work', detail: 'Program Chairs nearly desk-rejected for this. Standalone Limitations section. Non-negotiable.' },
      { task: 'Soften contamination claims', detail: 'Replace "guarantees zero contamination" with "substantially reduces contamination risk." Add model-specific cutoff dates table. Frame GS as indicative.' },
      { task: 'Categorize transformations by realism', detail: 'Split into realistic perturbations (Sanitized, NoComments, MinSan) vs adversarial stress tests (Chameleon, ShapeShifter, Trojan, FalseProphet). Report and analyze separately.' },
      { task: 'Expand ethics / dual-use statement', detail: 'Broader Impacts paragraph: prevents overreliance (positive), exploit variants could lower barriers (negative), all vulns already public (mitigation). Address "security theater" concern.' },
      { task: 'Prompt strategy summary in main text', detail: 'Concise table summarizing Direct/Ctx/CoT/Nat/Adv. Brief explanation of why adversarial framing helps and why naturalistic works for Qwen.' },
      { task: 'CodeActs inter-annotator agreement', detail: 'Two annotators independently label 10\u201315 contracts. Report Cohen\u2019s \u03BA. Discuss disagreement patterns. Outline hybrid annotation pipeline.' },
      { task: 'Standardize model naming', detail: 'Audit all names in text, tables, appendix. Create model summary table with name, provider, cutoff date.' },
    ],
  },
  {
    title: 'Statistical & Polish',
    description: 'Tighten rigor and update context.',
    items: [
      { task: 'CIs for all metrics', detail: 'Bootstrap CIs for TDR, RCIR, AVA, FSV, SUI across all subsets \u2014 not just DS averages. Significance tests for prompt protocol improvements on expanded GS.' },
      { task: 'Tighten claims throughout', detail: 'Read through entire paper. Check every claim against evidence. Distinguish "suggestive" from "conclusive." Hedge where CIs are wide.' },
      { task: 'Update related work', detail: 'Add 2026 papers on LLM code reasoning, benchmark contamination, smart contract security benchmarks. Position against recent evaluation methodology work.' },
      { task: 'Per-category variance analysis on GS', detail: 'Break down GS results by vulnerability type (logic errors, access control, etc.). Show the degradation is consistent across categories, not driven by one type.' },
    ],
  },
  {
    title: 'Out of Scope (Future Work)',
    description: 'Acknowledge clearly as limitations. Do not attempt.',
    items: [
      { task: 'Multi-language support (Vyper, Rust/Anchor)', detail: 'Solidity dominance is justified. Acknowledge limitation, note as future work.' },
      { task: 'Prompt ablation / mechanistic analysis', detail: 'Why prompts work is a separate research question beyond evaluation scope.' },
      { task: 'Model scaling / fine-tuning analysis', detail: 'Requires open-weight model families at multiple sizes we don\u2019t have.' },
      { task: 'Full audit context evaluation', detail: 'Multi-contract, cross-protocol context is a separate benchmark design challenge.' },
      { task: 'Hybrid LLM-verification pipelines', detail: 'Interesting but expands scope beyond evaluation into system design.' },
    ],
  },
]

// --- Components ---

function ScoreDot({ value, max = 5 }: { value: number | string; max?: number }) {
  const n = typeof value === 'string' ? parseFloat(value) : value
  const dots = []
  for (let i = 1; i <= max; i++) {
    const fill = i <= Math.floor(n) ? 'full' : i - 0.5 <= n ? 'half' : 'empty'
    dots.push(
      <div key={i} className={`w-2 h-2 rounded-full ${
        fill === 'full' ? 'bg-stone-400 dark:bg-white'
        : fill === 'half' ? 'bg-neutral-400 dark:bg-neutral-500'
        : 'bg-neutral-200 dark:bg-neutral-800'
      }`} />
    )
  }
  return (
    <div className="flex items-center gap-2">
      <div className="flex gap-1">{dots}</div>
      <span className="text-xs font-mono text-neutral-400 dark:text-neutral-600">{value}</span>
    </div>
  )
}

function Section({ title, children, defaultOpen = false, count }: {
  title: string; children: React.ReactNode; defaultOpen?: boolean; count?: number
}) {
  const [open, setOpen] = useState(defaultOpen)
  return (
    <div>
      <button onClick={() => setOpen(!open)} className="w-full flex items-center gap-2 py-2 text-left group">
        {open
          ? <ChevronDown className="w-3.5 h-3.5 text-neutral-400" />
          : <ChevronRight className="w-3.5 h-3.5 text-neutral-400" />
        }
        <span className="text-xs font-medium uppercase tracking-wider text-neutral-400 dark:text-neutral-500 group-hover:text-neutral-600 dark:group-hover:text-neutral-400 transition-colors">
          {title}
        </span>
        {count !== undefined && (
          <span className="text-xs font-mono text-neutral-300 dark:text-neutral-700">{count}</span>
        )}
      </button>
      {open && <div className="pl-5 pb-2">{children}</div>}
    </div>
  )
}

function ReviewCard({ review }: { review: ReviewData }) {
  const isMeta = review.role === 'meta'
  return (
    <div className="card overflow-hidden">
      {/* Header */}
      <div className="px-6 py-5 flex items-start justify-between gap-4">
        <div>
          <div className="flex items-center gap-2.5 mb-1">
            {isMeta && (
              <span className="text-2xs font-medium uppercase tracking-wider text-accent">Meta</span>
            )}
            <h3 className="font-medium text-stone-600 dark:text-white">{review.reviewer}</h3>
          </div>
          <p className="text-xs text-neutral-400 dark:text-neutral-600">
            {review.date} {review.modified !== review.date && `\u00B7 modified ${review.modified}`}
          </p>
        </div>
        <span className={`text-xs font-medium px-2.5 py-1 rounded-lg shrink-0 ${
          review.recommendation === 'Resubmit next cycle'
            ? 'bg-red-50 text-red-600 dark:bg-red-950/40 dark:text-red-400'
            : review.recommendation === 'Findings'
              ? 'bg-emerald-50 text-emerald-600 dark:bg-emerald-950/40 dark:text-emerald-400'
              : 'bg-amber-50 text-amber-600 dark:bg-amber-950/40 dark:text-amber-400'
        }`}>
          {review.recommendation}
        </span>
      </div>

      {/* Scores */}
      {review.scores.length > 0 && (
        <div className="px-6 pb-4 flex flex-wrap gap-x-8 gap-y-2">
          {review.scores.map(s => (
            <div key={s.label} className="flex items-center gap-3">
              <span className="text-xs text-neutral-500 dark:text-neutral-500 w-20">{s.label}</span>
              <ScoreDot value={s.value} max={s.max} />
            </div>
          ))}
        </div>
      )}

      {/* Divider */}
      <div className="border-t border-neutral-100 dark:border-neutral-800/50" />

      {/* Body */}
      <div className="px-6 py-5 space-y-4">
        {/* Summary */}
        <p className="text-sm text-neutral-600 dark:text-neutral-400 leading-relaxed">{review.summary}</p>

        {/* Meta-review specific: Reasons to Publish */}
        {review.reasonsToPublish && review.reasonsToPublish.length > 0 && (
          <Section title="Reasons to Publish" count={review.reasonsToPublish.length} defaultOpen>
            <ul className="space-y-1.5">
              {review.reasonsToPublish.map((r, i) => (
                <li key={i} className="text-sm text-neutral-600 dark:text-neutral-400 flex gap-2">
                  <span className="text-emerald-500 shrink-0">+</span>{r}
                </li>
              ))}
            </ul>
          </Section>
        )}

        {/* Meta-review specific: Suggested Revisions */}
        {review.suggestedRevisions && review.suggestedRevisions.length > 0 && (
          <Section title="Suggested Revisions" count={review.suggestedRevisions.length} defaultOpen>
            <ul className="space-y-1.5">
              {review.suggestedRevisions.map((r, i) => (
                <li key={i} className="text-sm text-neutral-600 dark:text-neutral-400 flex gap-2">
                  <span className="text-amber-500 shrink-0">\u2022</span>{r}
                </li>
              ))}
            </ul>
          </Section>
        )}

        {/* Strengths */}
        {review.strengths.length > 0 && (
          <Section title="Strengths" count={review.strengths.length} defaultOpen>
            <ul className="space-y-1.5">
              {review.strengths.map((s, i) => (
                <li key={i} className="text-sm text-neutral-600 dark:text-neutral-400 flex gap-2">
                  <span className="text-emerald-500 shrink-0">+</span>{s}
                </li>
              ))}
            </ul>
          </Section>
        )}

        {/* Weaknesses */}
        {review.weaknesses.length > 0 && (
          <Section title="Weaknesses" count={review.weaknesses.length} defaultOpen>
            <div className="space-y-2.5">
              {review.weaknesses.map((w, i) => (
                <div key={i} className="text-sm">
                  <span className="font-medium text-stone-500 dark:text-neutral-200">{w.title}</span>
                  <span className="text-neutral-500 dark:text-neutral-500"> \u2014 {w.detail}</span>
                </div>
              ))}
            </div>
          </Section>
        )}

        {/* Suggestions */}
        {review.suggestions.length > 0 && (
          <Section title="Suggestions" count={review.suggestions.length}>
            <ol className="space-y-1.5 list-decimal list-inside marker:text-neutral-300 dark:marker:text-neutral-700">
              {review.suggestions.map((s, i) => (
                <li key={i} className="text-sm text-neutral-600 dark:text-neutral-400">{s}</li>
              ))}
            </ol>
          </Section>
        )}

        {/* Ethics */}
        {review.ethics && (
          <Section title="Ethics & Societal Impact">
            <p className="text-sm text-neutral-600 dark:text-neutral-400">{review.ethics}</p>
            {review.limitations && <p className="text-sm text-neutral-500 dark:text-neutral-500 mt-1.5">{review.limitations}</p>}
          </Section>
        )}

        {/* Additional metadata */}
        {(review.overallAssessment || review.reportedIssues || review.confidence || review.reproducibility) && (
          <Section title="Metadata" defaultOpen>
            <div className="space-y-1 text-xs text-neutral-500 dark:text-neutral-500">
              {review.overallAssessment && <p><span className="text-neutral-400">Overall Assessment:</span> {review.overallAssessment}</p>}
              {review.confidence && <p><span className="text-neutral-400">Confidence:</span> {review.confidence}</p>}
              {review.reproducibility && <p><span className="text-neutral-400">Reproducibility:</span> {review.reproducibility}</p>}
              {review.datasets && <p><span className="text-neutral-400">Datasets:</span> {review.datasets}</p>}
              {review.software && <p><span className="text-neutral-400">Software:</span> {review.software}</p>}
              {review.reportedIssues && <p><span className="text-neutral-400">Reported Issues:</span> {review.reportedIssues}</p>}
              {review.ethicsCompliance && <p><span className="text-neutral-400">Ethics Compliance:</span> {review.ethicsCompliance}</p>}
            </div>
          </Section>
        )}

        {/* Author Response */}
        {review.authorResponse.length > 0 && (
          <Section title="Author Response" count={review.authorResponse.length}>
            <div className="space-y-3">
              {review.authorResponse.map((r, i) => (
                <div key={i} className="pl-3 border-l-2 border-neutral-200 dark:border-neutral-800">
                  <p className="text-xs font-medium text-stone-600 dark:text-neutral-300 mb-0.5">{r.title}</p>
                  <p className="text-sm text-neutral-500 dark:text-neutral-500 leading-relaxed">{r.content}</p>
                </div>
              ))}
            </div>
          </Section>
        )}
      </div>
    </div>
  )
}

// --- Page ---
export default function PaperReview() {
  const location = useLocation()
  const navigate = useNavigate()
  const validTabs = ['reviews', 'actions', 'workplan'] as const
  type Tab = typeof validTabs[number]
  const params = new URLSearchParams(location.search)
  const paramTab = params.get('tab') as Tab | null
  const tab: Tab = paramTab && validTabs.includes(paramTab) ? paramTab : 'reviews'
  const setTab = (t: Tab) => navigate(`/review?tab=${t}`, { replace: true })
  const [showPdf, setShowPdf] = useState(false)
  const metas = REVIEWS.filter(r => r.role === 'meta')
  const reviewers = REVIEWS.filter(r => r.role === 'reviewer')

  const avgScore = (key: string) => {
    const vals = reviewers.flatMap(r => r.scores.filter(s => s.label === key).map(s => typeof s.value === 'string' ? parseFloat(s.value) : s.value))
    return vals.length ? (vals.reduce((a, b) => a + b, 0) / vals.length).toFixed(1) : '\u2014'
  }

  // Split view: reviews left, PDF right
  if (showPdf) {
    return (
      <div className="min-h-screen bg-stone-50 dark:bg-neutral-950">
        <Navigation />
        <div className="fixed top-14 left-0 right-0 bottom-0 flex">
          {/* Reviews panel - scrollable */}
          <div className="w-[420px] shrink-0 border-r border-stone-200/50 dark:border-neutral-800/50 bg-stone-50 dark:bg-neutral-950 overflow-y-auto scrollbar-thin">
            <div className="p-5">
              {/* Header */}
              <div className="flex items-center justify-between mb-5">
                <span className="text-xs font-medium text-stone-500 dark:text-neutral-400">Reviews</span>
                <button onClick={() => setShowPdf(false)} className="btn-ghost text-2xs py-1 px-2">
                  <X className="w-3 h-3" /> Close
                </button>
              </div>

              {/* Decision compact */}
              <div className="flex items-center gap-2 mb-4">
                <div className="w-2 h-2 rounded-full bg-red-500" />
                <span className="text-sm font-semibold text-stone-600 dark:text-white">{DECISION.status}</span>
                <span className="text-2xs font-medium text-amber-600 bg-amber-50 dark:bg-amber-950/30 dark:text-amber-400 px-1.5 py-0.5 rounded">{DECISION.detail}</span>
              </div>

              {/* Scores */}
              <div className="grid grid-cols-4 gap-2 mb-5">
                {[
                  { l: 'SND', v: avgScore('Soundness') },
                  { l: 'EXC', v: avgScore('Excitement') },
                  { l: 'OVR', v: avgScore('Overall') },
                  { l: 'REP', v: reviewers.length ? (reviewers.map(r => parseFloat(r.reproducibility || '0')).reduce((a,b) => a+b, 0) / reviewers.length).toFixed(1) : '\u2014' },
                ].map(s => (
                  <div key={s.l} className="text-center">
                    <div className="text-lg font-light font-mono text-stone-500 dark:text-white">{s.v}</div>
                    <div className="text-2xs text-stone-400 dark:text-neutral-600">{s.l}</div>
                  </div>
                ))}
              </div>

              {/* Tabs */}
              <div className="flex gap-1 mb-4 border-b border-stone-200/50 dark:border-neutral-800/50">
                <button onClick={() => setTab('reviews')} className={`px-3 py-2 text-xs font-medium relative ${tab === 'reviews' ? 'text-stone-600 dark:text-white' : 'text-stone-400'}`}>
                  Reviews
                  {tab === 'reviews' && <div className="absolute bottom-0 left-3 right-3 h-0.5 bg-stone-600 dark:bg-white rounded-full" />}
                </button>
                <button onClick={() => setTab('actions')} className={`px-3 py-2 text-xs font-medium relative ${tab === 'actions' ? 'text-stone-600 dark:text-white' : 'text-stone-400'}`}>
                  Actions
                  {tab === 'actions' && <div className="absolute bottom-0 left-3 right-3 h-0.5 bg-stone-600 dark:bg-white rounded-full" />}
                </button>
                <button onClick={() => setTab('workplan')} className={`px-3 py-2 text-xs font-medium relative ${tab === 'workplan' ? 'text-stone-600 dark:text-white' : 'text-stone-400'}`}>
                  Work Plan
                  {tab === 'workplan' && <div className="absolute bottom-0 left-3 right-3 h-0.5 bg-stone-600 dark:bg-white rounded-full" />}
                </button>
              </div>

              {tab === 'reviews' && (
                <div className="space-y-4">
                  {[...metas, ...reviewers].map(r => <ReviewCard key={r.id} review={r} />)}
                </div>
              )}
              {tab === 'actions' && (
                <div className="space-y-6">
                  {(['must', 'should', 'later'] as const).map(priority => {
                    const items = ACTION_ITEMS.filter(a => a.priority === priority)
                    const cfg = { must: { l: 'Must Fix', d: 'bg-red-500' }, should: { l: 'Should Fix', d: 'bg-amber-500' }, later: { l: 'Future Work', d: 'bg-stone-300 dark:bg-neutral-700' } }[priority]
                    return (
                      <div key={priority}>
                        <div className="flex items-center gap-1.5 mb-2">
                          <div className={`w-1.5 h-1.5 rounded-full ${cfg.d}`} />
                          <span className="text-2xs font-medium uppercase tracking-wider text-stone-400 dark:text-neutral-600">{cfg.l}</span>
                        </div>
                        <div className="space-y-1">
                          {items.map(item => (
                            <div key={item.label} className="text-xs text-stone-600 dark:text-neutral-400 py-1">{item.label}</div>
                          ))}
                        </div>
                      </div>
                    )
                  })}
                </div>
              )}
              {tab === 'workplan' && (
                <div className="space-y-6">
                  {WORK_PLAN.map(section => (
                    <div key={section.title}>
                      <div className="flex items-center gap-1.5 mb-2">
                        <span className="text-2xs font-medium uppercase tracking-wider text-stone-400 dark:text-neutral-600">{section.title}</span>
                      </div>
                      <div className="space-y-1">
                        {section.items.map(item => (
                          <div key={item.task} className="text-xs text-stone-600 dark:text-neutral-400 py-1">{item.task}</div>
                        ))}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* PDF panel - takes remaining space, navpanes hidden */}
          <div className="flex-1 min-w-0">
            <iframe src={PDF_URL} className="w-full h-full border-0" title="Paper PDF" />
          </div>
        </div>
      </div>
    )
  }

  // Normal view (no PDF)
  return (
    <div className="min-h-screen bg-stone-50 dark:bg-neutral-950">
      <Navigation />

      <main className="max-w-3xl mx-auto px-6 pt-24 pb-24">
        {/* Header */}
        <div className="mb-12">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <span className="text-xs font-mono text-stone-400 dark:text-neutral-600">#{DECISION.submission}</span>
              <span className="text-stone-300 dark:text-neutral-700">\u00B7</span>
              <span className="text-xs text-stone-400 dark:text-neutral-600">{DECISION.venue}</span>
              <span className="text-stone-300 dark:text-neutral-700">\u00B7</span>
              <span className="text-xs text-stone-400 dark:text-neutral-600">{DECISION.cycle}</span>
            </div>
            <button onClick={() => setShowPdf(true)} className="btn-secondary gap-1.5">
              <PanelRightOpen className="w-3.5 h-3.5" /> View Paper
            </button>
          </div>
          <h1 className="text-3xl font-semibold tracking-tight text-stone-600 dark:text-white mb-2">
            Paper Review
          </h1>
          <p className="text-stone-400 dark:text-neutral-500">
            BlockBench: Do LLMs Truly Understand Smart Contract Vulnerabilities?
          </p>
        </div>

        {/* Decision */}
        <div className="card p-6 mb-6">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-3">
              <div className="w-2.5 h-2.5 rounded-full bg-red-500" />
              <span className="text-xl font-semibold text-stone-600 dark:text-white">{DECISION.status}</span>
              <span className="text-xs font-medium text-amber-600 dark:text-amber-400 bg-amber-50 dark:bg-amber-950/30 px-2 py-0.5 rounded-md">
                {DECISION.detail}
              </span>
            </div>
            <span className="text-xs text-stone-400 dark:text-neutral-600">{DECISION.date}</span>
          </div>
          <p className="text-sm text-stone-500 dark:text-neutral-500 leading-relaxed italic">
            "{DECISION.comment}"
          </p>
        </div>

        {/* Chair Warning */}
        <div className="card p-5 mb-6 border border-amber-200/30 dark:border-amber-800/20">
          <div className="flex gap-3">
            <div className="w-1 rounded-full bg-amber-400 shrink-0" />
            <div>
              <p className="text-xs font-medium text-amber-700 dark:text-amber-400 mb-1.5">
                Program Chairs \u2014 {DECISION.chairNote.date}
              </p>
              <p className="text-sm text-stone-500 dark:text-neutral-400 leading-relaxed">
                {DECISION.chairNote.text}
              </p>
            </div>
          </div>
        </div>

        {/* Score Summary */}
        <div className="grid grid-cols-4 gap-4 mb-10">
          {[
            { label: 'Soundness', value: avgScore('Soundness') },
            { label: 'Excitement', value: avgScore('Excitement') },
            { label: 'Overall', value: avgScore('Overall') },
            { label: 'Reproducibility', value: reviewers.length ? (reviewers.map(r => parseFloat(r.reproducibility || '0')).reduce((a,b) => a+b, 0) / reviewers.length).toFixed(1) : '\u2014' },
          ].map(s => (
            <div key={s.label} className="text-center py-4">
              <div className="text-2xl font-light font-mono text-stone-500 dark:text-white tracking-tight">{s.value}</div>
              <div className="text-2xs text-stone-400 dark:text-neutral-600 mt-0.5">{s.label}</div>
            </div>
          ))}
        </div>

        {/* Tabs */}
        <div className="flex items-center gap-1 mb-8 border-b border-stone-200/50 dark:border-neutral-800/50">
          <button
            onClick={() => setTab('reviews')}
            className={`px-4 py-2.5 text-sm font-medium transition-colors relative ${
              tab === 'reviews' ? 'text-stone-600 dark:text-white' : 'text-stone-400 dark:text-neutral-600 hover:text-stone-600 dark:hover:text-neutral-400'
            }`}
          >
            Reviews
            {tab === 'reviews' && <div className="absolute bottom-0 left-4 right-4 h-0.5 bg-stone-600 dark:bg-white rounded-full" />}
          </button>
          <button
            onClick={() => setTab('actions')}
            className={`px-4 py-2.5 text-sm font-medium transition-colors relative ${
              tab === 'actions' ? 'text-stone-600 dark:text-white' : 'text-stone-400 dark:text-neutral-600 hover:text-stone-600 dark:hover:text-neutral-400'
            }`}
          >
            Action Plan
            {tab === 'actions' && <div className="absolute bottom-0 left-4 right-4 h-0.5 bg-stone-600 dark:bg-white rounded-full" />}
          </button>
          <button
            onClick={() => setTab('workplan')}
            className={`px-4 py-2.5 text-sm font-medium transition-colors relative ${
              tab === 'workplan' ? 'text-stone-600 dark:text-white' : 'text-stone-400 dark:text-neutral-600 hover:text-stone-600 dark:hover:text-neutral-400'
            }`}
          >
            Work Plan
            {tab === 'workplan' && <div className="absolute bottom-0 left-4 right-4 h-0.5 bg-stone-600 dark:bg-white rounded-full" />}
          </button>
        </div>

        {/* Reviews Tab */}
        {tab === 'reviews' && (
          <div className="space-y-10">
            <div>
              <h2 className="text-xs font-medium uppercase tracking-wider text-stone-400 dark:text-neutral-600 mb-4">Meta Reviews ({metas.length})</h2>
              <div className="space-y-4">{metas.map(r => <ReviewCard key={r.id} review={r} />)}</div>
            </div>
            <div>
              <h2 className="text-xs font-medium uppercase tracking-wider text-stone-400 dark:text-neutral-600 mb-4">Reviewer Assessments ({reviewers.length})</h2>
              <div className="space-y-4">{reviewers.map(r => <ReviewCard key={r.id} review={r} />)}</div>
            </div>
          </div>
        )}

        {/* Actions Tab */}
        {tab === 'actions' && (
          <div className="space-y-10">
            {(['must', 'should', 'later'] as const).map(priority => {
              const items = ACTION_ITEMS.filter(a => a.priority === priority)
              const config = {
                must: { label: 'Must Fix', sublabel: 'Blocking acceptance', dot: 'bg-red-500' },
                should: { label: 'Should Fix', sublabel: 'Strengthens paper', dot: 'bg-amber-500' },
                later: { label: 'Future Work', sublabel: 'Acknowledged, not required', dot: 'bg-stone-300 dark:bg-neutral-700' },
              }[priority]
              return (
                <div key={priority}>
                  <div className="flex items-center gap-2 mb-4">
                    <div className={`w-2 h-2 rounded-full ${config.dot}`} />
                    <h2 className="text-sm font-medium text-stone-600 dark:text-white">{config.label}</h2>
                    <span className="text-xs text-stone-400 dark:text-neutral-600">{config.sublabel}</span>
                  </div>
                  <div className="space-y-2">
                    {items.map(item => (
                      <div key={item.label} className="card px-5 py-3.5 flex items-center justify-between gap-4">
                        <span className="text-sm text-stone-600 dark:text-neutral-300">{item.label}</span>
                        <div className="flex gap-1 shrink-0">
                          {item.raised.map(r => (
                            <span key={r} className="text-2xs text-stone-400 dark:text-neutral-600 bg-stone-100 dark:bg-neutral-800 px-1.5 py-0.5 rounded">{r}</span>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )
            })}
          </div>
        )}

        {/* Work Plan Tab */}
        {tab === 'workplan' && (
          <div className="space-y-10">
            {WORK_PLAN.map(section => (
              <div key={section.title}>
                <div className="mb-4">
                  <h2 className="text-sm font-medium text-stone-600 dark:text-white">{section.title}</h2>
                  <p className="text-xs text-stone-400 dark:text-neutral-600 mt-0.5">{section.description}</p>
                </div>
                <div className="space-y-2">
                  {section.items.map(item => (
                    <div key={item.task} className="card px-5 py-4">
                      <p className="text-sm font-medium text-stone-500 dark:text-neutral-300 mb-1">{item.task}</p>
                      <p className="text-xs text-stone-400 dark:text-neutral-500 leading-relaxed">{item.detail}</p>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  )
}
