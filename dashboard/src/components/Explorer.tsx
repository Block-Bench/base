import { useEffect, useState, useMemo } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import {
  Search,
  ChevronRight,
  X,
  SlidersHorizontal,
  Database,
  Tag,
  Layers,
  Clock,
  Award,
} from 'lucide-react'
import {
  loadDatasetIndex,
  filterSamples,
  getFilterOptions,
  formatCurrency,
  DATASETS,
  getSeverityClass,
} from '../data/loader'
import type { DatasetType, DatasetIndex, IndexSample, SubsetType } from '../types'
import Navigation from './Navigation'
import { MascotLoading } from './Mascot'

export default function Explorer() {
  const { datasetType = 'base' } = useParams<{ datasetType: string }>()
  const navigate = useNavigate()

  const [index, setIndex] = useState<DatasetIndex | null>(null)
  const [samples, setSamples] = useState<IndexSample[]>([])
  const [loading, setLoading] = useState(true)
  const [showFilters, setShowFilters] = useState(false)

  const [filters, setFilters] = useState({
    subset: 'all' as SubsetType | 'all',
    language: '',
    tier: '',
    severity: '',
    type: '',
    chain: '',
    search: '',
  })

  // Load dataset when type changes
  useEffect(() => {
    setLoading(true)
    loadDatasetIndex(datasetType as DatasetType).then((idx) => {
      setIndex(idx)
      setSamples(idx?.samples || [])
      setLoading(false)
    })
  }, [datasetType])

  // Filter samples
  const filteredSamples = useMemo(() => {
    return filterSamples(samples, {
      subset: filters.subset !== 'all' ? filters.subset as SubsetType : undefined,
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
    setFilters({
      subset: 'all',
      language: '',
      tier: '',
      severity: '',
      type: '',
      chain: '',
      search: '',
    })
  }

  const activeFilterCount = Object.entries(filters).filter(
    ([, value]) => value !== '' && value !== 'all'
  ).length

  const currentDataset = DATASETS.find((d) => d.id === datasetType)
  const isBase = datasetType === 'base'
  const isAnnotated = datasetType === 'annotated'

  // Get subset counts
  const subsetCounts = useMemo(() => {
    if (!samples.length) return { ds: 0, tc: 0, gs: 0 }
    return {
      ds: samples.filter((s) => s.id?.startsWith('ds_')).length,
      tc: samples.filter((s) => s.id?.startsWith('tc_')).length,
      gs: samples.filter((s) => s.id?.startsWith('gs_')).length,
    }
  }, [samples])

  return (
    <div className="min-h-screen bg-cream-100 dark:bg-neutral-950">
      <Navigation />

      {/* Header Section */}
      <div className="pt-24 pb-6 px-6 bg-white dark:bg-neutral-900 border-b border-cream-300 dark:border-neutral-800">
        <div className="max-w-7xl mx-auto">
          {/* Dataset Toggle */}
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
            <div className="toggle-group">
              <button
                onClick={() => navigate('/explorer/base')}
                className={isBase ? 'toggle-btn-active' : 'toggle-btn'}
              >
                <Database className="w-4 h-4 inline-block mr-1.5" />
                Base
              </button>
              <button
                onClick={() => navigate('/explorer/annotated')}
                className={isAnnotated ? 'toggle-btn-active' : 'toggle-btn'}
              >
                <Tag className="w-4 h-4 inline-block mr-1.5" />
                Annotated
              </button>
            </div>

            {/* Subset Filter Pills */}
            <div className="flex items-center gap-2 flex-wrap">
              <SubsetPill
                label="All"
                count={samples.length}
                active={filters.subset === 'all'}
                onClick={() => setFilters({ ...filters, subset: 'all' })}
              />
              <SubsetPill
                label="Stratified"
                count={subsetCounts.ds}
                icon={<Layers className="w-3 h-3" />}
                active={filters.subset === 'difficulty_stratified'}
                onClick={() =>
                  setFilters({ ...filters, subset: 'difficulty_stratified' })
                }
              />
              <SubsetPill
                label="Temporal"
                count={subsetCounts.tc}
                icon={<Clock className="w-3 h-3" />}
                active={filters.subset === 'temporal_contamination'}
                onClick={() =>
                  setFilters({ ...filters, subset: 'temporal_contamination' })
                }
              />
              <SubsetPill
                label="Gold"
                count={subsetCounts.gs}
                icon={<Award className="w-3 h-3" />}
                active={filters.subset === 'gold_standard'}
                onClick={() => setFilters({ ...filters, subset: 'gold_standard' })}
              />
            </div>
          </div>

          {/* Title & Stats */}
          <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
            <div>
              <h1 className="text-2xl font-light text-neutral-900 dark:text-white mb-1">
                {currentDataset?.name || 'Dataset Explorer'}
              </h1>
              <p className="text-sm text-neutral-500 dark:text-neutral-400">
                {loading
                  ? 'Loading...'
                  : `${filteredSamples.length} of ${samples.length} samples`}
              </p>
            </div>

            {/* Quick Stats */}
            {index && (
              <div className="flex gap-6">
                <StatBlock
                  value={index.statistics.total_samples.toString()}
                  label="Total"
                />
                <StatBlock
                  value={
                    Object.keys(index.statistics.by_vulnerability_type || {}).length.toString()
                  }
                  label="Vuln Types"
                />
                {index.statistics.by_original_subset && (
                  <StatBlock
                    value={Object.keys(index.statistics.by_original_subset).length.toString()}
                    label="Subsets"
                  />
                )}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Search & Filters */}
      <div className="sticky top-[73px] z-40 bg-cream-100 dark:bg-neutral-950 border-b border-cream-300 dark:border-neutral-800 py-4 px-6">
        <div className="max-w-7xl mx-auto">
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
              className={`btn-secondary ${showFilters ? 'bg-cream-300 dark:bg-neutral-700' : ''}`}
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
                {filterOptions.tiers.length > 0 && (
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
                {filterOptions.chains.length > 0 && (
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
                  className="flex items-center gap-2 text-sm text-neutral-500 dark:text-neutral-400 hover:text-neutral-700 dark:hover:text-neutral-200 mt-4"
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
        {loading ? (
          <div className="flex flex-col items-center justify-center py-20">
            <MascotLoading size={80} />
            <div className="text-neutral-400 dark:text-neutral-500 mt-4">
              Loading samples...
            </div>
          </div>
        ) : filteredSamples.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-20">
            <div className="text-neutral-400 dark:text-neutral-500 mb-2">
              No samples found
            </div>
            <button
              onClick={clearFilters}
              className="text-sm text-accent hover:underline"
            >
              Clear filters
            </button>
          </div>
        ) : (
          <div className="space-y-2">
            {filteredSamples.map((sample) => (
              <SampleCard
                key={sample.id}
                sample={sample}
                onClick={() => navigate(`/sample/${datasetType}/${sample.id}`)}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

function SubsetPill({
  label,
  count,
  icon,
  active,
  onClick,
}: {
  label: string
  count: number
  icon?: React.ReactNode
  active: boolean
  onClick: () => void
}) {
  return (
    <button
      onClick={onClick}
      className={`
        inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium transition-all duration-200
        ${active
          ? 'bg-neutral-900 text-white dark:bg-white dark:text-neutral-900'
          : 'bg-cream-200 dark:bg-neutral-800 text-neutral-600 dark:text-neutral-400 hover:bg-cream-300 dark:hover:bg-neutral-700'
        }
      `}
    >
      {icon}
      {label}
      <span className={`${active ? 'text-white/70 dark:text-neutral-900/70' : 'text-neutral-400 dark:text-neutral-500'}`}>
        {count}
      </span>
    </button>
  )
}

function StatBlock({ value, label }: { value: string; label: string }) {
  return (
    <div className="text-right">
      <div className="text-lg font-light text-neutral-800 dark:text-neutral-200">
        {value}
      </div>
      <div className="text-2xs text-neutral-400 dark:text-neutral-500">{label}</div>
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
      <label className="block text-2xs font-medium text-neutral-500 dark:text-neutral-400 mb-1.5 uppercase tracking-wide">
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
  onClick,
}: {
  sample: IndexSample
  onClick: () => void
}) {
  const isDS = sample.id?.startsWith('ds_')
  const isTC = sample.id?.startsWith('tc_')
  const isGS = sample.id?.startsWith('gs_')

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
            <span className="font-mono text-sm text-neutral-600 dark:text-neutral-300">
              {sample.id}
            </span>

            {/* Subset indicator */}
            {isDS && (
              <span className="badge-neutral">
                <Layers className="w-3 h-3 mr-1" />
                Stratified
              </span>
            )}
            {isTC && (
              <span className="badge-neutral">
                <Clock className="w-3 h-3 mr-1" />
                Temporal
              </span>
            )}
            {isGS && (
              <span className="badge-accent">
                <Award className="w-3 h-3 mr-1" />
                Gold
              </span>
            )}

            {sample.language && (
              <span className="badge-neutral capitalize">{sample.language}</span>
            )}

            {isDS && sample.difficulty_tier && (
              <span className="badge-neutral">
                Tier {sample.difficulty_tier} ·{' '}
                {tierLabels[sample.difficulty_tier] || sample.difficulty_tier_name}
              </span>
            )}

            {sample.severity && (
              <span className={`badge ${getSeverityClass(sample.severity)} capitalize`}>
                {sample.severity}
              </span>
            )}
          </div>

          <div className="flex items-center gap-4">
            {sample.vulnerability_type && (
              <span className="text-sm text-neutral-700 dark:text-neutral-300 capitalize">
                {sample.vulnerability_type.replace(/_/g, ' ')}
              </span>
            )}

            {isTC && sample.protocol_name && (
              <span className="text-sm text-neutral-500 dark:text-neutral-400">
                {sample.protocol_name}
                {sample.funds_lost_usd && ` · ${formatCurrency(sample.funds_lost_usd)}`}
              </span>
            )}

            {isGS && sample.source_platform && (
              <span className="text-sm text-neutral-500 dark:text-neutral-400 capitalize">
                {sample.source_platform}
              </span>
            )}
          </div>
        </div>

        <ChevronRight className="w-5 h-5 text-neutral-300 dark:text-neutral-600 group-hover:text-neutral-500 dark:group-hover:text-neutral-400 transition-colors flex-shrink-0" />
      </div>
    </button>
  )
}
