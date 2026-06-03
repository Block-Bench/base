import { useEffect, useState } from 'react'
import { Data, type Manifest } from '../data/v2'

interface Props { position?: 'top' | 'bottom' }

export default function ProvenanceRail({ position = 'top' }: Props) {
  const [m, setM] = useState<Manifest | null>(null)

  useEffect(() => {
    Data.manifest().then(setM).catch(() => {})
  }, [])

  if (!m) {
    return <div className="rail">loading…</div>
  }

  if (position === 'top') {
    return (
      <div className="rail">
        <span className="rail-accent">BLOCKBENCH</span>
        <span className="rail-sep">·</span>
        <span className="rail-key">version</span>
        <span className="rail-val">{m.version}</span>
        <span className="rail-sep">·</span>
        <span className="rail-key">gs</span>
        <span className="rail-val">{m.counts.gs}</span>
        <span className="rail-sep">·</span>
        <span className="rail-key">ds</span>
        <span className="rail-val">{m.counts.ds}</span>
        <span className="rail-sep">·</span>
        <span className="rail-key">tc</span>
        <span className="rail-val">{m.counts.tc}×{m.counts.tc_variants}</span>
        <span className="rail-sep">·</span>
        <span className="rail-key">neg</span>
        <span className="rail-val">{m.counts.negative}</span>
        <span className="rail-sep">·</span>
        <span className="rail-key">models</span>
        <span className="rail-val">{m.counts.models}</span>
        <span className="rail-sep">·</span>
        <span className="rail-key">judges</span>
        <span className="rail-val">{m.counts.judges}</span>
        <span className="ml-auto" />
        <span className="rail-key">build</span>
        <span className="rail-val">v2</span>
      </div>
    )
  }

  return (
    <div className="rail border-t">
      <span className="rail-key">⌘K</span>
      <span className="rail-val">command palette</span>
      <span className="rail-sep">·</span>
      <span className="rail-key">↑↓</span>
      <span className="rail-val">navigate</span>
      <span className="rail-sep">·</span>
      <span className="rail-key">⏎</span>
      <span className="rail-val">open</span>
      <span className="ml-auto" />
      <span className="rail-key">build</span>
      <span className="rail-val">v2 · static</span>
    </div>
  )
}
