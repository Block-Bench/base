/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        surface: {
          0: '#FFFFFF',
          1: '#FAFAFA',
          2: '#F5F5F5',
          3: '#EBEBEB',
          4: '#E0E0E0',
        },
        border: {
          DEFAULT: 'rgba(0, 0, 0, 0.08)',
          hover: 'rgba(0, 0, 0, 0.15)',
          active: 'rgba(0, 0, 0, 0.2)',
        },
        // Keep cream for backwards compat
        cream: {
          50: '#FDFCFB', 100: '#FAFAFA', 200: '#F5F5F5', 300: '#EBEBEB',
          400: '#E0E0E0', 500: '#BDBDBD', 600: '#9E9E9E', 700: '#757575',
          800: '#616161', 900: '#424242',
        },
        neutral: {
          50: '#FAFAFA', 100: '#F5F5F5', 200: '#E5E5E5', 300: '#D4D4D4',
          400: '#A3A3A3', 500: '#737373', 600: '#525252', 700: '#404040',
          800: '#262626', 850: '#1C1C1C', 900: '#141414', 950: '#0A0A0A',
        },
        accent: {
          DEFAULT: '#7C6A4F',
          light: '#9E8C70',
          dark: '#5C4E3A',
          muted: 'rgba(124, 106, 79, 0.1)',
        },
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
        sans: ['Inter', '-apple-system', 'BlinkMacSystemFont', 'system-ui', 'sans-serif'],
        mono: ['JetBrains Mono', 'SF Mono', 'Fira Code', 'monospace'],
      },
      fontSize: {
        '2xs': ['0.625rem', { lineHeight: '0.875rem' }],
        'xs': ['0.75rem', { lineHeight: '1.125rem' }],
        'sm': ['0.8125rem', { lineHeight: '1.25rem' }],
        'base': ['0.875rem', { lineHeight: '1.5rem' }],
        'lg': ['1rem', { lineHeight: '1.5rem' }],
        'xl': ['1.125rem', { lineHeight: '1.625rem' }],
        '2xl': ['1.375rem', { lineHeight: '1.75rem' }],
        '3xl': ['1.75rem', { lineHeight: '2.125rem' }],
        '4xl': ['2.25rem', { lineHeight: '2.625rem' }],
        '5xl': ['3rem', { lineHeight: '3.25rem' }],
        '6xl': ['3.75rem', { lineHeight: '1' }],
      },
      letterSpacing: {
        tight: '-0.02em',
        tighter: '-0.03em',
      },
      boxShadow: {
        'soft': '0 1px 2px 0 rgba(0,0,0,0.04)',
        'soft-md': '0 2px 8px -2px rgba(0,0,0,0.06)',
        'soft-lg': '0 4px 16px -4px rgba(0,0,0,0.08)',
        'soft-xl': '0 8px 32px -8px rgba(0,0,0,0.1)',
        'dark-soft': '0 1px 2px 0 rgba(0,0,0,0.4)',
        'dark-soft-md': '0 2px 8px -2px rgba(0,0,0,0.5)',
        'dark-soft-lg': '0 4px 16px -4px rgba(0,0,0,0.6)',
        'dark-glow': '0 0 24px rgba(124, 106, 79, 0.12)',
        'ring': '0 0 0 1px rgba(0,0,0,0.04)',
        'dark-ring': '0 0 0 1px rgba(255,255,255,0.06)',
      },
      borderRadius: {
        'xl': '0.875rem',
        '2xl': '1rem',
        '3xl': '1.25rem',
      },
      animation: {
        'fade-in': 'fadeIn 0.4s ease-out',
        'slide-up': 'slideUp 0.4s cubic-bezier(0.16, 1, 0.3, 1)',
        'slide-down': 'slideDown 0.3s cubic-bezier(0.16, 1, 0.3, 1)',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'typing': 'typing 3.5s steps(40, end)',
        'blink': 'blink 1s step-end infinite',
        'count-up': 'countUp 2s ease-out forwards',
        'float': 'float 4s ease-in-out infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%': { opacity: '0', transform: 'translateY(6px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideDown: {
          '0%': { opacity: '0', transform: 'translateY(-6px)' },
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
          '0%': { opacity: '0', transform: 'translateY(8px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-8px)' },
        },
      },
    },
  },
  plugins: [],
}
