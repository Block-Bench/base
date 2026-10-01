import { useEffect, useMemo, useState } from 'react'
import Prism from 'prismjs'
import 'prismjs/components/prism-solidity'
import { Data, type TcSample } from '../data/v2'

/* ────────────────────────────────────────────────────────────────────
   CodeActs Browser
   Groups the 19 operation types into 6 categories, each with a color.
   ──────────────────────────────────────────────────────────────────── */

type Variant = string

interface CodeAct {
  id: string
  type: string
  description: string
  vulnerable?: { file?: string; function?: string; line?: number | null; code?: string; security_function?: string; rationale?: string }
  fixed?:      { file?: string; function?: string; line?: number | null; code?: string; security_function?: string; rationale?: string }
  transition?: string
  transition_reason?: string
}

interface CodeActsFile {
  sample_id?: string
  base_sample_id?: string
  vulnerability_type?: string
  by_variant: Record<Variant, CodeAct[]>
}

type Category =
  | 'access'
  | 'data'
  | 'compute'
  | 'flow'
  | 'struct'
  | 'event'
  | 'meta'

const OP_CATEGORY: Record<string, Category> = {
  ACCESS_CTRL: 'access',
  INPUT_VAL: 'access',
  REENTRY_GUARD: 'access',
  SIGNATURE: 'access',

  STATE_MOD: 'data',
  FUND_XFER: 'data',
  EXT_CALL: 'data',
  DELEGATE: 'data',
  STORAGE_READ: 'data',

  ARITHMETIC: 'compute',
  COMPUTATION: 'compute',

  CTRL_FLOW: 'flow',
  DIRECTIVE: 'flow',

  DECLARATION: 'struct',
  INITIALIZATION: 'struct',

  EVENT_DEF: 'event',
  EVENT_EMIT: 'event',

  COMMENT: 'meta',
  SYNTAX: 'meta',
}

const CATEGORY_META: Record<Category, { label: string; color: string; sub: string }> = {
  access:  { label: 'access & validation', color: '#7BC8FF', sub: 'authority, input checks, guards' },
  data:    { label: 'data movement',       color: '#FF8E5A', sub: 'state, funds, external calls' },
  compute: { label: 'computation',         color: '#E8FF5A', sub: 'arithmetic, derivations' },
  flow:    { label: 'control flow',        color: '#C8A8FF', sub: 'branches, returns' },
  struct:  { label: 'structure',           color: '#9CB0BD', sub: 'declarations, init' },
  event:   { label: 'events',              color: '#5AFFA8', sub: 'log definitions, emits' },
  meta:    { label: 'meta',                color: '#525259', sub: 'comments, syntax' },
}

const CATEGORY_ORDER: Category[] = ['access', 'data', 'compute', 'flow', 'struct', 'event', 'meta']

const VARIANT_PREFIX_TO_VARIANT: Record<string, Variant> = {
  ms_: 'minimalsanitized',
  df_: 'differential',
  tr_: 'trojan',
}

function fileToVariant(file?: string): Variant | null {
  if (!file) return null
  const prefix = file.slice(0, 3)
  return VARIANT_PREFIX_TO_VARIANT[prefix] ?? null
}

/* ────────────────────────────────────────────────────────────────────
   Main component
   ──────────────────────────────────────────────────────────────────── */

