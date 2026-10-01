import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { Data, type Manifest, type ModelInfo, type TdrRow, formatPct } from '../data/v2'
import CodeStream from '../shell/CodeStream'
import CollapseBanner from '../components/charts/CollapseBanner'
import PaperFigure from '../components/charts/PaperFigure'
import PatternReliance from '../components/charts/PatternReliance'
import { GITHUB_URL } from '../lib/links'

export default function Overview() {
  const [m, setM] = useState<Manifest | null>(null)
  const [models, setModels] = useState<ModelInfo[]>([])
  const [tdr, setTdr] = useState<TdrRow[]>([])

  useEffect(() => {
    Data.manifest().then(setM).catch(() => {})
    Data.models().then(setModels).catch(() => {})
    Data.tdrMatrix().then(setTdr).catch(() => {})
  }, [])

  const gsTdr = tdr.filter(r => r.subset === 'gs' && r.strategy === 'direct')
  const negFp = tdr.filter(r => r.subset === 'negative' && r.strategy === 'direct')

  return (
    <div className="flex-1 overflow-y-auto scrollbar">
      <div className="relative border-b border-rule overflow-hidden">
        <CodeStream />
        {/* Dark vignette behind the hero text so it pops harder over the stream */}
        <div
          className="absolute inset-0 pointer-events-none"
          style={{
            background: 'radial-gradient(ellipse at 30% 50%, rgba(10,10,11,0.82) 0%, rgba(10,10,11,0.55) 35%, rgba(10,10,11,0.22) 70%, transparent 100%)',
          }}
        />
        <section className="relative max-w-[1100px] mx-auto px-10 pt-28 pb-24">
          <h1 className="serif-hero text-balance">
            BlockBench<span className="cursor-blink" />
          </h1>
          <p className="font-serif text-3xl leading-tight text-ink-muted mt-8 max-w-[900px]">
            Contamination-controlled evaluation of large language models for code analysis.
          </p>
          <p className="serif mt-12 text-ink-muted max-w-[820px] text-2xl leading-relaxed">
            Code-analysis benchmarks decay as their samples become public. BlockBench measures
            that decay directly: a post-cutoff <span className="text-ink font-semibold">Gold Standard</span> of
            audited findings, a <span className="text-ink font-semibold">Difficulty-Stratified</span> set
            of disclosed vulnerabilities, a <span className="text-ink font-semibold">Temporal-Contamination</span>{' '}
            slice transformed into eight variants, seven that keep the vulnerability and
            one fixed counterfactual, and a{' '}
            <span className="text-ink font-semibold">Negative</span> set of audited clean code. Every contract,
            every model verdict, every judge call is browsable here.
          </p>
          <div className="mt-12">
            <a
              href={GITHUB_URL}
              target="_blank"
              rel="noreferrer"
              className="btn h-10 px-4 text-xs gap-2.5 border-rule-strong text-ink-muted
                         hover:text-accent hover:border-accent transition-colors"
            >
              <svg viewBox="0 0 16 16" width="14" height="14" fill="currentColor" aria-hidden="true">
                <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38
                  0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01
                  1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95
                  0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82a7.42 7.42 0 0 1 2-.27c.68
                  0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0
                  3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01
                  8.01 0 0 0 16 8c0-4.42-3.58-8-8-8Z" />
              </svg>
              View on GitHub
              <span className="text-ink-faint">↗</span>
            </a>
          </div>
        </section>
      </div>

      {/* Headline numbers */}
      <section className="max-w-[1300px] mx-auto px-10 py-16 border-b border-rule">
        <div className="font-mono text-xs uppercase tracking-rail text-ink-faint mb-8">
          §1 · headline numbers
        </div>
        <div className="grid grid-cols-4 gap-0 border-l border-t border-rule">
          {m && [
            { k: 'gs contracts',  v: m.counts.gs },
            { k: 'ds contracts',  v: m.counts.ds },
            { k: 'tc × variants', v: `${m.counts.tc}×${m.counts.tc_variants}` },
            { k: 'negative',      v: m.counts.negative },
            { k: 'models',        v: m.counts.models },
            { k: 'judges',        v: m.counts.judges },
            { k: 'detection runs',v: m.counts.detection_bundles },
            { k: 'judge runs',    v: m.counts.judge_bundles },
          ].map((s) => (
            <div key={s.k} className="border-r border-b border-rule px-5 py-7">
              <div className="font-mono text-xs uppercase tracking-rail text-ink-faint">{s.k}</div>
              <div className="font-mono text-5xl text-ink mt-3 tabular font-semibold">{s.v}</div>
            </div>
          ))}
        </div>
      </section>

      {/* The core collapse */}
      <CollapseBanner />

      {/* Model TDR strip */}
      <section className="max-w-[1300px] mx-auto px-10 py-16 border-b border-rule">
        <div className="font-mono text-xs uppercase tracking-rail text-ink-faint mb-8">
          §4 · gs direct-prompt tdr · per model
        </div>
        <div className="border border-rule">
          <div className="grid grid-cols-[1fr_auto_auto_auto] font-mono text-xs uppercase tracking-rail text-ink-faint">
            <div className="px-4 py-3 border-b border-rule">model</div>
            <div className="px-4 py-3 border-b border-l border-rule text-right">tdr</div>
            <div className="px-4 py-3 border-b border-l border-rule text-right">n</div>
            <div className="px-4 py-3 border-b border-l border-rule text-right">fp</div>
          </div>
          {models.map(model => {
            const row = gsTdr.find(r => r.model === model.id)
            const fp = negFp.find(r => r.model === model.id)
            return (
              <div key={model.id} className="grid grid-cols-[1fr_auto_auto_auto] hover:bg-bg-elev">
                <div className="px-4 py-3.5 border-b border-rule flex items-center gap-3">
                  <span style={{ background: model.color }} className="w-2.5 h-2.5 rounded-full inline-block" />
                  <span className="font-mono text-md text-ink font-medium">{model.display}</span>
                  <span className="font-mono text-xs text-ink-faint">·  {model.vendor}</span>
                </div>
                <div className="px-4 py-3.5 border-b border-l border-rule text-right font-mono text-md text-ink tabular font-medium">{formatPct(row?.tdr)}</div>
                <div className="px-4 py-3.5 border-b border-l border-rule text-right font-mono text-sm text-ink-muted tabular">{row?.n ?? '—'}</div>
                <div className="px-4 py-3.5 border-b border-l border-rule text-right font-mono text-sm text-ink-muted tabular">{formatPct(fp?.tdr)}</div>
              </div>
            )
          })}
        </div>
        <div className="mt-4 font-mono text-xs uppercase tracking-rail text-ink-faint">
          → drill into a model in <Link className="text-accent underline" to="/results">results matrix</Link>
        </div>
      </section>

      {/* Figure 5 — TC obfuscation (paper figure, embedded as-is) */}
      <PaperFigure
        section="§5 · transformation robustness"
        title="Every model degrades as the obfuscation intensity rises."
        blurb="TDR across the seven semantic-preserving transformations, ordered by obfuscation intensity. Faint bands separate realistic perturbations from adversarial stress tests — the exploit is identical throughout."
        src="/figures/tc_obfuscation.svg"
        alt="TC benchmark: TDR across transformations ordered by obfuscation intensity"
        caption="Figure 5 · TC benchmark — TDR across transformations ordered by obfuscation intensity. Faint regions distinguish realistic perturbations from adversarial stress tests."
      />

      {/* Figure 9 — Decoy Sensitivity Index vs ROOT_CAUSE (rebuilt natively) */}
      <PatternReliance />

      {/* Section navigation */}
      <section className="max-w-[1300px] mx-auto px-10 py-16">
        <div className="font-mono text-xs uppercase tracking-rail text-ink-faint mb-8">§7 · surfaces</div>
        <div className="grid grid-cols-3 gap-px bg-rule border border-rule">
          {[
            { to: '/inspect',   label: 'Sample Inspector', sub: 'open any contract · every model + judge verdict' },
            { to: '/transform', label: 'Transformation Lab', sub: '8 variants of the same vulnerability, side-by-side' },
            { to: '/results',   label: 'Results Matrix',  sub: 'tdr heatmap · model × subset × strategy × category' },
            { to: '/codeacts',  label: 'CodeActs',        sub: '138 annotated samples · 17 operations · 4 acts' },
            { to: '/inspect?subset=negative', label: 'Negative Set', sub: '100 audited clean contracts · fp baseline' },
          ].map(s => (
            <Link key={s.to} to={s.to} className="bg-bg-surface hover:bg-bg-elev p-7 border-rule group">
              <div className="font-mono text-sm uppercase tracking-rail text-ink font-semibold">{s.label}</div>
              <div className="font-mono text-sm text-ink-faint mt-3">{s.sub}</div>
              <div className="font-mono text-xs text-ink-faint mt-5 group-hover:text-accent">→ open</div>
            </Link>
          ))}
        </div>
      </section>
    </div>
  )
}
