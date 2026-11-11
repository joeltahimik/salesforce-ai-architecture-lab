# Employer Portal test data

The `AWS-PORTAL-V1` fixtures provide three employer boundaries for future
Experience Cloud tests. Contact is the person record. Employment links that
person to the employer Account. Each employer has one designated representative
who is also an employee and has an effective Employee Changes authorization.
Authorization records model business authority. Portal record visibility will
depend on the external sharing design.

| Object | Records |
| --- | ---: |
| Account | 3 |
| Contact | 15 |
| Employment | 15 |
| Case | 6 |
| Case Employment | 6 |
| Employment Change Request | 6 |
| Employment Change Item | 11 |
| Contact Authorization | 3 |

Each employer has three Active, one Leave, and one Terminated Employment.
The fixture contains zero separate Employee records and zero external users.
Each Case has one affected Employment junction and one ECR. Contact names,
titles, employee numbers, dates, payroll transaction identifiers, and request
details are synthetic. Contact emails use `example.invalid`.

| Employer | Request 1 | Request 2 |
| --- | --- | --- |
| Harbor Lantern Hospitality | 2 Submitted → In Progress / Pending | 2 Implemented → Completed / Successful |
| Fernline Food Distribution | 2 Awaiting Implementation → In Progress / Pending | Implemented + Rejected → Completed / Mixed Outcome |
| Blue Reef Facilities | 2 Rejected → Completed / Rejected | 1 Cancelled → Completed / Cancelled |

Stage 2 created all 65 records in nine successful transactions. Salesforce
read-back confirmed all six outcomes in the table, and the original
post-Apply Plan proposed zero creates. Existing records in all eight
objects matched their pre-Apply counts and modification timestamps.

The All Employers Account list view and All Workforce Contacts Contact list
view exclude Developer Edition sample records by the sample owner's alias
`OEPIC`. Salesforce record sharing continues to control record visibility.

## Read-only Plan

Run from the repository root with PowerShell 7 and an authenticated Salesforce
CLI alias for the development org. Supply the approved org ID locally.

```powershell
.\scripts\seed\seed-employer-portal.ps1 -ExpectedOrgId $env:ALOHA_EXPECTED_ORG_ID
```

The default mode verifies the org ID, describes all eight writable objects,
checks active automation inventory, and queries fixture markers and
relationships. It prints expected and proposed create counts. An empty org
fixture scope should show 65 creates. Plan reads any existing manifest and
leaves it untouched.

## Automation and authorized apply

- The seven active Flow versions are pinned in the fixture. The live submission
  Flow is active at v1. The seed reproduces its submission fields through the
  API and sends the acknowledgement, decision, implementation, and cancellation
  facts through successive ECI updates. The active before-save lifecycle Flow
  sets ECI states and the after-save aggregation Flow sets final ECR status and
  outcome. Payroll evidence and dates represent simulated events. The selected
  fixture owner is also the synthetic decision actor.
- Each ECR has a payroll submission timestamp, so the existing submitted-ECR
  rule can share the requests with the Payroll Processors group. ECIs inherit
  their parent ECR's sharing. This dataset creates no direct Employment shares.
  Payroll Processor has object-level Read on Employment. The Stage 2
  fixture checks found Read Only on six ECRs, Read/Edit on eleven ECIs, and
  no Read or Edit on the fifteen Employment records. Permanent Employment
  sharing remains future design work under Option A.
- The org has an active Standard Case assignment rule. Account and Case REST
  create subrequests use
  `Sforce-Auto-Assign: FALSE`. The active Case escalation rule has eight
  entries with reassignment and notification actions. Each currently requires
  a populated Account SLA. The plan checks that fixture Accounts have blank
  SLA and billing country before creating their Cases.
- Read-only metadata review found no Case auto-response rules or workflow
  rules, alerts, or outbound messages on the fixture objects. No active Apex
  triggers were returned. The Account and Contact standard duplicate rules
  remain enforced. Reviewed employment Flows had no action or subflow calls.
  External integration subscriptions and org-wide notification routes require
  an owner check before writes. The available inventory cannot establish
  whether external systems consume changes made by this fixture.
