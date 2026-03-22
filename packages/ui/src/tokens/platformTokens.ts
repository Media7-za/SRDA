export const platformTokens = {
    layout: {
        containerMaxWidth: 1200,
        sectionSpacing: 24
    },
    spacing: {
        xs: 4,
        sm: 8,
        md: 12,
        lg: 16,
        xl: 24,
        xxl: 32
    },
    breakpoints: {
        sm: 640,
        md: 768,
        lg: 1024,
        xl: 1280,
        xxl: 1536
    },
    radius: {
        sm: 8,
        md: 12,
        lg: 20,
        pill: 9999
    },
    shadow: {
        card: "0 8px 24px rgba(17,24,39,0.08)",
        floating: "0 12px 32px rgba(17,24,39,0.12)"
    },
    border: {
        subtle: "#E9E5DC",
        default: "#D6D3D1",
        strong: "#A8A29E",
        error: "#DC2626"
    },
    component: {
        button: {
            height: 48
        },
        badge: {
            height: 24
        },
        input: {
            height: 48
        },
        card: {
            padding: 16
        }
    },
    state: {
        hoverOverlay: "rgba(17,24,39,0.04)",
        pressedOverlay: "rgba(17,24,39,0.08)",
        disabledBg: "#E5E7EB",
        disabledText: "#9CA3AF"
    },
    status: {
        pending: "#EAB308",
        preparing: "#2563EB",
        ready: "#7C3AED",
        delivered: "#16A34A",
        failed: "#DC2626",
        reconnecting: "#F59E0B",
        offline: "#DC2626"
    },
    accessibility: {
        tapTargetMin: 44,
        focusRingWidth: 2,
        focusRingOffset: 2,
        contrastTarget: "WCAG AA",
        reducedMotion: true
    },
    motion: {
        duration: {
            fast: "120ms",
            normal: "200ms",
            slow: "300ms"
        },
        easing: {
            standard: "cubic-bezier(0.2, 0, 0, 1)",
            entrance: "cubic-bezier(0, 0, 0, 1)",
            exit: "cubic-bezier(0.4, 0, 1, 1)"
        },
        rules: {
            subtleOnly: true,
            noSpringHeavyOperationalFlows: true,
            newOrderHighlightMaxMs: 3000
        }
    }
} as const

export type PlatformTokens = typeof platformTokens
