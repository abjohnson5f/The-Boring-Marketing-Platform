# Cursor Automation & Testing Strategy

## 1. Cursor Hooks Plan
- **Goal:** Add guardrails and automation around file edits, shell commands, and agent output.
- **Configuration:** Create `.cursor/hooks.json` with the following lifecycle scripts:
  - `beforeCommand`: execute script blocking destructive shell commands (e.g., `rm -rf`, exporting `.env`).
  - `afterFileEdit`: run linter/JSON validator for `workflows/*.json` and log changes to `docs/testing/hook-log.md`.
  - `onAgentFinish`: push notifications (e.g., Slack webhook) summarizing files touched.
- **Scripts:** Implement TypeScript/Node or Python scripts stored under `.cursor/scripts/` to parse output and enforce rules.
- **Use Cases:**
  - Audit modifications (record file, diff summary, agent name).
  - Redact environment variables from context (if `.env` accessed) via hook script.
  - Trigger automatic `npm run lint` (if applicable) on TypeScript/JS changes.
- **References:** Cursor hooks documentation highlights blocking unsafe commands and auditing usage[1][7].

## 2. Background Agents & Parallelization
- **Background Agents:** Utilize Cursor background agents for long-running tasks (e.g., refactoring large workflows or generating SOPs) while continuing manual work[5][7].
  - Launch via `cursor background run .cursor/agents/...` (after config). Agents can self-correct and run terminal commands under hook guardrails.
  - Suitable for: orchestrator workflow build, SQL migration drafting, multi-step testing sequences.
- **Parallel Execution:**
  - Kick off individual agents for each workflow simultaneously (as described in `Cursor-Agent-Commands.md`).
  - Use background agents to monitor Linear or task list; integrate with issue tracker if desired.

## 3. `.env` & Credential Strategy
- **Central File:** Add `.env.template` listing required keys (APIFY_TOKEN, POSTGRES_URL_DEV, POSTGRES_URL_PROD, GRAPHITI_URL, SLACK_WEBHOOK, LOOKER_CREDENTIALS, etc.).
- **Secrets Handling:**
  - Do not commit real `.env`. Add `.env` to `.gitignore`.
  - In n8n: store credentials inside credential vault (Hostinger server) referencing environment variables (via `process.env`).
  - Cursor hooks should block agent access to `.env` (`blockedPaths: [".env"]`) and redact if necessary.
  - Provide script to load `.env` for local dev (`source scripts/load-env.sh`).
- **Agent Usage:** When agents need placeholder values, instruct to reference environment variables (`{{$env.POSTGRES_URL_DEV}}`).

## 4. MCP Configuration Strategy
- **Current MCPs:** supabase, youtube-transcript, perplexity, firecrawl, Ref (active); vercel, dataforseo, chatprd disabled.
- **Recommendations:**
  - **Enable `firecrawl`** for documentation scraping when needed (already active).
  - **Add `n8n-docs` MCP** (if available) or configure Ref to point to latest n8n docs for workflow node syntax.
  - **Install `slack` MCP** (if provided) to automate alert configuration conversations.
  - **Consider `github` MCP** for commit automation once repo integration required.
  - Keep `perplexity` + `Ref` for research and documentation retrieval as shown in search results.
- **Usage:** Use Ref MCP to fetch official docs; use Perplexity for additional guidance (fast background agent research).

## 5. Feature Adoption Summary
| Feature | Purpose | Implementation Steps |
| --- | --- | --- |
| Hooks (`hooks.json`) | Guardrails & automation | Define scripts for command blocking, logging, lint triggers. |
| Background Agents | Parallel workflow execution | Launch for each major task; monitor results while continuing manual work. |
| Diff Review | Quality control | Use Cursor diff reviewer before commit to confirm only intended files changed. |
| LLM Cache | Efficiency | Enable caching for repetitive prompts (agent templates). |
| Basedir Rules | Security | `.cursor` config to restrict access to reference files and `.env`. |

## 6. Testing Strategy & TDD Assessment
- **TDD Considerations:** Full test-driven development is challenging for n8n workflows due to JSON-based configurations, external APIs, and limited automated testing support. Cursor agents also face context window limits; storing large test suites for every change could force aggressive summarization, risking loss of nuances.
- **Recommended Approach:**
  - **Targeted Integration Tests:** Use testing agent to run orchestrator end-to-end with sample hypotheses, verifying Postgres rows and Slack alerts.
  - **Workflow-level Assertions:** Add Function nodes or scripts to ensure outputs contain expected keys/values (e.g., `opportunity_metrics` fields).
  - **SQL Regression Checks:** Execute post-migration queries to validate schema and indexes.
  - **Manual QA:** Operator runs at least one real hypothesis each day, evaluating dashboards and newsletters.
  - **Hook-assisted Linting:** Use hooks to run JSON/schema linting but avoid full TDD loops.
- **Conclusion:** TDD provides limited ROI here; focus on integration testing, manual verification, and hook-based guardrails to maintain quality.

## 7. Action Items
1. **.env Workflow**
   - Add `.env.template` with all required keys. Ensure `.env` is gitignored and load via script (`scripts/load-env.sh`).
   - Configure n8n credentials to read from environment variables; store secrets in Hostinger vault.
   - Update `.cursor` rules/hooks to block direct `.env` access by agents.
2. **Hooks Implementation**
   - Create `.cursor/hooks.json` with `beforeCommand`, `afterFileEdit`, `onAgentFinish` scripts under `.cursor/scripts/`.
   - Scripts: block destructive commands, run JSON lint on workflow files, post Slack summary (Optional: log to `docs/testing/hook-log.md`).
3. **Background Agents Usage**
   - Launch Cursor background agents for long-running tasks (workflow refactors, SOP drafting) using commands in `Cursor-Agent-Commands.md`.
   - Monitor outputs while continuing manual work; rely on hooks for guardrails.
4. **MCP Recommendations**
   - Keep current MCPs (supabase, youtube-transcript, perplexity, firecrawl, Ref).
   - Add Slack MCP (for alert configuration), GitHub MCP (for commit automation) once repo integration required.
   - Explore n8n docs MCP or configure Ref to include latest n8n documentation.
5. **Testing Approach**
   - Forego full TDD; use integration testing via testing agent, manual QA, and SQL checks.
   - Record runtime metrics in `orchestrator_run_log` during each orchestrator execution.
   - Update `docs/testing/` with results from testing agent runs.
6. **Documentation Updates**
   - Reference this strategy in runbooks (orchestrator, ingestion) and developer onboarding notes.
   - Note Astro web build intent in future roadmap.

---

**References:**
- [1] InfoQ – Cursor 1.7 hooks overview (https://www.infoq.com/news/2025/10/cursor-hooks/)
- [5] PromptLayer – Cursor changelog & background agents (https://blog.promptlayer.com/cursor-changelog-whats-coming-next-in-2026/)
- [7] Collabnix – Cursor advanced features & best practices (https://collabnix.com/cursor-ai-deep-dive-technical-architecture-advanced-features-best-practices-2025/)
