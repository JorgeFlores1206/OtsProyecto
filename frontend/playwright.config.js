import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './tests/e2e',
  outputDir: './test-results',
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    baseURL: 'http://127.0.0.1:4173',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  webServer: {
    command: 'npm run build && npm run preview -- --host 127.0.0.1',
    url: 'http://127.0.0.1:4173',
    reuseExistingServer: !process.env.CI,
  },
  projects: [
    { name: 'chromium-desktop', use: { ...devices['Desktop Chrome'] } },
    { name: 'edge-desktop', use: { ...devices['Desktop Chrome'], channel: 'msedge' } },
    { name: 'webkit-desktop', use: { ...devices['Desktop Safari'] } },
    { name: 'android', use: { ...devices['Pixel 5'] } },
    { name: 'iphone', use: { ...devices['iPhone 13'] } },
    { name: 'ipad', use: { ...devices['iPad Pro 11'] } },
  ],
})
