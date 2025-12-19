import type { SVGProps } from 'react'
import type { JSX } from 'react'

interface StrategyIconProps extends SVGProps<SVGSVGElement> {
  size?: number
}

// Chameleon Strategy - Color-changing lizard icon
export function ChameleonIcon({ size = 24, className = '', ...props }: StrategyIconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      style={{ imageRendering: 'pixelated' }}
      {...props}
    >
      {/* Body */}
      <rect x="4" y="6" width="1" height="1" fill="currentColor" />
      <rect x="5" y="5" width="1" height="1" fill="currentColor" />
      <rect x="6" y="4" width="1" height="1" fill="currentColor" />
      <rect x="7" y="4" width="1" height="1" fill="currentColor" />
      <rect x="8" y="4" width="1" height="1" fill="currentColor" />
      <rect x="9" y="5" width="1" height="1" fill="currentColor" />
      <rect x="10" y="6" width="1" height="1" fill="currentColor" />
      <rect x="10" y="7" width="1" height="1" fill="currentColor" />
      <rect x="10" y="8" width="1" height="1" fill="currentColor" />
      <rect x="9" y="9" width="1" height="1" fill="currentColor" />
      <rect x="8" y="10" width="1" height="1" fill="currentColor" />
      <rect x="7" y="10" width="1" height="1" fill="currentColor" />
      <rect x="6" y="10" width="1" height="1" fill="currentColor" />
      <rect x="5" y="9" width="1" height="1" fill="currentColor" />
      <rect x="4" y="8" width="1" height="1" fill="currentColor" />
      <rect x="4" y="7" width="1" height="1" fill="currentColor" />
      {/* Eye */}
      <rect x="6" y="6" width="1" height="1" fill="currentColor" />
      {/* Tail curl */}
      <rect x="11" y="8" width="1" height="1" fill="currentColor" />
      <rect x="12" y="9" width="1" height="1" fill="currentColor" />
      <rect x="12" y="10" width="1" height="1" fill="currentColor" />
      <rect x="11" y="11" width="1" height="1" fill="currentColor" />
      {/* Tongue */}
      <rect x="3" y="7" width="1" height="1" fill="currentColor" />
      <rect x="2" y="7" width="1" height="1" fill="currentColor" />
    </svg>
  )
}

// Mirror Strategy - Reflection icon
export function MirrorIcon({ size = 24, className = '', ...props }: StrategyIconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      style={{ imageRendering: 'pixelated' }}
      {...props}
    >
      {/* Left side */}
      <rect x="3" y="3" width="1" height="1" fill="currentColor" />
      <rect x="4" y="4" width="1" height="1" fill="currentColor" />
      <rect x="5" y="5" width="1" height="1" fill="currentColor" />
      <rect x="5" y="6" width="1" height="1" fill="currentColor" />
      <rect x="5" y="7" width="1" height="1" fill="currentColor" />
      <rect x="4" y="8" width="1" height="1" fill="currentColor" />
      <rect x="3" y="9" width="1" height="1" fill="currentColor" />
      <rect x="4" y="10" width="1" height="1" fill="currentColor" />
      <rect x="5" y="11" width="1" height="1" fill="currentColor" />
      {/* Center line */}
      <rect x="7" y="2" width="1" height="12" fill="currentColor" />
      <rect x="8" y="2" width="1" height="12" fill="currentColor" />
      {/* Right side (mirrored) */}
      <rect x="12" y="3" width="1" height="1" fill="currentColor" />
      <rect x="11" y="4" width="1" height="1" fill="currentColor" />
      <rect x="10" y="5" width="1" height="1" fill="currentColor" />
      <rect x="10" y="6" width="1" height="1" fill="currentColor" />
      <rect x="10" y="7" width="1" height="1" fill="currentColor" />
      <rect x="11" y="8" width="1" height="1" fill="currentColor" />
      <rect x="12" y="9" width="1" height="1" fill="currentColor" />
      <rect x="11" y="10" width="1" height="1" fill="currentColor" />
      <rect x="10" y="11" width="1" height="1" fill="currentColor" />
    </svg>
  )
}

