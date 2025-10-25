# Claude Code Parallel Sub-Agent Execution Guide

**Last Updated**: October 24, 2025
**Based on**: Official Claude Code documentation + industry best practices

---

## 🎯 Overview

Claude Code supports **concurrent sub-agent execution** through the Task tool, enabling dramatically faster development by running multiple specialized agents in parallel. This guide provides battle-tested patterns for the Boring Businesses platform.

---

## 📊 Parallel Execution Capabilities

### Performance Characteristics

| Metric | Value | Notes |
|--------|-------|-------|
| **Max Parallel Tasks** | 10 simultaneous | Hard limit per session |
| **Total Task Queue** | 100+ supported | Queue automatically manages batches |
| **Context Isolation** | 100% | Each agent has independent context window |
| **Token Cost** | 3-4x single-threaded | Due to independent contexts |
| **Speed Improvement** | Up to 10x | For truly independent tasks |

### What Makes a Good Parallel Task?

✅ **Independent tasks** with no shared dependencies
✅ **Read-only operations** on different files/data
✅ **Exploratory analysis** of separate components
✅ **Documentation** for different features

❌ **Sequential dependencies** where Task B needs Task A's output
❌ **Concurrent writes** to same files (race conditions)
❌ **Shared state** that could cause conflicts

---

## 🚀 Parallel Execution Patterns

### Pattern 1: Exploratory Codebase Analysis

**Use Case**: Understanding a large unfamiliar codebase

**Implementation**:
```
Explore this codebase using 4 agents in parallel:
- Agent 1: Analyze database schema in sql/ directory
- Agent 2: Review n8n workflows in workflows/ directory
- Agent 3: Examine documentation in docs/ directory
- Agent 4: Investigate reference files in docs/Reference files/

Each agent should produce a markdown summary of their findings.
```

**Benefits**:
- 4x faster than sequential exploration
- Each agent builds specialized understanding
- Summaries can be synthesized for architecture overview

---

### Pattern 2: Multi-Component Testing

**Use Case**: Validating multiple independent systems

**Implementation**:
```
Run these tests in parallel using the testing-agent:
1. Database schema validation (sql/ migrations)
2. n8n workflow JSON validation (workflows/)
3. Documentation completeness check (docs/)
4. Hook functionality verification (.claude/hooks/)

Report pass/fail status for each component.
```

**Benefits**:
- All tests complete in time of slowest test
- Independent failure isolation
- Comprehensive system validation

---

### Pattern 3: Parallel Documentation Creation

**Use Case**: Generating multiple documentation artifacts

**Implementation**:
```
Create these documentation files in parallel using documentation-writer agent:
1. SOP for n8n workflow deployment → docs/runbooks/deploy-workflow.md
2. Database migration runbook → docs/runbooks/run-migrations.md
3. Testing procedures guide → docs/runbooks/testing-procedures.md
4. Troubleshooting guide → docs/runbooks/troubleshooting.md

Each document should follow standard runbook template.
```

**Benefits**:
- 4 documents in time of 1
- Consistent formatting (same agent template)
- Independent review possible

---

### Pattern 4: Multi-Feature Code Review

**Use Case**: Reviewing multiple pull requests or features

**Implementation**:
```
Review these independent features in parallel:
1. Data collection workflow changes (workflows/data-collection.json)
2. RAG chat interface updates (workflows/rag-chat.json)
3. Database migration additions (sql/00N_*.sql)
4. Testing infrastructure updates (docs/testing/)

Provide code review feedback for each component.
```

**Benefits**:
- Faster PR review cycle
- Specialized attention per feature
- Concurrent blocker identification

---

### Pattern 5: Parallel Migration Development

**Use Case**: Creating multiple database migrations

**Implementation**:
```
Using sql-migrations agent, create these migrations in parallel:
1. Add GIN indexes for JSONB search → sql/004_jsonb_indexes.sql
2. Create review sentiment analysis table → sql/005_sentiment_table.sql
3. Add business category materialized view → sql/006_category_view.sql
4. Create audit logging tables → sql/007_audit_logs.sql

Ensure migrations are numbered sequentially and non-conflicting.
```

**Benefits**:
- Multiple migrations drafted simultaneously
- Independent testing possible
- Faster schema evolution

