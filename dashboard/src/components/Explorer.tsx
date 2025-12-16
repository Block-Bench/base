import { useEffect, useState, useMemo } from 'react'
import { useNavigate, useParams, Link } from 'react-router-dom'
import { Search, ChevronRight, Layers, Clock, X, SlidersHorizontal } from 'lucide-react'
import { loadDatasetIndex, filterSamples, getFilterOptions, formatCurrency, DATASETS } from '../data/loader'
import type { DatasetType, ViewMode, DatasetIndex, IndexSample } from '../types'
import { Logo } from './Logo'
import { MascotLoading } from './Mascot'

export default function Explorer() {
  const { datasetType = 'difficulty_stratified' } = useParams<{ datasetType: DatasetType }>()
  const navigate = useNavigate()

  const [viewMode, setViewMode] = useState<ViewMode>('data')
  const [index, setIndex] = useState<DatasetIndex | null>(null)
  const [samples, setSamples] = useState<IndexSample[]>([])
  const [loading, setLoading] = useState(true)
  const [showFilters, setShowFilters] = useState(false)

  const [filters, setFilters] = useState({
    language: '',
    tier: '',
    severity: '',
    type: '',
    chain: '',
    search: '',
  })

  // Load dataset when type or view changes
  useEffect(() => {
    setLoading(true)
    loadDatasetIndex(datasetType as DatasetType, viewMode).then((idx) => {
      setIndex(idx)
      setSamples(idx?.samples || [])
      setLoading(false)
    })
  }, [datasetType, viewMode])

  // Filter samples
  const filteredSamples = useMemo(() => {
    return filterSamples(samples, {
      language: filters.language || undefined,
      tier: filters.tier ? parseInt(filters.tier) : undefined,
      severity: filters.severity || undefined,
      type: filters.type || undefined,
      chain: filters.chain || undefined,
      search: filters.search || undefined,
    })
  }, [samples, filters])

  // Get filter options
  const filterOptions = useMemo(() => getFilterOptions(samples), [samples])

  const clearFilters = () => {
    setFilters({ language: '', tier: '', severity: '', type: '', chain: '', search: '' })
  }

  const activeFilterCount = Object.values(filters).filter((v) => v !== '').length

  const currentDataset = DATASETS.find(d => d.id === datasetType)
  const isDifficultyStratified = datasetType === 'difficulty_stratified'
  const isTemporalContamination = datasetType === 'temporal_contamination'

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
              <span className="text-sm text-neutral-500">Explorer</span>
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

      {/* Header Section */}
      <div className="pt-24 pb-6 px-6 bg-white border-b border-cream-300">
        <div className="max-w-6xl mx-auto">
          {/* Dataset Toggle */}
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
            <div className="toggle-group">
              <button
                onClick={() => navigate('/explorer/difficulty_stratified')}
                className={isDifficultyStratified ? 'toggle-btn-active' : 'toggle-btn'}
              >
                <Layers className="w-4 h-4 inline-block mr-1.5" />
                Difficulty Stratified
              </button>
              <button
                onClick={() => navigate('/explorer/temporal_contamination')}
                className={isTemporalContamination ? 'toggle-btn-active' : 'toggle-btn'}
              >
                <Clock className="w-4 h-4 inline-block mr-1.5" />
                Temporal Contamination
              </button>
            </div>

            {/* View Mode Toggle */}
            <div className="toggle-group">
              <button
                onClick={() => setViewMode('data')}
                className={viewMode === 'data' ? 'toggle-btn-active' : 'toggle-btn'}
              >
                Clean Data
              </button>
              <button
                onClick={() => setViewMode('labelled')}
                className={viewMode === 'labelled' ? 'toggle-btn-active' : 'toggle-btn'}
              >
                Annotated
              </button>
            </div>
          </div>

          {/* Title & Stats */}
          <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
            <div>
              <h1 className="text-2xl font-light text-neutral-900 mb-1">
                {currentDataset?.name || 'Dataset Explorer'}
              </h1>
              <p className="text-sm text-neutral-500">
                {loading ? 'Loading...' : `${filteredSamples.length} of ${samples.length} samples`}
                {viewMode === 'labelled' && ' (with annotations)'}
              </p>
            </div>

            {/* Quick Stats */}
            {index && (
              <div className="flex gap-6">
                {isDifficultyStratified && index.statistics.by_tier_name && (
                  <>
                    {Object.entries(index.statistics.by_tier_name).map(([tier, count]) => (
                      <div key={tier} className="text-right">
                        <div className="text-lg font-light text-neutral-800">{count}</div>
                        <div className="text-2xs text-neutral-400 capitalize">{tier}</div>
                      </div>
                    ))}
                  </>
                )}
                {isTemporalContamination && (
                  <>
                    <div className="text-right">
                      <div className="text-lg font-light text-neutral-800">
                        {index.statistics.pre_cutoff_count || 0}
                      </div>
                      <div className="text-2xs text-neutral-400">Pre-Cutoff</div>
                    </div>
                    <div className="text-right">
                      <div className="text-lg font-light text-neutral-800">
                        {index.statistics.total_funds_lost_usd
                          ? formatCurrency(index.statistics.total_funds_lost_usd)
                          : '-'}
                      </div>
                      <div className="text-2xs text-neutral-400">Total Lost</div>
                    </div>
                  </>
                )}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Search & Filters */}
      <div className="sticky top-[73px] z-40 bg-cream-100 border-b border-cream-300 py-4 px-6">
        <div className="max-w-6xl mx-auto">
          <div className="flex gap-3">
            <div className="relative flex-1">
              <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 w-4 h-4 text-neutral-400" />
              <input
                type="text"
                placeholder="Search by ID, type, or protocol..."
                value={filters.search}
                onChange={(e) => setFilters({ ...filters, search: e.target.value })}
                className="input pl-11"
              />
            </div>
            <button
              onClick={() => setShowFilters(!showFilters)}
              className={`btn-secondary ${showFilters ? 'bg-cream-300' : ''}`}
            >
              <SlidersHorizontal className="w-4 h-4" />
              <span className="hidden sm:inline">Filters</span>
              {activeFilterCount > 0 && (
                <span className="w-5 h-5 bg-accent text-white text-xs rounded-full flex items-center justify-center">
                  {activeFilterCount}
                </span>
              )}
            </button>
          </div>

          {/* Filter Panel */}
          {showFilters && (
            <div className="mt-4 p-4 card animate-fade-in">
              <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-4">
                {filterOptions.languages.length > 0 && (
                  <FilterSelect
                    label="Language"
                    value={filters.language}
                    onChange={(v) => setFilters({ ...filters, language: v })}
                    options={filterOptions.languages}
                  />
                )}
                {isDifficultyStratified && filterOptions.tiers.length > 0 && (
                  <FilterSelect
                    label="Difficulty Tier"
                    value={filters.tier}
                    onChange={(v) => setFilters({ ...filters, tier: v })}
                    options={filterOptions.tiers.map(String)}
                    formatOption={(v) => `Tier ${v}`}
                  />
                )}
                {filterOptions.severities.length > 0 && (
                  <FilterSelect
                    label="Severity"
                    value={filters.severity}
                    onChange={(v) => setFilters({ ...filters, severity: v })}
                    options={filterOptions.severities}
                  />
                )}
                {filterOptions.types.length > 0 && (
                  <FilterSelect
                    label="Vulnerability"
                    value={filters.type}
                    onChange={(v) => setFilters({ ...filters, type: v })}
                    options={filterOptions.types}
                  />
                )}
                {isTemporalContamination && filterOptions.chains.length > 0 && (
                  <FilterSelect
                    label="Chain"
                    value={filters.chain}
                    onChange={(v) => setFilters({ ...filters, chain: v })}
                    options={filterOptions.chains}
                  />
                )}
              </div>
              {activeFilterCount > 0 && (
                <button
                  onClick={clearFilters}
                  className="flex items-center gap-2 text-sm text-neutral-500 hover:text-neutral-700 mt-4"
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
      <div className="max-w-6xl mx-auto px-6 py-6">
        {loading ? (
          <div className="flex flex-col items-center justify-center py-20">
            <MascotLoading size={80} />
            <div className="text-neutral-400 mt-4">Loading samples...</div>
          </div>
        ) : filteredSamples.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20">
            <div className="text-neutral-400 mb-2">No samples found</div>
            <button onClick={clearFilters} className="text-sm text-accent hover:underline">
              Clear filters
            </button>
          </div>
        ) : (
          <div className="space-y-2">
            {filteredSamples.map((sample) => (
              <SampleCard
                key={sample.id}
                sample={sample}
                datasetType={datasetType as DatasetType}
                onClick={() => navigate(`/sample/${datasetType}/${sample.id}?view=${viewMode}`)}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

function FilterSelect({
  label,
  value,
  onChange,
  options,
  formatOption,
}: {
  label: string
  value: string
  onChange: (value: string) => void
  options: string[]
  formatOption?: (option: string) => string
}) {
  return (
    <div>
      <label className="block text-2xs font-medium text-neutral-500 mb-1.5 uppercase tracking-wide">
        {label}
      </label>
      <select
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="input py-2 text-sm"
      >
        <option value="">All</option>
        {options.map((option) => (
          <option key={option} value={option}>
            {formatOption ? formatOption(option) : option.replace(/_/g, ' ')}
          </option>
        ))}
      </select>
    </div>
  )
}

function SampleCard({
  sample,
  datasetType,
  onClick,
}: {
  sample: IndexSample
  datasetType: DatasetType
  onClick: () => void
}) {
  const isDifficultyStratified = datasetType === 'difficulty_stratified'
  const isTemporalContamination = datasetType === 'temporal_contamination'

  const severityStyles: Record<string, string> = {
    critical: 'bg-neutral-900 text-white',
    high: 'bg-neutral-700 text-white',
    medium: 'bg-neutral-400 text-white',
    low: 'bg-neutral-200 text-neutral-700',
  }

  const tierLabels: Record<number, string> = {
    1: 'Textbook',
    2: 'Intermediate',
    3: 'Advanced',
    4: 'Expert',
  }

  return (
    <button
      onClick={onClick}
      className="w-full text-left card-hover p-4 group"
    >
      <div className="flex items-center justify-between gap-4">
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 mb-2 flex-wrap">
            <span className="font-mono text-sm text-neutral-600">{sample.id}</span>

            {sample.language && (
              <span className="badge-neutral capitalize">{sample.language}</span>
            )}

            {isDifficultyStratified && sample.difficulty_tier && (
              <span className="badge-neutral">
                Tier {sample.difficulty_tier} · {tierLabels[sample.difficulty_tier] || sample.difficulty_tier_name}
              </span>
            )}

            {sample.severity && (
              <span className={`badge ${severityStyles[sample.severity] || 'badge-neutral'} capitalize`}>
                {sample.severity}
              </span>
            )}
          </div>

          <div className="flex items-center gap-4">
            {sample.vulnerability_type && (
              <span className="text-sm text-neutral-700 capitalize">
                {sample.vulnerability_type.replace(/_/g, ' ')}
              </span>
            )}

            {isTemporalContamination && sample.protocol_name && (
              <span className="text-sm text-neutral-500">
                {sample.protocol_name}
                {sample.funds_lost_usd && ` · ${formatCurrency(sample.funds_lost_usd)}`}
              </span>
            )}
          </div>
        </div>

        <ChevronRight className="w-5 h-5 text-neutral-300 group-hover:text-neutral-500 transition-colors flex-shrink-0" />
      </div>
    </button>
  )
}