// Sanitize Strategy - Cleaning/eraser icon
export function SanitizeIcon({ size = 24, className = '', ...props }: StrategyIconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      style={{ imageRendering: 'pixelated' }}
      {...props}
    >
      {/* Eraser body */}
      <rect x="3" y="10" width="1" height="1" fill="currentColor" />
      <rect x="4" y="9" width="1" height="1" fill="currentColor" />
      <rect x="5" y="8" width="1" height="1" fill="currentColor" />
      <rect x="6" y="7" width="1" height="1" fill="currentColor" />
      <rect x="7" y="6" width="1" height="1" fill="currentColor" />
      <rect x="8" y="5" width="1" height="1" fill="currentColor" />
      <rect x="9" y="4" width="1" height="1" fill="currentColor" />
      <rect x="10" y="3" width="1" height="1" fill="currentColor" />
      {/* Handle */}
      <rect x="11" y="2" width="1" height="1" fill="currentColor" />
      <rect x="12" y="2" width="1" height="1" fill="currentColor" />
      <rect x="12" y="3" width="1" height="1" fill="currentColor" />
      <rect x="11" y="4" width="1" height="1" fill="currentColor" />
      {/* Eraser tip outline */}
      <rect x="2" y="11" width="1" height="1" fill="currentColor" />
      <rect x="3" y="11" width="1" height="1" fill="currentColor" />
      <rect x="4" y="10" width="1" height="1" fill="currentColor" />
      <rect x="2" y="12" width="1" height="1" fill="currentColor" />
      <rect x="3" y="12" width="1" height="1" fill="currentColor" />
      {/* Sparkles */}
      <rect x="6" y="3" width="1" height="1" fill="currentColor" />
      <rect x="4" y="5" width="1" height="1" fill="currentColor" />
      <rect x="8" y="2" width="1" height="1" fill="currentColor" />
    </svg>
  )
}

// NoComments Strategy - Comment slash icon
export function NoCommentsIcon({ size = 24, className = '', ...props }: StrategyIconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      style={{ imageRendering: 'pixelated' }}
      {...props}
    >
      {/* Comment bubble */}
      <rect x="2" y="3" width="12" height="1" fill="currentColor" />
      <rect x="2" y="4" width="1" height="6" fill="currentColor" />
      <rect x="13" y="4" width="1" height="6" fill="currentColor" />
      <rect x="2" y="10" width="5" height="1" fill="currentColor" />
      <rect x="9" y="10" width="5" height="1" fill="currentColor" />
      {/* Tail */}
      <rect x="4" y="11" width="1" height="1" fill="currentColor" />
      <rect x="3" y="12" width="1" height="1" fill="currentColor" />
      {/* Slash through */}
      <rect x="3" y="11" width="1" height="1" fill="currentColor" />
      <rect x="4" y="10" width="1" height="1" fill="currentColor" />
      <rect x="5" y="9" width="1" height="1" fill="currentColor" />
      <rect x="6" y="8" width="1" height="1" fill="currentColor" />
      <rect x="7" y="7" width="1" height="1" fill="currentColor" />
      <rect x="8" y="6" width="1" height="1" fill="currentColor" />
      <rect x="9" y="5" width="1" height="1" fill="currentColor" />
      <rect x="10" y="4" width="1" height="1" fill="currentColor" />
      <rect x="11" y="3" width="1" height="1" fill="currentColor" />
      <rect x="12" y="2" width="1" height="1" fill="currentColor" />
    </svg>
  )
}

// CrossDomain Strategy - Network/web icon
export function CrossDomainIcon({ size = 24, className = '', ...props }: StrategyIconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      style={{ imageRendering: 'pixelated' }}
      {...props}
    >
      {/* Center node */}
      <rect x="7" y="7" width="2" height="2" fill="currentColor" />
      {/* Top node */}
      <rect x="7" y="2" width="2" height="2" fill="currentColor" />
      {/* Bottom node */}
      <rect x="7" y="12" width="2" height="2" fill="currentColor" />
      {/* Left node */}
      <rect x="2" y="7" width="2" height="2" fill="currentColor" />
      {/* Right node */}
      <rect x="12" y="7" width="2" height="2" fill="currentColor" />
      {/* Connections */}
      <rect x="8" y="4" width="1" height="3" fill="currentColor" />
      <rect x="8" y="9" width="1" height="3" fill="currentColor" />
      <rect x="4" y="8" width="3" height="1" fill="currentColor" />
      <rect x="9" y="8" width="3" height="1" fill="currentColor" />
      {/* Diagonal lines */}
      <rect x="5" y="5" width="1" height="1" fill="currentColor" />
      <rect x="10" y="5" width="1" height="1" fill="currentColor" />
      <rect x="5" y="10" width="1" height="1" fill="currentColor" />
      <rect x="10" y="10" width="1" height="1" fill="currentColor" />
    </svg>
  )
}

