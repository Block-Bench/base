import { Link, useLocation } from 'react-router-dom'
import { Sun, Moon, Github } from 'lucide-react'
import { useTheme } from '../context/ThemeContext'
import { Logo } from './Logo'

export function Navigation() {
  const { theme, toggleTheme } = useTheme()
  const location = useLocation()

  const isActive = (path: string) => {
    if (path === '/explorer') {
      return location.pathname.startsWith('/explorer') || location.pathname.startsWith('/sample')
    }
    return location.pathname.startsWith(path)
  }

  return (
    <nav className="fixed top-0 left-0 right-0 z-50 glass">
      <div className="max-w-6xl mx-auto px-6 h-14 flex items-center justify-between">
        {/* Logo */}
        <Link to="/" className="flex items-center gap-2 group">
          <Logo size={28} className="transition-transform duration-200 group-hover:scale-105" />
          <span className="font-semibold text-neutral-900 dark:text-white text-sm tracking-tight">
            BlockBench
          </span>
        </Link>

        {/* Nav Links */}
        <div className="hidden md:flex items-center gap-0.5">
          <NavLink href="/explorer/base" active={isActive('/explorer')}>
            Explorer
          </NavLink>
          <NavLink href="/strategies" active={isActive('/strategies')}>
            Strategies
          </NavLink>
          <NavLink href="/review" active={isActive('/review')}>
            Review
          </NavLink>
        </div>

        {/* Actions */}
        <div className="flex items-center gap-1">
          <button
            onClick={toggleTheme}
            className="w-8 h-8 rounded-lg flex items-center justify-center text-neutral-400 hover:text-neutral-600 dark:hover:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800 transition-all duration-150"
            aria-label={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
          >
            <Sun className="w-4 h-4 absolute transition-all duration-200 rotate-0 scale-100 dark:-rotate-90 dark:scale-0" />
            <Moon className="w-4 h-4 absolute transition-all duration-200 rotate-90 scale-0 dark:rotate-0 dark:scale-100" />
          </button>
          <a
            href="https://github.com/anthropics/blockbench"
            target="_blank"
            rel="noopener noreferrer"
            className="hidden sm:flex w-8 h-8 rounded-lg items-center justify-center text-neutral-400 hover:text-neutral-600 dark:hover:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800 transition-all duration-150"
            aria-label="View on GitHub"
          >
            <Github className="w-4 h-4" />
          </a>
        </div>
      </div>
    </nav>
  )
}

function NavLink({ href, active, children }: { href: string; active: boolean; children: React.ReactNode }) {
  return (
    <Link
      to={href}
      className={`
        px-3 py-1.5 text-sm rounded-lg transition-all duration-150
        ${active
          ? 'text-stone-600 dark:text-white font-medium bg-stone-100 dark:bg-neutral-800'
          : 'text-stone-400 dark:text-neutral-500 hover:text-stone-600 dark:hover:text-neutral-300'
        }
      `}
    >
      {children}
    </Link>
  )
}

export default Navigation
