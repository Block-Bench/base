import { useInView } from '../../lib/useInView'

// Framed embed for a publication figure. Light plate so light-background
// matplotlib/tikz figures read as intentional on the dark page.
export default function PaperFigure({
  section, title, blurb, src, alt, caption, plate = true,
}: {
  section: string
  title: string
  blurb?: string
  src: string
  alt: string
  caption: string
  plate?: boolean
}) {
  const [ref, inView] = useInView<HTMLDivElement>()
  const base = import.meta.env.BASE_URL.replace(/\/$/, '')
  return (
    <section className="max-w-[1300px] mx-auto px-10 py-16 border-b border-rule">
      <div className="font-mono text-xs uppercase tracking-rail text-ink-faint mb-2">{section}</div>
      <h2 className="font-serif text-3xl text-ink leading-tight mb-3 max-w-[820px]">{title}</h2>
      {blurb && <p className="serif text-ink-muted text-lg max-w-[760px] mb-10">{blurb}</p>}

      <figure ref={ref} className="border border-rule rounded-md overflow-hidden bg-bg-surface">
        <div className={plate ? 'p-6 md:p-9' : ''} style={{ background: plate ? '#F7F7F4' : undefined }}>
          <img
            src={`${base}${src}`}
            alt={alt}
            className="w-full h-auto block rounded-sm"
            style={{
              opacity: inView ? 1 : 0,
              transform: inView ? 'translateY(0)' : 'translateY(14px)',
              transition: 'opacity .7s ease, transform .7s cubic-bezier(.2,.8,.2,1)',
            }}
          />
        </div>
        <figcaption className="font-mono text-xs text-ink-faint px-6 py-4 border-t border-rule leading-relaxed">
          {caption}
        </figcaption>
      </figure>
    </section>
  )
}
