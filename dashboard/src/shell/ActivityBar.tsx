import { NavLink } from 'react-router-dom'

interface Item { to: string; label: string; glyph: string; key: string }

const items: Item[] = [
  { to: '/',           label: 'Overview',        glyph: '◧', key: '1' },
  { to: '/inspect',    label: 'Sample Inspector',glyph: '⎘', key: '2' },
  { to: '/transform',  label: 'Transformations', glyph: '⇌', key: '3' },
  { to: '/results',    label: 'Results Matrix',  glyph: '▦', key: '4' },
  { to: '/codeacts',   label: 'CodeActs',        glyph: '∮', key: '5' },
  { to: '/paper',      label: 'Paper',           glyph: '✎', key: '6' },
]

export default function ActivityBar() {
  return (
    <nav className="activity-bar">
      <div className="h-14 w-full grid place-items-center border-b border-rule">
        <span className="font-mono text-sm uppercase tracking-rail text-accent font-semibold">bb</span>
      </div>
      {items.map(it => (
        <NavLink
          key={it.to}
          to={it.to}
          end={it.to === '/'}
          title={`${it.label}  (${it.key})`}
          className={({ isActive }) => `activity-btn ${isActive ? 'activity-btn-active' : ''}`}
        >
          <span>{it.glyph}</span>
        </NavLink>
      ))}
      <div className="flex-1" />
      <a
        href="https://github.com"
        target="_blank"
        rel="noreferrer"
        className="activity-btn"
        title="Repository"
      >
        <span>⌥</span>
      </a>
    </nav>
  )
}
