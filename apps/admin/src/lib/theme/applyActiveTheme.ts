"use client"

import { applyThemeVars, mergeThemeVars } from "@restaurant-direct/ui"

import { phuketThaiTheme } from "./phuketThaiTheme"

export function applyActiveTheme(target?: HTMLElement) {
    const resolvedTarget = target ?? (typeof document !== "undefined" ? document.documentElement : undefined)

    if (!resolvedTarget) {
        return
    }

    applyThemeVars(mergeThemeVars(phuketThaiTheme), resolvedTarget)
}