export default function CodeActs() {
  const [samples, setSamples] = useState<TcSample[]>([])
  const [activeId, setActiveId] = useState<string>('')
  const [variant, setVariant] = useState<Variant>('')
  const [src, setSrc] = useState<string>('')
  const [acts, setActs] = useState<CodeAct[]>([])
  const [, setMeta] = useState<any>(null)
  const [hoveredOp, setHoveredOp] = useState<string | null>(null)
  const [pinnedOp, setPinnedOp] = useState<string | null>(null)

  // Load TC index and pick first sample with codeacts
  useEffect(() => {
    Data.tcIndex().then(d => {
      const annotated = d.samples.filter(s => s.codeacts_variants.length > 0)
      setSamples(annotated)
      if (annotated.length > 0 && !activeId) {
        setActiveId(annotated[0].id)
        setVariant(annotated[0].codeacts_variants[0])
      }
    }).catch(() => {})
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  // Reset when sample changes
  useEffect(() => {
    if (!activeId) return
    const s = samples.find(x => x.id === activeId)
    if (s && (!variant || !s.codeacts_variants.includes(variant))) {
      setVariant(s.codeacts_variants[0] || '')
    }
    setPinnedOp(null)
    setHoveredOp(null)
    Data.tcMeta(activeId).then(setMeta).catch(() => setMeta(null))
  }, [activeId, samples])

  // Load source + codeacts when variant changes
  useEffect(() => {
    if (!activeId || !variant) return
    Data.tcContract(activeId, variant).then(setSrc).catch(() => setSrc(''))
    Data.codeacts(activeId).then((d: CodeActsFile | null) => {
      setActs((d?.by_variant?.[variant]) || [])
    }).catch(() => setActs([]))
  }, [activeId, variant])

  const sample = samples.find(s => s.id === activeId) || null
  const lines = useMemo(() => src.split('\n'), [src])

  // Highlight code per line
  const highlightedLines = useMemo(() => {
    return lines.map(raw => {
      const safe = raw.length === 0 ? ' ' : raw
      try {
        return Prism.highlight(safe, Prism.languages.solidity, 'solidity')
      } catch {
        return safe.replace(/[<>&]/g, (c) =>
          c === '<' ? '&lt;' : c === '>' ? '&gt;' : '&amp;')
      }
    })
  }, [lines])

  // Build line → annotations map. Use vulnerable.line if its file matches the active variant,
  // else fixed.line if its file matches.
  const lineToActs = useMemo(() => {
    const m = new Map<number, CodeAct[]>()
    acts.forEach(act => {
      let ln: number | null = null
      const vv = fileToVariant(act.vulnerable?.file)
      const fv = fileToVariant(act.fixed?.file)
      if (vv === variant && typeof act.vulnerable?.line === 'number') ln = act.vulnerable!.line!
      else if (fv === variant && typeof act.fixed?.line === 'number') ln = act.fixed!.line!
      if (ln && ln > 0) {
        if (!m.has(ln)) m.set(ln, [])
        m.get(ln)!.push(act)
      }
    })
    return m
  }, [acts, variant])

  // Counts per operation type (in the picked variant)
  const opCounts = useMemo(() => {
    const c: Record<string, number> = {}
    acts.forEach(a => { c[a.type] = (c[a.type] || 0) + 1 })
    return c
  }, [acts])

  // Grouped counts
  const grouped = useMemo(() => {
    const out: Record<Category, { op: string; count: number }[]> = {
      access: [], data: [], compute: [], flow: [], struct: [], event: [], meta: []
    }
    Object.entries(opCounts).forEach(([op, count]) => {
      const cat = OP_CATEGORY[op] || 'meta'
      out[cat].push({ op, count })
    })
    Object.values(out).forEach(list => list.sort((a, b) => b.count - a.count))
    return out
  }, [opCounts])

  const activeOp = pinnedOp || hoveredOp

  return (
    <div className="flex-1 min-h-0 flex flex-col bg-bg overflow-hidden">
      {/* Compact top strip: §codeacts label + sample id + serif title + n acts */}
      <div className="max-w-[1500px] mx-auto px-10 pt-5 pb-3 w-full shrink-0 flex items-baseline gap-4 flex-wrap">
        <span className="font-mono text-2xs uppercase tracking-rail text-ink-faint">
          §codeacts
        </span>
        {sample && (
          <>
            <span className="font-mono text-base text-ink font-semibold">{sample.id}</span>
            <span
              className="w-1.5 h-1.5 rounded-full inline-block self-center shrink-0"
              style={{ background: 'var(--bb-accent)', boxShadow: '0 0 10px rgba(232,255,90,0.55)' }}
            />
            <span className="font-serif text-base text-ink-muted truncate flex-1 min-w-0">
              <span className="text-ink">{(sample.vuln_type || '').replace(/_/g, ' ')}</span>
              <span className="text-ink-faint"> · </span>
              <span className="text-ink italic">{sample.title}</span>
            </span>
          </>
        )}
        <span className="font-mono text-2xs uppercase tracking-rail text-ink-faint shrink-0">
          <span className="text-ink tabular">{acts.length}</span> acts
        </span>
      </div>

      {/* Sample rail */}
      <div className="max-w-[1500px] mx-auto px-10 pb-2 w-full shrink-0 flex items-center gap-2">
        <span className="font-mono text-2xs uppercase tracking-rail text-ink-faint shrink-0 w-14">sample</span>
        <div className="flex items-center gap-1 overflow-x-auto no-scrollbar flex-1">
          {samples.map(s => {
            const active = s.id === activeId
            return (
              <button
                key={s.id}
                onClick={() => setActiveId(s.id)}
                className={`shrink-0 h-6 px-2 rounded-sm font-mono text-2xs uppercase tracking-rail ${
                  active
                    ? 'bg-accent text-accent-ink'
                    : 'text-ink-faint hover:text-ink hover:bg-bg-elev'
                }`}
              >
                {s.id}
              </button>
            )
          })}
        </div>
      </div>

      {/* Variant rail */}
      {sample && sample.codeacts_variants.length > 0 && (
        <div className="max-w-[1500px] mx-auto px-10 pb-3 w-full shrink-0 flex items-center gap-2">
          <span className="font-mono text-2xs uppercase tracking-rail text-ink-faint shrink-0 w-14">variant</span>
          <div className="flex items-center gap-1 flex-wrap">
            {sample.codeacts_variants.map(v => {
              const active = v === variant
              return (
                <button
                  key={v}
                  onClick={() => setVariant(v)}
                  className={`h-6 px-2 rounded-sm font-mono text-2xs uppercase tracking-rail ${
                    active
                      ? 'bg-accent text-accent-ink'
                      : 'text-ink-muted hover:text-ink hover:bg-bg-elev border border-rule'
                  }`}
                >
                  {v}
                </button>
              )
            })}
          </div>
        </div>
      )}

      {/* Main split — code on left, taxonomy on right */}
      <div className="max-w-[1500px] mx-auto px-10 pb-8 w-full flex-1 min-h-0 flex gap-px bg-rule border border-rule">
        {/* Code pane */}
        <div className="flex-1 min-w-0 bg-bg flex flex-col">
          <div className="flex items-center justify-between px-5 h-10 border-b border-rule bg-bg-surface shrink-0">
            <span className="font-mono text-2xs uppercase tracking-rail text-ink-muted">
              {variant} <span className="text-ink-faint">·</span> {lines.length} loc
            </span>
            {activeOp && (
              <span className="font-mono text-2xs uppercase tracking-rail">
                <span className="text-ink-faint">highlighting</span>{' '}
                <span style={{ color: CATEGORY_META[OP_CATEGORY[activeOp] || 'meta'].color }}>{activeOp}</span>
                {pinnedOp && (
                  <button
                    onClick={() => setPinnedOp(null)}
                    className="ml-2 text-ink-faint hover:text-ink"
                    title="clear pinned filter"
                  >× clear</button>
                )}
              </span>
            )}
          </div>
          <div className="flex-1 overflow-auto scrollbar codepane">
            <div className="py-4">
              {highlightedLines.map((html, i) => {
                const ln = i + 1
                const lineActs = lineToActs.get(ln) || []
                const cats = new Set(lineActs.map(a => OP_CATEGORY[a.type] || 'meta'))
                const dimByPinned = activeOp && !lineActs.some(a => a.type === activeOp)
                const highlighted = activeOp && lineActs.some(a => a.type === activeOp)
                return (
                  <div
                    key={ln}
                    className="relative flex items-start group"
                    style={{ opacity: dimByPinned ? 0.35 : 1 }}
                  >
                    {/* Category stripes on the left */}
                    <div className="shrink-0 w-3 flex" style={{ marginRight: 8 }}>
                      {CATEGORY_ORDER.filter(c => cats.has(c)).slice(0, 3).map((c, idx) => (
                        <span
                          key={c}
                          className="w-[2px] h-[22px] block"
                          style={{
                            background: CATEGORY_META[c].color,
                            opacity: highlighted ? 1 : 0.85,
                            boxShadow: highlighted ? `0 0 6px ${CATEGORY_META[c].color}aa` : 'none',
                            marginRight: idx < 2 ? 1 : 0,
                          }}
                        />
                      ))}
                    </div>
                    <pre
                      className="codeline language-solidity flex-1 min-w-0"
                      dangerouslySetInnerHTML={{ __html: html }}
                    />
                    {/* Op chips at end of line */}
                    {lineActs.length > 0 && (
                      <div className="shrink-0 flex items-center gap-1 ml-3 pr-5">
                        {lineActs.map((a, ai) => {
                          const cat = OP_CATEGORY[a.type] || 'meta'
                          const color = CATEGORY_META[cat].color
                          const matched = activeOp === a.type
                          return (
                            <span
                              key={`${a.id}-${ai}`}
                              className="inline-flex items-center font-mono text-[10px] uppercase tracking-[0.06em] px-1.5 h-[18px] rounded-sm pointer-events-none whitespace-nowrap"
                              style={{
                                background: matched ? `${color}28` : 'transparent',
                                color,
                                border: `1px solid ${color}${matched ? '99' : '40'}`,
                              }}
                            >
                              {a.type.toLowerCase().replace(/_/g, ' ')}
                            </span>
                          )
                        })}
                      </div>
                    )}
                  </div>
                )
              })}
            </div>
          </div>
        </div>

        {/* Taxonomy pane */}
        <aside className="w-[340px] shrink-0 bg-bg flex flex-col">
          <div className="px-5 h-10 border-b border-rule bg-bg-surface flex items-center justify-between shrink-0">
            <span className="font-mono text-2xs uppercase tracking-rail text-ink-muted">taxonomy</span>
            <span className="font-mono text-2xs uppercase tracking-rail text-ink-faint">
              <span className="text-ink">{Object.keys(opCounts).length}</span> ops
            </span>
          </div>
          <div className="flex-1 overflow-y-auto scrollbar py-2">
            {CATEGORY_ORDER.map(cat => {
              const ops = grouped[cat]
              if (ops.length === 0) return null
              const catTotal = ops.reduce((s, o) => s + o.count, 0)
              const meta = CATEGORY_META[cat]
              return (
                <div key={cat} className="mb-5">
                  <div className="flex items-center justify-between px-5 py-1.5">
                    <span className="flex items-center gap-2">
                      <span className="w-1.5 h-1.5 rounded-full inline-block" style={{ background: meta.color }} />
                      <span className="font-mono text-2xs uppercase tracking-rail text-ink">
                        {meta.label}
                      </span>
                    </span>
                    <span className="font-mono text-2xs tabular text-ink-faint">{catTotal}</span>
                  </div>
                  <div className="px-1">
                    {ops.map(({ op, count }) => {
                      const active = activeOp === op
                      const max = Math.max(...ops.map(o => o.count))
                      const w = max > 0 ? (count / max) : 0
                      return (
                        <button
                          key={op}
                          onMouseEnter={() => setHoveredOp(op)}
                          onMouseLeave={() => setHoveredOp(null)}
                          onClick={() => setPinnedOp(pinnedOp === op ? null : op)}
                          className={`relative w-full flex items-center gap-3 px-4 py-1.5 text-left rounded-sm group ${
                            active ? 'bg-bg-elev' : 'hover:bg-bg-elev/50'
                          }`}
                        >
                          {/* Bar visualization */}
                          <span
                            className="absolute left-4 right-4 bottom-1 h-[2px] rounded-pill"
                            style={{
                              background: `linear-gradient(90deg, ${meta.color} 0%, ${meta.color}66 ${w * 100}%, transparent ${w * 100}%)`,
                              opacity: active ? 1 : 0.6,
                            }}
                          />
                          <span className="font-mono text-xs text-ink-muted group-hover:text-ink flex-1 lowercase">
                            {op.toLowerCase().replace(/_/g, ' ')}
                          </span>
                          <span className="font-mono text-xs tabular text-ink-faint group-hover:text-ink">
                            {count}
                          </span>
                        </button>
                      )
                    })}
                  </div>
                </div>
              )
            })}
            {Object.keys(opCounts).length === 0 && (
              <div className="px-5 py-4 font-mono text-2xs uppercase tracking-rail text-ink-faint">
                no annotations in this variant
              </div>
            )}
          </div>
        </aside>
      </div>
    </div>
  )
}
