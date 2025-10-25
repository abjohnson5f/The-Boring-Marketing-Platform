#!/usr/bin/env node
const { execPath, argv } = process;
const command = argv.slice(2).join(" ");
const forbidden = ["rm -rf", "cat .env", "grep", "sed", "awk"];
const riskyPatterns = [/(rm\s+-rf\s+\.\.?)/, /(cat\s+.*\.env)/];

for (const pattern of riskyPatterns) {
  if (pattern.test(command)) {
    console.error(`Blocked command: ${command}`);
    process.exit(1);
  }
}
for (const phrase of forbidden) {
  if (command.includes(phrase)) {
    console.error(`Blocked command: ${command}`);
    process.exit(1);
  }
}
process.exit(0);
