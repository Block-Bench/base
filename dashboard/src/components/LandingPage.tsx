import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { ArrowRight, Database, Shield, Layers, Code } from 'lucide-react'
import { loadDataset, generateSummary } from '../data/loader'
import type { DatasetSummary } from '../types'

export default function LandingPage() {
  const [summary, setSummary] = useState<DatasetSummary | null>(null)

  useEffect(() => {
    loadDataset().then((data) => {
      setSummary(generateSummary(data))
    })
  }, [])

  return (
    <div className="min-h-screen bg-anthropic-cream dark:bg-anthropic-dark">
      {/* Hero Section */}
      <div className="max-w-6xl mx-auto px-6 py-20">
        <div className="text-center space-y-6">
          <h1 className="text-6xl font-light tracking-tight text-gray-900 dark:text-gray-100">
            BlockBench
          </h1>
          <p className="text-xl text-gray-600 dark:text-gray-400 max-w-2xl mx-auto font-light">
            A rigorous benchmark to evaluate AI domain expertise in blockchain
            security
          </p>
          <div className="pt-8">
            <Link
              to="/explorer"
              className="inline-flex items-center gap-2 px-8 py-4 bg-anthropic-orange text-white rounded-full hover:bg-opacity-90 font-medium"
            >
              Explore Dataset
              <ArrowRight className="w-5 h-5" />
            </Link>
          </div>
        </div>

        {/* Stats Grid */}
        {summary && (
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 mt-20">
            <StatCard
              icon={<Database className="w-6 h-6" />}
              label="Total Samples"
              value={summary.total.toString()}
            />
            <StatCard
              icon={<Layers className="w-6 h-6" />}
              label="Languages"
              value={Object.keys(summary.by_language).length.toString()}
            />
            <StatCard
              icon={<Shield className="w-6 h-6" />}
              label="Vulnerability Types"
              value={Object.keys(summary.by_type).length.toString()}
            />
            <StatCard
              icon={<Code className="w-6 h-6" />}
              label="Difficulty Tiers"
              value="4"
            />
          </div>
        )}

        {/* Features Section */}
        <div className="mt-32 space-y-20">
          <Feature
            title="Difficulty Stratified"
            description="235 samples across 4 difficulty tiers, from textbook patterns to expert-level exploits requiring multi-step reasoning."
            stats={summary?.by_tier}
          />
          <Feature
            title="Multi-Language Support"
            description="Comprehensive coverage of Solidity (EVM) and Rust (Solana/Anchor) with plans to expand to Move and Cairo."
            stats={summary?.by_language}
            reverse
          />
          <Feature
            title="Research Quality"
            description="Sourced from SmartBugs, DeFiVulnLabs, Trail of Bits, and Coral XYZ. Every sample includes vulnerability description, fix recommendations, and metadata."
            stats={summary?.by_severity}
          />
        </div>

        {/* Research Goals */}
        <div className="mt-32 py-20 border-t border-gray-200 dark:border-gray-800">
          <h2 className="text-3xl font-light text-center mb-12">
            Research Questions
          </h2>
          <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
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
              question="How does performance degrade as reasoning context expands?"
            />
          </div>
        </div>

        {/* Footer */}
        <div className="mt-20 text-center text-sm text-gray-500">
          <p>Target Venue: NeurIPS (Datasets & Benchmarks Track)</p>
          <p className="mt-2">© 2025 BlockBench Project</p>
        </div>
      </div>
    </div>
  )
}

function StatCard({
  icon,
  label,
  value,
}: {
  icon: React.ReactNode
  label: string
  value: string
}) {
  return (
    <div className="bg-white dark:bg-gray-900 rounded-2xl p-6 border border-gray-200 dark:border-gray-800">
      <div className="text-anthropic-orange mb-3">{icon}</div>
      <div className="text-3xl font-light mb-1">{value}</div>
      <div className="text-sm text-gray-500">{label}</div>
    </div>
  )
}

function Feature({
  title,
  description,
  stats,
  reverse = false,
}: {
  title: string
  description: string
  stats?: Record<string, number>
  reverse?: boolean
}) {
  return (
    <div
      className={`flex flex-col ${
        reverse ? 'md:flex-row-reverse' : 'md:flex-row'
      } gap-12 items-center`}
    >
      <div className="flex-1 space-y-4">
        <h3 className="text-3xl font-light">{title}</h3>
        <p className="text-lg text-gray-600 dark:text-gray-400 leading-relaxed">
          {description}
        </p>
      </div>
      {stats && (
        <div className="flex-1 bg-white dark:bg-gray-900 rounded-2xl p-8 border border-gray-200 dark:border-gray-800">
          {Object.entries(stats)
            .sort(([, a], [, b]) => b - a)
            .slice(0, 5)
            .map(([key, value]) => (
              <div
                key={key}
                className="flex justify-between items-center py-3 border-b border-gray-100 dark:border-gray-800 last:border-0"
              >
                <span className="text-gray-700 dark:text-gray-300 capitalize">
                  {key.replace(/_/g, ' ')}
                </span>
                <span className="font-medium">{value}</span>
              </div>
            ))}
        </div>
      )}
    </div>
  )
}

function ResearchQuestion({
  number,
  question,
}: {
  number: string
  question: string
}) {
  return (
    <div className="space-y-2">
      <div className="text-anthropic-orange font-mono text-sm">{number}</div>
      <p className="text-gray-700 dark:text-gray-300 leading-relaxed">
        {question}
      </p>
    </div>
  )
}
