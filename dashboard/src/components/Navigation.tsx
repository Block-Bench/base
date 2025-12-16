import { Link, useLocation } from 'react-router-dom'
import { Sun, Moon, Github, Sparkles } from 'lucide-react'
import { useTheme } from '../context/ThemeContext'
import { Logo } from './Logo'

interface NavigationProps {
  transparent?: boolean
}

export function Navigation({ transparent = false }: NavigationProps) {
  const { theme, toggleTheme } = useTheme()
  const location = useLocation()

  const isActive = (path: string) => {
    if (path === '/explorer') {
      return location.pathname.startsWith('/explorer') || location.pathname.startsWith('/sample')
    }
    if (path === '/strategies') {
      return location.pathname.startsWith('/strategies')
    }
    return location.pathname === path
  }

  return (
    <nav className={`fixed top-0 left-0 right-0 z-50 ${transparent ? 'glass' : 'glass'}`}>
      <div className="max-w-7xl mx-auto px-6 py-4">
        <div className="flex items-center justify-between">
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2.5 group">
            <Logo size={32} className="transition-transform group-hover:scale-105" />
            <span className="font-semibold text-neutral-800 dark:text-neutral-100">
              BlockBench
            </span>
          </Link>

          {/* Center Navigation */}
          <div className="hidden md:flex items-center gap-1 p-1 bg-cream-200 dark:bg-neutral-800 rounded-lg">
            <NavLink href="/explorer/base" active={isActive('/explorer')}>
              Explorer
            </NavLink>
            <NavLink href="/strategies" active={isActive('/strategies')}>
              <Sparkles className="w-3.5 h-3.5" />
              Strategies
            </NavLink>
          </div>

          {/* Right Actions */}
          <div className="flex items-center gap-3">
            {/* Theme Toggle */}
            <button
              onClick={toggleTheme}
              className="relative w-10 h-10 rounded-lg bg-cream-200 dark:bg-neutral-800 flex items-center justify-center transition-all duration-200 hover:bg-cream-300 dark:hover:bg-neutral-700 group"
              aria-label={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}
            >
              <Sun className="w-5 h-5 text-neutral-600 dark:text-neutral-400 absolute transition-all duration-300 rotate-0 scale-100 dark:-rotate-90 dark:scale-0" />
              <Moon className="w-5 h-5 text-neutral-600 dark:text-neutral-400 absolute transition-all duration-300 rotate-90 scale-0 dark:rotate-0 dark:scale-100" />
            </button>

            {/* GitHub */}
            <a
              href="https://github.com/anthropics/blockbench"
              target="_blank"
              rel="noopener noreferrer"
              className="hidden sm:flex w-10 h-10 rounded-lg bg-cream-200 dark:bg-neutral-800 items-center justify-center transition-all duration-200 hover:bg-cream-300 dark:hover:bg-neutral-700"
              aria-label="View on GitHub"
            >
              <Github className="w-5 h-5 text-neutral-600 dark:text-neutral-400" />
            </a>
          </div>
        </div>
      </div>
    </nav>
  )
}

function NavLink({
  href,
  active,
  children,
}: {
  href: string
  active: boolean
  children: React.ReactNode
}) {
  return (
    <Link
      to={href}
      className={`
        px-4 py-2 text-sm font-medium rounded-md transition-all duration-200
        flex items-center gap-1.5
        ${active
          ? 'bg-white dark:bg-neutral-700 text-neutral-800 dark:text-white shadow-soft dark:shadow-dark-soft'
          : 'text-neutral-500 dark:text-neutral-400 hover:text-neutral-700 dark:hover:text-neutral-200'
        }
      `}
    >
      {children}
    </Link>
  )
}

export default Navigation
