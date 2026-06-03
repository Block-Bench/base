import { useLocation } from 'react-router-dom'
import { useEffect, useState } from 'react'
import { Data, type Manifest } from '../data/v2'

export default function StatusBar() {
  const loc = useLocation()
  const [m, setM] = useState<Manifest | null>(null)
  useEffect(() => { Data.manifest().then(setM).catch(() => {}) }, [])

  const route = (loc.pathname.split('/')[1] || 'overview').toLowerCase()
  return (
    <footer className="statusbar">
      <span className="rail-key">route</span>
      <span className="rail-val">/{route || 'overview'}</span>
      <span className="ml-auto" />
      {m && (
        <>
          <span className="rail-key">contracts</span>
          <span className="rail-val">
            {m.counts.gs + m.counts.ds + m.counts.tc + m.counts.negative}
          </span>
          <span className="rail-sep">·</span>
        </>
      )}
      <span className="rail-key">build</span>
      <span className="rail-val">static</span>
      <span className="rail-sep">·</span>
      <span className="rail-accent">●</span>
      <span className="rail-val">ready</span>
    </footer>
  )
}
