/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        // BlockBench dark instrument palette
        ink: {
          DEFAULT: '#ECECEE',
          muted: '#8A8A93',
          faint: '#525259',
          dim: '#3A3A3F',
        },
        bg: {
          DEFAULT: '#0A0A0B',
          surface: '#111113',
          elev: '#17171A',
          high: '#1C1C20',
          chip: '#1F1F23',
        },
        rule: {
          DEFAULT: '#1F1F23',
          strong: '#2A2A30',
          hover: '#3A3A40',
        },
        accent: {
          DEFAULT: '#E8FF5A',
          dim: '#A8B83C',
          ink: '#0A0A0B',
        },
        sev: {
          high: '#FF5A5A',
          med: '#FFB05A',
          low: '#5AFFA8',
          ok: '#5AFFA8',
          fail: '#FF5A5A',
        },
        // Brand colors for model badges
        brand: {
          claude: '#D97757',
          openai: '#10A37F',
          gemini: '#4285F4',
          grok: '#A1A1A1',
          llama: '#0668E1',
          qwen: '#615CED',
          deepseek: '#4D6BFE',
        },
      },
      fontFamily: {
        sans: ['Inter', '-apple-system', 'BlinkMacSystemFont', 'system-ui', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'ui-monospace', 'SFMono-Regular', 'Menlo', 'monospace'],
        serif: ['"Source Serif 4"', '"Source Serif Pro"', 'Georgia', 'serif'],
      },
      fontSize: {
        '2xs': ['11px', { lineHeight: '16px', letterSpacing: '0.06em' }],
        'xs': ['13px', { lineHeight: '18px' }],
        'sm': ['14px', { lineHeight: '20px' }],
        'base': ['15px', { lineHeight: '24px' }],
        'md': ['16px', { lineHeight: '26px' }],
        'lg': ['18px', { lineHeight: '28px' }],
        'xl': ['22px', { lineHeight: '32px' }],
        '2xl': ['28px', { lineHeight: '38px' }],
        '3xl': ['36px', { lineHeight: '44px' }],
        '4xl': ['52px', { lineHeight: '60px' }],
        '5xl': ['72px', { lineHeight: '80px' }],
        '6xl': ['96px', { lineHeight: '104px' }],
        '7xl': ['120px', { lineHeight: '124px' }],
      },
      letterSpacing: {
        rail: '0.08em',
        tight: '-0.015em',
        tighter: '-0.025em',
        snug: '-0.005em',
      },
      borderRadius: {
        none: '0',
        sm: '2px',
        DEFAULT: '3px',
        md: '4px',
        lg: '6px',
        pill: '999px',
      },
      animation: {
        'fade-in': 'fadeIn 0.18s ease-out',
        'blink': 'blink 1s steps(2) infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        blink: {
          '50%': { opacity: '0' },
        },
      },
    },
  },
  plugins: [],
}
