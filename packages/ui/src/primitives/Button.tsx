"use client"

import React from "react"
import { motion, type HTMLMotionProps } from "framer-motion"
import { Loader2 } from "lucide-react"

import { cn } from "../utils/cn"

type ButtonVariant = "primary" | "secondary"
type ButtonSize = "sm" | "md" | "lg"
type LegacyButtonState = "default" | "disabled"

export interface BaseButtonProps extends Omit<HTMLMotionProps<"button">, "children"> {
    children?: React.ReactNode
    label?: React.ReactNode
    size?: ButtonSize
    loading?: boolean
    fullWidth?: boolean
    state?: LegacyButtonState
}

const buttonSizeMap: Record<ButtonSize, string> = {
    sm: "h-9 px-3 text-sm",
    md: "h-11 px-4 text-sm",
    lg: "h-12 px-5 text-base"
}

const buttonBase =
    "inline-flex items-center justify-center gap-2 rounded-2xl font-medium transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 active:scale-[0.99] shadow-sm"

const buttonVariantMap: Record<ButtonVariant, string> = {
    primary: "bg-slate-900 text-white hover:bg-slate-800 focus-visible:ring-slate-400",
    secondary: "border border-slate-200 bg-white text-slate-900 hover:bg-slate-50 focus-visible:ring-slate-300"
}

function Button({
    variant,
    className,
    children,
    label,
    size = "md",
    loading = false,
    fullWidth = false,
    disabled,
    state,
    ...props
}: BaseButtonProps & { variant: ButtonVariant }) {
    const isDisabled = disabled || loading || state === "disabled"
    const content = children ?? label

    return (
        <motion.button
            whileTap={{ scale: isDisabled ? 1 : 0.99 }}
            className={cn(
                buttonBase,
                buttonSizeMap[size],
                buttonVariantMap[variant],
                fullWidth && "w-full",
                className
            )}
            disabled={isDisabled}
            {...props}
        >
            {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : null}
            {content}
        </motion.button>
    )
}

export function PrimaryButton(props: BaseButtonProps) {
    return <Button variant="primary" {...props} />
}

export function SecondaryButton(props: BaseButtonProps) {
    return <Button variant="secondary" {...props} />
}
