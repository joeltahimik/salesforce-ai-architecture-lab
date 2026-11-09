# Aloha Workforce AI Assistant | Security Baseline

**Verified:** 2026-11-08  
**Environment:** Personal Salesforce Developer Edition  
**Org alias:** `aloha-dev`  
**Repository:** `joeltahimik/salesforce-ai-architecture-lab`

## 1. Agentforce Configuration

- Agent: Aloha Workforce AI Assistant
- Version: 1 (Draft)
- Deployment target: Salesforce Lightning
- Intended audience: Internal HR and Payroll staff
- Execution user ID: `005ak00000nN7W1AAK`
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

Permission Set ID:

`0PSak00000hBkunGAC`

Permission Set Assignment ID:

`0Paak00001DozwLCAR`

The permission set was successfully deployed to `aloha-dev`.

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

Group ID:

`00Gak00000mAX7dEAG`

The existing ECR sharing rule grants Edit-level record sharing
to this group.

Actual effective permissions remain constrained by object
permissions and other Salesforce security controls.

## 4. Payroll Processor Test User

User: Payroll Processor

User ID:

`005ak00000iuxHtAAI`

Profile: Aloha Workforce Platform User

Role: None

Active: Yes

Permission set:

`Aloha_Workforce_Payroll`

Permission Set ID:

`0PSak00000cj5FPGAY`

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
- ID: `a06ak00000hWVb0AAG`
- Owner: Joel Tahimik
- Owner ID: `005ak00000iGwY9AAK`
- Processing Status: Completed
- Outcome Summary: Successful

Child Employment Change Item:

- Name: ECI-000007
- ID: `a05ak00000mv2PdAAI`

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

## 7. Open Security and Implementation Questions

- Determine how authenticated Lightning user identity is
  propagated to the Agentforce action.
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
