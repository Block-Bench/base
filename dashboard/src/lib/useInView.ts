import { useEffect, useRef, useState } from 'react'

/** Returns [ref, inView] — flips true once when the element enters the viewport. */
export function useInView<T extends HTMLElement = HTMLDivElement>(margin = '-60px') {
  const ref = useRef<T | null>(null)
  const [inView, setInView] = useState(false)
  useEffect(() => {
    const el = ref.current
    if (!el) return
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((e) => {
          if (e.isIntersecting) {
            setInView(true)
            io.disconnect()
          }
        })
      },
      { rootMargin: margin, threshold: 0.15 }
    )
    io.observe(el)
    return () => io.disconnect()
  }, [margin])
  return [ref, inView] as const
}
