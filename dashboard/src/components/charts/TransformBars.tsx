import { useInView } from '../../lib/useInView'
import { TRANSFORMS } from '../../data/paperCharts'

export default function TransformBars() {
  const [ref, inView] = useInView<HTMLDivElement>()
  const max = Math.max(...TRANSFORMS.map((t) => t.avg))
  return (
    <section className="max-w-[1300px] mx-auto px-10 py-16 border-b border-rule">
      <div className="font-mono text-xs uppercase tracking-rail text-ink-faint mb-2">
        §6 · semantic-preserving stress tests
      </div>
      <h2 className="font-serif text-3xl text-ink leading-tight mb-3 max-w-[820px]">
        Strip the surface cues, keep the exploit — detection falls.
      </h2>
      <p className="serif text-ink-muted text-lg max-w-[760px] mb-10">
        Each transformation preserves the vulnerability while removing a recognition crutch.
        Realistic perturbations already hurt; adversarial ones push every model toward a floor.
      </p>

      <div ref={ref} className="border border-rule bg-bg-surface rounded-md p-8 md:p-10">
        {TRANSFORMS.map((t, i) => (
          <div key={t.key} className="py-3.5 border-b border-rule last:border-0">
            <div className="flex items-center justify-between mb-2">
              <span className="font-mono text-sm text-ink font-medium">{t.name}</span>
              <span className={`font-mono text-2xs uppercase tracking-rail px-2 py-0.5 rounded-sm ${
                t.tier === 'realistic' ? 'text-[#5AB8FF] bg-[#5AB8FF1a]' : 'text-[#FF8A5A] bg-[#FF8A5A1a]'
              }`}>{t.tier}</span>
            </div>
            <div className="relative h-[10px] bg-rule rounded-sm overflow-hidden">
              <div className="absolute left-0 top-0 h-full rounded-sm" style={{
                width: inView ? `${(t.avg / max) * 100}%` : '0%',
                background: t.tier === 'realistic'
                  ? 'linear-gradient(90deg,#4285F4,#5AB8FF)'
                  : 'linear-gradient(90deg,#FFB05A,#FF5A5A)',
                transition: `width .8s ${i * 0.06}s cubic-bezier(.2,.8,.2,1)`,
              }} />
            </div>
            <div className="font-mono text-2xs text-ink-faint tabular mt-1.5">{t.avg.toFixed(1)}% avg TDR</div>
          </div>
        ))}
      </div>
    </section>
  )
}