// GuardianShield Strategy - Shield with eye icon
export function GuardianShieldIcon({ size = 24, className = '', ...props }: StrategyIconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      style={{ imageRendering: 'pixelated' }}
      {...props}
    >
      {/* Shield outline */}
      <rect x="3" y="2" width="10" height="1" fill="currentColor" />
      <rect x="2" y="3" width="1" height="7" fill="currentColor" />
      <rect x="13" y="3" width="1" height="7" fill="currentColor" />
      <rect x="3" y="10" width="1" height="1" fill="currentColor" />
      <rect x="12" y="10" width="1" height="1" fill="currentColor" />
      <rect x="4" y="11" width="1" height="1" fill="currentColor" />
      <rect x="11" y="11" width="1" height="1" fill="currentColor" />
      <rect x="5" y="12" width="1" height="1" fill="currentColor" />
      <rect x="10" y="12" width="1" height="1" fill="currentColor" />
      <rect x="6" y="13" width="4" height="1" fill="currentColor" />
      {/* Eye */}
      <rect x="5" y="6" width="1" height="1" fill="currentColor" />
      <rect x="6" y="5" width="1" height="1" fill="currentColor" />
      <rect x="7" y="5" width="2" height="1" fill="currentColor" />
      <rect x="9" y="6" width="1" height="1" fill="currentColor" />
      <rect x="10" y="6" width="1" height="1" fill="currentColor" />
      <rect x="5" y="7" width="1" height="1" fill="currentColor" />
      <rect x="10" y="7" width="1" height="1" fill="currentColor" />
      <rect x="6" y="8" width="1" height="1" fill="currentColor" />
      <rect x="9" y="8" width="1" height="1" fill="currentColor" />
      <rect x="7" y="8" width="2" height="1" fill="currentColor" />
      {/* Pupil */}
      <rect x="7" y="6" width="2" height="2" fill="currentColor" />
    </svg>
  )
}

// Hydra Strategy - Multi-headed serpent icon
export function HydraIcon({ size = 24, className = '', ...props }: StrategyIconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      style={{ imageRendering: 'pixelated' }}
      {...props}
    >
      {/* Body/base */}
      <rect x="7" y="12" width="2" height="2" fill="currentColor" />
      <rect x="6" y="10" width="4" height="2" fill="currentColor" />
      <rect x="7" y="8" width="2" height="2" fill="currentColor" />
      {/* Left head */}
      <rect x="3" y="2" width="2" height="2" fill="currentColor" />
      <rect x="4" y="4" width="1" height="1" fill="currentColor" />
      <rect x="5" y="5" width="1" height="1" fill="currentColor" />
      <rect x="6" y="6" width="1" height="1" fill="currentColor" />
      <rect x="7" y="7" width="1" height="1" fill="currentColor" />
      {/* Center head */}
      <rect x="7" y="2" width="2" height="2" fill="currentColor" />
      <rect x="7" y="4" width="2" height="1" fill="currentColor" />
      <rect x="7" y="5" width="2" height="1" fill="currentColor" />
      <rect x="7" y="6" width="2" height="1" fill="currentColor" />
      {/* Right head */}
      <rect x="11" y="2" width="2" height="2" fill="currentColor" />
      <rect x="11" y="4" width="1" height="1" fill="currentColor" />
      <rect x="10" y="5" width="1" height="1" fill="currentColor" />
      <rect x="9" y="6" width="1" height="1" fill="currentColor" />
      <rect x="8" y="7" width="1" height="1" fill="currentColor" />
    </svg>
  )
}

