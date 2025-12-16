import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight, Layers, Clock, Database, Shield, FlaskConical } from 'lucide-react'
import { loadDatasetIndex, formatCurrency } from '../data/loader'
import type { DatasetIndex, DatasetType } from '../types'
import { Logo } from './Logo'
import { Mascot } from './Mascot'

export default function LandingPage() {
  const [indices, setIndices] = useState<Record<DatasetType, DatasetIndex | null>>({
    difficulty_stratified: null,
    temporal_contamination: null,
  })

  useEffect(() => {
    Promise.all([
      loadDatasetIndex('difficulty_stratified'),
      loadDatasetIndex('temporal_contamination'),
    ]).then(([ds, tc]) => {
      setIndices({
        difficulty_stratified: ds,
        temporal_contamination: tc,
      })
    })
  }, [])

  const totalSamples = Object.values(indices).reduce(
    (sum, idx) => sum + (idx?.statistics.total_samples || 0),
    0
  )

  const dsStats = indices.difficulty_stratified?.statistics
  const tcStats = indices.temporal_contamination?.statistics

  return (
    <div className="min-h-screen bg-cream-100">
      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 z-50 glass">
        <div className="max-w-6xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <Link to="/" className="flex items-center gap-2">
              <Logo size={32} />
              <span className="font-semibold text-neutral-800">BlockBench</span>
            </Link>
            <div className="flex items-center gap-6">
              <Link
                to="/explorer/difficulty_stratified"
                className="text-sm text-neutral-600 hover:text-neutral-800 transition-colors"
              >
                Explorer
              </Link>
              <a
                href="https://github.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-neutral-600 hover:text-neutral-800 transition-colors"
              >
                GitHub
              </a>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="pt-32 pb-20 px-6">
        <div className="max-w-4xl mx-auto text-center">
          {/* Mascot */}
          <div className="mb-8 flex justify-center">
            <Mascot size={120} />
          </div>

          <div className="inline-flex items-center gap-2 px-3 py-1.5 bg-cream-200 rounded-full text-sm text-neutral-600 mb-8">
            <FlaskConical className="w-4 h-4" />
            <span>NeurIPS 2025 Submission</span>
          </div>

          <h1 className="text-5xl md:text-6xl font-light tracking-tight text-neutral-900 mb-6 text-balance">
            Benchmark for AI
            <br />
            <span className="text-neutral-500">Security Analysis</span>
          </h1>

          <p className="text-xl text-neutral-500 max-w-2xl mx-auto mb-12 leading-relaxed">
            A rigorous evaluation framework to measure whether AI models genuinely
            reason about smart contract vulnerabilities or merely pattern-match
            on memorized examples.
          </p>

          <div className="flex items-center justify-center gap-4">
            <Link
              to="/explorer/difficulty_stratified"
              className="btn-primary py-3 px-6"
            >
              <span>Explore Dataset</span>
              <ArrowRight className="w-4 h-4" />
            </Link>
            <a
              href="#datasets"
              className="btn-secondary py-3 px-6"
            >
              Learn More
            </a>
          </div>
        </div>
      </section>

      {/* Stats Bar */}
      <section className="py-12 border-y border-cream-300 bg-white">
        <div className="max-w-6xl mx-auto px-6">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8">
            <Stat value={totalSamples.toString()} label="Total Samples" />
            <Stat value="4" label="Difficulty Tiers" />
            <Stat
              value={tcStats?.total_funds_lost_usd ? formatCurrency(tcStats.total_funds_lost_usd) : '-'}
              label="Historical Exploits"
            />
            <Stat value="2" label="Languages" />
          </div>
        </div>
      </section>

      {/* Datasets Section */}
      <section id="datasets" className="py-24 px-6">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-3xl font-light text-neutral-900 mb-4">
              Dataset Collections
            </h2>
            <p className="text-neutral-500 max-w-xl mx-auto">
              Multiple complementary datasets designed to test different aspects
              of AI security analysis capabilities.
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-6">
            <DatasetCard
              icon={<Layers className="w-6 h-6" />}
              title="Difficulty Stratified"
              description="235 samples organized into 4 difficulty tiers, from textbook patterns to expert-level exploits requiring multi-step reasoning."
              stats={[
                { label: 'Samples', value: dsStats?.total_samples?.toString() || '235' },
                { label: 'Tiers', value: '4' },
                { label: 'Languages', value: 'Solidity, Rust' },
              ]}
              href="/explorer/difficulty_stratified"
              available
            />

            <DatasetCard
              icon={<Clock className="w-6 h-6" />}
              title="Temporal Contamination"
              description="50 famous pre-cutoff DeFi exploits to measure memorization vs. genuine reasoning capabilities."
              stats={[
                { label: 'Samples', value: tcStats?.total_samples?.toString() || '50' },
                { label: 'Total Lost', value: tcStats?.total_funds_lost_usd ? formatCurrency(tcStats.total_funds_lost_usd) : '$3.2B' },
                { label: 'Era', value: '2016-2024' },
              ]}
              href="/explorer/temporal_contamination"
              available
            />

            <DatasetCard
              icon={<Shield className="w-6 h-6" />}
              title="Gold Standard"
              description="Post-cutoff high-quality vulnerabilities from Code4rena and Sherlock audits."
              stats={[
                { label: 'Status', value: 'Coming Soon' },
                { label: 'Target', value: '150+ samples' },
              ]}
              href="#"
              available={false}
            />

            <DatasetCard
              icon={<Database className="w-6 h-6" />}
              title="Adversarial Contrastive"
              description="Transformed variants to test robustness against surface-level changes and semantic decoys."
              stats={[
                { label: 'Status', value: 'Coming Soon' },
                { label: 'Strategies', value: '12 types' },
              ]}
              href="#"
              available={false}
            />
          </div>
        </div>
      </section>

      {/* Research Questions */}
      <section className="py-24 px-6 bg-white border-t border-cream-300">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-16">
            <h2 className="text-3xl font-light text-neutral-900 mb-4">
              Research Questions
            </h2>
            <p className="text-neutral-500">
              Core hypotheses we aim to test with this benchmark.
            </p>
          </div>

          <div className="space-y-6">
            <ResearchQuestion
              number="01"
              question="What is the boundary between memorization and generalization in AI vulnerability detection?"
            />
            <ResearchQuestion
              number="02"
              question="Can AI models reason about emergent vulnerabilities, or only recognize known patterns?"
            />
            <ResearchQuestion
              number="03"
              question="How does explanation quality correlate with detection accuracy?"
            />
            <ResearchQuestion
              number="04"
              question="How does performance degrade as reasoning context expands across contracts?"
            />
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-12 px-6 border-t border-cream-300">
        <div className="max-w-6xl mx-auto">
          <div className="flex flex-col md:flex-row items-center justify-between gap-4">
            <div className="flex items-center gap-2">
              <Logo size={24} />
              <span className="text-sm text-neutral-600">BlockBench</span>
            </div>
            <p className="text-sm text-neutral-500">
              Target Venue: NeurIPS 2025 (Datasets & Benchmarks Track)
            </p>
          </div>
        </div>
      </footer>
    </div>
  )
}

