export const semanticTokens = {
    color: {
        background: "var(--tenant-color-bg)",
        surface: "var(--tenant-color-surface)",
        textPrimary: "var(--tenant-color-text-primary)",
        textSecondary: "var(--tenant-color-text-secondary)",
        brandPrimary: "var(--tenant-color-brand-primary)",
        brandAccent: "var(--tenant-color-brand-accent)",
        brandAccentText: "var(--tenant-color-brand-accent-text)",
        borderSubtle: "var(--border-subtle)"
    },
    status: {
        pending: "var(--status-pending)",
        preparing: "var(--status-preparing)",
        ready: "var(--status-ready)",
        delivered: "var(--status-delivered)",
        failed: "var(--status-failed)",
        reconnecting: "var(--status-reconnecting)",
        offline: "var(--status-offline)"
    },
    component: {
        buttonHeight: "var(--component-button-height)",
        badgeHeight: "var(--component-badge-height)",
        inputHeight: "var(--component-input-height)",
        cardPadding: "var(--component-card-padding)"
    },
    radius: {
        sm: "var(--radius-sm)",
        md: "var(--radius-md)",
        lg: "var(--radius-lg)",
        pill: "var(--radius-pill)"
    },
    shadow: {
        card: "var(--shadow-card)",
        floating: "var(--shadow-floating)"
    }
} as const

export type SemanticTokens = typeof semanticTokens
