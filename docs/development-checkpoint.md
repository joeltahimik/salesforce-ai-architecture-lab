# Aloha Workforce Solutions | Development Checkpoint

**Last checkpoint review:** 2026-11-10

**Start here:** [Architecture Refresher](architecture-refresher.md)

## Current Project State

**Latest milestone:** The targeted Employment sharing test passed in Lightning,
and API checks verified cleanup. Stage 3C and 3D profile hardening passed API
verification. The broader direct-login regression checks are pending.

**Next proposed phase:** Experience Cloud Employer Portal (planned).

**Prior Git checkpoint:** `35b972e` on `main` (Checkpoint Agentforce identity
pilot and verified rollback).

**Current development environment:** Personal Windows PC, PowerShell,
repository `joeltahimik/salesforce-ai-architecture-lab`, branch `main`.

**Salesforce org alias:** `aloha-dev`

**Last verified org:** Personal Salesforce Developer Edition, `aloha-dev`.

Earlier development used GitHub Codespaces. During that phase, the Codespace
was reactivated and automatic deletion was disabled.

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

The dedicated test records were a parent Case, ECR-000003, and ECI-000006.

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
- Complete direct-login regression checks for the platform profile cleanup.
- Document final security matrix and acceptance evidence.
- Commit the completed security sprint.

## Resume Procedure

1. Open the local repository in PowerShell on the Windows development PC.
2. Confirm branch and working tree with `git status --short`.
3. Confirm the Salesforce connection with `sf org display --target-org aloha-dev`.
4. Read this checkpoint and `docs/architecture-refresher.md`.
5. Inspect the relevant Salesforce records before changing anything.
6. Work in small, testable steps and commit meaningful checkpoints.

## Future Roadmap

The next proposed development phase is the **Experience Cloud Employer
Portal**. This phase is planned. The proposed design work covers employer
sign-in, employer-specific access to workforce requests, and tests that
verify users cannot see another employer's records. The existing request
lifecycle and Payroll processing boundaries apply to the proposed design.

Other roadmap items:

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
zero errors. The pilot administrator was verified as its sole assignee. The
original Service Agent is separate.

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
  Stage 3B later verified execution identity for the temporary diagnostic
  only. Record and field authorization for HR and Payroll users still
  requires separate testing.
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

Independent authentication, Apex execution identity, and record and field
authorization were outside the scope of this Login As test. At the time, the
identity probe was still local. The later deployment and Stage 3B results
are recorded below. ECR and ECI retrieval and modification remain disabled.

**Rollback verified in `aloha-dev`.** Only the temporary Payroll Processor
assignment was removed. The pilot administrator is again the sole assignee of
the pilot permission set. The Payroll Processor retained its original
profile-derived permissions and direct `Aloha_Workforce_Payroll` assignment, with no
permission-set groups. No profile, app assignment, or agent changes were made.

### Execution Identity Pilot Apex Deployment

Stage 1 succeeded in `aloha-dev`. The API 67.0 deployment contained only
`AlohaAgentIdentityProbe`,
`AlohaAgentIdentityProbeTest`, and `Aloha_Identity_Pilot_Apex_Access`.
`RunSpecifiedTests` ran the probe test with one pass, zero errors, and 100%
probe coverage.

The deployed probe matched the reviewed source and performs no SOQL, DML,
or callouts. The permission set grants access only to the probe class and has
no assignees. The temporary `Aloha_Workforce_Identity_Pilot` authoring bundle
revalidated successfully against the deployed Apex with zero warnings.

At the close of Stage 1, the temporary agent was unpublished and inactive,
and its agent-access permission set was pending deployment. No trace flags
were created. The subsequent milestones are recorded below.

### Payroll Processor Lightning App Access

Direct Payroll Processor sign-in was confirmed by the project owner. The test
user retains the Salesforce Platform license, Aloha Workforce Platform User
profile, and `Aloha_Workforce_Payroll` assignment. The standard Lightning app
`Aloha_Workforce_Operations` is visible org-wide in App Launcher, while the
user's profile marked it hidden and the existing Payroll permission set had
no app visibility entry.

The app-access deployment added only
`Aloha_Workforce_Operations_App_Access`. Retrieved metadata confirmed one
app visibility grant and no additional permissions. Payroll Processor is its
sole assignee. Before-and-after checks matched for the original assignments,
ECR and ECI object and field permissions, and record access to the two
documented test records. No profile, license, sharing, or agent changes were
made.

