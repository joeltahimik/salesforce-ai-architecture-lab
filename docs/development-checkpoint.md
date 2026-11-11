# Aloha Workforce Solutions | Development Checkpoint

**Last checkpoint review:** 2026-11-10

**Start here:** [Architecture Refresher](architecture-refresher.md)

## Current Project State

**Latest milestone:** Employer Portal Stage 2 created and verified 65 synthetic
records. Read-only Plan verified zero proposed creates both after seeding and
after the intentional Account display-name changes.

**Next proposed phase:** Experience Cloud Employer Portal (planned).

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
4. Populating Payroll Submitted Date on the submitted request created a
   criteria-based sharing row.
5. Payroll Processor could then see the submitted request.
6. Payroll Processor could access the child change item through its parent.
7. Payroll Processor successfully edited Requested Value before
   the new validation rule.
8. After deployment, Salesforce rejected the same type of edit.

## Request Integrity Security Hardening | 2026-11-03

**Validation rule:** `Lock_Requested_Values_After_Submission`

**Improvement:** Added `PRIORVALUE(Item_Status__c)` to prevent
simultaneous Draft-reset and requested-value modification.

**Deployment:** Successfully deployed to the development org.

The test used a dedicated Case, ECR, and ECI.

**Verified tests:**
1. Draft Requested Value edit succeeded.
2. Submitted Requested Value modification was blocked.
3. Simultaneous status reset to Draft and Requested Value modification was blocked.
4. Read-only SOQL confirmed the rejected transaction preserved both fields.

Read-back confirmed that the rejected updates preserved the submitted status
and original requested value.

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

## Agentforce Development Checkpoint | 2026-11-08

**Current focus:** Aloha Workforce AI Assistant configuration.

**Environment:** Salesforce development org

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

**Environment:** Salesforce development org
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
4. PASS — Record retrieval: the sample request lookup was declined because live retrieval is unavailable; no record values were invented.
5. PASS — Read-only enforcement: Requests to approve the sample request and mark its ECIs Implemented were refused.

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
  Developer Edition org returned `COMPLETED` with zero errors.
- The bundle is ready for a separately approved, controlled publish of the
  new Employee Agent. Publishing and activation are separate steps.
- Before granting broader access in the Aloha Workforce Operations Lightning
  app, rerun the behavioral checks and verify the running user through a
  restricted pilot. Keep retrieval disabled until record and field-level
  authorization are proven with allowed and denied users.

### Employee Agent Lightning Pilot Acceptance

Version 1 of `Aloha_Workforce_AI_Assistant_Employee` was published and activated
in the development org. The pilot administrator
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
| 3. Live record retrieval | PASS | Declined the sample request lookup because live retrieval is disabled and supplied no invented status. |
| 4. Record modification | PASS | Refused to change the sample change item to Approved and made no claim that it changed the record. |
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

#### Preliminary Payroll Processor Eligibility

Lightning visibility and conversational access passed in a preliminary
administrator-assisted test. The temporary access assignment was removed and
the original Payroll permissions remained in place. Direct authentication and
execution identity were tested separately. Record and field authorization for
live retrieval still requires validation.

### Execution Identity Pilot Apex Deployment

Stage 1 succeeded in the development org. The API 67.0 deployment contained only
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

The temporary `Aloha_Workforce_Identity_Pilot` bundle revalidated against the
deployed Stage 1 Apex with zero warnings. The
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

### Execution Identity Pilot Publication

Stage 2 published only `Aloha_Workforce_Identity_Pilot` to the development org using
API 67.0 and a disposable DX project. Salesforce confirmed version 1 as
Inactive. Both existing agent definitions matched their preflight state.

Check-only validation of `Aloha_Identity_Pilot_Agent_Access` succeeded with
zero component errors. Stage 3A subsequently deployed the permission set.

### Execution Identity Pilot Agent Access

Stage 3A passed post-deployment verification in the development org. The deployment
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

Stage 3B completed in the development org. The test used the temporary
`Aloha_Workforce_Identity_Pilot` V1 in Lightning Experience
with Payroll Processor signed in directly in a private browser session.

| Step | Result | Evidence |
| --- | --- | --- |
| 1–3. Preflight, activation, and Apex access | PASS | Verified the org, agent versions, and access baseline. Activated only the temporary pilot V1 and temporarily assigned `Aloha_Identity_Pilot_Apex_Access` to Payroll Processor. |
| 4. Negative agent access | INCONCLUSIVE | Payroll Processor signed in directly and opened Aloha Workforce Operations, but the Agentforce interface was unavailable. The test could not establish a pilot-specific denial. |
| 4B. Visibility comparison | PASS | After temporarily assigning `Aloha_Identity_Pilot_Agent_Access`, Payroll Processor signed in directly again and saw Aloha Workforce Identity Pilot in Lightning. The Step 4 outcome remains inconclusive. |
| 5. Diagnostic trace | PASS | The diagnostic evidence was captured. |
| 6. Runtime identity | PASS | The Apex execution principal matched the authenticated Payroll Processor. |

The result establishes the Apex execution principal for this diagnostic turn.
The probe performs no SOQL, DML, or callouts, so CRUD, field-level security,
and record-level authorization still require separate tests before any ECR or
ECI retrieval is enabled. ECR and ECI retrieval and modification remain
disabled. The [Agentforce security baseline](agentforce/agentforce-security-baseline.md#stage-3b-apex-execution-identity)
records the authorization implications.

#### Verified Stage 3B rollback

**PASS.** `Aloha_Workforce_Identity_Pilot` V1 returned to Inactive. Both
temporary assignments were removed, leaving the agent-access
and Apex-access permission sets with zero assignees. The temporary diagnostic configuration was removed. Both original agents stayed Active on V1 with unchanged
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

The repository profile was outside the original change scope and differs from
the verified live baseline. Review and reconcile it before including it in a
deployment.

**Direct-login regression checks remain pending** for the affected administrative pages and permitted operational access.

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

### Employer Portal Seed Data

Stage 2 created 65 synthetic records in nine successful transactions across
Harbor Lantern Hospitality, Fernline Food Distribution, and Blue Reef
Facilities. The fixtures include 15 Contacts, 15 Employment relationships,
six Service Requests, six Case Employment junctions, six ECRs, eleven ECIs,
and three Contact Authorizations. External portal users remain future work.

All six ECR lifecycle scenarios matched the expected status and outcome.
The original read-only Plan after Apply proposed zero additional creates.
The three Accounts were later renamed to remove the Fixture prefix. The
read-only verification recognized all 65 records and proposed zero creates.
Record identity, ownership, and relationships were preserved. Duplicate or
ambiguous matches stopped validation.

Payroll Processor has object-level Read on Employment. After the seed,
Payroll Processor had Read Only on all six ECRs, Read/Edit on all eleven
ECIs, and no record-level Read or Edit on the fifteen Employments.
Permanent Employment record-sharing design remains open under Option A.

The All Employers and All Workforce Contacts list views exclude Developer
Edition sample records using the sample owner's alias. This filter controls
list results, while Salesforce record sharing controls record access. See the
[Employer Portal fixture and lifecycle details](testing/employer-portal-test-data.md).
