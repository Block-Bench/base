/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        // Anthropic-inspired cream palette
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
        // Neutral grays for text and borders
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
        // Accent color - subtle warm tone
        accent: {
          DEFAULT: '#8B7355',
          light: '#A08B70',
          dark: '#6B5A45',
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
      },
      borderRadius: {
        '4xl': '2rem',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-out',
        'slide-up': 'slideUp 0.3s ease-out',
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
      },
    },
  },
  plugins: [],
}
