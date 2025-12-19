import { useEffect, useState, useRef } from 'react'
import { Link } from 'react-router-dom'
import {
  ArrowRight,
  Database,
  Tag,
  Layers,
  Clock,
  Award,
  Sparkles,
  TrendingUp,
  Shield,
  Brain,
} from 'lucide-react'
import { loadDatasetIndex } from '../data/loader'
import type { DatasetIndex } from '../types'
import Navigation from './Navigation'
import { Mascot } from './Mascot'

// Animated counter hook
function useAnimatedCounter(end: number, duration: number = 2000, start: number = 0) {
  const [count, setCount] = useState(start)
  const countRef = useRef(start)
  const startTimeRef = useRef<number | null>(null)

  useEffect(() => {
    if (end === 0) return

    const animate = (timestamp: number) => {
      if (!startTimeRef.current) startTimeRef.current = timestamp
      const progress = Math.min((timestamp - startTimeRef.current) / duration, 1)

      // Easing function for smooth animation
      const easeOutQuart = 1 - Math.pow(1 - progress, 4)
      const currentCount = Math.floor(start + (end - start) * easeOutQuart)

      if (currentCount !== countRef.current) {
        countRef.current = currentCount
        setCount(currentCount)
      }

      if (progress < 1) {
        requestAnimationFrame(animate)
      }
    }

    requestAnimationFrame(animate)
  }, [end, duration, start])

  return count
}

// Typing animation component
function TypedText({ text, className = '' }: { text: string; className?: string }) {
  const [displayText, setDisplayText] = useState('')
  const [showCursor, setShowCursor] = useState(true)

  useEffect(() => {
    let index = 0
    const timer = setInterval(() => {
      if (index < text.length) {
        setDisplayText(text.slice(0, index + 1))
        index++
      } else {
        clearInterval(timer)
        // Blink cursor a few times then hide
        setTimeout(() => setShowCursor(false), 2000)
      }
    }, 50)

    return () => clearInterval(timer)
  }, [text])

  return (
    <span className={className}>
      {displayText}
      {showCursor && <span className="animate-blink border-r-2 border-accent ml-0.5">&nbsp;</span>}
    </span>
  )
}

