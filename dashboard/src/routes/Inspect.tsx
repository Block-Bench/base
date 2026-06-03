import { useEffect, useMemo, useRef, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import Prism from 'prismjs'
import 'prismjs/components/prism-solidity'
import {
  Data, severityClass,
  type GsSample, type DsSample, type TcSample, type NegSample,
} from '../data/v2'

/* ────────────────────────────────────────────────────────────────────
   Types
   ──────────────────────────────────────────────────────────────────── */

type SubsetKey = 'gs' | 'ds' | 'tc' | 'negative'
type SeverityFilter = 'all' | 'high' | 'medium' | 'low'

interface Tab {
  subset: SubsetKey
  id: string
  variant?: string
}

interface ExplorerSample {
  id: string
  title?: string
  severity?: string
  hint?: string
  tier?: string
}

/* ────────────────────────────────────────────────────────────────────
   FileTree — two-content rows + severity filter strip
   ──────────────────────────────────────────────────────────────────── */

interface TreeProps {
  onOpen: (tab: Tab) => void
  activeTab: Tab | null
  collapsed: Record<string, boolean>
  toggle: (k: string) => void
}

function FileTree({ onOpen, activeTab, collapsed, toggle }: TreeProps) {
  const [gs, setGs] = useState<GsSample[]>([])
  const [ds, setDs] = useState<DsSample[]>([])
  const [tc, setTc] = useState<TcSample[]>([])
  const [neg, setNeg] = useState<NegSample[]>([])
  const [filter, setFilter] = useState('')
  const [sev, setSev] = useState<SeverityFilter>('all')

  useEffect(() => {
    Data.gsIndex().then(d => setGs(d.samples)).catch(() => {})
    Data.dsIndex().then(d => setDs(d.samples)).catch(() => {})
    Data.tcIndex().then(d => setTc(d.samples)).catch(() => {})
    Data.negIndex().then(d => setNeg(d.samples)).catch(() => {})
  }, [])

  const f = filter.trim().toLowerCase()
  const matchText = (s: { id: string; title?: string; vuln_type?: string }) =>
    !f || s.id.toLowerCase().includes(f) ||
    (s.title || '').toLowerCase().includes(f) ||
    (s.vuln_type || '').toLowerCase().includes(f)
  const matchSev = (severity?: string) => {
    if (sev === 'all') return true
    const v = (severity || '').toLowerCase()
    if (sev === 'high')   return v === 'high' || v === 'critical'
    if (sev === 'medium') return v === 'medium' || v === 'med'
    if (sev === 'low')    return v === 'low'
    return true
  }

  const fgs = useMemo(() => gs.filter(s => matchText(s) && matchSev(s.severity as string)), [gs, f, sev])
  const fds = useMemo(() => ds.filter(s => matchText(s) && matchSev(s.severity)), [ds, f, sev])
  const ftc = useMemo(() => tc.filter(s => matchText(s) && matchSev(s.severity)), [tc, f, sev])
  const fneg = useMemo(() => neg.filter(matchText), [neg, f])

  const dsByTier = useMemo(() => {
    const out: Record<string, DsSample[]> = {}
    fds.forEach(s => { (out[s.tier] ||= []).push(s) })
    return out
  }, [fds])

  // Severity counts (whole corpus, ignoring filter input)
  const sevCounts = useMemo(() => {
    const c = { all: 0, high: 0, medium: 0, low: 0 }
    const allSamples: { severity?: string }[] = [...gs, ...ds, ...tc]
    allSamples.forEach(s => {
      c.all += 1
      const v = (s.severity || '').toLowerCase()
      if (v === 'high' || v === 'critical') c.high += 1
      else if (v === 'medium' || v === 'med') c.medium += 1
      else if (v === 'low') c.low += 1
    })
    return c
  }, [gs, ds, tc])

  return (
    <aside className="w-[300px] shrink-0 flex flex-col bg-bg border-r border-rule">
      {/* Search */}
      <div className="px-3 pt-4 pb-3">
        <div className="relative">
          <span className="absolute left-2.5 top-1/2 -translate-y-1/2 font-mono text-xs text-ink-faint pointer-events-none">⌕</span>
          <input
            value={filter}
            onChange={e => setFilter(e.target.value)}
            placeholder="filter"
            className="w-full h-8 pl-7 pr-2 bg-transparent font-mono text-xs text-ink placeholder:text-ink-faint border-0 focus:outline-none focus:bg-bg-elev rounded-sm"
          />
        </div>
      </div>

      {/* Severity filter strip */}
      <div className="px-3 pb-3 flex items-center gap-1">
        {[
          { k: 'all',    label: 'all',  c: sevCounts.all,    color: '#525259' },
          { k: 'high',   label: 'high', c: sevCounts.high,   color: '#FF5A5A' },
          { k: 'medium', label: 'med',  c: sevCounts.medium, color: '#FFB05A' },
          { k: 'low',    label: 'low',  c: sevCounts.low,    color: '#5AFFA8' },
        ].map(({ k, label, c, color }) => {
          const active = sev === k
          return (
            <button
              key={k}
              onClick={() => setSev(k as SeverityFilter)}
              className={`flex items-center gap-1.5 px-2 h-6 rounded-sm font-mono text-2xs uppercase tracking-rail ${
                active
                  ? 'bg-bg-elev text-ink'
                  : 'text-ink-faint hover:text-ink hover:bg-bg-elev/60'
              }`}
            >
              <span style={{ background: color }} className="w-1.5 h-1.5 rounded-full" />
              <span>{label}</span>
              <span className="tabular text-ink-faint">{c}</span>
            </button>
          )
        })}
      </div>

      <div className="overflow-y-auto scrollbar flex-1 pb-4">
        <ExplorerSection
          label="gold standard"
          count={fgs.length}
          open={!collapsed['gs']}
          onToggle={() => toggle('gs')}
        >
          {fgs.map(s => (
            <ExplorerRow
              key={`gs-${s.id}`}
              id={s.id}
              title={s.title}
              severity={s.severity as string}
              active={activeTab?.subset === 'gs' && activeTab?.id === s.id}
              onClick={() => onOpen({ subset: 'gs', id: s.id })}
            />
          ))}
        </ExplorerSection>

        <ExplorerSection
          label="difficulty stratified"
          count={fds.length}
          open={!collapsed['ds']}
          onToggle={() => toggle('ds')}
        >
          {Object.entries(dsByTier).sort().map(([tier, items]) => (
            <div key={tier}>
              <ExplorerSubSection
                label={tier}
                count={items.length}
                open={!collapsed[`ds-${tier}`]}
                onToggle={() => toggle(`ds-${tier}`)}
              />
              {!collapsed[`ds-${tier}`] && items.map(s => (
                <ExplorerRow
                  key={`ds-${s.id}`}
                  id={s.id}
                  title={s.title}
                  severity={s.severity}
                  indent={2}
                  active={activeTab?.subset === 'ds' && activeTab?.id === s.id}
                  onClick={() => onOpen({ subset: 'ds', id: s.id })}
                />
              ))}
            </div>
          ))}
        </ExplorerSection>

        <ExplorerSection
          label="temporal contamination"
          count={ftc.length}
          open={!collapsed['tc']}
          onToggle={() => toggle('tc')}
        >
          {ftc.map(s => (
            <ExplorerRow
              key={`tc-${s.id}`}
              id={s.id}
              title={s.title}
              severity={s.severity}
              variantCount={s.variants.length}
              active={activeTab?.subset === 'tc' && activeTab?.id === s.id}
              onClick={() => onOpen({ subset: 'tc', id: s.id, variant: 'original' })}
            />
          ))}
        </ExplorerSection>

        <ExplorerSection
          label="negative"
          count={fneg.length}
          open={!collapsed['neg']}
          onToggle={() => toggle('neg')}
        >
          {fneg.map(s => (
            <ExplorerRow
              key={`neg-${s.id}`}
              id={s.id}
              title={s.title}
              active={activeTab?.subset === 'negative' && activeTab?.id === s.id}
              onClick={() => onOpen({ subset: 'negative', id: s.id })}
            />
          ))}
        </ExplorerSection>
      </div>
    </aside>
  )
}

function ExplorerSection({ label, count, open, onToggle, children }: {
  label: string; count: number; open: boolean; onToggle: () => void; children: React.ReactNode
}) {
  return (
    <div className="mt-4">
      <div
        onClick={onToggle}
        className="flex items-center justify-between px-4 py-1.5 cursor-pointer group"
      >
        <span className="flex items-center gap-2 font-mono text-2xs uppercase tracking-rail text-ink-muted group-hover:text-ink">
          <span className="text-ink-faint w-3 inline-block">{open ? '▾' : '▸'}</span>
          <span>{label}</span>
        </span>
        <span className="font-mono text-2xs text-ink-faint tabular">{count}</span>
      </div>
      {open && <div className="mt-1">{children}</div>}
    </div>
  )
}

function ExplorerSubSection({ label, count, open, onToggle }: {
  label: string; count: number; open: boolean; onToggle: () => void
}) {
  return (
    <div
      onClick={onToggle}
      className="flex items-center justify-between cursor-pointer hover:text-ink"
      style={{ paddingLeft: 28, paddingRight: 16, paddingTop: 4, paddingBottom: 4 }}
    >
      <span className="font-mono text-xs text-ink-muted">
        <span className="text-ink-faint mr-1">{open ? '▾' : '▸'}</span>{label}
      </span>
      <span className="font-mono text-2xs text-ink-faint tabular">{count}</span>
    </div>
  )
}

function ExplorerRow({ id, title, severity, variantCount, active, onClick, indent = 1 }: {
  id: string; title?: string; severity?: string; variantCount?: number;
  active?: boolean; onClick: () => void; indent?: number
}) {
  const sevColor = severityToColor(severity)
  const showTitle = title && title.toLowerCase() !== id.toLowerCase()
  return (
    <div
      onClick={onClick}
      className="relative flex items-center gap-2 cursor-pointer group transition-colors"
      style={{
        paddingLeft: 12 + indent * 12,
        paddingRight: 12,
        paddingTop: 4,
        paddingBottom: 4,
        background: active ? 'rgba(232, 255, 90, 0.045)' : undefined,
      }}
    >
      {active && (
        <span
          className="absolute left-0 top-0 bottom-0 w-[2px]"
          style={{ background: 'var(--bb-accent)', boxShadow: '0 0 6px rgba(232,255,90,0.4)' }}
        />
      )}
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className={`font-mono text-xs truncate ${active ? 'text-accent' : 'text-ink group-hover:text-ink'}`}>
            {id}
          </span>
          {variantCount && (
            <span className="font-mono text-2xs text-ink-faint tabular shrink-0">{variantCount}v</span>
          )}
          {sevColor && (
            <span style={{ background: sevColor }} className="w-1 h-1 rounded-full inline-block shrink-0 ml-auto" />
          )}
        </div>
        {showTitle && (
          <div className={`font-mono text-2xs truncate leading-tight ${
            active ? 'text-accent/70' : 'text-ink-faint group-hover:text-ink-muted'
          }`}>
            {title}
          </div>
        )}
      </div>
    </div>
  )
}

function severityToColor(s?: string): string | null {
  const v = (s || '').toLowerCase()
  if (v === 'high' || v === 'critical') return '#FF5A5A'
  if (v === 'medium' || v === 'med')    return '#FFB05A'
  if (v === 'low')                      return '#5AFFA8'
  return null
}

/* ────────────────────────────────────────────────────────────────────
   CodeView — premium: minimap, inline vuln tag, collapsible ground truth
   ──────────────────────────────────────────────────────────────────── */

function CodeView({ tab, onVariantChange }: { tab: Tab; onVariantChange: (v: string) => void }) {
  const [src, setSrc] = useState<string>('')
  const [meta, setMeta] = useState<any>(null)
  const [tcSample, setTcSample] = useState<TcSample | null>(null)
  const [gtOpen, setGtOpen] = useState(false)
  const codepaneRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    setSrc('')
    setMeta(null)
    setTcSample(null)
    setGtOpen(false)

    const srcP =
      tab.subset === 'gs'   ? Data.gsContract(tab.id)
    : tab.subset === 'ds'   ? Data.dsContract(tab.id)
    : tab.subset === 'tc'   ? Data.tcContract(tab.id, tab.variant || 'original')
                            : Data.negContract(tab.id)
    srcP.then(setSrc).catch(() => setSrc('// failed to load contract source'))

    const metaP =
      tab.subset === 'gs'   ? Data.gsMeta(tab.id)
    : tab.subset === 'ds'   ? Data.dsMeta(tab.id)
    : tab.subset === 'tc'   ? Data.tcMeta(tab.id)
                            : Data.negMeta(tab.id)
    metaP.then(setMeta).catch(() => {})

    if (tab.subset === 'tc') {
      Data.tcIndex().then(idx => {
        setTcSample(idx.samples.find(s => s.id === tab.id) || null)
      }).catch(() => {})
    }
  }, [tab.subset, tab.id, tab.variant])

  const lines = useMemo(() => {
    if (!src) return []
    return src.split('\n').map(raw => {
      const safe = raw.length === 0 ? ' ' : raw
      try {
        return Prism.highlight(safe, Prism.languages.solidity, 'solidity')
      } catch {
        return safe.replace(/[<>&]/g, (c) =>
          c === '<' ? '&lt;' : c === '>' ? '&gt;' : '&amp;')
      }
    })
  }, [src])

  const vulnLines: number[] = useMemo(() => {
    if (Array.isArray(meta?.vulnerable_lines)) return meta.vulnerable_lines
    return []
  }, [meta])
  const firstVulnLine = vulnLines[0]

  const sev = (meta?.severity || '').toString().toLowerCase()
  const vulnType = meta?.vulnerability_type
  const isNeg = tab.subset === 'negative'

  const jumpToVuln = () => {
    if (!codepaneRef.current || !firstVulnLine) return
    const lineHeight = 22
    const top = (firstVulnLine - 1) * lineHeight - 80 // 80px breathing room
    codepaneRef.current.scrollTo({ top: Math.max(0, top), behavior: 'smooth' })
  }

  return (
    <div className="flex-1 min-w-0 min-h-0 flex flex-col bg-bg">
      {/* Header — single compact baseline-aligned row. Linear/Vercel pattern. */}
      <div className="px-20 py-4 shrink-0 border-b border-rule">
        <div className="flex items-baseline gap-x-4 gap-y-2 flex-wrap">
          {/* Left cluster — id + serif vuln summary + severity */}
          <span className="font-mono text-base text-ink font-semibold tracking-snug">
            {tab.id}.sol
          </span>

          {!isNeg && (vulnType || meta?.vulnerable_function) && (
            <span className="flex items-baseline gap-2 min-w-0">
              <span
                className="w-1.5 h-1.5 rounded-full inline-block self-center shrink-0"
                style={{ background: 'var(--bb-accent)', boxShadow: '0 0 10px rgba(232,255,90,0.55)' }}
              />
              <span className="font-serif text-base text-ink-muted truncate">
                {vulnType && <span className="text-ink">{vulnType.replace(/_/g, ' ')}</span>}
                {vulnType && meta?.vulnerable_function && <span className="text-ink-faint not-italic"> in </span>}
                {meta?.vulnerable_function && (
                  <span className="text-ink italic">{meta.vulnerable_function}()</span>
                )}
              </span>
            </span>
          )}

          {!isNeg && sev && sev !== 'unknown' && (
            <>
              <span className="text-ink-dim font-mono">·</span>
              <span className={severityClass(sev)}>{sev}</span>
            </>
          )}

          {isNeg && <span className="chip chip-severity-low">clean baseline</span>}

          {/* Right cluster — actions */}
          <div className="ml-auto flex items-baseline gap-4 shrink-0">
            {meta?.source_reference && (
              <a
                href={meta.source_reference}
                target="_blank"
                rel="noreferrer"
                className="font-mono text-2xs uppercase tracking-rail text-ink-faint hover:text-accent"
              >
                source ↗
              </a>
            )}
            {firstVulnLine && (
              <button
                onClick={jumpToVuln}
                className="group inline-flex items-baseline gap-1.5 font-mono text-2xs uppercase tracking-rail text-ink-faint hover:text-accent"
              >
                <span>jump to vuln</span>
                <span className="text-sev-high group-hover:text-accent">↓</span>
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Variant strip (TC only) — thin row aligned with header padding */}
      {tab.subset === 'tc' && tcSample && tcSample.variants.length > 0 && (
        <div className="px-20 py-2.5 flex items-center gap-1.5 flex-wrap shrink-0 border-b border-rule">
          <span className="font-mono text-2xs uppercase tracking-rail text-ink-faint mr-2 shrink-0">variant</span>
          {tcSample.variants.map(v => (
            <button
              key={v}
              onClick={() => onVariantChange(v)}
              className={`h-6 px-2.5 rounded-sm font-mono text-2xs uppercase tracking-rail ${
                tab.variant === v
                  ? 'bg-accent text-accent-ink'
                  : 'text-ink-faint hover:text-ink hover:bg-bg-elev'
              }`}
            >
              {v}
            </button>
          ))}
        </div>
      )}

      {/* Code — no gutter, no minimap, no footer. Code as content. */}
      <div
        ref={codepaneRef}
        key={`${tab.subset}-${tab.id}-${tab.variant ?? ''}`}
        className="flex-1 min-h-0 overflow-auto scrollbar codepane"
      >
        <div className="px-20 py-8 codestream-reveal">
          <div className="relative">
            {lines.map((html, i) => {
              const ln = i + 1
              const isVuln = vulnLines.includes(ln)
              const isFirstVuln = ln === firstVulnLine
              const delay = Math.min(i * 4, 800)
              return (
                <div key={ln} className="relative" style={{ animationDelay: `${delay}ms` }}>
                  <pre
                    className={`codeline language-solidity ${isVuln ? 'codeline-vuln' : ''}`}
                    dangerouslySetInnerHTML={{ __html: html }}
                    style={{ animationDelay: `${delay}ms` }}
                  />
                  {isFirstVuln && vulnType && (
                    <span
                      className="absolute -right-4 top-0 inline-flex items-center gap-1 px-2 h-[22px] font-mono text-2xs uppercase tracking-rail text-sev-high pointer-events-none whitespace-nowrap"
                      style={{ background: 'linear-gradient(90deg, transparent, rgba(255,90,90,0.18) 30%)' }}
                    >
                      <span>← {vulnType.replace(/_/g, ' ')}</span>
                    </span>
                  )}
                </div>
              )
            })}
          </div>
        </div>
      </div>

      {/* Ground truth (collapsible) */}
      {!isNeg && meta && (meta.exploit_name || meta.root_cause || meta.attack_scenario || meta.fix_description) && (
        <GroundTruth meta={meta} open={gtOpen} onToggle={() => setGtOpen(v => !v)} />
      )}
    </div>
  )
}

