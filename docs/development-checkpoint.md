# Aloha Workforce Solutions | Development Checkpoint

**Last checkpoint review:** 2026-11-16

**Start here:** [Architecture Refresher](architecture-refresher.md)

## Current Project State

**Latest milestone:** The [Phase 1 Employer Portal MVP](#phase-1-employer-portal-completion)
is complete in the published Experience Cloud pilot on `aloha-dev`
(Org ID `00Dak00001EqrL3EAJ`).

**Next step:** Begin the [Phase 2 Work Location Change MVP](#phase-2-handoff)
with the internal HR-to-Payroll handoff. The remaining Phase 1 negative-route
browser checks are a low-priority follow-up.

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

Future design work for the **Experience Cloud Employer Portal** covers employer
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

### Experience Cloud Employer Dashboard Phase 1

The **Aloha Workforce Employer Portal** uses the **Build Your Own (LWR)**
template at the `employers` URL path. Public Access is disabled and the site
is unpublished. The homepage welcome section was configured manually in
Experience Builder. The initial branding uses navy, blue, and white.

The `employerDashboard` Lightning web component was deployed to the
development org. Salesforce reported success for one component with zero
errors and zero warnings. A post-deployment query
confirmed the `lightningCommunity__Page` target and Builder exposure.

**Local validation.** The LWC compiled successfully, its metadata passed
local checks, and ESLint, Prettier, and both Jest tests passed. The compiled
component rendered in local Chromium at 1,200, 768, 390, and 320 px without
horizontal overflow.

**Manual Salesforce verification.** The project owner added **Employer
Dashboard** in Experience Builder and visually verified it in desktop
Builder Preview.

The dashboard shows three summary cards, My Workforce, and Employment Change
Requests using visibly labeled fictional demonstration data. The portal has
no external users or live dashboard data integration at the Phase 1 checkpoint.
Future live access must enforce authenticated employer
identity, object permissions, and record-level sharing.

### Experience Cloud Employer Dashboard Phase 2 | Personalized Welcome Header

The dashboard uses the Salesforce session's user ID and Lightning Data Service
to read the user's name and follow `User.ContactId` → `Contact.AccountId` →
`Account.Name`. Guest sessions skip identity reads. Missing links and denied
reads fall back to neutral text, preserving any available user name. The three
summary cards, workforce, and requests still use labeled demonstration data.
No Apex, org query, or profile and sharing changes were needed for local work.

**Local verification.** All seven Jest tests passed, covering the personalized
header, missing Contact and Account links, loading, denied reads, and the existing
demonstration dashboard. ESLint, Prettier for the LWC bundle, and
`git diff --check` passed.

**Deployment and browser verification.** Deployment `0Afak00000sIRSUCA4`
succeeded in `aloha-dev` with only the `employerDashboard` bundle. The project
owner subsequently published the site and confirmed that the authenticated
pilot session displayed Aven Harborfield and Harbor Lantern Hospitality.
This confirms the identity header; the workforce and request cards still show
demonstration data.

### Employer Portal Phase 2 | Read-only security verification

Focused Salesforce reads verified that Aven is active and portal-enabled, has
the Customer Community license and Aloha Employer Employment Pilot profile,
and is linked through Contact to Harbor Lantern Hospitality. The assigned
sources were the profile-backed permission set and Aloha Employer Employment
Read; no permission set group assignment was returned.

- **Object permissions — PASS (configuration).** Employment Read is granted.
  Neither source granted Create, Edit, Delete, View All Records, Modify All
  Records, or View All Fields for Employment. Neither source granted View All
  Data, Modify All Data, or API Enabled.
- **Field permissions — PASS (configuration).** The only explicit Employment
  field grants returned were Read on Job Title and Employment Status; both
  were non-editable. Portal rendering and exposure through record responses
  still require verification.
- **Sharing Set — PASS (configuration).** Aloha Employer Employment Access
  targets Aloha Employer Employment Pilot and maps `Contact.Account` to
  `Employment__c.Employer__c` with Read access. The exact set name supersedes
  the proposed name in the
  [Phase 2 security design](experience-cloud/employer-portal-phase2-security-design.md).
- **Record access — PASS (diagnostic).** An administrator read identified five
  fixtures for each employer. A separate `UserRecordAccess` query evaluated
  Aven on all 15: Read on 5 Harbor Lantern, 0 Fernline Food Distribution, and
  0 Blue Reef Facilities. Edit and Delete were false on all 15. The diagnostic
  does not exercise the portal or account for restriction rules.
- **External Employment session — partial verification.** The project owner
  confirmed Aven signed in, saw five records in the standard Employment List,
  and opened an authorized Employment Detail record. Direct foreign-record
  URL tests and a full review of visible fields and actions are still pending.

### Employer Portal Phase 2 | UI release | 2026-11-11

The dashboard now uses a navy welcome header with the greeting as a heading
and a separate employer identity panel that stacks on narrow screens. The
demonstration notice now explicitly covers the counts and both record sections
and is linked to them for assistive technology. The three metrics, workforce
and request examples, identity reads, and missing-data fallbacks are unchanged.
All seven Jest tests, ESLint, LWC formatting, and `git diff --check` passed.
Deployment `0Afak00000sIl9RCAS` succeeded in `aloha-dev`
(org `00Dak00001EqrL3EAJ`) with one component,
`LightningComponentBundle:employerDashboard`, and zero component errors.

**Read-only metadata inspection.** No site source was present in the workspace.
Salesforce retrieval `09Sak00000wtMcnEAE` exported only the named employer
portal `DigitalExperienceBundle`, its `DigitalExperienceConfig`, and its
Default Navigation menu to a temporary folder. The enhanced LWR bundle
confirmed the Home, Employment List, and Employment Detail routes and views.
No site metadata was edited or added to the repository.

**Owner-reported Builder changes and publication.** The owner reported
successful publication on November 11, 2026, after these changes:

- Renamed the **Employment List** navigation item to **My Workforce**.
- Added the **My Workforce** heading and **Back to Home** link on Employment
  List, retaining the standard Record List component.
- Changed the Employment Detail heading to **Employment Details** and added
  **Back to My Workforce**, retaining the standard Record Detail component.
- Moved Rich Content into the appropriate page-specific **Column 1** region
  to resolve unwanted visibility on other pages.

### Employer Portal Phase 2 | Active Employments and second pilot | 2026-11-11

**Active Employments dashboard.** Deployment `0Afak00000sJPoPCAW` succeeded
in `aloha-dev` (org `00Dak00001EqrL3EAJ`) with only the
`employerDashboard` LightningComponentBundle and zero errors or warnings.
The GraphQL wire adapter uses Lightning Data Service in the authenticated
user's context to count all accessible `Employment__c` records where
`Employment_Status__c = Active`. The metric links to the My Workforce
**All** list. All 13 Jest tests, ESLint, LWC formatting, and
`git diff --check` passed. No Apex controller was introduced.

**Second employer pilot.** The project owner reported successful provisioning,
invitation, portal login, and working portal functionality for Fenn Fernridge
of Fernline Food Distribution, using the Customer Community license and
**Aloha Employer Employment Pilot** profile. The existing read-only Sharing
Set maps `Contact.Account` to `Employment__c.Employer__c`. An administrator's
read-only query verified five Fernline fixtures: three Active, one Leave, and
one Terminated. In manual portal testing on November 11, 2026, the project
owner verified that Fenn's live dashboard displayed exactly **3 Active
Employments** and My Workforce displayed exactly **5 Fernline Employment
records**.

**Cross-employer direct URL test — PASS (observed, November 11, 2026).**
Fenn Fernridge opened the direct URL for a Harbor Lantern Hospitality
Employment record. Chrome Network showed record requests returning HTTP
404 and 400, and the portal displayed no foreign record data. Aven
Harborfield successfully opened the exact same record as the positive
control. The result covers this Fenn-to-Harbor Lantern test.

**Historical Experience Cloud Record Detail issue.** In Fenn's session, the page
continued to show a loading spinner after the failed record requests.
The Phase 1 completion entry below records the replacement component.

**Employment full name.** `Employment__c.Full_Name__c` is a Formula (Text)
field used to display employee names without linking to Contact pages that
portal users cannot access. The original verified formula was
`Employee__r.FirstName + ' ' + Employee__r.LastName`. The owner subsequently
reported updating it to use `TRIM` and `BLANKVALUE` for missing names. The revised
formula has not been independently retrieved from Salesforce. `Employee__c`
remains the underlying Contact lookup.

### Phase 1 Employer Portal completion

The published LWR portal provides the Employer Dashboard, the live
**Active Employments** metric, the **My Workforce** record list, and
read-only **Employment Details**. The dashboard count reflects records
visible to the signed-in employer. My Workforce leads to Employment Details,
with return links to My Workforce and Home.

DevTools located the old spinner inside the standard Record Detail form,
and Experience Builder offered no record-load error setting. The custom
`employerEmploymentDetail` LWC uses Lightning Data Service `getRecord` in
the pilot user's context. It displays Employee Name, Employment Number,
Job Title, and Employment Status, subject to field-level access. It has
no edit actions or employee Contact links. The centered SLDS card uses
two columns on desktop and one on mobile, with a neutral
**Employment details unavailable** message and a status announcement for
loading and failed reads. The latest bundle deployment,
`0Afak00000t63ZpCAI`, succeeded in `aloha-dev` with one component and
zero deployment errors or warnings.

**Published portal pilot evidence (reported by Joel).**

| Pilot | Own Employment records | Active Employments | Browser verification | Foreign Employment access |
| --- | ---: | ---: | --- | --- |
| Fenn Fernridge, Fernline Food Distribution | 5 | 3 | Passed all five checks | Harbor Lantern and Blue Reef denied |
| Aven Harborfield, Harbor Lantern Hospitality | 5 | 3 | Passed all five checks | Fernline and Blue Reef denied |

Blue Reef Facilities served as the negative control for both signed-in
pilots. A separate CLI `UserRecordAccess` diagnostic covered all 15
fixtures per pilot. Each could read five own records, zero foreign records,
and edit or delete none. The Sharing Set maps `Contact.Account` to
`Employment__c.Employer__c` with Read access.

**Automated component verification.** All eight focused Jest tests
passed. Mocked HTTP 400, 403, and 404 responses and missing record context
produce the same neutral unavailable state. The component shows no
Employment details or persistent loading state in those cases.

**Low-priority browser follow-up.** Independently verify published routes
for a valid-format nonexistent Employment ID, a malformed ID, and a route
with the ID omitted. Computer Use stopped before navigation because it
could not reliably identify the active Chrome URL. These three routes
remain unverified in the browser. The passing Jest cases cover component
behavior when the component mounts. LWR can reject a route before that
point.

**Permission-set source discrepancy.** Live checks found read-only field
grants for `Employment__c.Full_Name__c`, `Job_Title__c`, and
`Employment_Status__c` in `Aloha_Employer_Employment_Read`. The local
permission-set metadata contains only the Job Title and Employment Status
grants. Compare the local source with the verified org grant and reconcile
the difference before a future deployment of this permission set so the
employee display-name access is preserved. This checkpoint leaves the
permission set untouched.

### Phase 2 handoff

The approved MVP lets an authenticated employer representative submit one
Work Location Change for an eligible Employment in their own organization.
After a successful submission, the employer can immediately see the
request summary and individual change status. HR reviews the request
before forwarding it to Payroll. The existing ECR/ECI decision,
implementation, and aggregation lifecycle remains authoritative.

Reuse the Case, Case Employment, ECR, and ECI package. Resolve the tenant
from the authenticated user's Contact and primary Account, validate the
Employment and Work Location against that Account, and create the package
atomically. Use the planned server-managed ECR Account lookup for
read-only sharing to the employer. Keep internal and legacy ECRs withheld
by default. Any later internal release requires an explicit controlled
action. ECIs inherit record access from the ECR, so every child on a
visible ECR must be safe for employer disclosure. Keep Case, internal
notes, Payroll IDs and evidence, and sensitive processing fields private.

**First implementation task:** Build and verify the internal HR-only
**Forward to Payroll** action and Payroll entry-point guard on a synthetic
portal-originated Work Location request. Reuse
`Payroll_Submitted_Date__c` for the one-time handoff and existing Payroll
share. Verify that Payroll cannot process the request before HR forwards
it and can use the existing lifecycle afterward. Preserve the internal
submission path. Next, prove tenant sharing and field access on synthetic
records before connecting portal submission and tracking. See the
[Phase 2 security design](experience-cloud/employer-portal-phase2-security-design.md).

### Remaining development priorities

1. **Employer-submitted Work Location Changes.** Follow the
   [Phase 2 handoff](#phase-2-handoff).
2. **Internal Agentforce request lookup.** HR and Payroll can answer status
   questions faster. This has strong Agentforce learning and demo value and
   indirect employer value. The existing identity probe is a starting point;
   record and field authorization still need proof for each retrieval
   action. Codex can review the draft Flow and prepare authorization tests.
   Action deployment and activation need separate approval.
