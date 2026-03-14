import { defineConfig, devices } from '@playwright/test';
import path from 'path';

export default defineConfig({
    testDir: './e2e',
    timeout: 30 * 1000,
    expect: { timeout: 5000 },
    fullyParallel: false, // Run tests sequentially because they share a single DB and we re-seed
    forbidOnly: !!process.env.CI,
    retries: process.env.CI ? 2 : 0,
    workers: 1, // Must be 1 so DB state doesn't tear across tests
    reporter: 'list',
    use: {
        baseURL: 'http://localhost:3000',
        trace: 'on-first-retry',
    },
    projects: [
        {
            name: 'chromium',
            use: { ...devices['Desktop Chrome'] },
        },
    ],
});
