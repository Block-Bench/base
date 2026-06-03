import type { ReactNode } from 'react'
import ProvenanceRail from './ProvenanceRail'
import ActivityBar from './ActivityBar'
import StatusBar from './StatusBar'
import CommandPalette from './CommandPalette'

export default function Shell({ children }: { children: ReactNode }) {
  return (
    <div className="h-screen w-screen flex flex-col bg-bg text-ink">
      <ProvenanceRail position="top" />
      <div className="flex-1 flex min-h-0">
        <ActivityBar />
        <main className="flex-1 min-w-0 flex flex-col">
          {children}
        </main>
      </div>
      <StatusBar />
      <CommandPalette />
    </div>
  )
}
