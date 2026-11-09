# Aloha Workforce Solutions | Development Checkpoint

**Last checkpoint review:** 2026-11-03

**Start here:** [Architecture Refresher](architecture-refresher.md)

## Current Project State

**Active sprint:** Payroll Processor Persona and Least-Privilege Security

**Last confirmed Git checkpoint:** `92e2313`

**Commit message:**
WIP: Build payroll persona security and request integrity controls

**Development environment:**
GitHub Codespaces, repository `joeltahimik/salesforce-ai-architecture-lab`,
branch `main`.

**Salesforce org alias:** `aloha-dev`

**Last confirmed connection:** Connected, org ID `00Dak00001EqrL3EAJ`.

The Codespace was reactivated and automatic deletion was disabled.
Reconfirm its current state when resuming after a long absence.

## Completed Architecture

- Core workforce data model and relationships.
- Service Request and Employment Change Request architecture.
- Request Employment Change submission Flow.
- Payroll decision Flow: Approved, Modified, Rejected.
- Record Implementation Flow, generic and Work Location paths.
- Cancellation lifecycle and parent aggregation.
- Lightning application, operational pages, and Dynamic Actions.
- Initial Payroll Processor profile and permission set.
- Payroll public group and criteria-based ECR sharing.
- Submitted request immutability validation rule.

## Security Tests Completed

1. Salesforce Platform license assignment identified unsupported
   Case and Case_Employment access.
2. Revised Payroll permission set assignment succeeded.
3. Payroll Processor saw no ECRs before record sharing.
4. Populating Payroll Submitted Date on ECR-000000 created a
   criteria-based sharing row.
5. Payroll Processor could then see ECR-000000.
6. Payroll Processor could access ECI-000002 through its parent.
7. Payroll Processor successfully edited Requested Value before
   the new validation rule.
8. After deployment, Salesforce rejected the same type of edit.

## Request Integrity Security Hardening | 2026-11-03

**Validation rule:** `Lock_Requested_Values_After_Submission`

**Improvement:** Added `PRIORVALUE(Item_Status__c)` to prevent
simultaneous Draft-reset and requested-value modification.

**Deployment:** Successfully deployed to `aloha-dev`.

**Metadata backup:**
`documentation/metadata-backups/20261103-192543-request-lock-rule.xml`

**Dedicated test records:**
- Case: `500ak00003miwSvAAI`
- ECR-000003: `a06ak00000hUVTrAAO`
- ECI-000006: `a05ak00000mtRDeAAM`

**Verified tests:**
1. Draft Requested Value edit succeeded.
2. Submitted Requested Value modification was blocked.
3. Simultaneous status reset to Draft and Requested Value modification was blocked.
4. Read-only SOQL confirmed the rejected transaction preserved both fields.

**Final verified ECI-000006 state:**
- Item Status: Submitted
- Requested Value: Security Test Department B

**Earlier test-data correction:**
ECI-000002 Requested Value was restored to `People Operations`.
A subsequent unauthorized update failed, and read-only verification
confirmed the original value remained unchanged.

**Security scope:** Requested-value immutability is verified.
Unauthorized status-only transitions and full Payroll Processor
runtime permissions require separate testing.

## Remaining Security Work

- Regression-test legitimate request and lifecycle automation.
- Test permitted Payroll decisions and implementation actions.
- Investigate direct editing of process-controlled lifecycle fields.
- Verify Flow execution access and runtime permissions.
- Refine Payroll app and tab visibility.
- Review and harden inherited Platform profile permissions.
- Document final security matrix and acceptance evidence.
- Commit the completed security sprint.

## Resume Procedure

1. Open the existing GitHub Codespace.
2. Confirm branch and working tree with `git status --short`.
3. Confirm the Salesforce connection with `sf org display --target-org aloha-dev`.
4. Read this checkpoint and `docs/architecture-refresher.md`.
5. Inspect the relevant Salesforce records before changing anything.
6. Work in small, testable steps and commit meaningful checkpoints.

## Future Roadmap

After the Payroll security sprint:

- Expand operational features and testing.
- Develop integration architecture.
- Explore Salesforce Data 360 and Agentforce.
- Build reusable Python-based `sf-inspect` tooling.
- Improve portfolio documentation and demonstrations.

## Session Handoff Template

At the end of each development session, update:

- Date:
- Current branch and commit:
- What was completed:
- What was deployed:
- What was tested:
- Known issues:
- Exact next step:
- Relevant commands or record IDs:

**Reminder:** GitHub commits preserve source code. Salesforce org
data, group membership, authentication, and runtime configuration
may require separate verification or documentation.

---

## Agentforce Development Checkpoint | 2026-11-08

**Current focus:** Aloha Workforce AI Assistant configuration.

**Salesforce org:** `aloha-dev`

### Completed

- Created Aloha Workforce AI Assistant, Version 1 (Draft).
- Established dedicated Einstein Agent User.
- Created and deployed `Aloha_Workforce_AI_Read_Only`.
- Assigned the permission set to the Agentforce execution user.
- Verified read-only ECR and ECI object permissions.
- Verified 14 read-only ECI field permissions.
- Investigated Payroll Processor public-group membership and sharing.
- Verified Agentforce and Payroll Processor record-access differences.
- Documented findings in:
  `docs/agentforce/agentforce-security-baseline.md`

### Agentforce Configuration

Existing Agentforce Builder components:

- Agent Router
- Ambiguous Question
- Escalation
- Off Topic

Employment Change Inquiry remains to be completed.

Planned read-only retrieval actions:

- `GetEmploymentChangeRequest`
- `GetEmploymentChangeItems`

These actions are not yet operational.

### Security Status

The permission set has been deployed and its configuration verified.

Runtime authorization remains unresolved.

Do not activate the assistant until retrieval actions and
requesting-user authorization have been implemented and tested.

### Next Development Steps

1. Return to Agent Optimizer.
2. Complete Employment Change Inquiry subagent.
3. Review the generated Agent Script.
4. Design and implement secure read-only retrieval actions.
5. Test authorized and unauthorized access.
6. Complete Agentforce functional regression tests.

### Documentation First

Before repeating Salesforce discovery queries, consult:

- `docs/architecture-refresher.md`
- `docs/development-checkpoint.md`
- `docs/agentforce/agentforce-security-baseline.md`
- `docs/testing/employment-change-lifecycle-regression.md`

Requery Salesforce only when information is missing, has changed,
or requires live verification.
