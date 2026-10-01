import { useEffect, useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { Data, formatPct, type ModelInfo, type TdrRow } from '../data/v2'

/* ────────────────────────────────────────────────────────────────────
   Results Matrix
   ──────────────────────────────────────────────────────────────────── */

type Subset = 'gs' | 'negative'
type Strategy = 'direct' | 'context_protocol' | 'context_protocol_cot'

const COLUMNS: { subset: Subset; strategy: Strategy; label: string; sub: string }[] = [
  { subset: 'gs',       strategy: 'direct',                label: 'direct',         sub: 'gs' },
  { subset: 'gs',       strategy: 'context_protocol',      label: 'protocol',       sub: 'gs' },
  { subset: 'gs',       strategy: 'context_protocol_cot',  label: 'protocol + cot', sub: 'gs' },
  { subset: 'negative', strategy: 'direct',                label: 'fp rate',        sub: 'negative' },
]

const MODEL_ORDER = [
  'claude-opus-4-5',
  'gpt-5.2',
  'gemini-3-pro',
  'grok-4-fast',
  'llama-4-maverick',
  'qwen3-coder-plus',
  'deepseek-v3-2',
]

export default function Results() {
  const [models, setModels] = useState<ModelInfo[]>([])
  const [matrix, setMatrix] = useState<TdrRow[]>([])
  const [hovered, setHovered] = useState<{ row: number; col: number } | null>(null)

  useEffect(() => {
    Data.models().then(setModels).catch(() => {})
    Data.tdrMatrix().then(setMatrix).catch(() => {})
  }, [])

  const rows: ModelInfo[] = useMemo(() => {
    if (models.length === 0) return []
    const byId = Object.fromEntries(models.map(m => [m.id, m]))
    return MODEL_ORDER.map(id => byId[id]).filter(Boolean)
  }, [models])

  const cell = (model: string, col: typeof COLUMNS[0]): TdrRow | undefined =>
    matrix.find(r => r.model === model && r.subset === col.subset && r.strategy === col.strategy)

  // Highlight best (max TDR for GS columns; min FP for negative column)
  const bestPerCol = useMemo(() => {
    const out: Record<number, string> = {}
    COLUMNS.forEach((col, ci) => {
      let best: { model: string; v: number } | null = null
      rows.forEach(m => {
        const c = cell(m.id, col)
        if (!c) return
        const v = c.tdr ?? 0
        if (best === null) { best = { model: m.id, v }; return }
        if (col.subset === 'negative') {
          if (v < best.v) best = { model: m.id, v }
        } else {
          if (v > best.v) best = { model: m.id, v }
        }
      })
      if (best) out[ci] = (best as { model: string; v: number }).model
    })
    return out
  }, [matrix, rows])

  // Summary stats
  const stats = useMemo(() => {
    const gsDirect = matrix.filter(r => r.subset === 'gs' && r.strategy === 'direct' && (r.tdr ?? 0) > 0)
    const topGs = gsDirect.reduce<TdrRow | null>((a, b) => (!a || (b.tdr ?? 0) > (a.tdr ?? 0)) ? b : a, null)
    const fps = matrix.filter(r => r.subset === 'negative')
    const lowFp = fps.reduce<TdrRow | null>((a, b) => (!a || (b.tdr ?? 1) < (a.tdr ?? 1)) ? b : a, null)
    const cotPair = matrix.filter(r => r.subset === 'gs' && r.strategy === 'context_protocol_cot')
    const directPair = matrix.filter(r => r.subset === 'gs' && r.strategy === 'direct')
    let cotGain = 0
    let cotCount = 0
    cotPair.forEach(c => {
      const d = directPair.find(x => x.model === c.model)
      if (d) { cotGain += (c.tdr ?? 0) - (d.tdr ?? 0); cotCount += 1 }
    })
    return {
      topGs,
      lowFp,
      cotGain: cotCount > 0 ? cotGain / cotCount : 0,
    }
  }, [matrix])

  return (
    <div className="flex-1 overflow-y-auto scrollbar bg-bg">
      {/* Page header */}
      <section className="max-w-[1300px] mx-auto px-10 pt-16 pb-8">
        <div className="font-mono text-2xs uppercase tracking-rail text-ink-faint mb-6">
          §results · model × strategy
        </div>
        <h1 className="serif-display text-balance">Results matrix.</h1>
        <p className="serif mt-6 text-ink-muted max-w-[820px]">
          Target Detection Rate across seven LLMs and three prompt strategies.
          Cells on the <span className="text-ink font-semibold">gs</span> columns show judge-validated TDR
          when judges have been run; otherwise the model's self-reported verdict rate.
          The <span className="text-ink font-semibold">fp rate</span> column reports false-positive flags on the 100-contract clean set.
        </p>
      </section>

      {/* Summary stats */}
      <section className="max-w-[1300px] mx-auto px-10 pb-8">
        <div className="grid grid-cols-3 gap-px bg-rule border border-rule">
          <StatCard
            label="best on gs · direct"
            value={stats.topGs ? formatPct(stats.topGs.tdr) : '—'}
            sub={stats.topGs ? models.find(m => m.id === stats.topGs!.model)?.display : ''}
          />
          <StatCard
            label="lowest fp · negative"
            value={stats.lowFp ? formatPct(stats.lowFp.tdr) : '—'}
            sub={stats.lowFp ? models.find(m => m.id === stats.lowFp!.model)?.display : ''}
          />
          <StatCard
            label="cot lift over direct"
            value={`${stats.cotGain >= 0 ? '+' : ''}${(stats.cotGain * 100).toFixed(1)}%`}
            sub="average across models"
          />
        </div>
      </section>

      {/* Matrix */}
      <section className="max-w-[1300px] mx-auto px-10 pb-20">
        <div className="font-mono text-2xs uppercase tracking-rail text-ink-faint mb-4">
          matrix
        </div>
        <div className="border border-rule">
          {/* Column header row */}
          <div className="grid grid-cols-[260px_repeat(4,1fr)] bg-bg">
            <div className="border-r border-b border-rule px-4 py-3 font-mono text-2xs uppercase tracking-rail text-ink-faint">
              model
            </div>
            {COLUMNS.map((col, ci) => (
              <div
                key={ci}
                className="relative border-r border-b border-rule px-4 py-3"
                onMouseEnter={() => setHovered(h => ({ row: h?.row ?? -1, col: ci }))}
                onMouseLeave={() => setHovered(h => h?.col === ci ? null : h)}
              >
                <div className="font-mono text-2xs uppercase tracking-rail text-ink-faint">
                  {col.sub}
                </div>
                <div className={`font-mono text-xs mt-1 ${col.subset === 'negative' ? 'text-sev-high' : 'text-ink'}`}>
                  {col.label}
                </div>
              </div>
            ))}
          </div>

          {/* Body rows */}
          {rows.map((model, ri) => (
            <div key={model.id} className="grid grid-cols-[260px_repeat(4,1fr)] hover:bg-bg-elev/30 group">
              <div className="border-r border-rule px-4 py-3 flex items-center gap-3">
                <span style={{ background: model.color }} className="w-2 h-2 rounded-full inline-block shrink-0" />
                <span className="font-mono text-sm text-ink truncate">{model.display}</span>
              </div>
              {COLUMNS.map((col, ci) => {
                const c = cell(model.id, col)
                const v = c?.tdr
                const isHoverRow = hovered?.row === ri
                const isHoverCol = hovered?.col === ci
                const isBest = bestPerCol[ci] === model.id && v != null
                const bg = v == null ? 'transparent' : cellBg(v, col.subset)
                return (
                  <div
                    key={ci}
                    onMouseEnter={() => setHovered({ row: ri, col: ci })}
                    onMouseLeave={() => setHovered(null)}
                    className={`border-r border-rule px-4 py-3 relative cursor-default transition-colors ${
                      isHoverRow || isHoverCol ? 'outline outline-1 outline-rule-strong outline-offset-[-1px]' : ''
                    }`}
                    style={{ background: bg }}
                  >
                    <div className="flex items-baseline gap-2">
                      <span className="font-mono text-base tabular text-ink font-medium">
                        {v == null ? '—' : formatPct(v)}
                      </span>
                      {c?.tdr_source === 'judge' && (
                        <span className="font-mono text-2xs uppercase tracking-rail text-ink-faint" title="judge-validated TDR">j</span>
                      )}
                      {c?.tdr_source === 'verdict' && c?.subset === 'gs' && (
                        <span className="font-mono text-2xs uppercase tracking-rail text-ink-faint" title="verdict rate (judges not yet run on this strategy)">v</span>
                      )}
                      {isBest && (
                        <span
                          className="ml-auto w-1.5 h-1.5 rounded-full inline-block self-center"
                          style={{
                            background: 'var(--bb-accent)',
                            boxShadow: '0 0 8px rgba(232,255,90,0.6)',
                          }}
                          title={col.subset === 'negative' ? 'lowest FP' : 'highest TDR'}
                        />
                      )}
                    </div>
                    {c && (
                      <div className="font-mono text-2xs text-ink-faint mt-1 tabular">
                        n={c.n}
                      </div>
                    )}
                  </div>
                )
              })}
            </div>
          ))}
        </div>

        {/* Legend */}
        <div className="mt-5 flex items-center justify-between font-mono text-2xs uppercase tracking-rail text-ink-faint">
          <div className="flex items-center gap-3">
            <span className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full" style={{ background: 'var(--bb-accent)', boxShadow: '0 0 6px rgba(232,255,90,0.5)' }} />
              <span>best in column</span>
            </span>
            <span>·</span>
            <span><span className="text-ink">j</span> judge-validated</span>
            <span>·</span>
            <span><span className="text-ink">v</span> verdict rate</span>
          </div>
          <div className="flex items-center gap-3">
            <span className="flex items-center gap-1.5">
              <span className="inline-block w-12 h-2" style={{ background: 'linear-gradient(90deg, rgba(232,255,90,0.05), rgba(232,255,90,0.55))' }} />
              <span>TDR scale</span>
            </span>
            <span className="flex items-center gap-1.5">
              <span className="inline-block w-12 h-2" style={{ background: 'linear-gradient(90deg, rgba(255,90,90,0.05), rgba(255,90,90,0.55))' }} />
              <span>FP scale</span>
            </span>
          </div>
        </div>

        {/* Drill-in hint */}
        <div className="mt-12 border-t border-rule pt-6 font-mono text-2xs uppercase tracking-rail text-ink-faint">
          → open <Link to="/inspect" className="text-accent">sample inspector</Link> to drill into individual contracts
        </div>
      </section>
    </div>
  )
}

function StatCard({ label, value, sub }: { label: string; value: string; sub?: string }) {
  return (
    <div className="bg-bg p-5">
      <div className="font-mono text-2xs uppercase tracking-rail text-ink-faint">{label}</div>
      <div className="font-mono text-3xl text-ink mt-2 tabular font-semibold">{value}</div>
      {sub && <div className="font-mono text-xs text-ink-muted mt-1">{sub}</div>}
    </div>
  )
}

/* Color scale: low → high.
   GS cells use lime (#E8FF5A) — high TDR is good.
   Negative (FP) cells use red (#FF5A5A) — high FP is bad. */
function cellBg(value: number, subset: string): string {
  const v = Math.max(0, Math.min(1, value))
  const intensity = 0.05 + 0.55 * v
  if (subset === 'negative') {
    return `rgba(255, 90, 90, ${intensity})`
  }
  return `rgba(232, 255, 90, ${intensity})`
}
