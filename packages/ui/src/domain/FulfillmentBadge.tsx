import React from "react"
export type FulfillmentVariant = "delivery" | "pickup" | "collection"
export function FulfillmentBadge({ variant }: { variant: FulfillmentVariant }) {
    return <span>{variant}</span>
}
