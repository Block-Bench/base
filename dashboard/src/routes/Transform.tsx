import { useEffect, useMemo, useState } from 'react'
import Prism from 'prismjs'
import 'prismjs/components/prism-solidity'
import { Data, severityClass, type TcSample } from '../data/v2'

/* ────────────────────────────────────────────────────────────────────
   Transformation Lab — original vs variant, side-by-side
   ──────────────────────────────────────────────────────────────────── */

interface VariantDescriptor {
  id: string
  label: string
  kind: 'baseline' | 'realistic' | 'adversarial'
  desc: string
}

export default function Transform() {
  const [samples, setSamples] = useState<TcSample[]>([])
  const [variantDescs, setVariantDescs] = useState<VariantDescriptor[]>([])
  const [activeId, setActiveId] = useState<string>('tc_001')
  const [variant, setVariant] = useState<string>('sanitized')
  const [orig, setOrig] = useState<string>('')
  const [vari, setVari] = useState<string>('')
  const [, setMeta] = useState<any>(null)

  useEffect(() => {
    Data.tcIndex().then(d => {
      setSamples(d.samples)
      setVariantDescs((d.variants as VariantDescriptor[]) || [])
    }).catch(() => {})
  }, [])

  useEffect(() => {
    setOrig('')
    setVari('')
    Data.tcContract(activeId, 'original').then(setOrig).catch(() => setOrig(''))
    Data.tcContract(activeId, variant).then(setVari).catch(() => setVari(''))
    Data.tcMeta(activeId).then(setMeta).catch(() => setMeta(null))
  }, [activeId, variant])

  const sample = samples.find(s => s.id === activeId) || null

  const origLines = useMemo(() => orig.split('\n'), [orig])
  const variLines = useMemo(() => vari.split('\n'), [vari])

  // Set-based diff: any line in variant whose trimmed form doesn't exist in original is "changed".
  // Symmetric for original (lines removed).
  const origSet = useMemo(() => new Set(origLines.map(l => l.trim()).filter(Boolean)), [origLines])
  const variSet = useMemo(() => new Set(variLines.map(l => l.trim()).filter(Boolean)), [variLines])

  const variantInfo = variantDescs.find(v => v.id === variant)

  const lineChangedFromOriginal = (line: string) => {
    const t = line.trim()
    if (!t) return false
    return !origSet.has(t)
  }
  const lineRemovedInVariant = (line: string) => {
    const t = line.trim()
    if (!t) return false
    return !variSet.has(t)
  }

  // Stats: how much did the variant change?
  const changedCount = useMemo(
    () => variLines.filter(lineChangedFromOriginal).length,
    [variLines, origSet],
  )
  const removedCount = useMemo(
    () => origLines.filter(lineRemovedInVariant).length,
    [origLines, variSet],
  )
  const changedPct = variLines.length > 0 ? (changedCount / variLines.length) : 0

  return (
    <div className="flex-1 overflow-y-auto scrollbar bg-bg">
      {/* Header */}
      <section className="max-w-[1500px] mx-auto px-10 pt-16 pb-6">
        <div className="font-mono text-2xs uppercase tracking-rail text-ink-faint mb-6">
          §transformation lab
        </div>
        <h1 className="serif-display text-balance">Transformations.</h1>
        <p className="serif mt-6 text-ink-muted max-w-[820px]">
          Each Temporal-Contamination contract is mutated through{' '}
          <span className="text-ink font-semibold">eight variants</span>, seven that keep
          the vulnerability and one Differential counterfactual that removes it. Realistic
          perturbations cover sanitization and comment removal; adversarial stress tests
          cover chameleon, trojan and false prophet. The original sits on the left;
          the picked variant on the right with the changed lines marked.
        </p>
      </section>

      {/* Contract picker — horizontal chip rail */}
      <section className="max-w-[1500px] mx-auto px-10 pt-2 pb-4">
        <div className="font-mono text-2xs uppercase tracking-rail text-ink-faint mb-3">
          contract <span className="text-ink-muted">·</span> {samples.length} tc base contracts
        </div>
        <div className="flex items-center gap-1.5 overflow-x-auto no-scrollbar pb-1">
          {samples.map(s => {
            const active = s.id === activeId
            return (
              <button
                key={s.id}
                onClick={() => setActiveId(s.id)}
                className={`shrink-0 inline-flex items-center gap-2 h-7 px-2.5 rounded-sm font-mono text-2xs uppercase tracking-rail ${
                  active
                    ? 'bg-accent text-accent-ink'
                    : 'text-ink-faint hover:text-ink hover:bg-bg-elev border border-transparent hover:border-rule'
                }`}
              >
                <span>{s.id}</span>
                {s.severity && s.severity !== 'unknown' && (
                  <span
                    className={`w-1 h-1 rounded-full inline-block ${active ? '' : ''}`}
                    style={{
                      background: active ? 'rgba(10,10,11,0.6)' : severityColor(s.severity),
                    }}
                  />
                )}
              </button>
            )
          })}
        </div>
      </section>

      {/* Active contract banner */}
      {sample && (
        <section className="max-w-[1500px] mx-auto px-10 pb-4 flex items-baseline gap-4">
          <span className="font-mono text-base text-ink font-semibold">{sample.id}</span>
          <span
            className="w-1.5 h-1.5 rounded-full inline-block self-center shrink-0"
            style={{ background: 'var(--bb-accent)', boxShadow: '0 0 10px rgba(232,255,90,0.55)' }}
          />
          <span className="font-serif text-base text-ink-muted truncate flex-1">
            <span className="text-ink">{(sample.vuln_type || '').replace(/_/g, ' ')}</span>
            <span className="text-ink-faint"> · </span>
            <span className="text-ink italic">{sample.title}</span>
          </span>
          {sample.severity && sample.severity !== 'unknown' && (
            <span className={severityClass(sample.severity)}>{sample.severity}</span>
          )}
        </section>
      )}

      {/* Variant picker — grouped by kind */}
      <section className="max-w-[1500px] mx-auto px-10 py-4 border-t border-rule">
        <div className="font-mono text-2xs uppercase tracking-rail text-ink-faint mb-3">
          variant
        </div>
        <div className="flex items-center gap-1.5 flex-wrap">
          {variantDescs.filter(v => v.id !== 'original').map(v => {
            const active = v.id === variant
            const kindColor =
              v.kind === 'realistic'   ? '#7BC8FF' :
              v.kind === 'adversarial' ? '#FF8E5A' : '#525259'
            return (
              <button
                key={v.id}
                onClick={() => setVariant(v.id)}
                title={v.desc}
                className={`inline-flex items-center gap-2 h-7 px-2.5 rounded-sm font-mono text-2xs uppercase tracking-rail ${
                  active
                    ? 'bg-accent text-accent-ink'
                    : 'text-ink-muted hover:text-ink hover:bg-bg-elev border border-rule'
                }`}
              >
                <span
                  className="w-1.5 h-1.5 rounded-full inline-block"
                  style={{ background: active ? 'rgba(10,10,11,0.6)' : kindColor }}
                />
                <span>{v.label}</span>
              </button>
            )
          })}
        </div>
      </section>

      {/* Stats strip */}
      <section className="max-w-[1500px] mx-auto px-10 py-3 flex items-center gap-6 font-mono text-2xs uppercase tracking-rail text-ink-faint border-t border-rule">
        <span><span className="text-ink-muted">{origLines.length}</span> orig loc</span>
        <span>·</span>
        <span><span className="text-ink-muted">{variLines.length}</span> variant loc</span>
        <span>·</span>
        <span><span className="text-sev-low">+{changedCount}</span> added or changed</span>
        <span>·</span>
        <span><span className="text-sev-high">−{removedCount}</span> removed</span>
        <span>·</span>
        <span>
          <span className="text-ink-muted">{(changedPct * 100).toFixed(0)}%</span> mutation
        </span>
        <div className="flex-1" />
        {variantInfo && (
          <span className="font-serif italic text-ink-muted not-uppercase tracking-normal text-sm normal-case">
            {variantInfo.desc}
          </span>
        )}
      </section>

      {/* Side-by-side code panes */}
      <section className="max-w-[1500px] mx-auto px-10 pb-20">
        <div className="grid grid-cols-2 border border-rule" style={{ minHeight: 480 }}>
          <CodePane
            title="original"
            kind="orig"
            lines={origLines}
            isChanged={lineRemovedInVariant}
          />
          <CodePane
            title={variantInfo?.label || variant}
            kind="variant"
            lines={variLines}
            isChanged={lineChangedFromOriginal}
          />
        </div>
      </section>
    </div>
  )
}

