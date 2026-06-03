import { useEffect, useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'

interface Cmd { id: string; label: string; group: string; to: string; hint?: string }

const COMMANDS: Cmd[] = [
  { id: 'go.overview',  label: 'Overview',           group: 'go', to: '/' },
  { id: 'go.inspect',   label: 'Sample Inspector',   group: 'go', to: '/inspect' },
  { id: 'go.transform', label: 'Transformations',    group: 'go', to: '/transform' },
  { id: 'go.results',   label: 'Results Matrix',     group: 'go', to: '/results' },
  { id: 'go.codeacts',  label: 'CodeActs Browser',   group: 'go', to: '/codeacts' },
  { id: 'go.paper',     label: 'Paper & Reviews',    group: 'go', to: '/paper' },
  { id: 'gs.open',      label: 'Open Gold Standard',     group: 'datasets', to: '/inspect?subset=gs' },
  { id: 'ds.open',      label: 'Open Difficulty Stratified', group: 'datasets', to: '/inspect?subset=ds' },
  { id: 'tc.open',      label: 'Open Temporal Contamination', group: 'datasets', to: '/inspect?subset=tc' },
  { id: 'neg.open',     label: 'Open Negative',          group: 'datasets', to: '/inspect?subset=negative' },
]

export default function CommandPalette() {
  const [open, setOpen] = useState(false)
  const [q, setQ] = useState('')
  const [idx, setIdx] = useState(0)
  const nav = useNavigate()

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault()
        setOpen(v => !v)
      } else if (e.key === 'Escape') {
        setOpen(false)
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [])

  const filtered = useMemo(() => {
    const qq = q.toLowerCase().trim()
    if (!qq) return COMMANDS
    return COMMANDS.filter(c => c.label.toLowerCase().includes(qq) || c.id.toLowerCase().includes(qq))
  }, [q])

  useEffect(() => { setIdx(0) }, [q, open])

  if (!open) return null

  return (
    <div
      className="fixed inset-0 z-50 grid place-items-start pt-32 bg-black/60 backdrop-blur-sm"
      onClick={() => setOpen(false)}
    >
      <div
        className="w-[640px] max-w-[92vw] bg-bg-surface border border-rule"
        onClick={e => e.stopPropagation()}
      >
        <div className="border-b border-rule">
          <input
            autoFocus
            value={q}
            onChange={e => setQ(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'ArrowDown') { e.preventDefault(); setIdx(i => Math.min(i + 1, filtered.length - 1)) }
              if (e.key === 'ArrowUp')   { e.preventDefault(); setIdx(i => Math.max(i - 1, 0)) }
              if (e.key === 'Enter')     {
                e.preventDefault()
                const cmd = filtered[idx]
                if (cmd) { nav(cmd.to); setOpen(false); setQ('') }
              }
            }}
            placeholder="Type a command, dataset, or model…"
            className="w-full h-11 px-4 bg-transparent font-mono text-sm text-ink placeholder:text-ink-faint focus:outline-none"
          />
        </div>
        <div className="max-h-[400px] overflow-y-auto scrollbar">
          {filtered.length === 0 && (
            <div className="px-4 py-3 font-mono text-xs text-ink-faint">no match</div>
          )}
          {filtered.map((c, i) => (
            <div
              key={c.id}
              onMouseEnter={() => setIdx(i)}
              onClick={() => { nav(c.to); setOpen(false); setQ('') }}
              className={`flex items-center justify-between px-4 h-8 font-mono text-xs cursor-pointer ${i === idx ? 'bg-bg-elev text-ink' : 'text-ink-muted hover:text-ink'}`}
            >
              <span className="flex items-center gap-3">
                <span className="text-2xs uppercase tracking-rail text-ink-faint w-16">{c.group}</span>
                <span>{c.label}</span>
              </span>
              <span className="text-ink-faint">{c.to}</span>
            </div>
          ))}
        </div>
        <div className="border-t border-rule px-3 h-7 flex items-center gap-3 font-mono text-2xs uppercase tracking-rail text-ink-faint">
          <span>⏎ open</span>
          <span className="rail-sep">·</span>
          <span>↑↓ navigate</span>
          <span className="rail-sep">·</span>
          <span>esc close</span>
        </div>
      </div>
    </div>
  )
}
