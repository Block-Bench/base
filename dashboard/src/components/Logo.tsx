import type { SVGProps } from 'react'

interface LogoProps extends SVGProps<SVGSVGElement> {
  size?: number
  variant?: 'full' | 'icon'
}

// BlockBench Logo - Block + Shield combined
export function Logo({ size = 32, variant = 'icon', className = '', ...props }: LogoProps) {
  if (variant === 'full') {
    return (
      <svg
        width={size * 4}
        height={size}
        viewBox="0 0 160 40"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className={className}
        {...props}
      >
        {/* Icon */}
        <g transform="translate(0, 0)">
          {/* Block shape with shield cutout */}
          <path
            d="M8 12 L20 4 L32 12 L32 28 L20 36 L8 28 Z"
            fill="#262626"
          />
          {/* Inner shield */}
          <path
            d="M14 14 L20 10 L26 14 L26 22 Q20 28 14 22 Z"
            fill="#FAF9F7"
          />
          {/* Shield cross */}
          <path
            d="M20 13 L20 23 M16 17 L24 17"
            stroke="#262626"
            strokeWidth="2"
            strokeLinecap="round"
          />
        </g>

        {/* Text */}
        <text
          x="44"
          y="27"
          fontFamily="Inter, system-ui, sans-serif"
          fontSize="20"
          fontWeight="600"
          fill="#262626"
        >
          BlockBench
        </text>
      </svg>
    )
  }

  // Icon only variant
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 40 40"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      {...props}
    >
      {/* Block shape */}
      <path
        d="M8 14 L20 6 L32 14 L32 30 L20 38 L8 30 Z"
        fill="#262626"
      />
      {/* 3D effect - top */}
      <path
        d="M8 14 L20 6 L32 14 L20 22 Z"
        fill="#404040"
      />
      {/* 3D effect - left */}
      <path
        d="M8 14 L20 22 L20 38 L8 30 Z"
        fill="#262626"
      />
      {/* 3D effect - right */}
      <path
        d="M20 22 L32 14 L32 30 L20 38 Z"
        fill="#1F1F1F"
      />
      {/* Inner shield */}
      <path
        d="M14 17 L20 13 L26 17 L26 25 Q20 31 14 25 Z"
        fill="#FAF9F7"
      />
      {/* Shield cross/plus - security symbol */}
      <path
        d="M20 16 L20 26 M16 20.5 L24 20.5"
        stroke="#262626"
        strokeWidth="2.5"
        strokeLinecap="round"
      />
    </svg>
  )
}

// Minimal logo for very small sizes (favicon style)
export function LogoMini({ size = 16, className = '', ...props }: Omit<LogoProps, 'variant'>) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 16 16"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      {...props}
    >
      {/* Simplified block with shield */}
      <path
        d="M3 5.5 L8 2 L13 5.5 L13 12 L8 15.5 L3 12 Z"
        fill="#262626"
      />
      <path
        d="M5.5 6.5 L8 5 L10.5 6.5 L10.5 10 Q8 12.5 5.5 10 Z"
        fill="#FAF9F7"
      />
      <path
        d="M8 6.5 L8 10.5 M6.5 8.25 L9.5 8.25"
        stroke="#262626"
        strokeWidth="1.5"
        strokeLinecap="round"
      />
    </svg>
  )
}

// Animated logo for loading states
export function LogoAnimated({ size = 40, className = '', ...props }: Omit<LogoProps, 'variant'>) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 40 40"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
      {...props}
    >
      {/* Block shape */}
      <path
        d="M8 14 L20 6 L32 14 L32 30 L20 38 L8 30 Z"
        fill="#262626"
      >
        <animate
          attributeName="opacity"
          values="1;0.7;1"
          dur="2s"
          repeatCount="indefinite"
        />
      </path>
      {/* Top face */}
      <path
        d="M8 14 L20 6 L32 14 L20 22 Z"
        fill="#404040"
      />
      {/* Left face */}
      <path
        d="M8 14 L20 22 L20 38 L8 30 Z"
        fill="#262626"
      />
      {/* Right face */}
      <path
        d="M20 22 L32 14 L32 30 L20 38 Z"
        fill="#1F1F1F"
      />
      {/* Shield */}
      <path
        d="M14 17 L20 13 L26 17 L26 25 Q20 31 14 25 Z"
        fill="#FAF9F7"
      >
        <animate
          attributeName="fill"
          values="#FAF9F7;#8B7355;#FAF9F7"
          dur="2s"
          repeatCount="indefinite"
        />
      </path>
      {/* Cross */}
      <path
        d="M20 16 L20 26 M16 20.5 L24 20.5"
        stroke="#262626"
        strokeWidth="2.5"
        strokeLinecap="round"
      >
        <animate
          attributeName="stroke"
          values="#262626;#FAF9F7;#262626"
          dur="2s"
          repeatCount="indefinite"
        />
      </path>
    </svg>
  )
}

export default Logo