- `Contact_Authorization__c.Active__c` is a read-only formula. The seed
  supplies a past effective date and blank expiration, then verifies the
  resulting active state. Case and object describe checks cover the running
  user's schema. Stage 2 verified the nine transactions with the approved
  internal operator and owner.

After separate authorization, confirm the assignment, escalation, email,
and integration behavior still matches the reviewed scope. Select a dedicated
active internal owner. Use one manifest and a single operator for the run.

```powershell
.\scripts\seed\seed-employer-portal.ps1 -ExpectedOrgId $env:ALOHA_EXPECTED_ORG_ID -OwnerUsername $env:ALOHA_FIXTURE_OWNER -Apply -AutomationReviewed
```

The script creates an employer foundation first, then each complete Case/ECR
scenario in its own ordered REST Composite transaction. Each request uses
`allOrNone`. Earlier completed blocks remain committed if a later block fails.
Read-back validates ownership, lookups, fixture fields, ECI evidence, and ECR
aggregates after every block. Final validation checks for the expected payroll
group shares on all six ECRs. If sharing calculation is pending, rerun the
read-only validation after it finishes.

## Idempotency, recovery, and rollback preview

The runtime manifest defaults to
`%LOCALAPPDATA%\AlohaWorkforce\employer-portal-v1.manifest.json`. Keep it
outside Git. It binds the fixture file hash, org, owner, and IDs and records a
pending block before sending each write. The manifest maps deterministic
fixture keys to Salesforce record IDs. Existing blocks are recognized by
those IDs, then checked for ownership, relationships, and fixture field
values. The script stops on missing, deleted, untracked, ambiguous, or
unexpectedly changed records. Keep the manifest and its lock at the same
location across runs.

After Stage 2, the three employer Accounts were intentionally renamed to
remove the Fixture prefix. Each Account may have its original seed label or
its approved display name. The name check is specific to that Account's
manifest ID, so swapping employer names still fails validation. Plan and
repeated Apply preserve the Salesforce display names. The fixture JSON
retains the original create labels and stays compatible with the original
manifest hash across LF and CRLF checkouts.

The collision check looks for both Account name forms, deterministic Contact,
Employment, and Case markers, and records related to manifest-owned fixtures.
It also includes matching records in the Recycle Bin. If the manifest is
missing and candidates exist, the tool stops for reconciliation. It never
adopts records by name. Read-only Plan after the renames recognized all 65
records with zero creates. A separate run against an absent manifest stopped
at the existing Accounts.

After the approved apply, run a second read-only Plan. Every object must report
zero proposed creates, and the command must complete successfully.

```powershell
.\scripts\seed\seed-employer-portal.ps1 -ExpectedOrgId $env:ALOHA_EXPECTED_ORG_ID -RequireComplete
```

If the manifest shows a pending block, reconcile its deterministic markers and
relationships against Salesforce and the CLI result before retrying. Clear a
pending entry only after verifying the whole transaction rolled back. If the
transaction committed, review the exact returned or recovered IDs and complete
the manifest under the approved recovery procedure. Preserve earlier entries.

For a separately authorized cleanup, generate the reverse-dependency preview.

```powershell
.\scripts\seed\seed-employer-portal.ps1 -ExpectedOrgId $env:ALOHA_EXPECTED_ORG_ID -RollbackPlan
```

The preview lists manifest-owned IDs only. Before any deletion, check for
later user activity and dependencies outside the fixture, including portal
users, activities, files, cases, and other child records that Salesforce could
cascade or block. Stop for records with unexpected dependencies. Delete only
reviewed IDs in the preview order, verify the fixture and derived sharing rows
are gone, and archive the manifest locally.

When external identities are available, verify same-employer visibility and
cross-employer denial through both lists and direct links. Use a same-employer
Contact without authorization to test the distinction between membership and
permission to submit a change.
