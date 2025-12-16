import { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import {
  ArrowLeft,
  AlertTriangle,
  CheckCircle,
  Info,
  FileCode,
  Copy,
  Check,
  ExternalLink,
  Calendar,
  DollarSign,
  MapPin,
  Layers,
  Clock,
  Award,
} from 'lucide-react'
import Prism from 'prismjs'
import 'prismjs/components/prism-solidity'
import 'prismjs/components/prism-rust'
import { loadFullSample, formatCurrency, getLanguage, getSeverityClass } from '../data/loader'
import type { DatasetType, FullSample } from '../types'
import Navigation from './Navigation'
import { MascotLoading } from './Mascot'

export default function CodeViewer() {
  const { datasetType, sampleId } = useParams<{ datasetType: string; sampleId: string }>()
  const navigate = useNavigate()

  const [sample, setSample] = useState<FullSample | null>(null)
  const [loading, setLoading] = useState(true)
  const [copied, setCopied] = useState(false)
  const [activeTab, setActiveTab] = useState<'details' | 'provenance' | 'code_info'>('details')

  useEffect(() => {
    if (datasetType && sampleId) {
      setLoading(true)
      loadFullSample(datasetType as DatasetType, sampleId).then((data) => {
        setSample(data)
        setLoading(false)
      })
    }
  }, [datasetType, sampleId])


  const copyCode = async () => {
    if (sample?.code) {
      await navigator.clipboard.writeText(sample.code)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-cream-100 dark:bg-neutral-950 flex flex-col items-center justify-center">
        <MascotLoading size={80} />
        <div className="text-neutral-400 dark:text-neutral-500 mt-4">Loading sample...</div>
      </div>
    )
  }

  if (!sample) {
    return (
      <div className="min-h-screen bg-cream-100 dark:bg-neutral-950 flex flex-col items-center justify-center">
        <div className="text-neutral-500 dark:text-neutral-400 mb-4">Sample not found</div>
        <button
          onClick={() => navigate(`/explorer/${datasetType}`)}
          className="btn-secondary"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to Explorer
        </button>
      </div>
    )
  }

  const isDS = sample.id?.startsWith('ds_')
  const isTC = sample.id?.startsWith('tc_')
  const isGS = sample.id?.startsWith('gs_')
  const meta = sample.metadata
  const gt = meta?.ground_truth
  const lang = getLanguage(sample)

  const tierLabels: Record<number, string> = {
    1: 'Textbook',
    2: 'Intermediate',
    3: 'Advanced',
    4: 'Expert',
  }

  return (
    <div className="min-h-screen bg-cream-100 dark:bg-neutral-950">
      <Navigation />

      {/* Header */}
      <div className="pt-24 pb-6 px-6 bg-white dark:bg-neutral-900 border-b border-cream-300 dark:border-neutral-800">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col md:flex-row md:items-start justify-between gap-4">
            <div>
              <div className="flex items-center gap-3 mb-3 flex-wrap">
                <h1 className="text-xl font-mono text-neutral-800 dark:text-neutral-100">
                  {sample.id}
                </h1>

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
                    Gold Standard
                  </span>
                )}
              </div>

              <div className="flex items-center gap-2 flex-wrap">
                {gt?.severity && (
                  <span className={`badge ${getSeverityClass(gt.severity)} capitalize`}>
                    {gt.severity}
                  </span>
                )}
                <span className="badge-neutral capitalize">{lang}</span>
                {isDS && meta?.difficulty_fields && (
                  <span className="badge-neutral">
                    Tier {meta.difficulty_fields.difficulty_tier} ·{' '}
                    {tierLabels[meta.difficulty_fields.difficulty_tier] ||
                      meta.difficulty_fields.difficulty_tier_name}
                  </span>
                )}
                {isTC && meta?.temporal_fields && (
                  <span className="badge-neutral">{meta.temporal_fields.temporal_split?.split}</span>
                )}
              </div>
            </div>

            {/* Quick Actions */}
            <div className="flex gap-2">
              <button onClick={copyCode} className="btn-secondary">
                {copied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
                {copied ? 'Copied' : 'Copy Code'}
              </button>
              {meta?.provenance?.url && (
                <a
                  href={meta.provenance.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn-secondary"
                >
                  <ExternalLink className="w-4 h-4" />
                  Source
                </a>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-7xl mx-auto px-6 py-8">
        <div className="grid lg:grid-cols-3 gap-8">
          {/* Sidebar - Metadata */}
          <div className="lg:col-span-1 space-y-6">
            {/* Vulnerability Info */}
            {gt?.is_vulnerable && gt?.vulnerability_type && (
              <InfoCard
                icon={<AlertTriangle className="w-5 h-5 text-neutral-600 dark:text-neutral-400" />}
                title="Vulnerability"
              >
                <p className="text-neutral-800 dark:text-neutral-200 font-medium capitalize mb-2">
                  {gt.vulnerability_type.replace(/_/g, ' ')}
                </p>
                {gt.root_cause && (
                  <p className="text-sm text-neutral-600 dark:text-neutral-400 leading-relaxed">
                    {gt.root_cause}
                  </p>
                )}
              </InfoCard>
            )}

            {/* Attack Vector & Impact */}
            {(gt?.attack_vector || gt?.impact) && (
              <InfoCard
                icon={<Info className="w-5 h-5 text-neutral-600 dark:text-neutral-400" />}
                title="Details"
              >
                {gt?.attack_vector && (
                  <div className="mb-3">
                    <div className="text-2xs uppercase tracking-wide text-neutral-400 dark:text-neutral-500 mb-1">
                      Attack Vector
                    </div>
                    <p className="text-sm text-neutral-700 dark:text-neutral-300">
                      {gt.attack_vector}
                    </p>
                  </div>
                )}
                {gt?.impact && (
                  <div>
                    <div className="text-2xs uppercase tracking-wide text-neutral-400 dark:text-neutral-500 mb-1">
                      Impact
                    </div>
                    <p className="text-sm text-neutral-700 dark:text-neutral-300">{gt.impact}</p>
                  </div>
                )}
              </InfoCard>
            )}

            {/* Fix */}
            {gt?.correct_fix && (
              <InfoCard
                icon={<CheckCircle className="w-5 h-5 text-neutral-600 dark:text-neutral-400" />}
                title="Recommended Fix"
              >
                <p className="text-sm text-neutral-700 dark:text-neutral-300 leading-relaxed">
                  {gt.correct_fix}
                </p>
              </InfoCard>
            )}

            {/* Location */}
            {gt?.vulnerable_location && (
              <InfoCard
                icon={<MapPin className="w-5 h-5 text-neutral-600 dark:text-neutral-400" />}
                title="Location"
              >
                <div className="space-y-2 text-sm">
                  <div>
                    <span className="text-neutral-400 dark:text-neutral-500">Contract: </span>
                    <span className="font-mono text-neutral-700 dark:text-neutral-300">
                      {gt.vulnerable_location.contract_name}
                    </span>
                  </div>
                  {gt.vulnerable_location.function_name && (
                    <div>
                      <span className="text-neutral-400 dark:text-neutral-500">Function: </span>
                      <span className="font-mono text-neutral-700 dark:text-neutral-300">
                        {gt.vulnerable_location.function_name}
                      </span>
                    </div>
                  )}
                  {gt.vulnerable_location.line_numbers?.length > 0 && (
                    <div>
                      <span className="text-neutral-400 dark:text-neutral-500">Lines: </span>
                      <span className="font-mono text-accent">
                        {gt.vulnerable_location.line_numbers.join(', ')}
                      </span>
                    </div>
                  )}
                </div>
              </InfoCard>
            )}

            {/* Temporal Info */}
            {isTC && meta?.temporal_fields?.exploit_info && (
              <InfoCard
                icon={<Calendar className="w-5 h-5 text-neutral-600 dark:text-neutral-400" />}
                title="Exploit Info"
              >
                <div className="space-y-3 text-sm">
                  <div className="flex items-center justify-between">
                    <span className="text-neutral-400 dark:text-neutral-500">Protocol</span>
                    <span className="font-medium text-neutral-800 dark:text-neutral-200">
                      {meta.temporal_fields.exploit_info.protocol_name}
                    </span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-neutral-400 dark:text-neutral-500">Chain</span>
                    <span className="text-neutral-700 dark:text-neutral-300 capitalize">
                      {meta.temporal_fields.exploit_info.chain}
                    </span>
                  </div>
                  {meta.temporal_fields.exploit_info.exploit_date && (
                    <div className="flex items-center justify-between">
                      <span className="text-neutral-400 dark:text-neutral-500">Date</span>
                      <span className="text-neutral-700 dark:text-neutral-300">
                        {meta.temporal_fields.exploit_info.exploit_date}
                      </span>
                    </div>
                  )}
                  {meta.temporal_fields.exploit_info.funds_lost_usd != null && (
                    <div className="flex items-center justify-between pt-2 border-t border-cream-200 dark:border-neutral-800">
                      <span className="text-neutral-400 dark:text-neutral-500 flex items-center gap-1">
                        <DollarSign className="w-3 h-3" /> Funds Lost
                      </span>
                      <span className="font-medium text-neutral-800 dark:text-neutral-200">
                        {formatCurrency(meta.temporal_fields.exploit_info.funds_lost_usd)}
                      </span>
                    </div>
                  )}
                </div>
              </InfoCard>
            )}

            {/* Metadata Tabs */}
            <div className="card overflow-hidden">
              <div className="flex border-b border-cream-200 dark:border-neutral-800">
                <TabButton active={activeTab === 'details'} onClick={() => setActiveTab('details')}>
                  Details
                </TabButton>
                <TabButton
                  active={activeTab === 'provenance'}
                  onClick={() => setActiveTab('provenance')}
                >
                  Provenance
                </TabButton>
                <TabButton
                  active={activeTab === 'code_info'}
                  onClick={() => setActiveTab('code_info')}
                >
                  Code Info
                </TabButton>
              </div>
              <div className="p-4">
                {activeTab === 'details' && (
                  <div className="space-y-3 text-sm">
                    <MetaRow label="ID" value={meta?.id || sample.id || ''} mono />
                    <MetaRow label="Subset" value={meta?.subset || ''} />
                    {meta?.tags && meta.tags.length > 0 && (
                      <div>
                        <div className="text-2xs uppercase tracking-wide text-neutral-400 dark:text-neutral-500 mb-1.5">
                          Tags
                        </div>
                        <div className="flex flex-wrap gap-1.5">
                          {meta.tags.map((tag) => (
                            <span key={tag} className="badge-neutral text-2xs">
                              {tag}
                            </span>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                )}
                {activeTab === 'provenance' && meta?.provenance && (
                  <div className="space-y-3 text-sm">
                    <MetaRow label="Source" value={meta.provenance.source || ''} />
                    {meta.provenance.original_id && (
                      <MetaRow label="Original ID" value={meta.provenance.original_id} mono />
                    )}
                    {meta.provenance.date_discovered && (
                      <MetaRow label="Discovered" value={meta.provenance.date_discovered} />
                    )}
                    {meta.provenance.date_added && (
                      <MetaRow label="Added" value={meta.provenance.date_added} />
                    )}
                  </div>
                )}
                {activeTab === 'code_info' && meta?.code_metadata && (
                  <div className="space-y-3 text-sm">
                    <MetaRow
                      label="Solidity Version"
                      value={meta.code_metadata.solidity_version || ''}
                      mono
                    />
                    <MetaRow label="Lines" value={String(meta.code_metadata.num_lines || 0)} />
                    <MetaRow label="Contracts" value={String(meta.code_metadata.num_contracts || 0)} />
                    <MetaRow label="Functions" value={String(meta.code_metadata.num_functions || 0)} />
                    <div className="flex flex-wrap gap-2 pt-2 border-t border-cream-200 dark:border-neutral-800">
                      {meta.code_metadata.has_imports && <FeatureBadge>Imports</FeatureBadge>}
                      {meta.code_metadata.has_inheritance && (
                        <FeatureBadge>Inheritance</FeatureBadge>
                      )}
                      {meta.code_metadata.has_modifiers && <FeatureBadge>Modifiers</FeatureBadge>}
                      {meta.code_metadata.has_events && <FeatureBadge>Events</FeatureBadge>}
                      {meta.code_metadata.has_assembly && <FeatureBadge>Assembly</FeatureBadge>}
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Main - Code */}
          <div className="lg:col-span-2">
            <div className="code-container overflow-hidden">
              <div className="px-4 py-3 border-b border-cream-200 dark:border-neutral-800 flex items-center justify-between bg-cream-50 dark:bg-neutral-900">
                <div className="flex items-center gap-2">
                  <FileCode className="w-4 h-4 text-neutral-400" />
                  <span className="text-sm font-mono text-neutral-600 dark:text-neutral-400">
                    {sample.contract_file}
                  </span>
                </div>
                <span className="text-2xs text-neutral-400 dark:text-neutral-500 uppercase tracking-wide">
                  {lang}
                </span>
              </div>
              <div className="overflow-hidden">
                <div className="flex font-mono text-sm">
                  {/* Line numbers */}
                  <div className="select-none bg-cream-50 dark:bg-neutral-900 text-neutral-400 dark:text-neutral-600 text-right py-4 px-3 border-r border-cream-200 dark:border-neutral-800 min-w-[3.5rem]">
                    {sample.code.split('\n').map((_, idx) => {
                      const lineNum = idx + 1
                      const isVulnerable = gt?.vulnerable_location?.line_numbers?.includes(lineNum)
                      return (
                        <div
                          key={idx}
                          className={`h-[1.625rem] leading-[1.625rem] ${isVulnerable ? 'text-accent font-medium' : ''}`}
                        >
                          {lineNum}
                        </div>
                      )
                    })}
                  </div>

                  {/* Code */}
                  <div className="flex-1 overflow-x-auto bg-white dark:bg-neutral-950 scrollbar-thin">
                    <pre className="!bg-transparent !m-0 p-4">
                      <code className={`language-${lang}`}>
                        {sample.code.split('\n').map((line, idx) => {
                          const lineNum = idx + 1
                          const isVulnerable = gt?.vulnerable_location?.line_numbers?.includes(lineNum)
                          const highlightedLine = Prism.highlight(
                            line || ' ',
                            lang === 'rust' ? Prism.languages.rust : Prism.languages.solidity,
                            lang
                          )
                          return (
                            <div
                              key={idx}
                              className={`h-[1.625rem] leading-[1.625rem] whitespace-pre ${
                                isVulnerable
                                  ? 'bg-accent/10 dark:bg-accent/20 border-l-2 border-accent -ml-4 pl-4 pr-4'
                                  : ''
                              }`}
                              dangerouslySetInnerHTML={{ __html: highlightedLine }}
                            />
                          )
                        })}
                      </code>
                    </pre>
                  </div>
                </div>
              </div>
            </div>

            {/* Notes */}
            {meta?.notes && (
              <div className="mt-6 card p-4">
                <h3 className="text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-2">
                  Notes
                </h3>
                <p className="text-sm text-neutral-600 dark:text-neutral-400 leading-relaxed">
                  {meta.notes}
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

function InfoCard({
  icon,
  title,
  children,
}: {
  icon: React.ReactNode
  title: string
  children: React.ReactNode
}) {
  return (
    <div className="card p-4">
      <div className="flex items-center gap-2 mb-3">
        {icon}
        <span className="text-sm font-medium text-neutral-700 dark:text-neutral-300">{title}</span>
      </div>
      {children}
    </div>
  )
}

function TabButton({
  active,
  onClick,
  children,
}: {
  active: boolean
  onClick: () => void
  children: React.ReactNode
}) {
  return (
    <button
      onClick={onClick}
      className={`flex-1 px-3 py-2.5 text-sm font-medium transition-colors ${
        active
          ? 'text-neutral-800 dark:text-neutral-200 bg-white dark:bg-neutral-800 border-b-2 border-accent -mb-px'
          : 'text-neutral-500 dark:text-neutral-400 hover:text-neutral-700 dark:hover:text-neutral-200'
      }`}
    >
      {children}
    </button>
  )
}

function MetaRow({ label, value, mono = false }: { label: string; value: string; mono?: boolean }) {
  return (
    <div className="flex items-center justify-between">
      <span className="text-neutral-400 dark:text-neutral-500">{label}</span>
      <span
        className={`text-neutral-700 dark:text-neutral-300 ${mono ? 'font-mono text-xs' : ''}`}
      >
        {value}
      </span>
    </div>
  )
}

function FeatureBadge({ children }: { children: React.ReactNode }) {
  return <span className="badge-neutral text-2xs">{children}</span>
}
