import AxeBuilder from '@axe-core/playwright'
import { test as base, expect } from '@playwright/test'

export const test = base.extend({
  makeAxeBuilder: async ({ page }, use) => {
    await use(() => new AxeBuilder({ page }))
  },
})

export { expect }