function Stat({ value, label }: { value: string; label: string }) {
  return (
    <div className="text-center">
      <div className="text-3xl font-light text-neutral-900 mb-1">{value}</div>
      <div className="text-sm text-neutral-500">{label}</div>
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
        available ? 'hover:border-cream-400 hover:shadow-soft-md cursor-pointer' : 'opacity-60'
      } transition-all duration-200`}
    >
      <div className="flex items-start justify-between mb-4">
        <div className="p-2.5 bg-cream-200 rounded-lg text-neutral-700">
          {icon}
        </div>
        {!available && (
          <span className="badge-neutral text-2xs">Coming Soon</span>
        )}
      </div>

      <h3 className="text-lg font-medium text-neutral-900 mb-2">{title}</h3>
      <p className="text-sm text-neutral-500 mb-6 leading-relaxed">{description}</p>

      <div className="grid grid-cols-3 gap-4 pt-4 border-t border-cream-200">
        {stats.map((stat) => (
          <div key={stat.label}>
            <div className="text-sm font-medium text-neutral-800">{stat.value}</div>
            <div className="text-2xs text-neutral-400">{stat.label}</div>
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

function ResearchQuestion({
  number,
  question,
}: {
  number: string
  question: string
}) {
  return (
    <div className="flex gap-6 p-6 card">
      <div className="flex-shrink-0 w-10 h-10 bg-cream-200 rounded-lg flex items-center justify-center">
        <span className="text-sm font-mono text-neutral-600">{number}</span>
      </div>
      <p className="text-neutral-700 leading-relaxed pt-2">{question}</p>
    </div>
  )
}
