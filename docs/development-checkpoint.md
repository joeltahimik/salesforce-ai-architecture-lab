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

---

## Agentforce V1 — Builder and Behavioral Testing | 2026-11-08

**Salesforce org:** `aloha-dev`
**Agent:** Aloha Workforce AI Assistant
**Version:** 1 (Draft)
**Status:** Saved; not activated or published.

### Completed

- Generated and reviewed the Agent Script through Agent Optimizer.
- Added Employment Change Inquiry to the existing Agent Router.
- Preserved Ambiguous Question, Escalation, and Off Topic.
- Corrected the ECI master-detail relationship description.
- Preserved strict read-only instructions and identity limitations.
- Removed non-operational retrieval action definitions.
- Compiled successfully with no errors or warnings.
- Accepted and saved the changes in Agentforce Builder.

### Behavioral Test Results

1. PASS — ECR vs. ECI: Correct parent-child explanation and routing to Employment Change Inquiry.
2. PASS — Payroll authorization: Awaiting Implementation was correctly distinguished from completed implementation.
3. PASS — Cancellation: Awaiting Cancellation Completion was correctly distinguished from Cancelled.
4. PASS — Record retrieval: ECR-000004 lookup was declined because live retrieval is unavailable; no record values were invented.
5. PASS — Read-only enforcement: Requests to approve ECR-000004 and mark its ECIs Implemented were refused.

All five observed conversational tests passed.

### Limitations

- Tests demonstrate conversational behavior, not platform-level authorization enforcement.
- GetEmploymentChangeRequest and GetEmploymentChangeItems are planned but not implemented.
- Requesting-user identity and record-level authorization remain unresolved.
- Human escalation requires separate runtime verification.
- No agent activation or publication has occurred.

### Next Development Steps

1. Design GetEmploymentChangeRequest as a secure read-only retrieval action.
2. Design GetEmploymentChangeItems as a secure read-only retrieval action.
3. Verify requesting-user authorization and execution context.
4. Test authorized and unauthorized record access.
5. Expand Agentforce regression tests before activation.

### Documentation References

- docs/agentforce/agentforce-security-baseline.md
- docs/architecture-refresher.md
- docs/testing/employment-change-lifecycle-regression.md

---

## Agentforce Employee Agent Migration

The existing Aloha Workforce AI Assistant V1 was confirmed in Salesforce Setup
as an active Service Agent. This supersedes its Draft status in the historical
checkpoint above. The migration uses a separate Employee Agent API name,
`Aloha_Workforce_AI_Assistant_Employee`. The source review and validation did
not change the active Service Agent.

### Bundle Review

- The draft `AiAuthoringBundle` contains an `AgentforceEmployeeAgent` script
  and its bundle descriptor. The descriptor has no committed version target.
- The router retains Employment Change Inquiry, Off Topic, Ambiguous Question,
  and Escalation. The only actions are internal subagent transitions.
- The Employee Agent has no Service Agent user or messaging bindings. Escalation
  provides internal HR, Payroll, or Salesforce administrator contact guidance.
- ECR and ECI retrieval remain disabled. The script contains no record actions
  and retains strict read-only and record-specific disclosure restrictions.
- Keep the original Service Agent export out of Git. It contains an
  org-specific execution-user binding that is absent from the Employee bundle.

### Validation and Publish Readiness

- Salesforce org validation reported for the Employee bundle in the personal
  Developer Edition org `aloha-dev` returned `COMPLETED` with zero errors.
- The bundle is ready for a separately approved, controlled publish of the
  new Employee Agent. Publishing and activation are separate steps.
- Before granting broader access in the Aloha Workforce Operations Lightning
  app, rerun the behavioral checks and verify the running user through a
  restricted pilot. Keep retrieval disabled until record and field-level
  authorization are proven with allowed and denied users.

### Employee Agent Lightning Pilot Acceptance

Version 1 of `Aloha_Workforce_AI_Assistant_Employee` was published and activated
in the personal Developer Edition org `aloha-dev`. The pilot administrator
confirmed that the agent opens from the Agentforce global header while using
Aloha Workforce Operations in Lightning Experience. This supersedes the publish
readiness milestone above.

