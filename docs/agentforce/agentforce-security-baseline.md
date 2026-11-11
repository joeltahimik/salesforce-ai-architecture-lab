# Aloha Workforce AI Assistant | Security Baseline

**Initial verification:** 2026-11-08

**Environment:** Personal Salesforce Developer Edition  
**Org alias:** `aloha-dev`  
**Repository:** `joeltahimik/salesforce-ai-architecture-lab`

## 1. Agentforce Configuration

This section records the initial configuration. The
[development checkpoint](../development-checkpoint.md) tracks later agent
status and pilot milestones.

- Agent: Aloha Workforce AI Assistant
- Version: 1 (Draft)
- Deployment target: Salesforce Lightning
- Intended audience: Internal HR and Payroll staff
- Execution user: dedicated Einstein Agent User
- Agent status: Not activated
- Retrieval actions: Not implemented

Planned actions:
- `GetEmploymentChangeRequest`
- `GetEmploymentChangeItems`

The Agentforce Builder currently contains an Agent Router,
Escalation, Off Topic, and Ambiguous Question subagents.

Employment Change Inquiry remains to be completed.

## 2. Agent Execution User Permissions

Dedicated permission set:

`Aloha_Workforce_AI_Read_Only`

The permission set was successfully deployed to `aloha-dev` and assigned to
the dedicated Einstein Agent User.

### Object Permissions

| Object | Read | Create | Edit | Delete | View All | Modify All |
|---|---|---|---|---|---|---|
| Employment_Change_Request__c | Yes | No | No | No | No | No |
| Employment_Change_Item__c | Yes | No | No | No | No | No |

### Field Permissions

Fourteen explicit ECI field permissions were verified.

All fourteen have:

- PermissionsRead = true
- PermissionsEdit = false

Some fields are not individually permissionable and therefore
do not have explicit FieldPermissions entries.

No conflicting ECR/ECI object or field permissions were found
in the queried permission sources.

View All Data and Modify All Data were false for the five
permission sources returned by the security query.

These findings do not replace runtime authorization testing.

## 3. Record Sharing Architecture

| Object | Internal Sharing | External Sharing |
|---|---|---|
| Employment_Change_Request__c | Private | Private |
| Employment_Change_Item__c | ControlledByParent | ControlledByParent |

ECI record-level access is inherited from its parent ECR.

### Payroll Public Group

Name: Aloha Workforce Payroll Processors

Developer Name:

`Aloha_Workforce_Payroll_Processors`

The existing ECR sharing rule grants Edit-level record sharing
to this group.

Actual effective permissions remain constrained by object
permissions and other Salesforce security controls.

## 4. Payroll Processor Test User

User: Payroll Processor

Profile: Aloha Workforce Platform User

Role: None

Active: Yes

Permission set:

`Aloha_Workforce_Payroll`

Verified object permissions:

| Object | Read | Edit |
|---|---|---|
| Employment_Change_Request__c | Yes | No |
| Employment_Change_Item__c | Yes | Yes |

Payroll Processor is a direct member of the Payroll Processors
public group.

## 5. Verified Test Records

Parent Employment Change Request:

- Name: ECR-000004
- Owner: test administrator
- Processing Status: Completed
- Outcome Summary: Successful

Child Employment Change Item:

- Name: ECI-000007

### UserRecordAccess Results

| User | Record | Read | Edit | Delete |
|---|---|---|---|---|
| Agentforce execution user | ECR-000004 | No | No | No |
| Agentforce execution user | ECI-000007 | No | No | No |
| Payroll Processor | ECR-000004 | Yes | No | No |

Payroll Processor's ECR access is consistent with its direct
public-group membership and the existing ECR sharing rule.

## 6. Authorization Requirements

The assistant must:

1. Serve authenticated internal HR and Payroll users.
2. Obtain requesting-user identity from a trusted context.
3. Verify that the requesting user is eligible to use the action.
4. Verify access to the specific requested ECR.
5. Return only authorized information.
6. Never accept a chat-supplied user ID as proof of identity.
7. Never create, edit, approve, implement, or cancel records.

Important:

The Agentforce execution user and the requesting employee may
be different Salesforce users.

A Flow running in the agent's execution context does not
automatically enforce the requesting employee's record access.

### Stage 3B Apex Execution Identity

On November 9, 2026, one diagnostic invocation from the directly authenticated
Payroll Processor session in Lightning Experience passed. The temporary
`Aloha_Workforce_Identity_Pilot` V1 invoked `AlohaAgentIdentityProbe`. Its
restricted Apex log contained the expected WARN marker, and the principal
reported by `UserInfo.getUserId()` matched both the authenticated Payroll
Processor and the Apex log's `LogUserId`. The agent returned only a completion
message. The [Stage 3B checkpoint](../development-checkpoint.md#execution-identity-pilot-runtime-verification--2026-11-09)
records the invocation time, diagnostic marker, and verified rollback.

This finding applies to the tested Employee Agent, Apex action, and Lightning
session. The probe performs no database operations. CRUD, field-level security,
and record-level access still require explicit enforcement and separate tests.
Before enabling retrieval, verify trusted requester identity and test allowed
and denied record and field access with representative users. Other actions
and channels, including Flow and the separate Service Agent, require their
own execution-context verification. ECR and ECI retrieval and modification
remain disabled.

### Stage 3C and 3D Platform Profile Baseline

The shared Aloha Workforce Platform User profile provides the base access for
Payroll Processor and Aloha StandardTester. Salesforce API verification showed
that Stage 3C disabled Setup, audit history, role hierarchy, and license
utilization permissions. Stage 3D disabled Email Administration and Manage
Email Templates. All six flags were false for both personas after the changes.

Payroll Processor retained the dedicated payroll and app-access assignments,
Work Locations visibility, and access to the sampled ECR and ECI records.
Aloha StandardTester remained excluded from those samples. Profile assignments,
sharing, and Agentforce configuration were unchanged. Direct-login checks are
pending. See the [platform profile checkpoint](../development-checkpoint.md#platform-user-least-privilege-hardening)
for the test scope, backup status, and follow-up checks.

### Employment Record Access

`Employment__c` has Private internal and external defaults. The submitted ECR
sharing rule grants access to qualifying ECRs, and ECIs inherit access from
their parent ECR. The Employment lookup on the ECR does not grant record access
to Employment. Payroll Processor has object-level Read and requires an
Employment record share or other applicable record-level grant.

Option A is the agreed design. Payroll Processor may read authorized
Employment records, and employment changes must go through ECR/ECI. A
temporary Read Only manual share passed the Lightning test and was removed.
Permanent Employment sharing remains future design work. See the
[Employment record access test](../development-checkpoint.md#employment-record-access-test)
for the interactive checks and cleanup verification.

## 7. Open Security and Implementation Questions

- Verify trusted requester identity for each proposed retrieval action and
  channel before enabling it.
- Verify actual Flow execution context.
- Design secure record retrieval without blanket sharing.
- Implement and test GetEmploymentChangeRequest.
- Implement and test GetEmploymentChangeItems.
- Validate authorized and unauthorized user scenarios.
- Complete Employment Change Inquiry subagent.
- Review Agent Optimizer output.
- Activate only after successful functional and security tests.

## 8. Documentation Policy

This document records verified historical findings.

Salesforce org configuration and record access can change.

Consult this baseline before repeating discovery queries,
but perform fresh verification when deploying, changing
security, or validating runtime authorization.

Do not commit credentials, access tokens, or sensitive
employee data to this public repository.
