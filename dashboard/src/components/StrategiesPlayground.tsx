import { useState, useEffect, useRef } from 'react'
import { Play, Copy, Check, ChevronDown, Loader2, RefreshCw } from 'lucide-react'
import Prism from 'prismjs'
import 'prismjs/components/prism-solidity'
import Navigation from './Navigation'
import { STRATEGIES, type StrategyInfo } from './StrategyIcons'

const SAMPLE_CODE = `// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title VulnerableBank
 * @notice A simple bank contract with a reentrancy vulnerability
 */
contract VulnerableBank {
    mapping(address => uint256) public balances;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    function deposit() external payable {
        require(msg.value > 0, "Must deposit something");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Vulnerable withdraw function - no reentrancy guard
    function withdraw() external {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance to withdraw");

        // External call before state update - VULNERABILITY!
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");

        balances[msg.sender] = 0;
        emit Withdrawal(msg.sender, balance);
    }

    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
}`

export default function StrategiesPlayground() {
  const [inputCode, setInputCode] = useState(SAMPLE_CODE)
  const [outputCode, setOutputCode] = useState('')
  const [selectedStrategy, setSelectedStrategy] = useState<StrategyInfo>(STRATEGIES[0])
  const [isDropdownOpen, setIsDropdownOpen] = useState(false)
  const [isTransforming, setIsTransforming] = useState(false)
  const [copied, setCopied] = useState<'input' | 'output' | null>(null)
  const dropdownRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) setIsDropdownOpen(false)
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  const hl = (line: string) => Prism.highlight(line || ' ', Prism.languages.solidity, 'solidity')

  const handleTransform = async () => {
    if (!inputCode.trim()) return
    setIsTransforming(true)
    await new Promise(r => setTimeout(r, 800 + Math.random() * 400))
    let t = inputCode
    switch (selectedStrategy.id) {
      case 'sanitize': t = t.replace(/Vulnerable/g, 'Basic').replace(/vulnerable/g, 'basic').replace(/VULNERABILITY/g, 'LOGIC').replace(/reentrancy/g, 'transfer'); break
      case 'nocomments': t = t.replace(/\/\/.*$/gm, '').replace(/\/\*[\s\S]*?\*\//g, '').replace(/^\s*[\r\n]/gm, ''); break
      case 'chameleon': t = t.replace(/VulnerableBank/g, 'TreasureVault').replace(/balances/g, 'goldHoldings').replace(/deposit/g, 'storeGold').replace(/Deposit/g, 'GoldStored').replace(/withdraw/g, 'claimLoot').replace(/Withdrawal/g, 'LootClaimed').replace(/getBalance/g, 'checkTreasure'); break
      case 'shapeshifter': t = t.replace(/require\(msg\.value > 0, "Must deposit something"\);/g, 'if (msg.value > 0 && (block.timestamp > 0)) {\n            // Opaque predicate: always true\n        } else {\n            revert("Must deposit something");\n        }').replace(/require\(balance > 0, "No balance to withdraw"\);/g, 'if (balance > 0 || (block.number < 0)) {\n            // always false branch\n        } else {\n            revert("No balance");\n        }').replace(/require\(success, "Transfer failed"\);/g, 'if (success && (1 == 1)) {} else { revert("Transfer failed"); }'); break
      case 'hydra': t = t.replace(/\/\/.*$/gm, '').replace(/Vulnerable/g, 'Basic').replace(/balances/g, 'holdings'); break
      case 'restructure': t = `// Restructured into modules\n\n${t.substring(0, t.length / 2)}\n\n// --- Module 2 ---\n`; break
      case 'mirror': t = t.replace(/\n\s*\n/g, '\n').replace(/{\s+/g, '{ ').replace(/\s+}/g, ' }'); break
      default: t = `// Transformed with ${selectedStrategy.name}\n${t}`
    }
    setOutputCode(t)
    setIsTransforming(false)
  }

  const copy = async (type: 'input' | 'output') => {
    await navigator.clipboard.writeText(type === 'input' ? inputCode : outputCode)
    setCopied(type); setTimeout(() => setCopied(null), 2000)
  }

  return (
    <div className="min-h-screen bg-stone-50 dark:bg-neutral-950">
      <Navigation />

      <div className="pt-20 px-6">
        <div className="max-w-6xl mx-auto py-8">
          {/* Header */}
          <div className="flex flex-col md:flex-row md:items-end justify-between gap-4 mb-10">
            <div>
              <h1 className="text-2xl font-semibold tracking-tight text-stone-600 dark:text-white mb-1">
                Strategy Playground
              </h1>
              <p className="text-sm text-stone-400 dark:text-neutral-500 max-w-lg">
                Transform smart contract code using adversarial strategies and see the output in real-time.
              </p>
            </div>
            <button onClick={() => { setInputCode(SAMPLE_CODE); setOutputCode('') }} className="btn-secondary shrink-0">
              <RefreshCw className="w-3.5 h-3.5" /> Reset
            </button>
          </div>

          {/* Controls */}
          <div className="flex flex-col sm:flex-row items-start sm:items-center gap-3 mb-6">
            <div className="relative" ref={dropdownRef}>
              <button
                onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                className="card flex items-center gap-3 px-4 py-3 min-w-[280px] hover:shadow-soft-md transition-shadow cursor-pointer"
              >
                <selectedStrategy.icon size={18} className="text-stone-500 dark:text-neutral-400 shrink-0" />
                <div className="flex-1 text-left min-w-0">
                  <div className="text-sm font-medium text-stone-500 dark:text-white">{selectedStrategy.name}</div>
                  <div className="text-2xs text-stone-400 dark:text-neutral-500 truncate">{selectedStrategy.description}</div>
                </div>
                <ChevronDown className={`w-4 h-4 text-stone-400 transition-transform duration-200 ${isDropdownOpen ? 'rotate-180' : ''}`} />
              </button>

              {isDropdownOpen && (
                <div className="absolute top-full left-0 mt-1.5 w-full card overflow-hidden z-50 animate-slide-down shadow-soft-lg dark:shadow-dark-soft-lg py-1">
                  {STRATEGIES.map((s) => (
                    <button
                      key={s.id}
                      onClick={() => { setSelectedStrategy(s); setIsDropdownOpen(false) }}
                      className={`w-full flex items-center gap-3 px-4 py-2.5 hover:bg-stone-50 dark:hover:bg-neutral-800/50 transition-colors ${selectedStrategy.id === s.id ? 'bg-stone-50 dark:bg-neutral-800/50' : ''}`}
                    >
                      <s.icon size={15} className="text-stone-400 dark:text-neutral-500" />
                      <div className="flex-1 text-left">
                        <div className="text-sm text-stone-500 dark:text-neutral-200">{s.name}</div>
                        <div className="text-2xs text-stone-400 dark:text-neutral-500">{s.description}</div>
                      </div>
                      {selectedStrategy.id === s.id && <Check className="w-3.5 h-3.5 text-accent" />}
                    </button>
                  ))}
                </div>
              )}
            </div>

            <button
              onClick={handleTransform}
              disabled={isTransforming || !inputCode.trim()}
              className="btn-primary py-2.5 px-5 disabled:opacity-40 disabled:cursor-not-allowed"
            >
              {isTransforming ? <><Loader2 className="w-4 h-4 animate-spin" /> Transforming...</> : <><Play className="w-4 h-4" /> Apply Strategy</>}
            </button>
          </div>

          {/* Code panels */}
          <div className="grid lg:grid-cols-2 gap-4">
            {/* Input */}
            <div className="flex flex-col">
              <div className="flex items-center justify-between mb-2">
                <span className="text-2xs font-medium uppercase tracking-wider text-stone-400 dark:text-neutral-600">Input</span>
                <button onClick={() => copy('input')} className="btn-ghost text-2xs py-1 px-2" disabled={!inputCode}>
                  {copied === 'input' ? <><Check className="w-3 h-3" /> Copied</> : <><Copy className="w-3 h-3" /> Copy</>}
                </button>
              </div>
              <div className="flex-1 min-h-[520px] code-container overflow-auto">
                <div className="h-full flex min-w-full">
                  <LineNumbers code={inputCode} />
                  <div className="flex-1 relative bg-white dark:bg-neutral-950 min-w-0">
                    <textarea
                      value={inputCode}
                      onChange={(e) => setInputCode(e.target.value)}
                      className="absolute inset-0 w-full h-full p-4 font-mono text-sm bg-transparent text-transparent caret-stone-600 dark:caret-neutral-200 resize-none focus:outline-none overflow-auto"
                      style={{ lineHeight: '1.625rem', whiteSpace: 'pre' }}
                      spellCheck={false}
                      placeholder="Paste Solidity code..."
                    />
                    <CodeLines code={inputCode} highlight={hl} />
                  </div>
                </div>
              </div>
            </div>

            {/* Output */}
            <div className="flex flex-col">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-1.5">
                  <span className="text-2xs font-medium uppercase tracking-wider text-stone-400 dark:text-neutral-600">Output</span>
                  <span className="text-2xs text-stone-300 dark:text-neutral-700">\u00B7</span>
                  <span className="text-2xs text-stone-400 dark:text-neutral-600">{selectedStrategy.name}</span>
                </div>
                <button onClick={() => copy('output')} className="btn-ghost text-2xs py-1 px-2" disabled={!outputCode}>
                  {copied === 'output' ? <><Check className="w-3 h-3" /> Copied</> : <><Copy className="w-3 h-3" /> Copy</>}
                </button>
              </div>
              <div className="flex-1 min-h-[520px] code-container overflow-auto relative">
                {isTransforming && (
                  <div className="absolute inset-0 bg-white/80 dark:bg-neutral-950/80 backdrop-blur-sm rounded-2xl z-10 flex items-center justify-center">
                    <Loader2 className="w-5 h-5 text-accent animate-spin" />
                  </div>
                )}
                {!outputCode && !isTransforming && (
                  <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                    <div className="text-center">
                      <selectedStrategy.icon size={32} className="mx-auto mb-3 text-stone-200 dark:text-neutral-800" />
                      <p className="text-xs text-stone-400 dark:text-neutral-600">Click "Apply Strategy" to transform</p>
                    </div>
                  </div>
                )}
                {outputCode && (
                  <div className="h-full flex min-w-full">
                    <LineNumbers code={outputCode} />
                    <div className="flex-1 overflow-auto bg-white dark:bg-neutral-950 scrollbar-thin">
                      <CodeLines code={outputCode} highlight={hl} />
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Strategy cards */}
          <div className="mt-16 mb-8">
            <h2 className="text-2xs font-medium uppercase tracking-wider text-stone-400 dark:text-neutral-600 mb-4">All Strategies</h2>
            <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-3 stagger">
              {STRATEGIES.map((s) => (
                <button
                  key={s.id}
                  onClick={() => setSelectedStrategy(s)}
                  className={`card p-4 text-left transition-all duration-150 group ${
                    selectedStrategy.id === s.id ? 'ring-1 ring-stone-600 dark:ring-white' : 'hover:shadow-soft-md'
                  }`}
                >
                  <div className="flex items-start gap-3">
                    <div className="p-1.5 bg-stone-100 dark:bg-neutral-800 rounded-lg shrink-0">
                      <s.icon size={14} className="text-stone-500 dark:text-neutral-400" />
                    </div>
                    <div className="min-w-0">
                      <h3 className="text-sm font-medium text-stone-500 dark:text-white mb-0.5">{s.name}</h3>
                      <p className="text-2xs text-stone-400 dark:text-neutral-500 leading-relaxed">{s.description}</p>
                    </div>
                  </div>
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

function LineNumbers({ code }: { code: string }) {
  return (
    <div className="select-none bg-stone-50/50 dark:bg-neutral-900/30 text-stone-300 dark:text-neutral-700 text-right py-4 px-3 border-r border-stone-100 dark:border-neutral-800/50 font-mono text-xs min-w-[3rem]">
      {(code || '\n').split('\n').map((_, i) => <div key={i} className="h-[1.625rem] leading-[1.625rem]">{i + 1}</div>)}
    </div>
  )
}

function CodeLines({ code, highlight }: { code: string; highlight: (l: string) => string }) {
  return (
    <pre className="p-4 font-mono text-sm pointer-events-none overflow-auto">
      <code className="language-solidity">
        {(code || '').split('\n').map((line, i) => (
          <div key={i} className="h-[1.625rem] leading-[1.625rem] whitespace-pre" dangerouslySetInnerHTML={{ __html: highlight(line) }} />
        ))}
      </code>
    </pre>
  )
}