The first directly authenticated Lightning session did not show the app tile.
After signing out and back in directly as Payroll Processor, the project owner
confirmed that the tile appeared in App Launcher and the app opened. No
broader permissions were required.

The temporary `Aloha_Workforce_Identity_Pilot` bundle revalidated in
`aloha-dev` against the deployed Stage 1 Apex with zero warnings. The
publication result is recorded below.

#### Work Locations tab visibility

After the app-access deployment, the project owner used Salesforce Setup to
change the Work Locations tab (`Work_Location__c`) from `None` to `Visible`
on `Aloha_Workforce_Operations_App_Access`. Setup Audit Trail recorded the
change. Live metadata confirmed the tab setting, and Payroll Processor was
verified as the sole assignee. The
Aloha Workforce Platform User profile still lists the tab as `Hidden`.

The [local permission-set metadata](../force-app/main/default/permissionsets/Aloha_Workforce_Operations_App_Access.permissionset-meta.xml)
records the app grant and the Work Locations tab setting.

To roll back the tab change only, open Setup, then Permission Sets, then
Aloha Workforce Operations App Access. In Object Settings, open Work Locations,
choose Edit, clear tab visibility to restore `None`, and save. Verify that
Payroll Processor still has the app-access assignment and can open Aloha
Workforce Operations.

To roll back the separate app-access assignment, open Manage Assignments for
Aloha Workforce Operations App Access and remove only Payroll Processor. Verify
that the original Payroll permission set and profile-derived access remain.

### Execution Identity Pilot Publication

Stage 2 published only `Aloha_Workforce_Identity_Pilot` to `aloha-dev` using
API 67.0 and a disposable DX project. Salesforce confirmed version 1 as
Inactive. Both existing agent definitions matched their preflight state.

Check-only validation of `Aloha_Identity_Pilot_Agent_Access` succeeded with
zero component errors. Stage 3A subsequently deployed the permission set.

### Execution Identity Pilot Agent Access

Stage 3A passed post-deployment verification in `aloha-dev`. The deployment
succeeded with one component and zero errors. The sole component,
`Aloha_Identity_Pilot_Agent_Access`, grants access only to
`Aloha_Workforce_Identity_Pilot`.

Both `Aloha_Identity_Pilot_Agent_Access` and `Aloha_Identity_Pilot_Apex_Access`
have zero direct assignees and no permission-set group memberships.

| Agent API name | Version | Verified status |
| --- | --- | --- |
| `Aloha_Workforce_Identity_Pilot` | 1 | Inactive |
| `Aloha_Workforce_AI_Assistant_Employee` | 1 | Active |
| `Aloha_Workforce_AI_Assistant` | 1 | Active |

The existing Employee and Service Agent definitions and versions were last
modified before Stage 2, consistent with the preflight comparison.

### Execution Identity Pilot Runtime Verification | 2026-11-09

Stage 3B completed in `aloha-dev`. The test used the temporary
`Aloha_Workforce_Identity_Pilot` V1 in Lightning Experience
with Payroll Processor signed in directly in a private browser session.

| Step | Result | Evidence |
| --- | --- | --- |
| 1–3. Preflight, activation, and Apex access | PASS | Verified the org, agent versions, and access baseline. Activated only the temporary pilot V1 and temporarily assigned `Aloha_Identity_Pilot_Apex_Access` to Payroll Processor. |
| 4. Negative agent access | INCONCLUSIVE | Payroll Processor signed in directly and opened Aloha Workforce Operations, but the Agentforce interface was unavailable. The test could not establish a pilot-specific denial. |
| 4B. Visibility comparison | PASS | After temporarily assigning `Aloha_Identity_Pilot_Agent_Access`, Payroll Processor signed in directly again and saw Aloha Workforce Identity Pilot in Lightning. The Step 4 outcome remains inconclusive. |
| 5. Diagnostic trace | PASS | Verified a ten-minute Payroll Processor user trace with Apex Code at `WARN` and other categories at `NONE`. |
| 6. Runtime identity | PASS | At 6:55:10 p.m. HST on November 9, 2026, the single `Run identity probe` turn returned “The diagnostic completed.” In the correlated restricted Apex log, the principal recorded with WARN marker `ALOHA_IDENTITY_PROBE_P1_82F7C4` and the `LogUserId` both identified Payroll Processor. |