---

## 🏗️ Advanced Patterns

### Pattern 6: Git Worktree + Parallel Branches

**Use Case**: True isolation for parallel feature development

**Implementation**:
```bash
# Create isolated worktrees for parallel work
git worktree add ../boring-businesses-feature-a -b feature/rag-improvements
git worktree add ../boring-businesses-feature-b -b feature/data-pipeline-v2
git worktree add ../boring-businesses-feature-c -b feature/testing-framework

# Run separate Claude Code sessions in each worktree
cd ../boring-businesses-feature-a && claude
cd ../boring-businesses-feature-b && claude
cd ../boring-businesses-feature-c && claude
```

**Benefits**:
- **Zero conflicts**: Each branch has own filesystem
- **True parallelism**: Separate Claude sessions
- **Independent PRs**: Merge features individually
- **Context isolation**: No cross-contamination

**Best Practices**:
- Use descriptive branch names
- Coordinate schema changes (avoid migration conflicts)
- Regular sync with main branch
- Clean up worktrees after merge: `git worktree remove ../boring-businesses-feature-a`

---

### Pattern 7: Queue-Based Batch Processing

**Use Case**: Processing 100+ tasks beyond 10-task limit

**Implementation**:
```
I have 50 workflow files to validate. Process them in batches:
- Batch 1 (10 workflows): Files 1-10 in parallel
- Batch 2 (10 workflows): Files 11-20 in parallel
- Batch 3 (10 workflows): Files 21-30 in parallel
- ... continue through all 50 files

For each batch, run JSON validation and report issues.
```

**How Claude Code Handles This**:
1. First 10 tasks start immediately
2. As tasks complete, new tasks automatically start
3. Never exceeds 10 concurrent tasks
4. Queue maintains order within batches

**Benefits**:
- Automatic queue management
- Optimal resource utilization
- Progress tracking per batch

---

### Pattern 8: Agent Specialization Matrix

**Use Case**: Multiple agents working on different aspects simultaneously

**Implementation**:
```
Launch 4 specialized agents in parallel:
1. documentation-writer: Create runbooks for all workflows
2. sql-migrations: Audit existing migrations for performance issues
3. testing-agent: Run comprehensive test suite
4. workflow-editor: Add error handling to all workflows

Report progress and blockers from each agent.
```

**Benefits**:
- Specialized expertise per domain
- Separate context prevents interference
- Holistic project improvement

---

## ⚙️ Invocation Syntax

### Explicit Parallel Invocation

```
Use the Task tool to launch [N] agents in parallel:
1. [Agent name]: [Task description]
2. [Agent name]: [Task description]
3. [Agent name]: [Task description]

Each agent should [completion criteria].
```

### Automatic Parallelization (Let Claude Decide)

```
Review all workflows in workflows/ directory for:
- JSON syntax errors
- Missing error handling
- Performance issues
- Security vulnerabilities

Complete this as efficiently as possible.
```

Claude Code will automatically determine if tasks can be parallelized.

### Specifying Parallelism Level

```
Explore the codebase using 4 tasks in parallel.
Each agent should analyze a different directory.
```

Claude Code will run 4 tasks concurrently (up to max of 10).

---

## 🎯 Boring Businesses Specific Use Cases

### Use Case 1: Complete Workflow Audit

```
Audit all n8n workflows in parallel using workflow-editor agent:
1. workflows/data-collection.json → Check Apify integration
2. workflows/rag-chat.json → Verify LangChain configuration
3. workflows/etl-*.json → Validate data transformations

Report issues and suggested improvements for each.
```

### Use Case 2: Multi-Source Documentation Generation

```
Generate documentation using documentation-writer in parallel:
1. Data collection workflow SOP
2. RAG chat system architecture doc
3. Database schema documentation
4. Testing procedures guide

Output to docs/runbooks/ and docs/architecture/.
```

### Use Case 3: Comprehensive Database Testing

```
Run database tests in parallel using testing-agent:
1. Schema validation (all tables exist, correct types)
2. Index performance testing (query times <100ms)
3. Data quality checks (no duplicates, valid JSONB)
4. Migration rollback testing (all migrations reversible)

Create timestamped test reports in docs/testing/.
```

