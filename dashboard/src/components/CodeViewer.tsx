import { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { ArrowLeft, AlertTriangle, CheckCircle, Info } from 'lucide-react'
import Prism from 'prismjs'
import 'prismjs/themes/prism-tomorrow.css'
import 'prismjs/components/prism-solidity'
import 'prismjs/components/prism-rust'
import { loadDataset } from '../data/loader'
import type { VulnerabilitySample } from '../types'

export default function CodeViewer() {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const [sample, setSample] = useState<VulnerabilitySample | null>(null)

  useEffect(() => {
    loadDataset().then((data) => {
      const found = data.find((s) => s.id === id)
      setSample(found || null)
    })
  }, [id])

  const [highlightedCode, setHighlightedCode] = useState<string>('')

  useEffect(() => {
    if (sample) {
      // Create a temporary element for Prism to highlight
      const tempCode = document.createElement('code')
      tempCode.className = `language-${
        languageMap[sample.language] || 'javascript'
      }`
      tempCode.textContent = sample.file_content

      Prism.highlightElement(tempCode)
      setHighlightedCode(tempCode.innerHTML)
    }
  }, [sample])

  if (!sample) {
    return (
      <div className="min-h-screen bg-anthropic-dark flex items-center justify-center">
        <div className="text-gray-400">Loading...</div>
      </div>
    )
  }

  const severityColors = {
    critical: 'text-red-500 bg-red-500/10 border-red-500/20',
    high: 'text-orange-500 bg-orange-500/10 border-orange-500/20',
    medium: 'text-yellow-500 bg-yellow-500/10 border-yellow-500/20',
    low: 'text-blue-500 bg-blue-500/10 border-blue-500/20',
  }

  const tierLabels = {
    1: 'Easy',
    2: 'Medium',
    3: 'Hard',
    4: 'Expert',
  }

  const languageMap: Record<string, string> = {
    solidity: 'solidity',
    rust: 'rust',
  }

  return (
    <div className="min-h-screen bg-anthropic-dark text-gray-100">
      {/* Header */}
      <div className="border-b border-gray-800 bg-gray-900 sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <button
            onClick={() => navigate('/explorer')}
            className="flex items-center gap-2 text-gray-400 hover:text-gray-200 mb-4"
          >
            <ArrowLeft className="w-4 h-4" />
            Back to Explorer
          </button>
          <div className="flex items-start justify-between gap-4">
            <div className="flex-1">
              <h1 className="text-xl font-mono text-gray-300">{sample.id}</h1>
              <div className="flex items-center gap-3 mt-2">
                <span
                  className={`text-xs px-3 py-1 rounded-full border ${
                    severityColors[
                      sample.severity as keyof typeof severityColors
                    ]
                  }`}
                >
                  {sample.severity.toUpperCase()}
                </span>
                <span className="text-xs px-3 py-1 bg-gray-800 rounded-full text-gray-400 capitalize">
                  {sample.language}
                </span>
                <span className="text-xs px-3 py-1 bg-gray-800 rounded-full text-gray-400">
                  Tier {sample.difficulty_tier} -{' '}
                  {
                    tierLabels[
                      sample.difficulty_tier as keyof typeof tierLabels
                    ]
                  }
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="max-w-7xl mx-auto px-6 py-8">
        <div className="grid lg:grid-cols-3 gap-8">
          {/* Sidebar - Metadata */}
          <div className="lg:col-span-1 space-y-6">
            <InfoCard
              icon={<AlertTriangle className="w-5 h-5" />}
              title="Vulnerability"
              content={sample.vulnerability_type.replace(/_/g, ' ')}
              className="capitalize"
            />

            <InfoCard
              icon={<Info className="w-5 h-5" />}
              title="Description"
              content={sample.description}
            />

            <InfoCard
              icon={<CheckCircle className="w-5 h-5" />}
              title="Fix"
              content={sample.fix_description}
            />

            <div className="p-4 bg-gray-900 rounded-lg border border-gray-800 space-y-3">
              <div className="text-sm">
                <div className="text-gray-400 mb-1">Source</div>
                <div className="text-gray-300">{sample.source_dataset}</div>
              </div>
              <div className="text-sm">
                <div className="text-gray-400 mb-1">File</div>
                <div className="text-gray-300 font-mono text-xs">
                  {sample.file_name}
                </div>
              </div>
              <div className="text-sm">
                <div className="text-gray-400 mb-1">Vulnerable Function</div>
                <div className="text-gray-300 font-mono text-xs">
                  {sample.vulnerable_function}
                </div>
              </div>
              {sample.vulnerable_lines && sample.vulnerable_lines.length > 0 && (
                <div className="text-sm">
                  <div className="text-gray-400 mb-1">Vulnerable Lines</div>
                  <div className="text-red-400 font-mono text-xs">
                    {sample.vulnerable_lines.join(', ')}
                  </div>
                </div>
              )}
              <div className="flex gap-2 pt-2 border-t border-gray-800">
                {sample.has_poc && (
                  <span className="text-xs px-2 py-1 bg-green-500/10 text-green-400 rounded">
                    Has PoC
                  </span>
                )}
                {sample.has_remediation && (
                  <span className="text-xs px-2 py-1 bg-blue-500/10 text-blue-400 rounded">
                    Has Fix
                  </span>
                )}
              </div>
            </div>
          </div>

          {/* Main - Code */}
          <div className="lg:col-span-2">
            <div className="bg-gray-900 rounded-lg border border-gray-800 overflow-hidden">
              <div className="px-4 py-3 border-b border-gray-800 flex items-center justify-between">
                <span className="text-sm text-gray-400 font-mono">
                  {sample.file_name}
                </span>
                <span className="text-xs text-gray-500 capitalize">
                  {sample.language}
                </span>
              </div>
              <div className="relative bg-gray-900 rounded-lg border border-gray-700 overflow-hidden">
                <div className="flex font-mono text-sm">
                  {/* Line numbers column */}
                  <div className="select-none bg-gray-800 text-gray-400 text-right py-4 px-3 border-r border-gray-700 min-w-[3.5rem]">
                    {sample.file_content.split('\n').map((_, idx) => (
                      <div
                        key={idx}
                        className="leading-6"
                        style={{ height: '1.5rem' }}
                      >
                        {idx + 1}
                      </div>
                    ))}
                  </div>

                  {/* Code column */}
                  <div className="flex-1 overflow-x-auto">
                    <pre className="!bg-transparent !m-0 p-4">
                      <code
                        className={`language-${
                          languageMap[sample.language] || 'javascript'
                        }`}
                        dangerouslySetInnerHTML={{
                          __html: highlightedCode
                            .split('\n')
                            .map((line, idx) => {
                              const lineNumber = idx + 1
                              const isVulnerable = sample.vulnerable_lines?.includes(
                                lineNumber,
                              )
                              if (isVulnerable) {
                                return `<span class="block bg-red-500/20 border-l-4 border-red-500 -ml-4 pl-4 pr-4">${line}</span>`
                              }
                              return line
                            })
                            .join('\n'),
                        }}
                      />
                    </pre>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

function InfoCard({
  icon,
  title,
  content,
  className = '',
}: {
  icon: React.ReactNode
  title: string
  content: string
  className?: string
}) {
  return (
    <div className="p-4 bg-gray-900 rounded-lg border border-gray-800">
      <div className="flex items-center gap-2 text-gray-400 mb-3">
        {icon}
        <span className="text-sm font-medium">{title}</span>
      </div>
      <p className={`text-sm text-gray-300 leading-relaxed ${className}`}>
        {content}
      </p>
    </div>
  )
}