/* ────────────────────────────────────────────────────────────────────
   CodePane
   ──────────────────────────────────────────────────────────────────── */

function CodePane({ title, kind, lines, isChanged }: {
  title: string
  kind: 'orig' | 'variant'
  lines: string[]
  isChanged: (line: string) => boolean
}) {
  const highlighted = useMemo(() => {
    return lines.map(line => {
      const safe = line.length === 0 ? ' ' : line
      try {
        return Prism.highlight(safe, Prism.languages.solidity, 'solidity')
      } catch {
        return safe.replace(/[<>&]/g, (c) =>
          c === '<' ? '&lt;' : c === '>' ? '&gt;' : '&amp;')
      }
    })
  }, [lines])

  return (
    <div className={`min-w-0 flex flex-col ${kind === 'orig' ? 'border-r border-rule' : ''}`}>
      <div className="flex items-center justify-between px-5 h-10 border-b border-rule bg-bg-surface">
        <span className="font-mono text-2xs uppercase tracking-rail text-ink-muted">{title}</span>
        <span className="font-mono text-2xs uppercase tracking-rail text-ink-faint">
          {lines.length} loc
        </span>
      </div>
      <div className="flex-1 overflow-auto scrollbar codepane">
        <div className="px-5 py-4">
          {highlighted.map((html, i) => {
            const changed = isChanged(lines[i] || '')
            return (
              <pre
                key={i}
                className={`codeline language-solidity ${
                  changed
                    ? kind === 'orig' ? 'codeline-removed' : 'codeline-added'
                    : ''
                }`}
                dangerouslySetInnerHTML={{ __html: html }}
              />
            )
          })}
        </div>
      </div>
    </div>
  )
}

function severityColor(s?: string): string {
  const v = (s || '').toLowerCase()
  if (v === 'high' || v === 'critical') return '#FF5A5A'
  if (v === 'medium' || v === 'med')    return '#FFB05A'
  if (v === 'low')                      return '#5AFFA8'
  return '#525259'
}