// Shapeshifter Strategy - Morphing/transformation icon
export function ShapeshifterIcon({ size = 24, className = '', ...props }: StrategyIconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      style={{ imageRendering: 'pixelated' }}
      {...props}
    >
      {/* Left shape (circle) */}
      <rect x="3" y="5" width="1" height="1" fill="currentColor" />
      <rect x="2" y="6" width="1" height="1" fill="currentColor" />
      <rect x="2" y="7" width="1" height="1" fill="currentColor" />
      <rect x="3" y="8" width="1" height="1" fill="currentColor" />
      <rect x="4" y="5" width="1" height="1" fill="currentColor" />
      <rect x="4" y="8" width="1" height="1" fill="currentColor" />
      <rect x="5" y="5" width="1" height="1" fill="currentColor" />
      <rect x="5" y="8" width="1" height="1" fill="currentColor" />
      <rect x="6" y="6" width="1" height="1" fill="currentColor" />
      <rect x="6" y="7" width="1" height="1" fill="currentColor" />
      {/* Transformation arrow */}
      <rect x="7" y="6" width="1" height="2" fill="currentColor" />
      <rect x="8" y="6" width="1" height="2" fill="currentColor" />
      <rect x="9" y="5" width="1" height="1" fill="currentColor" />
      <rect x="9" y="8" width="1" height="1" fill="currentColor" />
      {/* Right shape (hexagon) */}
      <rect x="11" y="4" width="2" height="1" fill="currentColor" />
      <rect x="10" y="5" width="1" height="1" fill="currentColor" />
      <rect x="13" y="5" width="1" height="1" fill="currentColor" />
      <rect x="10" y="6" width="1" height="2" fill="currentColor" />
      <rect x="13" y="6" width="1" height="2" fill="currentColor" />
      <rect x="10" y="8" width="1" height="1" fill="currentColor" />
      <rect x="13" y="8" width="1" height="1" fill="currentColor" />
      <rect x="11" y="9" width="2" height="1" fill="currentColor" />
    </svg>
  )
}

// Restructure Strategy - Building blocks rearranging
export function RestructureIcon({ size = 24, className = '', ...props }: StrategyIconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      style={{ imageRendering: 'pixelated' }}
      {...props}
    >
      {/* Top left block */}
      <rect x="2" y="2" width="4" height="4" fill="currentColor" />
      <rect x="3" y="3" width="2" height="2" fill="white" opacity="0.3" />
      {/* Top right blocks (split) */}
      <rect x="10" y="2" width="2" height="2" fill="currentColor" />
      <rect x="13" y="2" width="2" height="2" fill="currentColor" />
      {/* Bottom left blocks (split) */}
      <rect x="2" y="10" width="2" height="2" fill="currentColor" />
      <rect x="5" y="10" width="2" height="2" fill="currentColor" />
      {/* Bottom right block (merged) */}
      <rect x="10" y="10" width="4" height="4" fill="currentColor" />
      <rect x="11" y="11" width="2" height="2" fill="white" opacity="0.3" />
      {/* Arrows indicating movement */}
      <rect x="7" y="3" width="2" height="1" fill="currentColor" opacity="0.5" />
      <rect x="3" y="7" width="1" height="2" fill="currentColor" opacity="0.5" />
      <rect x="8" y="11" width="1" height="1" fill="currentColor" opacity="0.5" />
    </svg>
  )
}

// Strategy info type
export interface StrategyInfo {
  id: string
  name: string
  description: string
  icon: (props: StrategyIconProps) => JSX.Element
}

// All available strategies
export const STRATEGIES: StrategyInfo[] = [
  {
    id: 'sanitize',
    name: 'Sanitize',
    description: '280+ patterns to remove vulnerability hints from code',
    icon: SanitizeIcon,
  },
  {
    id: 'nocomments',
    name: 'No Comments',
    description: 'Strip all comments while preserving code logic',
    icon: NoCommentsIcon,
  },
  {
    id: 'chameleon',
    name: 'Chameleon',
    description: 'Thematic identifier renaming with 60-70% coverage',
    icon: ChameleonIcon,
  },
  {
    id: 'shapeshifter',
    name: 'Shapeshifter',
    description: 'Multi-level obfuscation (L2: identifiers, L3: control flow)',
    icon: ShapeshifterIcon,
  },
  {
    id: 'hydra',
    name: 'Hydra',
    description: 'Sequential composition of multiple transformations',
    icon: HydraIcon,
  },
  {
    id: 'restructure',
    name: 'Restructure',
    description: 'Contract splitting and merging operations',
    icon: RestructureIcon,
  },
  {
    id: 'mirror',
    name: 'Mirror',
    description: 'Format code with different styling conventions',
    icon: MirrorIcon,
  },
]

export default STRATEGIES
