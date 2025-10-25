#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const file = process.argv[2];
if (!file) process.exit(0);

const workflowDir = path.join(process.cwd(), 'workflows');
const testingDir = path.join(process.cwd(), 'docs', 'testing');
const logFile = path.join(testingDir, 'hook-log.md');

if (!fs.existsSync(testingDir)) fs.mkdirSync(testingDir, { recursive: true });

function log(message) {
  const entry = `- ${new Date().toISOString()} - ${message}\n`;
  fs.appendFileSync(logFile, entry);
}

if (file.startsWith(workflowDir)) {
  try {
    const content = fs.readFileSync(file, 'utf8');
    JSON.parse(content);
    log(`Validated JSON: ${path.relative(process.cwd(), file)}`);
  } catch (err) {
    log(`JSON validation failed for ${file}: ${err.message}`);
    process.exit(1);
  }
} else {
  log(`Edited file: ${path.relative(process.cwd(), file)}`);
}
process.exit(0);
