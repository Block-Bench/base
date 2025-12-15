import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Search, Filter, X } from 'lucide-react'
import { loadDataset, filterSamples } from '../data/loader'
import type { VulnerabilitySample } from '../types'

export default function Explorer() {
  const [data, setData] = useState<VulnerabilitySample[]>([])
  const [filteredData, setFilteredData] = useState<VulnerabilitySample[]>([])
  const [filters, setFilters] = useState({
    language: '',
    tier: '',
    severity: '',
    type: '',
    search: '',
  })
  const [showFilters, setShowFilters] = useState(false)
  const navigate = useNavigate()

  useEffect(() => {
    loadDataset().then((dataset) => {
      setData(dataset)
      setFilteredData(dataset)
    })
  }, [])

  useEffect(() => {
    const filtered = filterSamples(data, {
      language: filters.language || undefined,
      tier: filters.tier ? parseInt(filters.tier) : undefined,
      severity: filters.severity || undefined,
      type: filters.type || undefined,
      search: filters.search || undefined,
    })
    setFilteredData(filtered)
  }, [filters, data])

  const uniqueLanguages = [...new Set(data.map((d) => d.language))]
  const uniqueSeverities = [...new Set(data.map((d) => d.severity))]
  const uniqueTypes = [...new Set(data.map((d) => d.vulnerability_type))].sort()

  const clearFilters = () => {
    setFilters({ language: '', tier: '', severity: '', type: '', search: '' })
  }

  const activeFilterCount = Object.values(filters).filter((v) => v !== '')
    .length

  return (
    <div className="min-h-screen bg-anthropic-dark text-gray-100">
      {/* Header */}
      <div className="border-b border-gray-800 bg-gray-900">
        <div className="max-w-7xl mx-auto px-6 py-6">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-2xl font-light">Dataset Explorer</h1>
              <p className="text-sm text-gray-400 mt-1">
                {filteredData.length} of {data.length} samples
              </p>
            </div>
            <button
              onClick={() => setShowFilters(!showFilters)}
              className="flex items-center gap-2 px-4 py-2 bg-gray-800 hover:bg-gray-700 rounded-lg"
            >
              <Filter className="w-4 h-4" />
              Filters
              {activeFilterCount > 0 && (
                <span className="bg-anthropic-orange text-white text-xs px-2 py-0.5 rounded-full">
                  {activeFilterCount}
                </span>
              )}
            </button>
          </div>

          {/* Search Bar */}
          <div className="relative">
            <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Search by ID, type, or description..."
              value={filters.search}
              onChange={(e) =>
                setFilters({ ...filters, search: e.target.value })
              }
              className="w-full pl-12 pr-4 py-3 bg-gray-800 border border-gray-700 rounded-lg focus:outline-none focus:border-anthropic-orange"
            />
          </div>

          {/* Filters */}
          {showFilters && (
            <div className="mt-4 p-4 bg-gray-800 rounded-lg space-y-4">
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <FilterSelect
                  label="Language"
                  value={filters.language}
                  onChange={(v) => setFilters({ ...filters, language: v })}
                  options={uniqueLanguages}
                />
                <FilterSelect
                  label="Difficulty Tier"
                  value={filters.tier}
                  onChange={(v) => setFilters({ ...filters, tier: v })}
                  options={['1', '2', '3', '4']}
                />
                <FilterSelect
                  label="Severity"
                  value={filters.severity}
                  onChange={(v) => setFilters({ ...filters, severity: v })}
                  options={uniqueSeverities}
                />
                <FilterSelect
                  label="Vulnerability Type"
                  value={filters.type}
                  onChange={(v) => setFilters({ ...filters, type: v })}
                  options={uniqueTypes}
                />
              </div>
              {activeFilterCount > 0 && (
                <button
                  onClick={clearFilters}
                  className="flex items-center gap-2 text-sm text-gray-400 hover:text-gray-200"
                >
                  <X className="w-4 h-4" />
                  Clear all filters
                </button>
              )}
            </div>
          )}
        </div>
      </div>

      {/* Sample List */}
      <div className="max-w-7xl mx-auto px-6 py-6">
        <div className="space-y-2">
          {filteredData.map((sample) => (
            <SampleCard
              key={sample.id}
              sample={sample}
              onClick={() => navigate(`/sample/${sample.id}`)}
            />
          ))}
        </div>
      </div>
    </div>
  )
}

function FilterSelect({
  label,
  value,
  onChange,
  options,
}: {
  label: string
  value: string
  onChange: (value: string) => void
  options: string[]
}) {
  return (
    <div>
      <label className="block text-sm text-gray-400 mb-2">{label}</label>
      <select
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="w-full px-3 py-2 bg-gray-900 border border-gray-700 rounded-lg focus:outline-none focus:border-anthropic-orange capitalize"
      >
        <option value="">All</option>
        {options.map((option) => (
          <option key={option} value={option} className="capitalize">
            {option.replace(/_/g, ' ')}
          </option>
        ))}
      </select>
    </div>
  )
}

function SampleCard({
  sample,
  onClick,
}: {
  sample: VulnerabilitySample
  onClick: () => void
}) {
  const severityColors = {
    critical: 'bg-red-500',
    high: 'bg-orange-500',
    medium: 'bg-yellow-500',
    low: 'bg-blue-500',
  }

  const tierLabels = {
    1: 'Easy',
    2: 'Medium',
    3: 'Hard',
    4: 'Expert',
  }

  return (
    <button
      onClick={onClick}
      className="w-full text-left p-4 bg-gray-900 hover:bg-gray-850 border border-gray-800 hover:border-gray-700 rounded-lg transition-colors"
    >
      <div className="flex items-start justify-between gap-4">
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-3 mb-2">
            <span className="font-mono text-sm text-gray-400">{sample.id}</span>
            <span className="text-xs px-2 py-1 bg-gray-800 rounded text-gray-400 capitalize">
              {sample.language}
            </span>
            <span className="text-xs px-2 py-1 bg-gray-800 rounded text-gray-400">
              Tier {sample.difficulty_tier} -{' '}
              {tierLabels[sample.difficulty_tier as keyof typeof tierLabels]}
            </span>
          </div>
          <div className="text-sm text-gray-300 capitalize mb-1">
            {sample.vulnerability_type.replace(/_/g, ' ')}
          </div>
          <div className="text-sm text-gray-500 line-clamp-2">
            {sample.description}
          </div>
        </div>
        <div className="flex-shrink-0">
          <div
            className={`w-2 h-2 rounded-full ${
              severityColors[sample.severity as keyof typeof severityColors]
            }`}
          />
        </div>
      </div>
    </button>
  )
}
