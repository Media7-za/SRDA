"use client";

import { applyThemeVars, getPlatformCssVars, phuketThaiThemeVars } from '@restaurant-direct/ui';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useEffect, useState } from 'react';

export function Providers({ children }: { children: React.ReactNode }) {
    const [queryClient] = useState(() => new QueryClient({
        defaultOptions: {
            queries: {
                staleTime: 1000 * 60, // 1 minute default stale time
                refetchOnWindowFocus: false,
            },
        },
    }));

    useEffect(() => {
        applyThemeVars({
            ...getPlatformCssVars(),
            ...phuketThaiThemeVars,
        });
    }, []);

    return (
        <QueryClientProvider client={queryClient}>
            {children}
        </QueryClientProvider>
    );
}
