import { useInView } from '../../lib/useInView'
import { COLLAPSE, EXPOSURE } from '../../data/paperCharts'

function Stat({ v, label, sub, tone, w, delay, show }: {
  v: number; label: string; sub: string; tone: string; w: number; delay: number; show: boolean
}) {
  return (
    <div className="flex-1 min-w-[150px]">
      <div className="font-mono text-6xl text-ink tabular font-semibold leading-none" style={{ color: tone }}>
        {v.toFixed(1)}<span className="text-3xl text-ink-faint">%</span>
      </div>
      <div className="font-mono text-sm text-ink mt-3 font-medium">{label}</div>
      <div className="font-mono text-xs text-ink-faint mt-1">{sub}</div>
      <div className="h-[3px] bg-rule mt-4 overflow-hidden">
        <div className="h-full" style={{
          width: show ? `${w}%` : '0%', background: tone,
          transition: `width 1s ${delay}s cubic-bezier(.2,.8,.2,1)`,
        }} />
      </div>
    </div>
  )
}

export default function CollapseBanner() {
  const [ref, inView] = useInView<HTMLDivElement>()
  return (
    <section className="max-w-[1300px] mx-auto px-10 py-16 border-b border-rule">
      <div className="font-mono text-xs uppercase tracking-rail text-ink-faint mb-8">
        §2 · the core collapse
      </div>
      <div ref={ref} className="grid grid-cols-[1fr_auto_1fr_auto_1fr] items-start gap-8 border border-rule bg-bg-surface p-10 rounded-md max-md:grid-cols-1">
        <Stat v={COLLAPSE.contaminated} label="Likely-contaminated" sub="DS · canonical benchmarks" tone="#E8FF5A" w={100} delay={0.05} show={inView} />
        <div className="self-center font-mono text-2xl text-ink-dim max-md:hidden">→</div>
        <Stat v={COLLAPSE.postCutoff} label="After reported cutoff" sub="GS · full audit set" tone="#FFB05A" w={32} delay={0.15} show={inView} />
        <div className="self-center font-mono text-2xl text-ink-dim max-md:hidden">→</div>
        <Stat v={COLLAPSE.newest} label="Newest disclosed" sub="GS · most recent slice" tone="#FF5A5A" w={4} delay={0.25} show={inView} />
      </div>
      <p className="serif text-ink-muted text-lg mt-6 max-w-[880px]">
        The same models that score <span className="text-ink font-semibold">86.5%</span> on familiar,
        well-documented vulnerabilities fall to near-zero on audit findings disclosed after their
        training cutoff. Re-run the older Gold-Standard contracts today and detection climbs from{' '}
        <span className="text-ink font-semibold">{EXPOSURE.early}%</span> back to{' '}
        <span className="text-ink font-semibold">{EXPOSURE.late}%</span> as public exposure accumulates,
        on contracts that never changed. This is consistent with contamination rather than a gain
        in capability.
      </p>
    </section>
  )
}
