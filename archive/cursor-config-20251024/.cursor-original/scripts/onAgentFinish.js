#!/usr/bin/env node
const https = require('https');
const fs = require('fs');
const path = require('path');

const payloadPath = process.argv[2];
const webhookUrl = process.env.SLACK_WEBHOOK_URL;
if (!payloadPath || !webhookUrl) process.exit(0);

const payload = JSON.parse(fs.readFileSync(payloadPath, 'utf8'));
const files = (payload.modifiedFiles || []).map(f => `• ${f}`).join('\n') || 'None';
const message = {
  text: `Agent run complete.\nModified files:\n${files}`
};

const req = https.request(webhookUrl, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' }
});
req.write(JSON.stringify(message));
req.end();
