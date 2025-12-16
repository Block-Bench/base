import type { SVGProps } from 'react'

interface MascotProps extends SVGProps<SVGSVGElement> {
  size?: number
}

// BlockBench Mascot - Minimal pixel art security guardian
// Simple, 2D, pixelated, premium aesthetic
export function Mascot({ size = 96, className = '', ...props }: MascotProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 12 12"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      style={{ imageRendering: 'pixelated' }}
      {...props}
    >
      {/* Shield body - dark */}
      <rect x="2" y="1" width="8" height="1" fill="#262626" />
      <rect x="1" y="2" width="10" height="1" fill="#262626" />
      <rect x="1" y="3" width="10" height="1" fill="#262626" />
      <rect x="1" y="4" width="10" height="1" fill="#262626" />
      <rect x="1" y="5" width="10" height="1" fill="#262626" />
      <rect x="1" y="6" width="10" height="1" fill="#262626" />
      <rect x="2" y="7" width="8" height="1" fill="#262626" />
      <rect x="2" y="8" width="8" height="1" fill="#262626" />
      <rect x="3" y="9" width="6" height="1" fill="#262626" />
      <rect x="4" y="10" width="4" height="1" fill="#262626" />
      <rect x="5" y="11" width="2" height="1" fill="#262626" />

      {/* Eyes - cream/white */}
      <rect x="3" y="4" width="2" height="2" fill="#FAF9F7" />
      <rect x="7" y="4" width="2" height="2" fill="#FAF9F7" />

      {/* Pupils */}
      <rect x="4" y="5" width="1" height="1" fill="#262626" />
      <rect x="8" y="5" width="1" height="1" fill="#262626" />

      {/* Smile */}
      <rect x="4" y="7" width="1" height="1" fill="#8B7355" />
      <rect x="5" y="8" width="2" height="1" fill="#8B7355" />
      <rect x="7" y="7" width="1" height="1" fill="#8B7355" />
    </svg>
  )
}

// Mini version for small contexts
export function MascotMini({ size = 24, className = '', ...props }: MascotProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 8 8"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      style={{ imageRendering: 'pixelated' }}
      {...props}
    >
      {/* Shield body */}
      <rect x="1" y="0" width="6" height="1" fill="#262626" />
      <rect x="0" y="1" width="8" height="4" fill="#262626" />
      <rect x="1" y="5" width="6" height="1" fill="#262626" />
      <rect x="2" y="6" width="4" height="1" fill="#262626" />
      <rect x="3" y="7" width="2" height="1" fill="#262626" />

      {/* Eyes */}
      <rect x="2" y="2" width="1" height="2" fill="#FAF9F7" />
      <rect x="5" y="2" width="1" height="2" fill="#FAF9F7" />

      {/* Pupils */}
      <rect x="2" y="3" width="1" height="1" fill="#262626" />
      <rect x="5" y="3" width="1" height="1" fill="#262626" />
    </svg>
  )
}

// Loading state - simple blink animation
export function MascotLoading({ size = 48, className = '', ...props }: MascotProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 12 12"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      style={{ imageRendering: 'pixelated' }}
      {...props}
    >
      {/* Shield body */}
      <rect x="2" y="1" width="8" height="1" fill="#262626" />
      <rect x="1" y="2" width="10" height="1" fill="#262626" />
      <rect x="1" y="3" width="10" height="1" fill="#262626" />
      <rect x="1" y="4" width="10" height="1" fill="#262626" />
      <rect x="1" y="5" width="10" height="1" fill="#262626" />
      <rect x="1" y="6" width="10" height="1" fill="#262626" />
      <rect x="2" y="7" width="8" height="1" fill="#262626" />
      <rect x="2" y="8" width="8" height="1" fill="#262626" />
      <rect x="3" y="9" width="6" height="1" fill="#262626" />
      <rect x="4" y="10" width="4" height="1" fill="#262626" />
      <rect x="5" y="11" width="2" height="1" fill="#262626" />

      {/* Blinking eyes */}
      <rect x="3" y="4" width="2" height="2" fill="#FAF9F7">
        <animate attributeName="height" values="2;0;2" dur="1.5s" repeatCount="indefinite" />
      </rect>
      <rect x="7" y="4" width="2" height="2" fill="#FAF9F7">
        <animate attributeName="height" values="2;0;2" dur="1.5s" repeatCount="indefinite" />
      </rect>

      {/* Pupils */}
      <rect x="4" y="5" width="1" height="1" fill="#262626">
        <animate attributeName="opacity" values="1;0;1" dur="1.5s" repeatCount="indefinite" />
      </rect>
      <rect x="8" y="5" width="1" height="1" fill="#262626">
        <animate attributeName="opacity" values="1;0;1" dur="1.5s" repeatCount="indefinite" />
      </rect>

      {/* Smile */}
      <rect x="4" y="7" width="1" height="1" fill="#8B7355" />
      <rect x="5" y="8" width="2" height="1" fill="#8B7355" />
      <rect x="7" y="7" width="1" height="1" fill="#8B7355" />
    </svg>
  )
}

export default Mascot
