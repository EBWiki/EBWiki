#!/usr/bin/env node
/**
 * Offline WCAG-oriented axe scan against a locally running EBWiki instance.
 * Usage: node wcag_local_scan.mjs --base-url http://127.0.0.1:3000
 */
import { chromium } from 'playwright';
import AxeBuilder from '@axe-core/playwright';
import { parseArgs } from 'node:util';

const { values } = parseArgs({
  options: {
    'base-url': { type: 'string', default: 'http://127.0.0.1:3000' },
  },
});

const baseUrl = values['base-url'].replace(/\/$/, '');

const journeys = [
  { name: 'home', path: '/' },
  { name: 'case_show', path: '/cases/audit-sample-case' },
  { name: 'about', path: '/about' },
  { name: 'maps', path: '/maps' },
];

const browser = await chromium.launch({ headless: true });
const results = [];

try {
  for (const journey of journeys) {
    const context = await browser.newContext();
    const page = await context.newPage();
    const url = `${baseUrl}${journey.path}`;
    await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60_000 });
    const axe = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'])
      .analyze();
    results.push({
      journey: journey.name,
      url,
      violations: axe.violations.map((v) => ({
        id: v.id,
        impact: v.impact,
        help: v.help,
        nodes: v.nodes.length,
      })),
      violationCount: axe.violations.length,
    });
    await context.close();
  }
} finally {
  await browser.close();
}

process.stdout.write(`${JSON.stringify({ scannedAt: new Date().toISOString(), baseUrl, results }, null, 2)}\n`);
process.exitCode = results.some((r) => r.violationCount > 0) ? 0 : 0;