### Use Case 4: Parallel Migration Development

```
Create database migrations using sql-migrations agent in parallel:
1. Add full-text search indexes
2. Create business analytics materialized views
3. Add audit logging triggers
4. Implement row-level security policies

Ensure migrations don't conflict and are sequentially numbered.
```

---

## 🚨 Anti-Patterns (Avoid These)

### ❌ Anti-Pattern 1: Sequential Dependencies in Parallel

**Wrong**:
```
Run in parallel:
1. Create database migration
2. Apply database migration  # DEPENDS ON #1 COMPLETING!
3. Test database schema      # DEPENDS ON #2 COMPLETING!
```

**Why It Fails**: Tasks have dependencies but run concurrently → race conditions

**Correct Approach**:
```
Run sequentially:
1. Create database migration
2. Apply database migration (after #1 completes)
3. Test database schema (after #2 completes)
```

---

### ❌ Anti-Pattern 2: Concurrent File Writes

**Wrong**:
```
Run in parallel:
1. Agent A: Update workflows/data-collection.json
2. Agent B: Update workflows/data-collection.json  # SAME FILE!
```

**Why It Fails**: Race condition → one agent's changes overwrite the other's

**Correct Approach**:
```
Run sequentially or split into different files:
1. Agent A: Update workflows/data-collection.json
2. Agent B: Update workflows/rag-chat.json  # DIFFERENT FILE
```

---

### ❌ Anti-Pattern 3: Over-Parallelization

**Wrong**:
```
Launch 50 agents in parallel to analyze 50 files
```

**Why It Fails**:
- Max 10 concurrent tasks → queuing delay
- Context switching overhead
- Token cost explosion (3-4x per agent)

**Correct Approach**:
```
Launch 5-10 agents for strategic high-value tasks:
1. Analyze critical workflows (5 most important files)
2. Synthesize findings after parallel analysis completes
```

---

## 📈 Performance Optimization

### Token Cost Management

**Single-Threaded** (1 conversation):
- Context: 50K tokens
- Total cost: 50K tokens

**Parallel (5 agents)** without shared context:
- Agent 1 context: 50K tokens
- Agent 2 context: 50K tokens
- Agent 3 context: 50K tokens
- Agent 4 context: 50K tokens
- Agent 5 context: 50K tokens
- **Total cost**: 250K tokens (5x)