/* ────────────────────────────────────────────────────────────────────
   Ground Truth panel — collapsible
   ──────────────────────────────────────────────────────────────────── */

function GroundTruth({ meta, open, onToggle }: { meta: any; open: boolean; onToggle: () => void }) {
  return (
    <div className="shrink-0">
      <button
        onClick={onToggle}
        className={`w-full flex items-center justify-between px-8 h-11 transition-colors ${
          open
            ? 'bg-bg-surface border-t border-b border-rule hover:bg-bg-elev/40'
            : 'bg-accent hover:brightness-95'
        }`}
      >
        <span className="flex items-center gap-3 min-w-0">
          <span className={`font-mono text-2xs uppercase tracking-rail shrink-0 ${
            open ? 'text-ink-faint' : 'text-accent-ink/80'
          }`}>
            ground truth
          </span>
          {meta.exploit_name && (
            <span className={`font-serif text-sm truncate max-w-[640px] ${
              open ? 'text-ink-muted' : 'text-accent-ink'
            }`}>
              {meta.exploit_name}
            </span>
          )}
        </span>
        <span className={`font-mono text-2xs uppercase tracking-rail font-semibold shrink-0 ml-4 ${
          open ? 'text-ink-faint' : 'text-accent-ink'
        }`}>
          {open ? '× close' : 'view ↓'}
        </span>
      </button>
      {open && (
        <div className="px-8 pb-6 max-h-[400px] overflow-y-auto scrollbar">
          {meta.exploit_name && (
            <div className="font-serif text-2xl leading-snug text-ink mt-4 max-w-[820px]">
              {meta.exploit_name}
            </div>
          )}
          <Field label="root cause" value={meta.root_cause} />
          <Field label="attack scenario" value={meta.attack_scenario} />
          <Field label="fix description" value={meta.fix_description} value_mono />
          {(meta.tags && Array.isArray(meta.tags) && meta.tags.length > 0) && (
            <div className="mt-4 flex items-center gap-1.5 flex-wrap">
              {meta.tags.map((t: string) => (
                <span key={t} className="chip">{t.replace(/_/g, ' ')}</span>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  )
}

function Field({ label, value, value_mono }: { label: string; value?: string; value_mono?: boolean }) {
  if (!value) return null
  return (
    <div className="mt-5">
      <div className="font-mono text-2xs uppercase tracking-rail text-ink-faint mb-2">{label}</div>
      <div className={`${value_mono ? 'font-mono text-xs whitespace-pre-wrap' : 'font-serif text-md leading-relaxed'} text-ink-muted max-w-[820px]`}>
        {value}
      </div>
    </div>
  )
}

/* ────────────────────────────────────────────────────────────────────
   Inspect (orchestrator)
   ──────────────────────────────────────────────────────────────────── */

export default function Inspect() {
  const [search, setSearch] = useSearchParams()
  const [tabs, setTabs] = useState<Tab[]>([])
  const [active, setActive] = useState(0)
  // All sections collapsed by default — discoverable but quiet.
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>({
    gs: true, ds: true, tc: true, neg: true,
  })

  // Honor URL params on first mount: if user lands on a shareable link, open that contract
  // AND expand the section it lives in. Without params, stay empty.
  useEffect(() => {
    const subset = search.get('subset') as SubsetKey | null
    const id = search.get('id')
    if (subset && id && tabs.length === 0) {
      const variant = search.get('variant') || (subset === 'tc' ? 'original' : undefined)
      setTabs([{ subset, id, variant }])
      setActive(0)
      setCollapsed(c => ({ ...c, [subset === 'negative' ? 'neg' : subset]: false }))
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  // Sync URL with active tab — clear params when no tab is open
  useEffect(() => {
    if (tabs[active]) {
      const t = tabs[active]
      const next = new URLSearchParams()
      next.set('subset', t.subset)
      next.set('id', t.id)
      if (t.variant) next.set('variant', t.variant)
      setSearch(next, { replace: true })
    } else {
      setSearch(new URLSearchParams(), { replace: true })
    }
  }, [active, tabs, setSearch])

  const open = (tab: Tab) => {
    const i = tabs.findIndex(t => t.subset === tab.subset && t.id === tab.id)
    if (i >= 0) {
      setActive(i)
    } else {
      setTabs([...tabs, tab])
      setActive(tabs.length)
    }
    // Auto-expand the section the contract lives in
    setCollapsed(c => ({ ...c, [tab.subset === 'negative' ? 'neg' : tab.subset]: false }))
  }

  const close = (i: number) => {
    const next = tabs.filter((_, idx) => idx !== i)
    setTabs(next)
    if (next.length === 0) setActive(0)
    else if (active >= next.length) setActive(next.length - 1)
    else if (active > i) setActive(active - 1)
  }

  const setVariant = (v: string) => {
    if (!tabs[active]) return
    const next = [...tabs]
    next[active] = { ...next[active], variant: v }
    setTabs(next)
  }

  const toggle = (k: string) => setCollapsed(c => ({ ...c, [k]: !c[k] }))

  const current = tabs[active]

  return (
    <div className="flex-1 min-h-0 flex">
      <FileTree onOpen={open} activeTab={current || null} collapsed={collapsed} toggle={toggle} />

      <div className="flex-1 min-w-0 min-h-0 flex flex-col">
        <div className="tab-bar shrink-0">
          {tabs.length === 0 && (
            <div className="px-5 self-center font-mono text-2xs uppercase tracking-rail text-ink-faint">
              no contract open
            </div>
          )}
          {tabs.map((t, i) => (
            <div
              key={`${t.subset}-${t.id}-${i}`}
              onClick={() => setActive(i)}
              className={`tab ${i === active ? 'tab-active' : ''}`}
            >
              <span>{t.id}.sol</span>
              {t.variant && <span className="text-ink-faint text-2xs">· {t.variant}</span>}
              <button
                onClick={(e) => { e.stopPropagation(); close(i) }}
                className="tab-close ml-1"
                title="close tab"
              >×</button>
            </div>
          ))}
        </div>

        {current ? (
          <CodeView tab={current} onVariantChange={setVariant} />
        ) : (
          <EmptyState onOpen={open} />
        )}
      </div>
    </div>
  )
}

/* ────────────────────────────────────────────────────────────────────
   EmptyState — shown when no contract is open
   ──────────────────────────────────────────────────────────────────── */

function EmptyState({ onOpen }: { onOpen: (tab: Tab) => void }) {
  const SUGGESTIONS: { subset: SubsetKey; id: string; hint: string }[] = [
    { subset: 'gs',       id: 'gs_001',   hint: 'audit finding · hybra finance' },
    { subset: 'tc',       id: 'tc_001',   hint: 'temporal · nomad bridge' },
    { subset: 'ds',       id: 'ds_t1_001', hint: 'difficulty tier 1' },
    { subset: 'negative', id: 'neg_001',  hint: 'clean baseline' },
  ]
  return (
    <div className="flex-1 grid place-items-center bg-bg overflow-hidden">
      <div className="text-center px-8 max-w-[640px]">
        <img
          src={`${import.meta.env.BASE_URL.replace(/\/$/, '')}/catimage.gif`}
          alt=""
          className="block mx-auto"
          style={{
            width: 220,
            height: 'auto',
            // invert + hue-rotate flips luminance for dark mode while preserving hues
            filter: 'invert(1) hue-rotate(180deg)',
            mixBlendMode: 'screen',
          }}
        />
        <div className="mt-10 font-serif text-2xl text-ink leading-tight">
          Select a contract to start viewing.
        </div>
        <div className="mt-3 font-mono text-sm text-ink-muted">
          pick one from the explorer · or try a suggestion below
        </div>

        <div className="mt-8 flex items-center justify-center gap-2 flex-wrap">
          {SUGGESTIONS.map(s => (
            <button
              key={s.id}
              onClick={() => onOpen({ subset: s.subset, id: s.id, variant: s.subset === 'tc' ? 'original' : undefined })}
              className="group flex items-center gap-2 h-8 px-3 rounded-sm border border-rule hover:border-accent/60 hover:bg-bg-elev"
            >
              <span className="font-mono text-2xs uppercase tracking-rail text-ink-faint group-hover:text-ink-muted">{s.subset}</span>
              <span className="font-mono text-xs text-ink">{s.id}</span>
              <span className="font-mono text-2xs text-ink-faint group-hover:text-accent">→</span>
            </button>
          ))}
        </div>

        <div className="mt-10 font-mono text-2xs uppercase tracking-rail text-ink-faint">
          press <span className="text-ink">⌘K</span> for the command palette
        </div>
      </div>
    </div>
  )
}
