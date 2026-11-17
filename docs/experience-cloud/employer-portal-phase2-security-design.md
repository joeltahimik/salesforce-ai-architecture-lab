# Employer Portal Phase 2 security design

**Current handoff.** Phase 1 pilot delivery and verification are recorded
in the [completion checkpoint](../development-checkpoint.md#phase-1-employer-portal-completion).
The [approved Phase 2 MVP](../development-checkpoint.md#phase-2-handoff)
starts with one Work Location Change per authenticated submission,
immediate employer visibility, and HR review before Payroll handoff.
The sections below retain the original pilot proposal and security design.
For employer-originated requests, successful submission sets the tenant
lookup. Manual release applies only if selected internal requests are
later approved for employer visibility.

**Status** Proposed for approval. The first pilot is invite-only, read-only,
and limited to Employment for one Harbor Lantern representative. Request,
Case, and Agentforce access have separate acceptance gates.

## Verified baseline

- The Employer Portal uses Build Your Own (LWR). It is unpublished with Public
  Access disabled. The dashboard currently renders fictional data. Its manual
  desktop preview established presentation, and external authentication and
  record isolation remain untested.
- Employment links a worker Contact to an employer Account through required
  lookups. An ECR looks up both an Employment and its Service Request (Case).
  The ECI parent field is explicitly `MasterDetail` to ECR, and ECI has
  `ControlledByParent` sharing. This verifies the mechanism for inheriting
  ECR record access. External users still need ECI object and field Read.
  Case Employment is master-detail to Case and looks up Employment. Contact
  Authorization links an Account and Contact and evaluates effective dates.
  Salesforce sharing does not consume that formula.
- Employment and ECR have Private internal and external sharing defaults. ECI
  inherits ECR access. Case Employment is modeled as Controlled by Parent.
  The submitted-ECR sharing rule serves the internal Payroll group.
  Payroll Processor has object-level Employment Read and still needs
  permanent targeted record sharing. Preserve Option A and the internal
  ECR/ECI workflow.
- **Confirmed by the project owner.** Customer Community and Customer
  Community Plus licenses are available. Each has an existing member and
  login profile. No external employer users exist. A dedicated portal
  profile and its effective grants still require review.
- **Prior focused org verification.** External defaults for Account, Contact, and
  Case are Private. The metadata inventory returned zero Sharing Sets. ECR
  has no direct Account or Contact lookup.
- **Current ownership, confirmed by the project owner.** Joel Tahimik owns
  Harbor Lantern Hospitality and now holds the CEO role. Harbor Lantern meets
  the Account-owner role prerequisite for enabling a Contact as an external
  user. This supersedes the earlier role blocker for Harbor Lantern.
  [External-user prerequisites](https://help.salesforce.com/s/articleView?id=sf.networks_create_ext_users_considerations.htm&language=en_US&type=5)

[Development checkpoint](../development-checkpoint.md) ·
[Data model](../diagrams/aloha-workforce-core-erd.md) ·
[Security baseline](../agentforce/agentforce-security-baseline.md)

## Identity and licensing

**Proposed.** Use a **Customer Community** license for a named representative
if the available entitlement supports the required objects and Sharing Set
mappings. Each representative has one approved business Account, one primary
Contact, and one named Experience Cloud User. Resolve the tenant from the
authenticated user's Contact and its primary Account on the server. Reject
guest, internal, nonmember, unlinked, and unapproved identities on employer
data routes. Keep indirect account relationships and cross-employer delegation
outside the pilot.

An internal administrator provisions the user after validating employer
sponsorship and a deliverable login address. Use a dedicated license-compatible
external profile for Sharing Set targeting and site membership, plus an
Employer Portal Read permission set for the approved object and field grants.
Start with Salesforce-managed sign-in, password reset, and MFA where
supported. Keep self-registration and just-in-time account linking disabled.
Offboard by disabling the user, revoking sessions, and removing membership and
permission assignments. Treat an employer transfer as offboarding and
reprovisioning so the same session cannot silently switch tenants.

**Requires verification.** Before provisioning, confirm the assignable seat
and dedicated profile's effective object entitlements and site membership.
Confirm the LWR sign-in, invitation, reset, MFA, and
session revocation paths in the target org. Use a separately approved
member-only test environment or release for real external login. Builder
Preview alone is insufficient evidence. Keep guest access disabled.
[Experience Cloud licenses](https://help.salesforce.com/s/articleView?id=users_license_types_communities.htm&language=en_US&type=0) ·
[External user provisioning](https://help.salesforce.com/s/articleView?id=sf.networks_create_ext_users_considerations.htm&language=en_US&type=5) ·
[External MFA](https://help.salesforce.com/s/articleView?id=sf.mfa_direct_login_user_perm.htm&language=en_US&type=5) ·
[LWR publication and login](https://help.salesforce.com/s/articleView?id=sf.community_designer_publish.htm&language=en_US&type=5)

## Proposed object access

Preserve the verified Private external defaults for exposed independent
objects. Verify additive and implicit grants in the configured pilot.
Each **R** means Read only. Create, Edit, and Delete are denied throughout the
pilot. Grant only the fields used by the approved surface.

| Object | Pilot CRUD | Intended record boundary and mechanism | Schema or exposure gate |
| --- | --- | --- | --- |
| Account | None initially. R only if a later surface needs it. | A later grant may map the authenticated Contact's Account to the target Account. | Verify implicit child access before granting. The Employment Sharing Set uses the identity relationship without an Account mapping. |
| Contact | None initially. R for self only if needed and proven. | If needed, map the authenticated Contact to its own Contact record. Verify Contact sharing does not inherit wider Account access. | Existing relationship. Workforce rows initially show job title and status. Employee names require a separate Contact access decision. |
| Employment | R | Read-only Sharing Set mapping from the user's primary Account to `Employment__c.Employer__c`. | Existing lookup. Allow job title and employment status. Withhold employee and payroll identifiers, personal details, and the worker Contact lookup. |
| ECR | R after release gate | Read-only Sharing Set from the user's primary Account to a proposed direct `Portal_Employer__c` Account lookup. | Nullable, internal-managed lookup. Null means withheld. Expose request number, processing status, and approved outcome summary. Hide payroll fields and Case lookup while Case access is deferred. |
| ECI | R after ECR gate | Inherit the released ECR's access through master-detail. A user with ECI Read may see every item on a shared ECR. | No new lookup. Expose change type and status only. Withhold requested and implemented values, payroll evidence, actor, and rejection or cancellation notes. Keep ECI Read off if the request contains items that must remain private. |
| Case | None initially. R for released cases if approved. | If added, use a verified Case Sharing Set mapping to an explicit portal employer lookup. Keep it separate from routine internal Case access. | A nullable internal-managed Account lookup is proposed only for this extension. Avoid account-wide sharing of all Cases by `AccountId`. Withhold internal descriptions, notes, files, and comments until separately reviewed. |
| Case Employment | None initially. R only with approved Case access. | Inherit access from the released Case. An Employment lookup cannot grant access to its target. | No new lookup. Require every junction's Employment employer to match the Case employer before exposure. Withhold resolution notes. |

Keep Contact Authorization internal. Its effective dates may inform enrollment
or later action authorization. An expired formula value does not revoke native
shares or sessions. If enrollment is time-bound, prove revocation at expiry
before relying on that entitlement. Do not give the external profile broad
data permissions, directory access, administrative privileges, payroll
permission sets, or API access for the pilot. Test lookup-name visibility,
search, lists, related lists, and files for indirect exposure.

## Sharing design and alternatives

**Proposed.** Use one dedicated-profile Sharing Set with read-only mappings
to the primary employer. Sharing Sets can follow supported lookup paths,
but the setup excludes custom objects without an Account or Contact lookup.
The current ECR schema lacks that prerequisite. Use the proposed direct
lookup for explicit release. Employment already meets the lookup
prerequisite. Verify its actual profile and field choices in Setup and its
effective access in an external session. Sharing Sets apply across the user's site
memberships, so keep this profile dedicated to the employer portal.
[Sharing Set capabilities and exclusions](https://help.salesforce.com/s/articleView?id=networks_setting_light_users.htm&language=en_US&type=0)

### Proposed Harbor Lantern pilot configuration

| Setting | Proposed value |
| --- | --- |
| License and profile | Customer Community. Clone **Customer Community User** to **Aloha Employer Employment Pilot**. Review and remove inherited business access before membership or assignment. Keep the profile separate from internal profiles and other sites. |
| Permission set | **Aloha Employer Employment Read**. Grant `Employment__c` Read and field Read for `Job_Title__c` and `Employment_Status__c`, plus the standard record label where required. Withhold employee and employer lookups, payroll identifiers, personal data, Create, Edit, Delete, View All, and Modify All. Verify the combined profile and permission-set grants. |
| Site membership | Add only the dedicated external pilot profile to the Aloha Workforce Employer Portal's pilot membership under separate approval. Invite one approved Harbor Lantern Contact after checking effective access. Keep self-registration and Public Access disabled. |
| Sharing Set | **Aloha Employer Employment Pilot**. Select only the dedicated profile and `Employment__c`. User mapping `Contact.Account` → target `Employment__c.Employer__c` (Employer), **Read Only**. Verify the exact options in Setup. Keep Account, Contact, ECR, ECI, Case, and Case Employment business object access out of the initial grant. |
| Runtime | Use an approved authenticated test surface that exercises Salesforce sharing and field permissions. Real external login requires a separately approved member-only runtime. The current unpublished site and demonstration dashboard stay outside the configuration step. |

The mapping is tenant-keyed. The pilot stays limited to Harbor Lantern through
profile assignment and membership. Do not add other users to the dedicated
profile until the negative controls pass.
[Salesforce profile cloning guidance](https://help.salesforce.com/s/articleView?id=ind.energy_create_an_experience_cloud_profile.htm&language=en_US&type=5) ·
[Site membership](https://help.salesforce.com/s/articleView?id=sf.networks_customize_members.htm&language=en_US)

**Candidate verified by focused read.** Harbor Lantern's designated synthetic
representative has the correct primary Account, an active Employee Changes
authorization, and no linked Salesforce user. The Contact has a reserved
example email address, so actual invitation delivery requires a separately
approved, deliverable test address. The authorization supports candidate
selection. It does not grant Salesforce record access.

Only trusted internal logic can populate a portal employer lookup. For ECR,
require `Case.AccountId = Employment__r.Employer__c = Portal_Employer__c`
and an explicit release decision. For a released Case, also verify every
junction's Employment belongs to that employer. Backfill only approved rows
after checking existing relationships. Block changes that invalidate a
released relationship, or withdraw release before the change takes effect.
Cover updates to Cases and Employments, changes to child links, and employer
transfers. A dashboard filter cannot compensate for a mismatched native share.

- **License comparison.** Both Customer Community and Customer Community Plus
  support Sharing Sets. Customer Community users have no roles. Plus also
  supports roles and standard sharing. Use Customer Community for the pilot
  and consider Plus only for a demonstrated role-based delegation or sharing
  exception. Plus does not provide employer isolation by itself.
  A role-enabled design needs explicit employer-specific recipient groups
  and record criteria. A rule to all external users would cross tenant
  boundaries. [License comparison](https://help.salesforce.com/s/articleView?id=users_license_types_communities.htm&language=en_US&type=0) ·
  [Salesforce sharing architecture](https://architect.salesforce.com/docs/architect/fundamentals/guide/platform-sharing-architecture.html)
- **Apex-managed sharing.** Consider it only for a supported role-enabled
  license and an independently shareable custom object when declarative
  sharing cannot express the grant. It adds recalculation, revocation, and
  ownership-change tests. It is unnecessary for the proposed pilot and does
  not replace inherited sharing for ECI or Case Employment.
  [Apex sharing model](https://developer.salesforce.com/docs/platform/apex-dev/references/apex-dev/apex-bulk-sharing-understanding.html)

For the live dashboard, prefer Lightning Data Service or UI API where the
site and license support the needed operations. If Apex is required, use
explicit sharing and user-mode access, resolve the tenant from the session,
and return only permitted fields. Test the underlying data surface as well
as the UI. Never use a caller-supplied tenant or system-mode fallback to
recover from a denied read. [Secure Apex classes](https://developer.salesforce.com/docs/platform/lwc/guide/apex-security)

## Security acceptance tests

Use Harbor Lantern Hospitality (A) as the first identity. Use Fernline Food
Distribution (B) and Blue Reef Facilities (C) as negative controls before
provisioning more users. Run with real external sessions in an approved test
environment and keep admin fixture verification separate.

| Employer | Workforce expectation | ECR test after release mapping is approved |
| --- | --- | --- |
| Harbor Lantern Hospitality | 5 own Employments, 3 Active. No B or C rows. | Release the Completed / Successful ECR with two Implemented items. Withhold its In Progress request. |
| Fernline Food Distribution | 5 own Employments, 3 Active. No A or C rows. | Release the Completed / Mixed Outcome ECR with one Implemented and one Rejected item. Withhold its In Progress request. |
| Blue Reef Facilities | 5 own Employments, 3 Active. No A or B rows. | Release the Completed / Rejected ECR with two Rejected items. Withhold its Cancelled request. |

Use separate sessions and swap direct links between the three employers.
Use the expected counts only after the corresponding scope is enabled.
During the Employment-only pilot, all ECR and ECI reads must fail.

| Test | Required result |
| --- | --- |
| A opens workforce list, summary, and an own Employment | Only A's allowed rows and fields appear. Counts derive from visible records. |
| Harbor Lantern Employment-only pilot checks own list and known direct records | Exactly five Harbor Lantern Employments, including three Active. A known Fernline Employment and a known Blue Reef Employment both fail by direct URL and available data route. Searches and lists expose no foreign rows or counts. |
| A searches for B or C and uses their direct record URLs or data requests | Account, Contact, Employment, ECR, ECI, Case, and junction data are denied according to the matrix. No related names, counts, or existence hints leak. |
| A opens a released own ECR and its ECI list | Approved fields only. An unreleased ECR and all its ECIs remain inaccessible even when their Employment is visible. |
| A has ECR Read and parent access while ECI object Read is withheld | The ECR remains visible and its ECIs are denied. Restoring ECI Read only exposes items under accessible ECRs. |
| A opens Case or Case Employment paths | Denied in the initial pilot. If the extension is approved, test released A Cases and valid children, and deny unrelated Cases, notes, files, and mismatched junctions. |
| A attempts create, edit, or delete through available UI and data paths | Denied for every object. Test employer links, release flags, and payroll status fields explicitly. |
| Missing sharing, object Read, membership, or valid tenant binding | Deny or return an empty authorized result without substituting broader data. Null or mismatched release anchors remain inaccessible. Test access again after offboarding and session revocation. |
| B and C reciprocal tests after first identity passes | Provision B and C sequentially under separate approval. Each user sees only their own eligible rows and is denied the other two employers' records. |
| Agentforce boundary | Phase 2 exposes no employer assistant or retrieval action. Before a future launch, test own-record retrieval, foreign record links, supplied user or Account identifiers, and expired authorization. An agent with elevated access must reject the request when trusted requester identity, tenant, object, field, or row authorization is missing. |

### Pilot rollback

If verification fails, disable the pilot identity and revoke its sessions
first. Remove the pilot user's permission set and the dedicated profile's
pilot site membership. Remove the Employment mapping from the pilot Sharing
Set under the approved cleanup scope. Leave Account ownership, the CEO role,
internal Payroll access, and existing site settings in place. Verify the
former pilot session and a fresh login cannot retrieve Harbor Lantern,
Fernline, or Blue Reef records. If the identity is ever re-enabled under
separate approval, rerun both foreign-employer denial checks before restoring
access.

## Implementation sequence and open decisions

1. **Next approval.** Clone **Customer Community User** as **Aloha Employer
   Employment Pilot**, with no user assignment or site membership. This
   establishes a dedicated configuration boundary for the pilot.
2. Under separate approval, review the clone's effective permissions, add the
   Employment Read permission set and exact Sharing Set mapping, and confirm
   lookup-name exposure and the approved member-only runtime.
3. After configuration and invitation prerequisites are verified, obtain
   approval to add pilot site membership and provision one Harbor Lantern
   identity. Keep the other employers as negative controls.
4. Pass Employment isolation and revocation tests with A against B and C.
   Approve and validate ECR release integrity and ECI inheritance before
   exposing requests. Add B and C sequentially for reciprocal tests.
5. Connect the dashboard to the approved data surface and rerun the isolation
   matrix on summaries, lists, and direct requests.
6. Keep any employer assistant behind a separate authorization review and
   runtime identity test. The internal diagnostic pilot establishes evidence
   for one execution path only.

Prior focused reads established standard external defaults, ECR lookup
eligibility, and the Sharing Set inventory. Runtime eligibility, additive
access, and external sessions still require validation.