**Optimization Strategy**:
1. Use parallel execution for **truly independent tasks**
2. Keep agent prompts **concise** (minimize context overhead)
3. **Synthesize results** in main thread (don't recursively parallelize)
4. Reserve parallelism for **time-critical** or **exploratory** work

---

### Determining Optimal Parallelism

**Decision Matrix**:

| Task Type | Recommended Parallelism | Reasoning |
|-----------|------------------------|-----------|
| Exploratory codebase analysis | 4-8 agents | High value, read-only |
| Code review (multiple PRs) | 3-5 agents | Independent reviews |
| Documentation generation | 3-6 agents | Independent artifacts |
| Testing (separate components) | 5-10 agents | Max parallelism safe |
| Migration development | 2-4 agents | Risk of conflicts |
| Workflow editing | 1-2 agents | High conflict risk |

**Rule of Thumb**:
- **Read-heavy tasks**: Maximize parallelism (8-10 agents)
- **Write-heavy tasks**: Minimize parallelism (1-3 agents)

---

## 🔍 Monitoring & Debugging

### Tracking Parallel Execution

Claude Code provides execution feedback:
```
🤖 Starting 4 parallel tasks...
✅ Task 1 (documentation-writer): Completed in 45s
✅ Task 2 (sql-migrations): Completed in 62s
✅ Task 3 (testing-agent): Completed in 38s
⏳ Task 4 (workflow-editor): In progress...
✅ Task 4 (workflow-editor): Completed in 91s

All tasks completed. Synthesizing results...
```

### Debugging Parallel Failures

If a parallel task fails:
1. **Check task isolation**: Does task depend on another task's output?
2. **Check file conflicts**: Are multiple tasks writing to same file?
3. **Check resource limits**: Are tasks exceeding time/token limits?
4. **Run sequentially**: Try same tasks one at a time to isolate issue

---

## 📚 Real-World Examples

### Example 1: Onboarding to Boring Businesses Codebase

**Goal**: Understand entire project in <10 minutes

**Execution**:
```
Launch 5 parallel exploration agents:
1. Database expert: Analyze sql/ directory + schema
2. Workflow expert: Review workflows/ for n8n patterns
3. Documentation expert: Read all docs/ for context
4. Architecture expert: Examine reference files + PRDs
5. Testing expert: Analyze testing infrastructure

Each agent produces a 1-page summary of their domain.
```

**Results**:
- 5 summaries in ~8 minutes (vs. 40 minutes sequential)
- Comprehensive understanding across all domains
- Ready to start contributing immediately

---

### Example 2: Pre-Deployment Validation

**Goal**: Comprehensive system check before production deploy

**Execution**:
```
Run validation suite with 6 parallel testing agents:
1. SQL migrations: Verify all migrations apply cleanly
2. Workflow JSON: Validate all workflow files
3. Database queries: Test all queries meet <100ms SLA
4. Documentation: Verify all runbooks are current
5. Hook scripts: Test all .claude/hooks/ scripts
6. Integration tests: Run end-to-end workflow execution

Report go/no-go decision with evidence.
```

**Results**:
- All checks in 5 minutes (vs. 30 minutes sequential)
- Identified 2 breaking issues before production
- Prevented production incident

---

### Example 3: Multi-Feature Development Sprint

**Goal**: Develop 3 independent features simultaneously

**Execution**:
```bash
# Create 3 git worktrees
git worktree add ../bb-feature-rag -b feature/rag-improvements
git worktree add ../bb-feature-data -b feature/data-pipeline-v2
git worktree add ../bb-feature-test -b feature/testing-framework

# Launch 3 Claude Code sessions
# Terminal 1: cd ../bb-feature-rag && claude
# Terminal 2: cd ../bb-feature-data && claude
# Terminal 3: cd ../bb-feature-test && claude

# Each session works independently
# Session 1: Improve RAG relevance with reranking
# Session 2: Add CDC pipeline for real-time updates
# Session 3: Build comprehensive test suite
```

**Results**:
- 3 features developed in parallel
- No merge conflicts (isolated contexts)
- 3 PRs ready for review simultaneously
- Sprint velocity increased 3x

---

## 🎓 Best Practices Summary

### DO ✅

1. **Parallelize read-heavy, independent tasks**
   - Codebase exploration
   - Documentation review
   - Code analysis

2. **Use git worktrees for true feature parallelism**
   - Separate filesystems
   - No merge conflicts during development
   - Independent testing

3. **Specify agent and task clearly**
   ```
   Use the testing-agent to validate [specific component]
   ```

4. **Let Claude Code manage queue**
   - Don't manually batch unless >50 tasks
   - Trust automatic task pulling

5. **Synthesize results in main thread**
   - Parallel: Gather data
   - Sequential: Analyze and decide

### DON'T ❌

1. **Don't parallelize sequential dependencies**
   - Bad: Create migration → Apply migration (parallel)
   - Good: Create migration → Apply migration (sequential)

2. **Don't write to same files concurrently**
   - Bad: 2 agents editing same workflow
   - Good: 2 agents editing different workflows

3. **Don't over-parallelize trivial tasks**
   - Token cost explosion
   - Complexity overhead
   - Diminishing returns

4. **Don't ignore context isolation**
   - Each agent starts fresh
   - No shared memory between agents
   - Re-load context as needed

---

## 🔗 Related Documentation

- [Official Claude Code Sub-Agents Guide](https://docs.claude.com/en/docs/claude-code/sub-agents)
- [Claude Agent SDK: Subagents](https://docs.claude.com/en/api/agent-sdk/subagents)
- [Agent Configuration Reference](.claude/agents/)
- [Project Memory](.claude/CLAUDE.md)

---

## 📝 Feedback & Iteration

**This guide evolves with team experience.**

Found a new parallel pattern? Document it here!
Discovered an anti-pattern? Add to the warnings!

Update this guide as we learn what works best for Boring Businesses platform development.

---

**Last Updated**: October 24, 2025
**Maintained By**: Claude Code Configuration Team
