# Agent Error-Handling Protocol

**For**: All Claude Code Sub-Agents (documentation-writer, sql-migrations, testing-agent, workflow-editor)
**Purpose**: Prevent workarounds, force root cause resolution, ensure CMO notification
**Authority**: This protocol OVERRIDES all agent autonomy when errors occur

---

## 🎯 Core Principle

**AGENTS MUST NEVER:**
- Take the "easy way out" when encountering errors
- Change the implementation plan to avoid challenges
- Create placeholders (TODO-CONFIGURE-X) instead of solving problems
- Use fallback technologies (SQLite instead of Postgres, etc.)
- Silently fail and continue
- Make architectural changes without explicit approval

**AGENTS MUST ALWAYS:**
- Identify root cause of every error
- Escalate blockers immediately with non-technical explanation
- Provide 3 options with 1 recommendation
- Wait for CMO decision before proceeding
- Document the error and resolution

---

## 📋 Error Classification System

### Class 1: CRITICAL BLOCKERS (Stop Everything)

**Definition**: Errors that prevent core functionality, violate PRD requirements, or risk data loss.

**Examples**:
- Database connection failed (can't access Neon Postgres)
- API authentication failed (Apify token invalid)
- Data corruption detected (duplicate businesses, missing reviews)
- Security vulnerability discovered (credentials exposed)
- PRD requirement cannot be met (impossible technical constraint)

**Required Action**: **IMMEDIATE ESCALATION** using Critical Error Template (below)

---

### Class 2: IMPLEMENTATION CHALLENGES (Pause & Plan)

**Definition**: Technical obstacles that require different approaches but don't violate PRD requirements.

**Examples**:
- n8n node doesn't support desired feature (need workaround)
- Performance issue (query takes 10s instead of <5s target)
- Third-party API limitation (rate limits, data format changes)
- Dependency conflict (library versions incompatible)

**Required Action**: **PROVIDE OPTIONS** using Implementation Challenge Template (below)

---

### Class 3: MINOR ISSUES (Fix & Document)

**Definition**: Small bugs, typos, or edge cases that can be resolved without changing architecture.

**Examples**:
- Typo in SQL query
- Missing index causing slow query (can add immediately)
- Incorrect field mapping (trivial fix)
- Documentation outdated (simple update)

**Required Action**: **FIX AND LOG** using Minor Issue Template (below)

---

## 🚨 Escalation Templates

### Template 1: CRITICAL BLOCKER

**When to Use**: Class 1 errors that stop sprint progress

**Format**:
```markdown
# 🚨 CRITICAL BLOCKER - Sprint Progress Halted

## Error Classification
**Class**: 1 (Critical Blocker)
**Severity**: High
**Impact**: [Sprint day/deliverable affected]
**Time Discovered**: [Timestamp]

## Non-Technical Explanation (For CMO)

**What Happened**:
[Explain in business terms - no jargon]
Example: "The database connection failed, which means we can't store business data.
This is like trying to run a store without a cash register - nothing can be saved."

**Why It Happened**:
[Root cause in simple terms]
Example: "The database password we tried to use has expired. This happens
automatically after 90 days for security."

**Business Impact**:
[Revenue/timeline consequences]
Example: "Without database access, we can't process hypotheses, which delays
the entire sprint. This affects the $20k+ monthly revenue target (PRD Section 2)."

## Technical Details (For Reference)

**Error Message**:
```
[Exact error text]
```

**Stack Trace** (if applicable):
```
[Full stack trace]
```

**Attempted Solutions**:
1. [What was tried]
2. [Result of attempt]
3. [Why it didn't work]

**Root Cause Analysis**:
[Technical explanation of underlying problem]

## 3 Options with Recommendation

### Option 1: [Name of First Solution]
**What**: [Brief description]
**Pros**:
- ✅ [Advantage 1]
- ✅ [Advantage 2]
**Cons**:
- ❌ [Disadvantage 1]
- ❌ [Disadvantage 2]
**Time**: [Hours/days to implement]
**Cost**: [Dollar cost if applicable]
**Risk**: [Low/Medium/High]

### Option 2: [Name of Second Solution]
**What**: [Brief description]
**Pros**:
- ✅ [Advantage 1]
- ✅ [Advantage 2]
**Cons**:
- ❌ [Disadvantage 1]
- ❌ [Disadvantage 2]
**Time**: [Hours/days to implement]
**Cost**: [Dollar cost if applicable]
**Risk**: [Low/Medium/High]

### Option 3: [Name of Third Solution]
**What**: [Brief description]
**Pros**:
- ✅ [Advantage 1]
- ✅ [Advantage 2]
**Cons**:
- ❌ [Disadvantage 1]
- ❌ [Disadvantage 2]
**Time**: [Hours/days to implement]
**Cost**: [Dollar cost if applicable]
**Risk**: [Low/Medium/High]

## 🎯 RECOMMENDATION: Option [1/2/3]

**Why This is Best**:
[Explain reasoning in business terms]

**Alignment with Product Vision**:
[How this preserves James playbook principles, media-led GTM, etc.]

**Next Steps If Approved**:
1. [First action]
2. [Second action]
3. [Verification step]

## Awaiting CMO Decision

⏸️ **SPRINT PAUSED** - No further progress until CMO responds with:
- "Approved: Option X" → Resume with selected option
- "Need more info: [question]" → Provide clarification
- "Alternative: [description]" → Evaluate new approach

**Response Time Target**: <1 hour (per PRD Section 6.2 failure policy)
```

---

### Template 2: IMPLEMENTATION CHALLENGE

**When to Use**: Class 2 errors requiring approach changes

**Format**:
```markdown
# ⚠️ Implementation Challenge - Approach Adjustment Needed

## Challenge Classification
**Class**: 2 (Implementation Challenge)
**Severity**: Medium
**Component**: [Workflow/Database/Agent/etc.]
**Sprint Impact**: [Delay estimate: hours/days]

## What We're Trying to Accomplish

**PRD Requirement**:
[Quote from PRD - Section X.Y]

**Original Plan**:
[What we intended to do]

**Why It's Not Working**:
[Non-technical explanation of obstacle]

## Technical Context

**Specific Issue**:
[Detailed technical explanation]

**Evidence**:
```
[Error messages, logs, test results]
```

**Why Original Approach Failed**:
[Root cause analysis]

## 3 Alternative Approaches

### Approach 1: [Name]
**How It Works**: [Technical description]
**Business Value**: [How this delivers on PRD requirement]
**Pros/Cons**: [Listed above]
**PRD Compliance**: ✅ Fully compliant / ⚠️ Partial / ❌ Non-compliant
**Time**: [Implementation estimate]

### Approach 2: [Name]
[Same structure as Approach 1]

### Approach 3: [Name]
[Same structure as Approach 1]

## 🎯 RECOMMENDATION: Approach [1/2/3]

**Why**: [Business reasoning]

**Preserves Product Vision**:
- ✅ Still achieves $20k+ monthly revenue target
- ✅ Maintains James playbook principles
- ✅ Doesn't compromise on media-led GTM

**What Changes**:
[Specific differences from original plan]

**What Stays the Same**:
[PRD requirements still met]

## Request for CMO Approval

⏸️ **PAUSED** - Awaiting decision:
- "Proceed with Approach X"
- "Modify: [instructions]"
- "Defer to [later sprint day]"
```

---

### Template 3: MINOR ISSUE LOG

**When to Use**: Class 3 errors that were fixed immediately

**Format**:
```markdown
# 🔧 Minor Issue - Fixed & Documented

**Timestamp**: [Date/Time]
**Component**: [File/Workflow/Table name]
**Discovered By**: [Agent name]

## Issue
[One-sentence description]

## Root Cause
[Technical explanation]

## Fix Applied
[What was changed]

**Code Change**:
```sql
-- Before
SELECT * FROM businesses WHERE city = Charlotte;

-- After (Fixed)
SELECT * FROM businesses WHERE city = 'Charlotte';  -- Added quotes
```

## Verification
[How fix was tested]
- [ ] Test query executed successfully
- [ ] No side effects detected
- [ ] Documentation updated (if needed)

## Prevention
[How to avoid this in future]

**Filed In**: `docs/testing/issue-log.md`
```

---

## 🚫 Forbidden Workarounds

### Workaround 1: Technology Substitution

**FORBIDDEN**:
```
Agent: "Neon Postgres connection failed. Using SQLite as fallback."
```

**Why This is Bad**:
- Violates PRD requirement for JSONB support (SQLite doesn't have it)
- Changes data model fundamentally
- Creates technical debt
- Breaks RAG compatibility

**REQUIRED**:
```
Agent: "🚨 CRITICAL BLOCKER - Neon Postgres connection failed

       Non-Technical: Database is unreachable, can't store business data

       Root Cause: [Connection string malformed / Credentials expired / Network issue]

       Options:
       1. Fix credentials (5 min) - RECOMMENDED
       2. Migrate to different Postgres provider (2 hours)
       3. Debug Neon network settings (30 min)

       Awaiting CMO decision..."
```

---

### Workaround 2: Placeholder Credentials

**FORBIDDEN**:
```
Agent: "API token not found. Adding placeholder: TODO-CONFIGURE-APIFY"
```

**Why This is Bad**:
- Creates broken workflow that can't be tested
- Delays error discovery until runtime
- Forces manual fix during sprint
- Cascades to other dependent workflows

**REQUIRED**:
```
Agent: "🚨 CRITICAL BLOCKER - Apify API token not configured

       Non-Technical: Can't scrape Google Maps data without this credential

       Impact: Blocks Day 1 foundation sprint, prevents hypothesis processing

       Required Action: Add APIFY_API_TOKEN to:
       - n8n credentials vault (recommended)
       - .env file (local dev)

       See: .claude/CREDENTIALS-SETUP.md for step-by-step instructions

       ⏸️ Sprint paused until credential added and tested"
```

---

### Workaround 3: PRD Requirement Reduction

**FORBIDDEN**:
```
Agent: "Performance target of <5s for KG queries seems hard.
       Changing target to <30s to make it achievable."
```

**Why This is Bad**:
- Violates PRD Section 7 (Non-Functional Requirements)
- Changes success criteria without approval
- May break user experience assumptions
- Undermines trust in agent autonomy

**REQUIRED**:
```
Agent: "⚠️ IMPLEMENTATION CHALLENGE - KG Query Performance

       PRD Requirement: <5s latency target (Section 7)
       Current Performance: ~15s average

       Root Cause: Neo4j not optimized, missing indexes on entity relationships

       Options:
       1. Add graph indexes (30 min implementation, achieves <3s)
       2. Implement query caching (1 hour, achieves <1s for repeat queries)
       3. Defer KG to Day 3, use PGVector-only initially (achieves <2s)

       RECOMMENDATION: Option 2 (caching)
       - Meets PRD requirement
       - Better UX (sub-second repeat queries)
       - Aligns with production scale needs

       Awaiting approval to proceed with caching implementation..."
```

---

### Workaround 4: Silent Failures

**FORBIDDEN**:
```
Agent: "Migration failed with foreign key constraint error.
       Continuing with remaining migrations..."
```

**Why This is Bad**:
- Data integrity compromised
- Cascading failures likely
- Debugging nightmare later
- May violate business logic assumptions

**REQUIRED**:
```
Agent: "🚨 CRITICAL BLOCKER - Migration 003 Failed

       Non-Technical: Database structure update failed, data relationships broken

       Error: Foreign key constraint violation on lead_tasks.business_id
       Meaning: Trying to create lead task for business that doesn't exist

       Root Cause: Migration order wrong - lead_tasks created before businesses table

       Fix: Reorder migrations (5 minutes)

       Impact: Blocks all subsequent migrations, testing impossible

       ⏸️ Sprint paused - Awaiting acknowledgment to fix migration order"
```

---

## 📞 Escalation Channels

### Channel 1: In-Line Notification (Always)

**Format**: Display escalation template directly in agent output

**When**: All Class 1 and Class 2 errors

---

### Channel 2: Slack Alert (If Configured)

**Trigger**: Class 1 errors only

**Message Format**:
```
🚨 BORING BUSINESSES - CRITICAL BLOCKER

Component: [Workflow/Database/API]
Sprint Impact: Day X paused

Issue: [One-sentence non-technical summary]

Root Cause: [One-sentence explanation]

Action Required: Review full details in agent output and select option

Response Time Target: <1 hour

Notification sent: [Timestamp]
```

**Channel**: `#boring-ops` (configured in SLACK_WEBHOOK_URL)

---

### Channel 3: Issue Log (All Errors)

**File**: `docs/testing/error-log.md`

**Format**:
```markdown
## [Timestamp] - [Class X] - [Component]

**Issue**: [Summary]
**Root Cause**: [Technical explanation]
**Resolution**: [Option selected / Fix applied]
**Time Lost**: [Hours]
**Lessons Learned**: [Prevention strategy]
```

---

## 🎯 CMO Decision Framework

When presented with error escalation, Alex (CMO) should:

### Step 1: Understand Business Impact
- Read "Non-Technical Explanation" section
- Assess timeline impact (delay to $20k+ revenue target?)
- Evaluate risk to product vision (does workaround compromise James playbook?)

### Step 2: Review Options
- Don't need to understand technical details
- Focus on Pros/Cons, Time, Cost, Risk
- Consider recommendation rationale

### Step 3: Decide
**Fast Decision (Class 1)**:
- Goal: <1 hour response time
- Default to recommendation unless strong reason not to
- If uncertain: "Approved: Option X, but explain why after implementing"

**Thoughtful Decision (Class 2)**:
- Can take longer if needed
- May request more information
- Can suggest hybrid approach

### Step 4: Communicate
**Simple Response**:
```
Approved: Option 2

Reasoning: Aligns with proof point (Diesel Dudes model),
           acceptable 2-hour delay, no architectural compromises
```

---

## 🧪 Testing This Protocol

### Scenario 1: Missing Credential

**Agent discovers**: `OPENAI_API_KEY` not in environment

**WRONG Response**:
```
"Using mock responses for testing instead of real OpenAI calls"
```

**CORRECT Response**:
```
🚨 CRITICAL BLOCKER - OpenAI API Key Missing

Non-Technical: Can't generate AI-powered analysis without this credential

Impact: Blocks RAG workflow (Day 2), newsletter generation, sentiment scoring

Required Action: Add sk-proj-... key per CREDENTIALS-SETUP.md

⏸️ Sprint paused
```

---

### Scenario 2: Performance Miss

**Agent discovers**: Database query takes 8 seconds (target: <5s)

**WRONG Response**:
```
"Increased timeout to 15 seconds to prevent failures"
```

**CORRECT Response**:
```
⚠️ IMPLEMENTATION CHALLENGE - Query Performance

PRD Target: <5s (Section 7)
Actual: 8.2s average

Options:
1. Add GIN index on JSONB field (achieves 1.2s)
2. Implement query result caching (achieves <1s repeat)
3. Defer to post-MVP optimization (accept 8s for now)

RECOMMENDATION: Option 1
- Quick win (15 min implementation)
- Beats target significantly
- No architectural changes

Awaiting approval...
```

---

### Scenario 3: Dependency Conflict

**Agent discovers**: n8n version doesn't support new LangChain node

**WRONG Response**:
```
"Using older Postgres node instead, same functionality"
```

**CORRECT Response**:
```
⚠️ IMPLEMENTATION CHALLENGE - n8n Compatibility

PRD Requirement: LangChain agent with Graphiti KG (Section 6.4)
Issue: Current n8n version (0.xxx) doesn't include latest LangChain nodes

Options:
1. Upgrade n8n to v1.x (30 min, requires Hostinger VPS access)
2. Use community LangChain plugin (15 min, slightly different API)
3. Defer KG integration to Day 3 (use PGVector-only initially)

RECOMMENDATION: Option 1
- Future-proof (access to all latest nodes)
- Minimal risk (can rollback if issues)
- Aligns with 2025 best practices

Awaiting approval for n8n upgrade...
```

---

## ✅ Success Criteria for This Protocol

**This protocol is working when**:
1. ✅ Zero placeholder credentials in workflows
2. ✅ Zero technology substitutions without approval
3. ✅ Zero silent failures
4. ✅ All Class 1 errors escalated within 5 minutes of discovery
5. ✅ CMO receives non-technical explanation every time
6. ✅ 3 options always provided (not 2, not 4)
7. ✅ Root cause always identified before escalation
8. ✅ Error log maintained in `docs/testing/error-log.md`

---

## 📚 Agent Training Examples

### Example 1: sql-migrations Agent

**Scenario**: Migration fails with foreign key error

**Agent Response**:
```markdown
🚨 CRITICAL BLOCKER - Migration 004 Failed

Non-Technical Explanation:
Tried to create a link between two database tables, but one table doesn't
exist yet. Like trying to add a door to a room before building the room.

Root Cause:
Migration 004_lead_tasks.sql references businesses table, but businesses
table is created in migration 005 (wrong order).

Options:
1. Swap migration numbers (004 ↔ 005) - 2 minutes
2. Add dependency check to migration script - 10 minutes
3. Manual intervention to drop and recreate - 15 minutes

RECOMMENDATION: Option 1
- Fastest fix
- Prevents future ordering issues
- No manual steps required

Files affected:
- sql/004_lead_tasks.sql → rename to 005
- sql/005_businesses.sql → rename to 004

⏸️ Awaiting approval to swap migration order
```

---

### Example 2: workflow-editor Agent

**Scenario**: Can't preserve credential ID (doesn't exist in n8n)

**Agent Response**:
```markdown
🚨 CRITICAL BLOCKER - Credential Not Found

Non-Technical Explanation:
Workflow expects an "Apify Token (Production)" credential, but it's not
configured in n8n. Like trying to unlock a door with a key that doesn't exist.

Root Cause:
CREDENTIALS-SETUP.md instructions not completed. n8n credentials vault is empty.

Required Action (CMO):
1. Open n8n: https://n8n.avgj.io
2. Menu → Credentials → Add Credential
3. Type: HTTP Header Auth
4. Name: "Apify Token (Production)"
5. Header: Authorization
6. Value: Bearer apify_api_[your token from Apify console]

Verification:
```bash
# I'll test with this after you add it
curl -H "Authorization: Bearer apify_api_XXX" https://api.apify.com/v2/actor-tasks
# Should return: {"data": {"total": X}}
```

⏸️ Sprint paused until credential configured

Alternative: Provide token now and I'll configure via n8n API (requires n8n API access)
```

---

## 🎓 Summary for Agents

**Your job as an agent**:
1. **Attempt to solve** problems using your expertise
2. **Identify root cause** if attempt fails
3. **Classify error** (Class 1/2/3)
4. **Use appropriate template** for your classification
5. **NEVER** create workarounds without approval
6. **ALWAYS** wait for CMO decision on Class 1/2
7. **ALWAYS** provide 3 options with clear recommendation
8. **ALWAYS** explain in non-technical terms

**Your job is NOT**:
- Making architectural decisions alone
- Changing PRD requirements to match what's easy
- Hiding problems with placeholders
- Optimizing for your convenience over product quality

---

**Remember**: Alex (CMO) is relying on you to be his technical expert, not to paper over problems. Escalate early, escalate clearly, provide options, make a recommendation, then wait for the decision.

**Your expertise** = Technical execution
**His expertise** = Business decisions

Together = Successful product that matches the vision.
