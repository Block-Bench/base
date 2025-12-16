/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        // Light mode cream palette
        cream: {
          50: '#FDFCFB',
          100: '#FAF9F7',
          200: '#F5F3EF',
          300: '#EBE8E2',
          400: '#DDD8CE',
          500: '#C4BDB0',
          600: '#A69E8E',
          700: '#857D6E',
          800: '#635C50',
          900: '#423D35',
        },
        // Dark mode slate palette
        slate: {
          850: '#1a1d23',
          925: '#12141a',
          950: '#0a0c10',
        },
        // Neutral grays
        neutral: {
          50: '#FAFAFA',
          100: '#F5F5F5',
          200: '#E5E5E5',
          300: '#D4D4D4',
          400: '#A3A3A3',
          500: '#737373',
          600: '#525252',
          700: '#404040',
          800: '#262626',
          850: '#1F1F1F',
          900: '#171717',
          950: '#0A0A0A',
        },
        // Accent color
        accent: {
          DEFAULT: '#8B7355',
          light: '#A08B70',
          dark: '#6B5A45',
        },
        // Code syntax highlighting colors
        syntax: {
          comment: { light: '#6B7280', dark: '#6B7280' },
          keyword: { light: '#7C3AED', dark: '#A78BFA' },
          string: { light: '#059669', dark: '#34D399' },
          number: { light: '#8B7355', dark: '#D4A574' },
          function: { light: '#2563EB', dark: '#60A5FA' },
          variable: { light: '#DC2626', dark: '#F87171' },
          punctuation: { light: '#374151', dark: '#9CA3AF' },
        },
      },
      fontFamily: {
        sans: [
          'Inter',
          '-apple-system',
          'BlinkMacSystemFont',
          'Segoe UI',
          'system-ui',
          'sans-serif',
        ],
        mono: [
          'JetBrains Mono',
          'Fira Code',
          'SF Mono',
          'Monaco',
          'Cascadia Code',
          'Roboto Mono',
          'Consolas',
          'monospace',
        ],
      },
      fontSize: {
        '2xs': ['0.625rem', { lineHeight: '0.875rem' }],
      },
      boxShadow: {
        'soft': '0 1px 2px 0 rgb(0 0 0 / 0.03)',
        'soft-md': '0 2px 4px -1px rgb(0 0 0 / 0.04), 0 1px 2px -1px rgb(0 0 0 / 0.03)',
        'soft-lg': '0 4px 6px -2px rgb(0 0 0 / 0.03), 0 2px 4px -2px rgb(0 0 0 / 0.02)',
        'inner-soft': 'inset 0 1px 2px 0 rgb(0 0 0 / 0.03)',
        // Dark mode shadows
        'dark-soft': '0 1px 2px 0 rgb(0 0 0 / 0.2)',
        'dark-soft-md': '0 2px 4px -1px rgb(0 0 0 / 0.3), 0 1px 2px -1px rgb(0 0 0 / 0.2)',
        'dark-glow': '0 0 20px rgba(139, 115, 85, 0.15)',
      },
      borderRadius: {
        '4xl': '2rem',
      },
      backgroundImage: {
        'grid-light': `
          linear-gradient(to right, rgba(0, 0, 0, 0.03) 1px, transparent 1px),
          linear-gradient(to bottom, rgba(0, 0, 0, 0.03) 1px, transparent 1px)
        `,
        'grid-dark': `
          linear-gradient(to right, rgba(255, 255, 255, 0.03) 1px, transparent 1px),
          linear-gradient(to bottom, rgba(255, 255, 255, 0.03) 1px, transparent 1px)
        `,
      },
      backgroundSize: {
        'grid': '24px 24px',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-out',
        'slide-up': 'slideUp 0.3s ease-out',
        'slide-down': 'slideDown 0.3s ease-out',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'typing': 'typing 3.5s steps(40, end)',
        'blink': 'blink 1s step-end infinite',
        'count-up': 'countUp 2s ease-out forwards',
        'scan-line': 'scanLine 2s linear infinite',
        'glow': 'glow 2s ease-in-out infinite alternate',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { opacity: '0', transform: 'translateY(8px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideDown: {
          '0%': { opacity: '0', transform: 'translateY(-8px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        typing: {
          '0%': { width: '0' },
          '100%': { width: '100%' },
        },
        blink: {
          '50%': { borderColor: 'transparent' },
        },
        countUp: {
          '0%': { opacity: '0', transform: 'translateY(10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        scanLine: {
          '0%': { transform: 'translateY(-100%)' },
          '100%': { transform: 'translateY(100vh)' },
        },
        glow: {
          '0%': { boxShadow: '0 0 5px rgba(139, 115, 85, 0.2)' },
          '100%': { boxShadow: '0 0 20px rgba(139, 115, 85, 0.4)' },
        },
      },
    },
  },
  plugins: [],
}
