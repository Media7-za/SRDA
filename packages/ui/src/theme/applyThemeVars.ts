import { getPlatformCssVars, type ThemeVars } from "./platformCssVars"

export function mergeThemeVars(...themeSets: Array<ThemeVars | undefined>): ThemeVars {
    return themeSets.reduce<ThemeVars>((acc, themeSet) => {
        if (!themeSet) {
            return acc
        }

        return {
            ...acc,
            ...themeSet
        }
    }, getPlatformCssVars())
}

export function applyThemeVars(themeVars: ThemeVars, target?: HTMLElement) {
    if (!target) {
        return
    }

    for (const [key, value] of Object.entries(themeVars)) {
        target.style.setProperty(key, value)
    }
}
