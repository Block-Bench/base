import { useState, useEffect, useRef } from 'react'
import { Play, Copy, Check, ChevronDown, Loader2, RefreshCw, Code2 } from 'lucide-react'
import Prism from 'prismjs'
import 'prismjs/components/prism-solidity'
import Navigation from './Navigation'
import { STRATEGIES, type StrategyInfo } from './StrategyIcons'

// Sample code for demonstration
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

    // Deposit funds into the contract
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

  // Close dropdown when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsDropdownOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    return () => document.removeEventListener('mousedown', handleClickOutside)
  }, [])

  // Highlight a single line of code
  const highlightLine = (line: string) => {
    return Prism.highlight(line || ' ', Prism.languages.solidity, 'solidity')
  }

  // Simulate transformation (in a real app, this would call the Python backend)
  const handleTransform = async () => {
    if (!inputCode.trim()) return

    setIsTransforming(true)

    // Simulate processing time
    await new Promise(resolve => setTimeout(resolve, 800 + Math.random() * 400))

    // Apply mock transformation based on strategy
    let transformed = inputCode

    switch (selectedStrategy.id) {
      case 'sanitize':
        transformed = inputCode
          .replace(/Vulnerable/g, 'Basic')
          .replace(/vulnerable/g, 'basic')
          .replace(/VULNERABILITY/g, 'LOGIC')
          .replace(/reentrancy/g, 'transfer')
          .replace(/Reentrancy/g, 'Transfer')
        break

      case 'nocomments':
        transformed = inputCode
          .replace(/\/\/.*$/gm, '')
          .replace(/\/\*[\s\S]*?\*\//g, '')
          .replace(/^\s*[\r\n]/gm, '')
        break

      case 'chameleon':
        transformed = inputCode
          .replace(/VulnerableBank/g, 'TreasureVault')
          .replace(/balances/g, 'goldHoldings')
          .replace(/deposit/g, 'storeGold')
          .replace(/Deposit/g, 'GoldStored')
          .replace(/withdraw/g, 'claimLoot')
          .replace(/Withdrawal/g, 'LootClaimed')
          .replace(/getBalance/g, 'checkTreasure')
        break

      case 'mirror':
        // Compress formatting
        transformed = inputCode
          .replace(/\n\s*\n/g, '\n')
          .replace(/{\s+/g, '{ ')
          .replace(/\s+}/g, ' }')
        break

      default:
        transformed = `// Transformed with ${selectedStrategy.name} strategy\n${inputCode}`
    }

    setOutputCode(transformed)
    setIsTransforming(false)
  }

  const copyToClipboard = async (type: 'input' | 'output') => {
    const code = type === 'input' ? inputCode : outputCode
    await navigator.clipboard.writeText(code)
    setCopied(type)
    setTimeout(() => setCopied(null), 2000)
  }

  const resetPlayground = () => {
    setInputCode(SAMPLE_CODE)
    setOutputCode('')
  }

  return (
    <div className="min-h-screen bg-cream-100 dark:bg-neutral-950">
      <Navigation />

      {/* Header */}
      <div className="pt-24 pb-8 px-6 bg-white dark:bg-neutral-900 border-b border-cream-300 dark:border-neutral-800">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
            <div>
              <h1 className="text-2xl font-light text-neutral-900 dark:text-white mb-2">
                Strategy Playground
              </h1>
              <p className="text-sm text-neutral-500 dark:text-neutral-400 max-w-xl">
                Transform smart contract code using adversarial strategies. Paste your code,
                select a strategy, and see the transformed output in real-time.
              </p>
            </div>

            <div className="flex items-center gap-3">
              <button
                onClick={resetPlayground}
                className="btn-ghost"
              >
                <RefreshCw className="w-4 h-4" />
                Reset
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-6 py-8">
        {/* Strategy Selector */}
        <div className="mb-6 flex flex-col sm:flex-row items-start sm:items-center gap-4">
          <div className="relative" ref={dropdownRef}>
            <button
              onClick={() => setIsDropdownOpen(!isDropdownOpen)}
              className="flex items-center gap-3 px-4 py-3 bg-white dark:bg-neutral-900 border border-cream-300 dark:border-neutral-700 rounded-xl shadow-soft dark:shadow-dark-soft hover:border-cream-400 dark:hover:border-neutral-600 transition-all duration-200 min-w-[280px]"
            >
              <selectedStrategy.icon
                size={24}
                className="text-neutral-800 dark:text-neutral-200"
              />
              <div className="flex-1 text-left">
                <div className="font-medium text-neutral-800 dark:text-neutral-100">
                  {selectedStrategy.name}
                </div>
                <div className="text-xs text-neutral-500 dark:text-neutral-400 truncate max-w-[180px]">
                  {selectedStrategy.description}
                </div>
              </div>
              <ChevronDown className={`w-5 h-5 text-neutral-400 transition-transform duration-200 ${isDropdownOpen ? 'rotate-180' : ''}`} />
            </button>

            {/* Dropdown */}
            {isDropdownOpen && (
              <div className="absolute top-full left-0 mt-2 w-full bg-white dark:bg-neutral-900 border border-cream-300 dark:border-neutral-700 rounded-xl shadow-soft-lg dark:shadow-dark-soft-md overflow-hidden z-50 animate-slide-down">
                {STRATEGIES.map((strategy) => (
                  <button
                    key={strategy.id}
                    onClick={() => {
                      setSelectedStrategy(strategy)
                      setIsDropdownOpen(false)
                    }}
                    className={`w-full flex items-center gap-3 px-4 py-3 hover:bg-cream-100 dark:hover:bg-neutral-800 transition-colors ${
                      selectedStrategy.id === strategy.id ? 'bg-cream-100 dark:bg-neutral-800' : ''
                    }`}
                  >
                    <strategy.icon
                      size={20}
                      className="text-neutral-700 dark:text-neutral-300"
                    />
                    <div className="flex-1 text-left">
                      <div className="font-medium text-sm text-neutral-800 dark:text-neutral-100">
                        {strategy.name}
                      </div>
                      <div className="text-xs text-neutral-500 dark:text-neutral-400">
                        {strategy.description}
                      </div>
                    </div>
                    {selectedStrategy.id === strategy.id && (
                      <Check className="w-4 h-4 text-accent" />
                    )}
                  </button>
                ))}
              </div>
            )}
          </div>

          <button
            onClick={handleTransform}
            disabled={isTransforming || !inputCode.trim()}
            className="btn-primary py-3 px-6 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {isTransforming ? (
              <>
                <Loader2 className="w-4 h-4 animate-spin" />
                Transforming...
              </>
            ) : (
              <>
                <Play className="w-4 h-4" />
                Apply Strategy
              </>
            )}
          </button>
        </div>

        {/* Code Panels */}
        <div className="grid lg:grid-cols-2 gap-6">
          {/* Input Panel */}
          <div className="flex flex-col">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <Code2 className="w-4 h-4 text-neutral-500 dark:text-neutral-400" />
                <span className="text-sm font-medium text-neutral-700 dark:text-neutral-300">
                  Input Code
                </span>
              </div>
              <button
                onClick={() => copyToClipboard('input')}
                className="btn-ghost text-xs py-1.5 px-2.5"
                disabled={!inputCode}
              >
                {copied === 'input' ? (
                  <>
                    <Check className="w-3.5 h-3.5" />
                    Copied
                  </>
                ) : (
                  <>
                    <Copy className="w-3.5 h-3.5" />
                    Copy
                  </>
                )}
              </button>
            </div>

            <div className="flex-1 min-h-[500px] code-container overflow-hidden">
              <div className="h-full flex">
                {/* Line numbers */}
                <div className="select-none bg-cream-50 dark:bg-neutral-900 text-neutral-400 dark:text-neutral-600 text-right py-4 px-3 border-r border-cream-200 dark:border-neutral-800 font-mono text-sm">
                  {inputCode.split('\n').map((_, idx) => (
                    <div key={idx} className="h-[1.625rem] leading-[1.625rem]">
                      {idx + 1}
                    </div>
                  ))}
                </div>
                {/* Code editor */}
                <div className="flex-1 relative bg-white dark:bg-neutral-950">
                  <textarea
                    value={inputCode}
                    onChange={(e) => setInputCode(e.target.value)}
                    className="absolute inset-0 w-full h-full p-4 font-mono text-sm bg-transparent text-transparent caret-neutral-800 dark:caret-neutral-200 resize-none focus:outline-none"
                    style={{ lineHeight: '1.625rem' }}
                    spellCheck={false}
                    placeholder="Paste your Solidity code here..."
                  />
                  <pre className="p-4 font-mono text-sm pointer-events-none">
                    <code className="language-solidity">
                      {inputCode.split('\n').map((line, idx) => (
                        <div
                          key={idx}
                          className="h-[1.625rem] leading-[1.625rem] whitespace-pre"
                          dangerouslySetInnerHTML={{ __html: highlightLine(line) }}
                        />
                      ))}
                    </code>
                  </pre>
                </div>
              </div>
            </div>
          </div>

          {/* Output Panel */}
          <div className="flex flex-col">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <selectedStrategy.icon
                  size={16}
                  className="text-neutral-500 dark:text-neutral-400"
                />
                <span className="text-sm font-medium text-neutral-700 dark:text-neutral-300">
                  Output ({selectedStrategy.name})
                </span>
              </div>
              <button
                onClick={() => copyToClipboard('output')}
                className="btn-ghost text-xs py-1.5 px-2.5"
                disabled={!outputCode}
              >
                {copied === 'output' ? (
                  <>
                    <Check className="w-3.5 h-3.5" />
                    Copied
                  </>
                ) : (
                  <>
                    <Copy className="w-3.5 h-3.5" />
                    Copy
                  </>
                )}
              </button>
            </div>

            <div className="flex-1 min-h-[500px] code-container overflow-hidden relative">
              {/* Transformation overlay */}
              {isTransforming && (
                <div className="absolute inset-0 bg-white/80 dark:bg-neutral-950/80 backdrop-blur-sm z-10 flex items-center justify-center">
                  <div className="flex flex-col items-center gap-3">
                    <Loader2 className="w-8 h-8 text-accent animate-spin" />
                    <span className="text-sm text-neutral-500 dark:text-neutral-400">
                      Applying {selectedStrategy.name}...
                    </span>
                  </div>
                </div>
              )}

              {/* Empty state */}
              {!outputCode && !isTransforming && (
                <div className="absolute inset-0 flex items-center justify-center">
                  <div className="text-center">
                    <selectedStrategy.icon
                      size={48}
                      className="mx-auto mb-4 text-neutral-300 dark:text-neutral-700"
                    />
                    <p className="text-sm text-neutral-400 dark:text-neutral-500 mb-1">
                      No output yet
                    </p>
                    <p className="text-xs text-neutral-400 dark:text-neutral-600">
                      Click "Apply Strategy" to transform your code
                    </p>
                  </div>
                </div>
              )}

              {/* Output code */}
              {outputCode && (
                <div className="h-full flex">
                  {/* Line numbers */}
                  <div className="select-none bg-cream-50 dark:bg-neutral-900 text-neutral-400 dark:text-neutral-600 text-right py-4 px-3 border-r border-cream-200 dark:border-neutral-800 font-mono text-sm">
                    {outputCode.split('\n').map((_, idx) => (
                      <div key={idx} className="h-[1.625rem] leading-[1.625rem]">
                        {idx + 1}
                      </div>
                    ))}
                  </div>
                  {/* Code display */}
                  <div className="flex-1 overflow-auto bg-white dark:bg-neutral-950 scrollbar-thin">
                    <pre className="p-4 font-mono text-sm">
                      <code className="language-solidity">
                        {outputCode.split('\n').map((line, idx) => (
                          <div
                            key={idx}
                            className="h-[1.625rem] leading-[1.625rem] whitespace-pre"
                            dangerouslySetInnerHTML={{ __html: highlightLine(line) }}
                          />
                        ))}
                      </code>
                    </pre>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Strategy Info Cards */}
        <div className="mt-12">
          <h2 className="text-lg font-medium text-neutral-800 dark:text-neutral-200 mb-6">
            Available Strategies
          </h2>
          <div className="grid sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 stagger-children">
            {STRATEGIES.map((strategy) => (
              <button
                key={strategy.id}
                onClick={() => setSelectedStrategy(strategy)}
                className={`card p-4 text-left transition-all duration-200 hover:scale-[1.02] ${
                  selectedStrategy.id === strategy.id
                    ? 'ring-2 ring-accent border-accent dark:border-accent'
                    : ''
                }`}
              >
                <div className="flex items-start gap-3">
                  <div className="p-2 bg-cream-200 dark:bg-neutral-800 rounded-lg">
                    <strategy.icon
                      size={20}
                      className="text-neutral-700 dark:text-neutral-300"
                    />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="font-medium text-neutral-800 dark:text-neutral-100 mb-1">
                      {strategy.name}
                    </h3>
                    <p className="text-xs text-neutral-500 dark:text-neutral-400 leading-relaxed">
                      {strategy.description}
                    </p>
                  </div>
                </div>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
