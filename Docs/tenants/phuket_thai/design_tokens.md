# Phuket Thai Brand Overrides (V2)

This document defines the brand-specific design tokens for the Phuket Thai restaurant tenant. It overrides the generic brand parameters without altering the core SaaS structural platform tokens.

## 1. Brand Identity & Surfaces
```yaml
brand:
  primary: "#D4A017"
  secondary: "#F6E7B8"
  accent: "#EAB308"

surface:
  background: "#F8F6F2"
  card: "#FFFFFF"
```

## 2. Text System
```yaml
text:
  primary: "#111827"
  secondary: "#6B7280"
  muted: "#9CA3AF"
  inverse: "#FFFFFF"
  link: "#D4A017"
```

## 3. Typography Scale & Roles
```yaml
typography:
  family:
    primary: "Plus Jakarta Sans"
    secondary: "Inter"
  role:
    display:
      size: 40
      line_height: 48
      weight: 700
    h1:
      size: 32
      line_height: 40
      weight: 700
    h2:
      size: 24
      line_height: 32
      weight: 700
    h3:
      size: 20
      line_height: 28
      weight: 600
    body:
      size: 16
      line_height: 24
      weight: 400
    body_strong:
      size: 16
      line_height: 24
      weight: 600
    caption:
      size: 14
      line_height: 20
      weight: 500
    overline:
      size: 12
      line_height: 16
      weight: 600
```

## 4. Brand Component Variants
```yaml
component:
  button:
    primary:
      bg: "#D4A017"
      text: "#FFFFFF"
      hover_bg: "#B88912"
      pressed_bg: "#9E7710"
      focus_ring: "#D4A017"
      radius: 9999
    secondary:
      bg: "#F6E7B8"
      text: "#D4A017"
      hover_bg: "#E7D8A8"
      pressed_bg: "#D9C998"
      focus_ring: "#D4A017"
      radius: 9999
  
  input:
    bg: "#FFFFFF"
    border: "#D6D3D1"
    focus_ring: "#D4A017"
    error_border: "#DC2626"
    success_border: "#16A34A"
```

## 5. Commerce Semantics
```yaml
commerce:
  payment:
    paid: "#16A34A"
    unpaid: "#DC2626"
    refunded: "#7C3AED"
    pay_in_store: "#D4A017"
  
  fulfillment:
    delivery: "#2563EB"
    pickup: "#7C3AED"
```

## 6. Marketing & Imagery
```yaml
image:
  shape: "circle"
  shadow: "soft"
```
