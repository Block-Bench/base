import { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { ArrowLeft, Copy, Check, ExternalLink } from 'lucide-react'
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

  useEffect(() => {
    if (datasetType && sampleId) {
      setLoading(true)
      loadFullSample(datasetType as DatasetType, sampleId).then((data) => {
        setSample(data); setLoading(false)
      })
    }
  }, [datasetType, sampleId])

  const copyCode = async () => {
    if (sample?.code) {
      await navigator.clipboard.writeText(sample.code)
      setCopied(true); setTimeout(() => setCopied(false), 2000)
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-stone-50 dark:bg-neutral-950 flex flex-col items-center justify-center">
        <MascotLoading size={64} />
        <div className="text-stone-400 text-sm mt-4">Loading sample...</div>
      </div>
    )
  }

  if (!sample) {
    return (
      <div className="min-h-screen bg-stone-50 dark:bg-neutral-950 flex flex-col items-center justify-center">
        <div className="text-stone-400 text-sm mb-4">Sample not found</div>
        <button onClick={() => navigate(`/explorer/${datasetType}`)} className="btn-secondary">
          <ArrowLeft className="w-4 h-4" /> Back
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
  const tiers: Record<number, string> = { 1: 'Textbook', 2: 'Intermediate', 3: 'Advanced', 4: 'Expert' }

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-neutral-950">
      <Navigation />

      {/* Header */}
      <div className="pt-20 px-6">
        <div className="max-w-6xl mx-auto py-6">
          {/* Back */}
          <button
            onClick={() => navigate(`/explorer/${datasetType}`)}
            className="flex items-center gap-1.5 text-xs text-stone-400 hover:text-stone-600 dark:hover:text-neutral-300 mb-6 transition-colors"
          >
            <ArrowLeft className="w-3.5 h-3.5" /> Back to Explorer
          </button>

          {/* Title row */}
          <div className="flex flex-col md:flex-row md:items-start justify-between gap-4 mb-6">
            <div>
              <div className="flex items-center gap-2.5 mb-2 flex-wrap">
                <h1 className="text-xl font-mono font-medium text-stone-600 dark:text-white">{sample.id}</h1>
                {isDS && <span className="badge-neutral text-2xs">DS</span>}
                {isTC && <span className="badge-neutral text-2xs">TC</span>}
                {isGS && <span className="badge-accent text-2xs">GS</span>}
                {gt?.severity && <span className={`badge text-2xs ${getSeverityClass(gt.severity)} capitalize`}>{gt.severity}</span>}
                <span className="badge-neutral text-2xs uppercase">{lang}</span>
                {isDS && meta?.difficulty_fields && <span className="badge-neutral text-2xs">T{meta.difficulty_fields.difficulty_tier} {tiers[meta.difficulty_fields.difficulty_tier]}</span>}
              </div>
              {gt?.vulnerability_type && (
                <p className="text-sm text-stone-500 dark:text-neutral-400 capitalize">{gt.vulnerability_type.replace(/_/g, ' ')}</p>
              )}
            </div>

            <div className="flex gap-2 shrink-0">
              <button onClick={copyCode} className="btn-secondary text-xs">
                {copied ? <Check className="w-3.5 h-3.5" /> : <Copy className="w-3.5 h-3.5" />}
                {copied ? 'Copied' : 'Copy'}
              </button>
              {meta?.provenance?.url && (
                <a href={meta.provenance.url} target="_blank" rel="noopener noreferrer" className="btn-secondary text-xs">
                  <ExternalLink className="w-3.5 h-3.5" /> Source
                </a>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-6xl mx-auto px-6 pb-16">
        <div className="grid lg:grid-cols-[1fr,320px] gap-6">
          {/* Code */}
          <div className="code-container overflow-hidden">
            <div className="px-4 py-2.5 border-b border-stone-100 dark:border-neutral-800/50 flex items-center justify-between">
              <span className="text-xs font-mono text-stone-400 dark:text-neutral-500">{sample.contract_file}</span>
              <span className="text-2xs text-stone-400 dark:text-neutral-600 uppercase tracking-wider">{lang}</span>
            </div>
            <div className="overflow-auto scrollbar-thin">
              <div className="flex font-mono text-sm min-w-full">
                {/* Line numbers */}
                <div className="select-none bg-stone-50 dark:bg-neutral-900/30 text-stone-300 dark:text-neutral-700 text-right py-4 px-3 border-r border-stone-100 dark:border-neutral-800/50 min-w-[3rem] text-xs">
                  {sample.code.split('\n').map((_, idx) => {
                    const n = idx + 1
                    const isVuln = gt?.vulnerable_location?.line_numbers?.includes(n)
                    return <div key={idx} className={`h-[1.625rem] leading-[1.625rem] ${isVuln ? 'text-accent font-medium' : ''}`}>{n}</div>
                  })}
                </div>
                {/* Code */}
                <div className="flex-1 overflow-x-auto bg-white dark:bg-neutral-950 scrollbar-thin">
                  <pre className="!bg-transparent !m-0 p-4">
                    <code className={`language-${lang}`}>
                      {sample.code.split('\n').map((line, idx) => {
                        const n = idx + 1
                        const isVuln = gt?.vulnerable_location?.line_numbers?.includes(n)
                        const html = Prism.highlight(line || ' ', lang === 'rust' ? Prism.languages.rust : Prism.languages.solidity, lang)
                        return (
                          <div
                            key={idx}
                            className={`h-[1.625rem] leading-[1.625rem] whitespace-pre ${isVuln ? 'bg-accent/5 dark:bg-accent/10 border-l-2 border-accent -ml-4 pl-4 pr-4' : ''}`}
                            dangerouslySetInnerHTML={{ __html: html }}
                          />
                        )
                      })}
                    </code>
                  </pre>
                </div>
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-4">
            {/* Vulnerability */}
            {gt?.is_vulnerable && gt?.vulnerability_type && (
              <SideCard title="Vulnerability">
                <p className="text-sm font-medium text-stone-500 dark:text-neutral-200 capitalize mb-1.5">
                  {gt.vulnerability_type.replace(/_/g, ' ')}
                </p>
                {gt.root_cause && <p className="text-xs text-stone-500 dark:text-neutral-400 leading-relaxed">{gt.root_cause}</p>}
              </SideCard>
            )}

            {/* Attack / Impact */}
            {(gt?.attack_vector || gt?.impact) && (
              <SideCard title="Details">
                {gt?.attack_vector && (
                  <div className="mb-2.5">
                    <div className="text-2xs uppercase tracking-wider text-stone-400 dark:text-neutral-600 mb-0.5">Attack Vector</div>
                    <p className="text-xs text-stone-600 dark:text-neutral-400">{gt.attack_vector}</p>
                  </div>
                )}
                {gt?.impact && (
                  <div>
                    <div className="text-2xs uppercase tracking-wider text-stone-400 dark:text-neutral-600 mb-0.5">Impact</div>
                    <p className="text-xs text-stone-600 dark:text-neutral-400">{gt.impact}</p>
                  </div>
                )}
              </SideCard>
            )}

            {/* Fix */}
            {gt?.correct_fix && (
              <SideCard title="Recommended Fix">
                <p className="text-xs text-stone-600 dark:text-neutral-400 leading-relaxed">{gt.correct_fix}</p>
              </SideCard>
            )}

            {/* Location */}
            {gt?.vulnerable_location && (
              <SideCard title="Location">
                <div className="space-y-1.5 text-xs">
                  <Row label="Contract" value={gt.vulnerable_location.contract_name} mono />
                  {gt.vulnerable_location.function_name && <Row label="Function" value={gt.vulnerable_location.function_name} mono />}
                  {gt.vulnerable_location.line_numbers?.length > 0 && (
                    <Row label="Lines" value={gt.vulnerable_location.line_numbers.join(', ')} mono accent />
                  )}
                </div>
              </SideCard>
            )}

            {/* Temporal */}
            {isTC && meta?.temporal_fields?.exploit_info && (
              <SideCard title="Exploit">
                <div className="space-y-1.5 text-xs">
                  <Row label="Protocol" value={meta.temporal_fields.exploit_info.protocol_name} />
                  <Row label="Chain" value={meta.temporal_fields.exploit_info.chain} />
                  {meta.temporal_fields.exploit_info.exploit_date && <Row label="Date" value={meta.temporal_fields.exploit_info.exploit_date} />}
                  {meta.temporal_fields.exploit_info.funds_lost_usd != null && (
                    <Row label="Funds Lost" value={formatCurrency(meta.temporal_fields.exploit_info.funds_lost_usd)} />
                  )}
                </div>
              </SideCard>
            )}

            {/* Provenance */}
            {meta?.provenance && (
              <SideCard title="Provenance">
                <div className="space-y-1.5 text-xs">
                  <Row label="Source" value={meta.provenance.source || ''} />
                  {meta.provenance.original_id && <Row label="Original ID" value={meta.provenance.original_id} mono />}
                  {meta.provenance.date_discovered && <Row label="Discovered" value={meta.provenance.date_discovered} />}
                </div>
              </SideCard>
            )}

            {/* Code Info */}
            {meta?.code_metadata && (
              <SideCard title="Code Info">
                <div className="space-y-1.5 text-xs">
                  <Row label="Solidity" value={meta.code_metadata.solidity_version || ''} mono />
                  <Row label="Lines" value={String(meta.code_metadata.num_lines || 0)} />
                  <Row label="Contracts" value={String(meta.code_metadata.num_contracts || 0)} />
                  <Row label="Functions" value={String(meta.code_metadata.num_functions || 0)} />
                </div>
                <div className="flex flex-wrap gap-1 mt-2">
                  {meta.code_metadata.has_imports && <span className="badge-neutral text-2xs">Imports</span>}
                  {meta.code_metadata.has_inheritance && <span className="badge-neutral text-2xs">Inheritance</span>}
                  {meta.code_metadata.has_modifiers && <span className="badge-neutral text-2xs">Modifiers</span>}
                  {meta.code_metadata.has_events && <span className="badge-neutral text-2xs">Events</span>}
                  {meta.code_metadata.has_assembly && <span className="badge-neutral text-2xs">Assembly</span>}
                </div>
              </SideCard>
            )}

            {/* Notes */}
            {meta?.notes && (
              <SideCard title="Notes">
                <p className="text-xs text-stone-500 dark:text-neutral-400 leading-relaxed">{meta.notes}</p>
              </SideCard>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}

function SideCard({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="card p-4">
      <h3 className="text-2xs font-medium uppercase tracking-wider text-stone-400 dark:text-neutral-600 mb-2.5">{title}</h3>
      {children}
    </div>
  )
}

function Row({ label, value, mono, accent }: { label: string; value: string; mono?: boolean; accent?: boolean }) {
  return (
    <div className="flex items-center justify-between">
      <span className="text-stone-400 dark:text-neutral-600">{label}</span>
      <span className={`${mono ? 'font-mono' : ''} ${accent ? 'text-accent' : 'text-stone-600 dark:text-neutral-400'}`}>{value}</span>
    </div>
  )
}