export default function LandingPage() {
  const [baseIndex, setBaseIndex] = useState<DatasetIndex | null>(null)
  const [loaded, setLoaded] = useState(false)

  useEffect(() => {
    loadDatasetIndex('base').then((idx) => {
      setBaseIndex(idx)
      setLoaded(true)
    })
  }, [])

  const totalSamples = baseIndex?.statistics.total_samples || 0
  const animatedTotal = useAnimatedCounter(loaded ? totalSamples : 0, 1500)

  // Calculate subset counts from composition
  const dsCount = baseIndex?.composition?.difficulty_stratified?.count || 179
  const tcCount = baseIndex?.composition?.temporal_contamination?.count || 50
  const gsCount = baseIndex?.composition?.gold_standard?.count || 34

  return (
    <div className="min-h-screen bg-cream-100 dark:bg-neutral-950">
      <Navigation />

      {/* Hero Section */}
      <section className="pt-32 pb-20 px-6 relative overflow-hidden">
        {/* Background grid */}
        <div className="absolute inset-0 bg-grid opacity-50" />

        <div className="max-w-5xl mx-auto text-center relative">
          {/* Mascot */}
          <div className="mb-8 flex justify-center">
            <div className="animate-float">
              <Mascot size={120} />
            </div>
          </div>

          <div className="inline-flex items-center gap-2 px-4 py-2 bg-cream-200 dark:bg-neutral-800 rounded-full text-sm text-neutral-600 dark:text-neutral-400 mb-8 animate-fade-in">
            <Sparkles className="w-4 h-4" />
            <span>Open Source Research Benchmark</span>
          </div>

          <h1 className="text-5xl md:text-6xl lg:text-7xl font-light tracking-tight text-neutral-900 dark:text-white mb-6 text-balance">
            <TypedText text="BlockBench" className="block" />
            <span className="text-neutral-500 dark:text-neutral-400 text-4xl md:text-5xl lg:text-6xl block mt-2">
              AI Security Analysis Benchmark
            </span>
          </h1>

          <p className="text-lg md:text-xl text-neutral-500 dark:text-neutral-400 max-w-3xl mx-auto mb-12 leading-relaxed animate-fade-in">
            A rigorous evaluation framework to measure whether AI models genuinely
            reason about smart contract vulnerabilities or merely pattern-match
            on memorized examples.
          </p>

          <div className="flex items-center justify-center gap-4 animate-slide-up stagger-children">
            <Link to="/explorer/base" className="btn-primary py-3 px-6">
              <span>Explore Dataset</span>
              <ArrowRight className="w-4 h-4" />
            </Link>
            <Link to="/strategies" className="btn-secondary py-3 px-6">
              <Sparkles className="w-4 h-4" />
              Try Strategies
            </Link>
          </div>
        </div>
      </section>

      {/* Stats Bar */}
      <section className="py-16 border-y border-cream-300 dark:border-neutral-800 bg-white dark:bg-neutral-900 relative">
        <div className="absolute inset-0 bg-grid opacity-30" />
        <div className="max-w-6xl mx-auto px-6 relative">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            <AnimatedStat value={animatedTotal || 263} label="Total Samples" />
            <AnimatedStat value={loaded ? 3 : 0} label="Dataset Subsets" />
            <AnimatedStat
              value={loaded ? 13 : 0}
              label="Vulnerability Types"
            />
            <AnimatedStat value={loaded ? 7 : 0} label="Adversarial Strategies" />
          </div>
        </div>
      </section>

      {/* Dataset Collections */}
      <section id="datasets" className="py-24 px-6">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-light text-neutral-900 dark:text-white mb-4">
              Dataset Collections
            </h2>
            <p className="text-neutral-500 dark:text-neutral-400 max-w-xl mx-auto">
              Multiple complementary datasets designed to test different aspects
              of AI security analysis capabilities.
            </p>
          </div>

          {/* Main datasets */}
          <div className="grid md:grid-cols-2 gap-6 mb-6">
            <DatasetCard
              icon={<Database className="w-6 h-6" />}
              title="Base Dataset"
              description="Clean contract code without annotations. All 263 vulnerable samples organized by source subset."
              stats={[
                { label: 'Samples', value: totalSamples.toString() },
                { label: 'Stratified', value: dsCount.toString() },
                { label: 'Temporal', value: tcCount.toString() },
              ]}
              href="/explorer/base"
              available
            />

            <DatasetCard
              icon={<Tag className="w-6 h-6" />}
              title="Annotated Dataset"
              description="Rich vulnerability annotations with location markers, fix suggestions, and detailed metadata."
              stats={[
                { label: 'Samples', value: totalSamples.toString() },
                { label: 'Line Labels', value: 'Yes' },
                { label: 'Fix Guide', value: 'Yes' },
              ]}
              href="/explorer/annotated"
              available
            />
          </div>

          {/* Subset cards */}
          <div className="grid md:grid-cols-3 gap-6 mb-12">
            <SubsetCard
              icon={<Layers className="w-5 h-5" />}
              title="Difficulty Stratified"
              description="Contracts from SmartBugs, Trail of Bits stratified by severity."
              count={dsCount}
              color="neutral"
            />

            <SubsetCard
              icon={<Clock className="w-5 h-5" />}
              title="Temporal Contamination"
              description="Famous pre-cutoff DeFi exploits to measure memorization."
              count={tcCount}
              color="neutral"
            />

            <SubsetCard
              icon={<Award className="w-5 h-5" />}
              title="Gold Standard"
              description="Post-cutoff audits from Code4rena, Spearbit & MixBytes."
              count={gsCount}
              color="accent"
            />
          </div>

          {/* Strategy link */}
          <div className="text-center">
            <Link
              to="/strategies"
              className="inline-flex items-center gap-3 px-6 py-4 bg-cream-200 dark:bg-neutral-800 rounded-xl text-neutral-700 dark:text-neutral-300 hover:bg-cream-300 dark:hover:bg-neutral-700 transition-all duration-200 group"
            >
              <Sparkles className="w-5 h-5 text-accent" />
              <span className="font-medium">Try 7 Adversarial Strategies</span>
              <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
            </Link>
          </div>
        </div>
      </section>

      {/* Research Questions */}
      <section className="py-24 px-6 bg-white dark:bg-neutral-900 border-t border-cream-300 dark:border-neutral-800 relative">
        <div className="absolute inset-0 bg-grid opacity-20" />
        <div className="max-w-4xl mx-auto relative">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-light text-neutral-900 dark:text-white mb-4">
              Research Questions
            </h2>
            <p className="text-neutral-500 dark:text-neutral-400">
              Core hypotheses we aim to test with this benchmark.
            </p>
          </div>

          <div className="space-y-6 stagger-children">
            <ResearchQuestion
              number="01"
              icon={<TrendingUp className="w-5 h-5" />}
              question="What is the boundary between memorization and generalization in AI vulnerability detection?"
            />
            <ResearchQuestion
              number="02"
              icon={<Brain className="w-5 h-5" />}
              question="Can AI models reason about emergent vulnerabilities, or only recognize known patterns?"
            />
            <ResearchQuestion
              number="03"
              icon={<Shield className="w-5 h-5" />}
              question="How does explanation quality correlate with detection accuracy?"
            />
            <ResearchQuestion
              number="04"
              icon={<Layers className="w-5 h-5" />}
              question="How does performance degrade as reasoning context expands across contracts?"
            />
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-12 px-6 border-t border-cream-300 dark:border-neutral-800">
        <div className="max-w-6xl mx-auto">
          <div className="flex flex-col md:flex-row items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <Mascot size={32} />
              <span className="text-sm font-medium text-neutral-600 dark:text-neutral-400">
                BlockBench
              </span>
            </div>
            <p className="text-sm text-neutral-500 dark:text-neutral-500">
              A rigorous benchmark for smart contract vulnerability detection
            </p>
          </div>
        </div>
      </footer>
    </div>
  )
}

