import { useEffect, useState, useMemo } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { Search, X, SlidersHorizontal, ArrowUpRight } from 'lucide-react'
import {
  loadDatasetIndex, filterSamples, getFilterOptions, formatCurrency, DATASETS, getSeverityClass,
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
    language: '', tier: '', severity: '', type: '', chain: '', search: '',
  })

  useEffect(() => {
    setLoading(true)
    loadDatasetIndex(datasetType as DatasetType).then((idx) => {
      setIndex(idx); setSamples(idx?.samples || []); setLoading(false)
    })
  }, [datasetType])

  const filteredSamples = useMemo(() => filterSamples(samples, {
    subset: filters.subset !== 'all' ? filters.subset as SubsetType : undefined,
    language: filters.language || undefined, tier: filters.tier ? parseInt(filters.tier) : undefined,
    severity: filters.severity || undefined, type: filters.type || undefined,
    chain: filters.chain || undefined, search: filters.search || undefined,
  }), [samples, filters])

  const filterOptions = useMemo(() => getFilterOptions(samples), [samples])
  const clearFilters = () => setFilters({ subset: 'all', language: '', tier: '', severity: '', type: '', chain: '', search: '' })
  const activeFilterCount = Object.entries(filters).filter(([, v]) => v !== '' && v !== 'all').length
  const currentDataset = DATASETS.find((d) => d.id === datasetType)
  const isBase = datasetType === 'base'
  const isAnnotated = datasetType === 'annotated'
  const subsetCounts = useMemo(() => {
    if (!samples.length) return { ds: 0, tc: 0, gs: 0 }
    return {
      ds: samples.filter((s) => s.id?.startsWith('ds_')).length,
      tc: samples.filter((s) => s.id?.startsWith('tc_')).length,
      gs: samples.filter((s) => s.id?.startsWith('gs_')).length,
    }
  }, [samples])

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-neutral-950">
      <Navigation />

      {/* Header */}
      <div className="pt-20 px-6">
        <div className="max-w-6xl mx-auto py-8">
          <div className="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-8">
            <div>
              <h1 className="text-2xl font-semibold tracking-tight text-stone-600 dark:text-white mb-1">
                {currentDataset?.name || 'Dataset Explorer'}
              </h1>
              <p className="text-sm text-stone-400 dark:text-neutral-500">
                {loading ? 'Loading...' : `${filteredSamples.length} of ${samples.length} samples`}
              </p>
            </div>
            {index && (
              <div className="flex gap-8">
                <StatNum value={index.statistics.total_samples.toString()} label="Total" />
                <StatNum value={Object.keys(index.statistics.by_vulnerability_type || {}).length.toString()} label="Types" />
              </div>
            )}
          </div>

          {/* Controls */}
          <div className="flex flex-wrap items-center gap-1.5">
            <Pill label="Base" active={isBase} onClick={() => navigate('/explorer/base')} />
            <Pill label="Annotated" active={isAnnotated} onClick={() => navigate('/explorer/annotated')} />
            <div className="w-px h-4 bg-stone-200 dark:bg-neutral-800 mx-1" />
            <Pill label={`All ${samples.length}`} active={filters.subset === 'all'} onClick={() => setFilters({ ...filters, subset: 'all' })} />
            <Pill label={`DS ${subsetCounts.ds}`} active={filters.subset === 'difficulty_stratified'} onClick={() => setFilters({ ...filters, subset: 'difficulty_stratified' })} />
            <Pill label={`TC ${subsetCounts.tc}`} active={filters.subset === 'temporal_contamination'} onClick={() => setFilters({ ...filters, subset: 'temporal_contamination' })} />
            <Pill label={`GS ${subsetCounts.gs}`} active={filters.subset === 'gold_standard'} onClick={() => setFilters({ ...filters, subset: 'gold_standard' })} accent />
          </div>
        </div>
      </div>

      {/* Search */}
      <div className="sticky top-14 z-40 bg-stone-50/90 dark:bg-neutral-950/90 backdrop-blur-xl border-y border-stone-200/50 dark:border-neutral-800/50">
        <div className="max-w-6xl mx-auto px-6 py-3 flex gap-2">
          <div className="relative flex-1">
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-stone-400" />
            <input
              type="text" placeholder="Search by ID, type, or protocol..."
              value={filters.search} onChange={(e) => setFilters({ ...filters, search: e.target.value })}
              className="input pl-10 py-2"
            />
          </div>
          <button
            onClick={() => setShowFilters(!showFilters)}
            className={`btn-secondary px-3 ${showFilters ? 'bg-stone-100 dark:bg-neutral-800' : ''}`}
          >
            <SlidersHorizontal className="w-4 h-4" />
            {activeFilterCount > 0 && (
              <span className="w-4 h-4 bg-stone-600 dark:bg-white text-white dark:text-neutral-900 text-2xs rounded-full flex items-center justify-center">{activeFilterCount}</span>
            )}
          </button>
        </div>
        {showFilters && (
          <div className="max-w-6xl mx-auto px-6 pb-4 animate-fade-in">
            <div className="card p-4">
              <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-3">
                {filterOptions.languages.length > 0 && <FilterSelect label="Language" value={filters.language} onChange={(v) => setFilters({ ...filters, language: v })} options={filterOptions.languages} />}
                {filterOptions.tiers.length > 0 && <FilterSelect label="Tier" value={filters.tier} onChange={(v) => setFilters({ ...filters, tier: v })} options={filterOptions.tiers.map(String)} formatOption={(v) => `Tier ${v}`} />}
                {filterOptions.severities.length > 0 && <FilterSelect label="Severity" value={filters.severity} onChange={(v) => setFilters({ ...filters, severity: v })} options={filterOptions.severities} />}
                {filterOptions.types.length > 0 && <FilterSelect label="Vulnerability" value={filters.type} onChange={(v) => setFilters({ ...filters, type: v })} options={filterOptions.types} />}
                {filterOptions.chains.length > 0 && <FilterSelect label="Chain" value={filters.chain} onChange={(v) => setFilters({ ...filters, chain: v })} options={filterOptions.chains} />}
              </div>
              {activeFilterCount > 0 && (
                <button onClick={clearFilters} className="flex items-center gap-1.5 text-xs text-stone-400 hover:text-stone-600 mt-3">
                  <X className="w-3 h-3" /> Clear filters
                </button>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Grid */}
      <div className="max-w-6xl mx-auto px-6 py-6">
        {loading ? (
          <div className="flex flex-col items-center py-24">
            <MascotLoading size={64} />
            <div className="text-stone-400 text-sm mt-4">Loading...</div>
          </div>
        ) : filteredSamples.length === 0 ? (
          <div className="flex flex-col items-center py-24">
            <div className="text-stone-400 text-sm mb-2">No samples found</div>
            <button onClick={clearFilters} className="text-xs text-accent hover:underline">Clear filters</button>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
            {filteredSamples.map((sample) => (
              <SampleCard key={sample.id} sample={sample} onClick={() => navigate(`/sample/${datasetType}/${sample.id}`)} />
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

function Pill({ label, active, onClick, accent }: { label: string; active: boolean; onClick: () => void; accent?: boolean }) {
  return (
    <button onClick={onClick} className={`px-2.5 py-1 rounded-lg text-xs font-medium transition-all duration-150 ${
      active
        ? accent ? 'bg-accent/10 text-accent' : 'bg-stone-500 text-white dark:bg-white dark:text-neutral-900'
        : 'text-stone-400 hover:text-stone-600 dark:hover:text-neutral-300 hover:bg-stone-100 dark:hover:bg-neutral-900'
    }`}>
      {label}
    </button>
  )
}

function StatNum({ value, label }: { value: string; label: string }) {
  return (
    <div className="text-right">
      <div className="text-lg font-light font-mono text-stone-500 dark:text-white">{value}</div>
      <div className="text-2xs text-stone-400 dark:text-neutral-600">{label}</div>
    </div>
  )
}

function FilterSelect({ label, value, onChange, options, formatOption }: {
  label: string; value: string; onChange: (v: string) => void; options: string[]; formatOption?: (o: string) => string
}) {
  return (
    <div>
      <label className="block text-2xs font-medium text-stone-400 mb-1 uppercase tracking-wider">{label}</label>
      <select value={value} onChange={(e) => onChange(e.target.value)} className="input py-1.5 text-xs">
        <option value="">All</option>
        {options.map((o) => <option key={o} value={o}>{formatOption ? formatOption(o) : o.replace(/_/g, ' ')}</option>)}
      </select>
    </div>
  )
}

function SampleCard({ sample, onClick }: { sample: IndexSample; onClick: () => void }) {
  const isDS = sample.id?.startsWith('ds_')
  const isTC = sample.id?.startsWith('tc_')
  const isGS = sample.id?.startsWith('gs_')
  const tiers: Record<number, string> = { 1: 'Textbook', 2: 'Intermediate', 3: 'Advanced', 4: 'Expert' }

  return (
    <button onClick={onClick} className="card-hover p-5 text-left group flex flex-col">
      <div className="flex items-start justify-between mb-3">
        <span className="font-mono text-xs text-stone-400 dark:text-neutral-600">{sample.id}</span>
        <ArrowUpRight className="w-3.5 h-3.5 text-stone-300 dark:text-neutral-700 group-hover:text-stone-500 dark:group-hover:text-neutral-400 transition-colors" />
      </div>

      <div className="flex-1">
        {sample.vulnerability_type && (
          <h3 className="text-sm font-medium text-stone-500 dark:text-neutral-200 capitalize mb-2 leading-snug">
            {sample.vulnerability_type.replace(/_/g, ' ')}
          </h3>
        )}

        <div className="flex items-center gap-1.5 flex-wrap">
          {isDS && <span className="badge-neutral text-2xs">DS</span>}
          {isTC && <span className="badge-neutral text-2xs">TC</span>}
          {isGS && <span className="badge-accent text-2xs">GS</span>}
          {isDS && sample.difficulty_tier && <span className="badge-neutral text-2xs">T{sample.difficulty_tier} {tiers[sample.difficulty_tier]}</span>}
          {sample.severity && <span className={`badge text-2xs ${getSeverityClass(sample.severity)} capitalize`}>{sample.severity}</span>}
        </div>
      </div>

      {isTC && sample.protocol_name && (
        <div className="mt-3 pt-3 border-t border-stone-100 dark:border-neutral-800/50 flex items-center justify-between">
          <span className="text-xs text-stone-400 dark:text-neutral-500">{sample.protocol_name}</span>
          {sample.funds_lost_usd && <span className="text-xs font-mono text-stone-500 dark:text-neutral-400">{formatCurrency(sample.funds_lost_usd)}</span>}
        </div>
      )}
    </button>
  )
}