The result establishes the Apex execution principal for this diagnostic turn.
The probe performs no SOQL, DML, or callouts, so CRUD, field-level security,
and record-level authorization still require separate tests before any ECR or
ECI retrieval is enabled. ECR and ECI retrieval and modification remain
disabled. The [Agentforce security baseline](agentforce/agentforce-security-baseline.md#stage-3b-apex-execution-identity)
records the authorization implications.

#### Verified Stage 3B rollback

**PASS.** `Aloha_Workforce_Identity_Pilot` V1 returned to Inactive. Both
temporary assignments were removed, leaving the agent-access
and Apex-access permission sets with zero assignees. The expired temporary
trace was removed, followed by its debug level after confirming it had no
remaining references. Both original agents stayed Active on V1 with unchanged
version IDs and modification timestamps. Payroll Processor retained the
original payroll and app-access assignments and Work Locations tab visibility.

### Platform User Least-Privilege Hardening

Payroll Processor and Aloha StandardTester share the Aloha Workforce Platform
User profile. Payroll Processor receives operational access through separate
payroll and app-access permission sets and payroll sharing. Aloha StandardTester
serves as the baseline persona without payroll privileges. Neither persona
requires Salesforce administration for its intended duties.

| Stage | Profile permissions disabled | Verification |
| --- | --- | --- |
| 3C | `ViewSetup`, `ViewSetupAuditTrail`, `ViewRoles`, `ViewLicenseUtilization` | API PASS. All four changed from enabled to disabled for both users. |
| 3D | `EmailAdministration`, `EmailTemplateManagement` | API PASS. Salesforce validated the individual changes, the combined change, and its rollback package. The two-permission profile update succeeded, and all six permissions were verified disabled for both users. |

Before-and-after API checks matched for unrelated system permissions, profile
and permission-set assignments, sharing memberships, and checked object and
field permissions. Payroll Processor retained the Aloha Workforce Operations
app and Work Locations tab grants. On the sampled records, Payroll Processor
retained ECR read access and ECI read/edit access. Aloha StandardTester remained
without read or edit access to either sample. The original Employee and
Service Agents remained Active on V1. The Identity Pilot remained Inactive
with both pilot permission sets unassigned.

Restricted backups were saved outside the repository for both stages and
verified readable with the original permission values. Rollback was not
needed. The repository profile XML was outside the change scope and does not
reflect the verified live permission state. Any future profile deployment
requires a separately reviewed reconciliation against the live profile.

**Direct-login regression checks: PENDING.** In fresh sessions, confirm both
personas lose access to the affected administrative pages. Confirm Payroll
Processor can open Aloha Workforce Operations, Work Locations, and the
permitted ECR and ECI. Confirm Aloha StandardTester can open their normal
Lightning landing page and is denied access to the same ECR and ECI. Use the
existing test records and leave them unsaved.

### Employment Record Access Test

**Root cause.** Payroll Processor had object-level Read on `Employment__c`.
Internal and external organization-wide defaults were Private, there were no
Employment sharing rules, and the test record had only its owner share. The
submitted ECR sharing rule and ECI access inherited from the parent ECR did not
grant access to the Employment referenced by the ECR lookup.

**Lightning verification.** A temporary manual share granted Read Only on one
Employment directly to Payroll Processor. All four interactive checks passed.
Payroll Processor found the record in the Employments list, opened it, confirmed
direct editing was unavailable, and viewed the fields required for payroll
processing.

**Cleanup verified.** The temporary share was deleted and the original owner
share remained intact. Salesforce API checks confirmed that Payroll Processor
again had neither Read nor Edit on the test Employment and Aloha StandardTester
remained denied. On the sampled ECRs and ECIs, Payroll Processor retained ECR
Read and ECI Read/Edit, and Aloha StandardTester remained denied. The checked
object and field permissions, permission-set assignments, payroll group
membership, and Employment sharing defaults matched preflight.

**Agreed architecture (Option A).** Payroll Processor may read authorized
Employment records. Employment changes must go through the ECR/ECI workflow.
Designing permanent, least-privilege Employment record sharing is future work.
