import { useEffect, useState, useRef } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight, ArrowUpRight } from 'lucide-react'
import { loadDatasetIndex } from '../data/loader'
import type { DatasetIndex } from '../types'
import Navigation from './Navigation'
import { Mascot } from './Mascot'

function useCounter(end: number, duration = 1800) {
  const [count, setCount] = useState(0)
  const ref = useRef(0)
  const startRef = useRef<number | null>(null)

  useEffect(() => {
    if (!end) return
    const animate = (ts: number) => {
      if (!startRef.current) startRef.current = ts
      const p = Math.min((ts - startRef.current) / duration, 1)
      const ease = 1 - Math.pow(1 - p, 4)
      const v = Math.floor(end * ease)
      if (v !== ref.current) { ref.current = v; setCount(v) }
      if (p < 1) requestAnimationFrame(animate)
    }
    requestAnimationFrame(animate)
  }, [end, duration])

  return count
}

export default function LandingPage() {
  const [idx, setIdx] = useState<DatasetIndex | null>(null)
  const [ready, setReady] = useState(false)

  useEffect(() => {
    loadDatasetIndex('base').then((i) => { setIdx(i); setReady(true) })
  }, [])

  const total = idx?.statistics.total_samples || 0
  const ds = idx?.composition?.difficulty_stratified?.count || 179
  const tc = idx?.composition?.temporal_contamination?.count || 50
  const gs = idx?.composition?.gold_standard?.count || 34

  const animTotal = useCounter(ready ? total || 263 : 0)
  const animDS = useCounter(ready ? ds : 0)
  const animTC = useCounter(ready ? tc : 0)
  const animGS = useCounter(ready ? gs : 0)

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-neutral-950">
      <Navigation />

      {/* Hero */}
      <section className="pt-32 pb-24 px-6">
        <div className="max-w-3xl mx-auto text-center">
          <div className="mb-10 flex justify-center">
            <div className="animate-float">
              <Mascot size={88} />
            </div>
          </div>

          <p className="text-sm font-medium text-accent tracking-wide uppercase mb-6 animate-fade-in">
            Open Source Research Benchmark
          </p>

          <h1 className="text-5xl md:text-6xl font-semibold tracking-tighter text-stone-600 dark:text-white mb-5 text-balance">
            BlockBench
          </h1>
          <p className="text-xl md:text-2xl font-light text-neutral-400 dark:text-neutral-500 mb-4 tracking-tight">
            AI Security Analysis Benchmark
          </p>

          <p className="text-base text-neutral-500 dark:text-neutral-500 max-w-xl mx-auto mb-12 leading-relaxed">
            A rigorous evaluation framework measuring whether AI models
            genuinely reason about smart contract vulnerabilities or merely
            pattern-match on memorized examples.
          </p>

          <div className="flex items-center justify-center gap-3">
            <Link to="/explorer/base" className="btn-primary py-3 px-6">
              Explore Dataset
              <ArrowRight className="w-4 h-4" />
            </Link>
            <Link to="/strategies" className="btn-secondary py-3 px-6">
              Try Strategies
            </Link>
          </div>
        </div>
      </section>

      {/* Stats */}
      <section className="py-20 border-t border-neutral-100 dark:border-neutral-800/50">
        <div className="max-w-4xl mx-auto px-6">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-12">
            <Stat value={animTotal || 263} label="Total Samples" />
            <Stat value={ready ? 3 : 0} label="Subsets" />
            <Stat value={ready ? 13 : 0} label="Vulnerability Types" />
            <Stat value={ready ? 7 : 0} label="Strategies" />
          </div>
        </div>
      </section>

      {/* Subsets */}
      <section className="py-24 px-6">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-2xl font-semibold tracking-tight text-stone-600 dark:text-white mb-2">
            Dataset
          </h2>
          <p className="text-neutral-500 dark:text-neutral-500 mb-12">
            Three complementary subsets designed to isolate different aspects of AI vulnerability analysis.
          </p>

          <div className="space-y-4 stagger">
            <SubsetRow
              number={animDS}
              label="Difficulty Stratified"
              description="Contracts from SmartBugs & DeFiVulnLabs, stratified across four difficulty tiers."
              href="/explorer/base"
            />
            <SubsetRow
              number={animTC}
              label="Temporal Contamination"
              description="Famous pre-cutoff DeFi exploits representing $1.65B+ in losses, with semantic-preserving transformations."
              href="/explorer/base"
            />
            <SubsetRow
              number={animGS}
              label="Gold Standard"
              description="Post-cutoff professional audit findings from Code4rena, Spearbit & MixBytes. Zero contamination."
              href="/explorer/base"
              accent
            />
          </div>
        </div>
      </section>

      {/* Research Questions */}
      <section className="py-24 px-6 border-t border-neutral-100 dark:border-neutral-800/50">
        <div className="max-w-4xl mx-auto">
          <h2 className="text-2xl font-semibold tracking-tight text-stone-600 dark:text-white mb-12">
            Research Questions
          </h2>

          <div className="grid gap-6 stagger">
            {[
              'What is the boundary between memorization and generalization in AI vulnerability detection?',
              'Can AI models reason about emergent vulnerabilities, or only recognize known patterns?',
              'How does explanation quality correlate with detection accuracy?',
              'How does performance degrade as reasoning context expands across contracts?',
            ].map((q, i) => (
              <div key={i} className="flex gap-5 group">
                <span className="text-xs font-mono text-neutral-300 dark:text-neutral-700 pt-0.5 shrink-0 w-6">
                  {String(i + 1).padStart(2, '0')}
                </span>
                <p className="text-neutral-600 dark:text-neutral-400 leading-relaxed">{q}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-10 px-6 border-t border-neutral-100 dark:border-neutral-800/50">
        <div className="max-w-4xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Mascot size={20} />
            <span className="text-xs text-neutral-400 dark:text-neutral-600">BlockBench</span>
          </div>
          <p className="text-xs text-neutral-400 dark:text-neutral-600">
            A rigorous benchmark for smart contract vulnerability detection
          </p>
        </div>
      </footer>
    </div>
  )
}

function Stat({ value, label }: { value: number; label: string }) {
  const animated = useCounter(value, 1500)
  return (
    <div className="text-center">
      <div className="text-4xl font-light tracking-tight text-stone-600 dark:text-white font-mono mb-1">
        {animated}
      </div>
      <div className="text-xs text-neutral-400 dark:text-neutral-600">{label}</div>
    </div>
  )
}

function SubsetRow({ number, label, description, href, accent }: {
  number: number; label: string; description: string; href: string; accent?: boolean
}) {
  return (
    <Link to={href} className="card-hover p-6 flex items-center gap-6 group">
      <span className={`text-3xl font-light font-mono tracking-tight w-16 shrink-0 ${accent ? 'text-accent' : 'text-neutral-300 dark:text-neutral-700'}`}>
        {number}
      </span>
      <div className="flex-1 min-w-0">
        <h3 className="font-medium text-stone-600 dark:text-white mb-0.5">{label}</h3>
        <p className="text-sm text-neutral-500 dark:text-neutral-500 leading-relaxed">{description}</p>
      </div>
      <ArrowUpRight className="w-4 h-4 text-neutral-300 dark:text-neutral-700 group-hover:text-neutral-500 transition-colors shrink-0" />
    </Link>
  )
}