function AnimatedStat({ value, label }: { value: number; label: string }) {
  const animatedValue = useAnimatedCounter(value, 1500)

  return (
    <div className="text-center">
      <div className="text-4xl md:text-5xl font-light text-neutral-900 dark:text-white mb-2 font-mono">
        {animatedValue}
      </div>
      <div className="text-sm text-neutral-500 dark:text-neutral-400">{label}</div>
    </div>
  )
}

function DatasetCard({
  icon,
  title,
  description,
  stats,
  href,
  available,
}: {
  icon: React.ReactNode
  title: string
  description: string
  stats: { label: string; value: string }[]
  href: string
  available: boolean
}) {
  const content = (
    <div
      className={`card p-6 h-full ${
        available ? 'hover:border-cream-400 dark:hover:border-neutral-700 hover:shadow-soft-md dark:hover:shadow-dark-soft-md cursor-pointer group' : 'opacity-60'
      } transition-all duration-200`}
    >
      <div className="flex items-start justify-between mb-4">
        <div className="p-3 bg-cream-200 dark:bg-neutral-800 rounded-xl text-neutral-700 dark:text-neutral-300 group-hover:bg-cream-300 dark:group-hover:bg-neutral-700 transition-colors">
          {icon}
        </div>
        {!available && <span className="badge-neutral text-2xs">Coming Soon</span>}
      </div>

      <h3 className="text-lg font-medium text-neutral-900 dark:text-white mb-2">{title}</h3>
      <p className="text-sm text-neutral-500 dark:text-neutral-400 mb-6 leading-relaxed">
        {description}
      </p>

      <div className="grid grid-cols-3 gap-4 pt-4 border-t border-cream-200 dark:border-neutral-800">
        {stats.map((stat) => (
          <div key={stat.label}>
            <div className="text-sm font-medium text-neutral-800 dark:text-neutral-200">
              {stat.value}
            </div>
            <div className="text-2xs text-neutral-400 dark:text-neutral-500">{stat.label}</div>
          </div>
        ))}
      </div>
    </div>
  )

  if (available) {
    return <Link to={href}>{content}</Link>
  }

  return content
}

function SubsetCard({
  icon,
  title,
  description,
  count,
  color,
}: {
  icon: React.ReactNode
  title: string
  description: string
  count: number
  color: 'neutral' | 'accent'
}) {
  return (
    <div className="card p-5">
      <div className="flex items-center gap-3 mb-3">
        <div
          className={`p-2 rounded-lg ${
            color === 'accent'
              ? 'bg-accent/10 text-accent'
              : 'bg-cream-200 dark:bg-neutral-800 text-neutral-600 dark:text-neutral-400'
          }`}
        >
          {icon}
        </div>
        <div className="flex-1">
          <h4 className="font-medium text-neutral-800 dark:text-neutral-200">{title}</h4>
        </div>
        <span
          className={`text-lg font-mono font-light ${
            color === 'accent' ? 'text-accent' : 'text-neutral-600 dark:text-neutral-400'
          }`}
        >
          {count}
        </span>
      </div>
      <p className="text-xs text-neutral-500 dark:text-neutral-400 leading-relaxed">
        {description}
      </p>
    </div>
  )
}

function ResearchQuestion({
  number,
  icon,
  question,
}: {
  number: string
  icon: React.ReactNode
  question: string
}) {
  return (
    <div className="flex gap-6 p-6 card group hover:border-cream-400 dark:hover:border-neutral-700 transition-all duration-200">
      <div className="flex-shrink-0 w-12 h-12 bg-cream-200 dark:bg-neutral-800 rounded-xl flex items-center justify-center group-hover:bg-cream-300 dark:group-hover:bg-neutral-700 transition-colors">
        <span className="text-neutral-600 dark:text-neutral-400">{icon}</span>
      </div>
      <div>
        <span className="text-2xs font-mono text-accent mb-2 block">{number}</span>
        <p className="text-neutral-700 dark:text-neutral-300 leading-relaxed">{question}</p>
      </div>
    </div>
  )
}
