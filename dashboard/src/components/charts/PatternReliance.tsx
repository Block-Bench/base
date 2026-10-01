import { useInView } from '../../lib/useInView'
import { RELIANCE, RELIANCE_THRESHOLD } from '../../data/paperCharts'

// Native rebuild of Figure 9 — Decoy Sensitivity Index vs ROOT_CAUSE Match Rate.
export default function PatternReliance() {
  const [ref, inView] = useInView<HTMLDivElement>()

  const W = 1000, H = 600
  const padL = 74, padR = 40, padT = 46, padB = 78
  const xMin = 0, xMax = 45, yMin = 25, yMax = 70
  const px = (v: number) => padL + ((v - xMin) / (xMax - xMin)) * (W - padL - padR)
  const py = (v: number) => padT + (1 - (v - yMin) / (yMax - yMin)) * (H - padT - padB)

  const xTicks = [0, 10, 20, 30, 40]
  const yTicks = [30, 40, 50, 60, 70]

  return (
    <section className="max-w-[1300px] mx-auto px-10 py-16 border-b border-rule">
      <div className="font-mono text-xs uppercase tracking-rail text-ink-faint mb-2">
        §5 · pattern reliance
      </div>
      <h2 className="font-serif text-3xl text-ink leading-tight mb-3 max-w-[820px]">
        Models that lean on surface patterns collapse when decoys appear.
      </h2>
      <p className="serif text-ink-muted text-lg max-w-[760px] mb-10">
        Decoy Sensitivity Index measures how far detection drops when suspicious-but-safe{' '}
        <span className="text-ink">DECOY</span> segments are injected. High index (right)
        means the model was leaning on how the code <em>looks</em>, not what it does.
      </p>

      <div ref={ref} className="border border-rule bg-bg-surface rounded-md overflow-hidden">
        <svg viewBox={`0 0 ${W} ${H}`} className="w-full h-auto block" role="img"
          aria-label="Decoy Sensitivity Index versus ROOT_CAUSE match rate, per model">
          {/* high-pattern-reliance zone */}
          <rect x={px(RELIANCE_THRESHOLD)} y={padT} width={px(xMax) - px(RELIANCE_THRESHOLD)}
            height={H - padT - padB} fill="rgba(255,90,90,0.06)" />
          <line x1={px(RELIANCE_THRESHOLD)} y1={padT} x2={px(RELIANCE_THRESHOLD)} y2={H - padB}
            stroke="rgba(255,90,90,0.35)" strokeDasharray="4 5" />
          <text x={px(38)} y={py(29)} fill="#FF5A5A" fillOpacity={0.75} fontSize="15"
            fontFamily="var(--font-mono, monospace)" textAnchor="middle" fontStyle="italic">
            high pattern reliance
          </text>
          <text x={px(9)} y={py(66)} fill="#5AFFA8" fillOpacity={0.7} fontSize="13.5"
            fontFamily="var(--font-mono, monospace)">
            robust · low reliance
          </text>

          {/* grid + axes */}
          {xTicks.map((t) => (
            <g key={`x${t}`}>
              <line x1={px(t)} y1={padT} x2={px(t)} y2={H - padB} stroke="rgba(255,255,255,0.05)" />
              <text x={px(t)} y={H - padB + 26} fill="#525259" fontSize="14" textAnchor="middle" fontFamily="monospace">{t}</text>
            </g>
          ))}
          {yTicks.map((t) => (
            <g key={`y${t}`}>
              <line x1={padL} y1={py(t)} x2={W - padR} y2={py(t)} stroke="rgba(255,255,255,0.05)" />
              <text x={padL - 14} y={py(t) + 5} fill="#525259" fontSize="14" textAnchor="end" fontFamily="monospace">{t}</text>
            </g>
          ))}

          {/* axis titles */}
          <text x={(padL + W - padR) / 2} y={H - 20} fill="#8A8A93" fontSize="15" textAnchor="middle"
            fontFamily="monospace">Decoy Sensitivity Index (%) — drop when DECOYs added</text>
          <text transform={`translate(20 ${(padT + H - padB) / 2}) rotate(-90)`} fill="#8A8A93" fontSize="15"
            textAnchor="middle" fontFamily="monospace">ROOT_CAUSE match rate (%)</text>

          {/* points */}
          {RELIANCE.map((p, i) => (
            <g key={p.key} style={{
              opacity: inView ? 1 : 0,
              transform: inView ? 'scale(1)' : 'scale(0.6)',
              transformOrigin: `${px(p.ci)}px ${py(p.rc)}px`,
              transition: `opacity .5s ${0.1 + i * 0.07}s ease, transform .6s ${0.1 + i * 0.07}s cubic-bezier(.2,.8,.2,1)`,
            }}>
              <circle cx={px(p.ci)} cy={py(p.rc)} r={13} fill={p.color} fillOpacity={0.18} />
              <circle cx={px(p.ci)} cy={py(p.rc)} r={8} fill={p.color} stroke="#0A0A0B" strokeWidth={1.5} />
              <text x={px(p.ci) + 16} y={py(p.rc) + 5} fill={p.color} fontSize="15.5" fontWeight={600}
                fontFamily="var(--font-sans, sans-serif)">{p.label}</text>
            </g>
          ))}
        </svg>
      </div>

      <div className="mt-5 font-mono text-xs text-ink-faint leading-relaxed max-w-[860px]">
        <span className="text-ink">Llama 4 Maverick</span> sits top-left — highest ROOT_CAUSE match (60.9%)
        yet only 31.7% TDR: it points at the right lines without explaining why. Claude and DeepSeek sit
        deep in the high-reliance zone, most sensitive to injected decoys.
      </div>
    </section>
  )
}
