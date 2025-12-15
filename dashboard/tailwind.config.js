/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        anthropic: {
          cream: '#F5F3EE',
          dark: '#1A1A1A',
          orange: '#CC785C',
          beige: '#E8DED2',
        },
      },
      fontFamily: {
        sans: [
          '-apple-system',
          'BlinkMacSystemFont',
          'Inter',
          'system-ui',
          'sans-serif',
        ],
      },
    },
  },
  plugins: [],
}
