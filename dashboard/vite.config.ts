import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    fs: {
      // Allow serving files from parent directory
      allow: ['..'],
    },
  },
  publicDir: 'public',
  build: {
    outDir: 'dist',
    copyPublicDir: true,
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