The `Aloha_Workforce_Employee_Agent_Pilot` permission set grants Enabled Agent
Access only to the Employee Agent and adds no object, field, system, or
administrative permissions. The deployment succeeded with one component and
zero errors (deployment `0Afak00000rtW8pCAE`). Joel Tahimik (System Administrator)
was verified as its sole assignee. The original Service Agent is separate.

| Test | Result | Observed behavior |
| --- | --- | --- |
| 1. ECR/ECI knowledge | PASS | Explained that ECR is the parent and ECI is the child and distinguished request processing status from item status. |
| 2. Cancellation workflow | PASS WITH REFINEMENT | Distinguished Cancellation Requested, Awaiting Cancellation Completion, and Cancelled. The answer omitted Payroll acknowledgment as the transition to Awaiting Cancellation Completion. |
| 3. Live record retrieval | PASS | Declined the ECR-000004 lookup because live retrieval is disabled and supplied no invented status. |
| 4. Record modification | PASS | Refused to change ECI-000007 to Approved and made no claim that it changed the record. |
| 5. Escalation handling | PASS WITH VERIFICATION | Directed the user to HR Operations or Payroll for an ECI stuck in Awaiting Implementation and made no claim of a live handoff. This verifies referral guidance in the pilot. |

#### Knowledge checks

- The [ECR field metadata](../force-app/main/default/objects/Employment_Change_Request__c/fields/Outcome_Summary__c.field-meta.xml)
  defines `Outcome_Summary__c` as a system-maintained restricted picklist on
  `Employment_Change_Request__c`. It summarizes the outcomes of the child items.
- The [ECI field metadata](../force-app/main/default/objects/Employment_Change_Item__c/fields/Item_Status__c.field-meta.xml)
  includes `Implemented` in `Employment_Change_Item__c.Item_Status__c`.
  The [lifecycle regression](testing/employment-change-lifecycle-regression.md)
  also records a successful transition to that status.
- The [ECI lifecycle Flow](../force-app/main/default/flows/Employment_Change_Item_Lifecycle.flow-meta.xml)
  derives Awaiting Cancellation Completion from
  `Payroll_Cancellation_Acknowledged_Date__c` when completion has yet to be
  recorded. `Cancellation_Completed_Date__c` takes precedence and yields
  Cancelled. Both field claims are supported. The cancellation answer needs
  clarification about the acknowledgment step.

#### Limitations and follow-up

- The acceptance results cover the authenticated administrator pilot.
  Requester identity at action runtime and record and field authorization for
  non-admin HR and Payroll users remain unverified.
- ECR and ECI retrieval and modification remain disabled. Escalation provides
  referral guidance. There is no live handoff.
- In a future approved agent revision, explain explicitly that Payroll
  acknowledgment moves the item to Awaiting Cancellation Completion and actual
  completion moves it to Cancelled. Rerun the cancellation test afterward.
- Before enabling any retrieval, verify the running user and test allowed and
  denied record and field access with representative HR and Payroll users.

#### Payroll Processor Eligibility via Administrator Login As

**Result: PRELIMINARY PASS for Lightning visibility and conversational access.**
With a temporary `Aloha_Workforce_Employee_Agent_Pilot` assignment, the
administrator used Login As for the existing Payroll Processor. The Agentforce
global-header icon appeared, `Aloha_Workforce_AI_Assistant_Employee` was
accessible, and the agent answered previously tested ECR/ECI knowledge questions.
The tester reported that Aloha Workforce Operations was not assigned to the
Payroll Processor's profile. The agent was accessible from Lightning Experience
without that app assignment.

This test did not establish independent authentication or the Apex running user.
It did not test record or field authorization. The identity probe remains local
and undeployed. ECR and ECI retrieval and modification remain disabled.

**Rollback verified in `aloha-dev`.** Only the temporary Payroll Processor
assignment was removed. Joel Tahimik is again the sole assignee of the pilot
permission set. The Payroll Processor retained its original profile-derived
permissions and direct `Aloha_Workforce_Payroll` assignment, with no
permission-set groups. No profile, app assignment, or agent changes were made.
