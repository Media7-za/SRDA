import React from "react"
export function OfflineBanner({ onRetry }: { onRetry: () => void }) {
    return (
        <div className="bg-status-failed text-white p-2 flex justify-between rounded-md mb-4 shadow">
            <span>You are currently offline.</span>
            <button onClick={onRetry} className="underline">Retry</button>
        </div>
    )
}
