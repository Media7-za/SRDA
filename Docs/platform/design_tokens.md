# Platform Design Tokens (V2)

This document defines the structural UI system used by *every* tenant on the platform. These values are immutable at the brand level and should never be overridden by a tenant, ensuring a safe, consistent operational UI across the SaaS product.

## 1. Interaction & Fallback Rules

**Cross-App Scope Rules:**
* **Shared across all apps:** spacing, radius, breakpoints, typography scale, semantic state colors, accessibility rules.
* **Customer app may use:** brand promo cards, loyalty accent patterns, rich imagery tokens.
* **Admin and driver apps must prioritize:** operational contrast, reduced decorative imagery, stronger semantic indicators over brand flair.

**Anti-Hallucination Fallback Rules:**
If an AI agent finds a required component token missing:
1. Use the nearest existing platform token.
2. DO NOT invent new hex codes, radius values, or shadow values.
3. Flag the missing token in implementation notes or request permission to add it.

## 2. Layout & Spacing
```yaml
layout:
  container:
    max_width: 1200
  section:
    spacing: 24

spacing:
  xs: 4
  sm: 8
  md: 12
  lg: 16
  xl: 24
  xxl: 32

breakpoints:
  sm: 640
  md: 768
  lg: 1024
  xl: 1280
  xxl: 1536
```

## 3. Structural Primitives
```yaml
radius:
  sm: 8
  md: 12
  lg: 20
  pill: 9999

shadow:
  card: "0 8px 24px rgba(17,24,39,0.08)"
  floating: "0 12px 32px rgba(17,24,39,0.12)"

border:
  subtle: "#E9E5DC"
  default: "#D6D3D1"
  strong: "#A8A29E"
  error: "#DC2626"
```

## 4. Component Dimensions (Base)
```yaml
component:
  button:
    height: 48
  badge:
    height: 24
  input:
    height: 48
  card:
    padding: 16
```

## 5. Global States & Semantic Status
These are critical to kitchen operations and must remain absolutely consistent across all restaurant dashboards.
```yaml
state:
  hover_overlay: "rgba(17,24,39,0.04)"
  pressed_overlay: "rgba(17,24,39,0.08)"
  disabled_bg: "#E5E7EB"
  disabled_text: "#9CA3AF"

status:
  pending: "#EAB308"
  preparing: "#2563EB"
  ready: "#7C3AED"
  delivered: "#16A34A"
  failed: "#DC2626"
  reconnecting: "#F59E0B"
  offline: "#DC2626"
```

## 6. Motion & Accessibility
```yaml
accessibility:
  tap_target_min: 44
  focus_ring_width: 2
  focus_ring_offset: 2
  contrast_target: "WCAG AA"
  reduced_motion: true

motion:
  duration:
    fast: 120ms
    normal: 200ms
    slow: 300ms
  easing:
    standard: "cubic-bezier(0.2, 0, 0, 1)"
    entrance: "cubic-bezier(0, 0, 0, 1)"
    exit: "cubic-bezier(0.4, 0, 1, 1)"
  rules:
    - use subtle fade or slide only
    - no spring-heavy animation for operational flows
    - new order highlight max 3 seconds
```
