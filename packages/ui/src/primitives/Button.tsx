import React from "react"
export function PrimaryButton({ label, onClick, className, state, disabled }: any) {
    return <button className={className} onClick={onClick} disabled={state === 'disabled' || disabled}>{label}</button>
}
export function SecondaryButton({ label, onClick, className, disabled }: any) {
    return <button className={className} onClick={onClick} disabled={disabled}>{label}</button>
}
