# Aloha Workforce Solutions | Architecture Refresher

**Purpose:** A permanent learning guide for understanding the architecture,
business processes, security design, and key technical decisions.

**Last reviewed:** 2026-11-03

## 1. Business Context

Aloha Workforce Solutions is a Salesforce portfolio application for
coordinating employer workforce service requests and employment changes.

Salesforce manages requests, approvals, processing visibility, and audit
history. Payroll remains authoritative for payroll execution.

The project is designed to demonstrate Salesforce application architecture,
automation, data modeling, security, integration readiness, and eventually
AI-assisted operations.

## 2. Core Data Architecture

```text
Service Request (Case)
    |
    | Maximum one ECR per Service Request
    v
Employment Change Request (ECR)
    |
    | One or many ECIs
    v
Employment Change Item (ECI)
    |-- Job Title
    |-- Department
    |-- Work Location
    |-- Other supported changes
```

### Supporting Objects

- `Employment__c`: Connects an employee (Contact) to an employer (Account).
- `Work_Location__c`: Employer-specific work locations.
- `Case_Employment__c`: Associates affected employments with a Service Request.
- `Employment_Change_Request__c`: The package of changes for one employment.
- `Employment_Change_Item__c`: An individual, independently processed change.

### Why separate ECR and ECI?

A single request may contain multiple changes with different outcomes.
Payroll might approve a job title change, modify a work location change,
and reject a department change.

The ECR provides transaction-level coordination.
Each ECI provides atomic processing and auditability.

## 3. Three-Stage Processing Architecture

```text
REQUESTED
    |
    | Payroll reviews and decides
    v
PAYROLL AUTHORIZED
    |
    | External Payroll processing occurs
    v
IMPLEMENTED
```

**Core principle: Authorization describes what should happen.
Implementation records what actually happened.**

Requested values preserve the employer's original instructions.

Payroll-authorized values preserve what Payroll approved or modified.

Implemented values preserve what actually occurred, supported by an
effective date and Payroll transaction identifier.

Approval alone must never be treated as implementation.

### Payroll Decisions

- Approved: Payroll authorizes the requested change.
- Modified: Payroll authorizes different values.
- Rejected: Payroll declines the change.

Approved or Modified items await implementation until implementation
evidence is recorded.

## 4. Parent Request Aggregation

The ECR remains **In Progress** while any ECI is nonterminal.

Terminal ECI statuses:

- Implemented
- Rejected
- Cancelled

Once every ECI is terminal, the parent ECR becomes Completed and its
outcome summary reflects Successful, Rejected, Cancelled, or Mixed Outcome.

**Principle: A parent request is complete only when every child change
has reached a final outcome.**

## 5. Cancellation Architecture

Cancellation is tracked as a business process, not an instantaneous event.

```text
Cancellation Requested
    |
    v
Awaiting Cancellation Completion
    |
    v
Cancelled
```

A Payroll acknowledgment is not equivalent to completed cancellation.

If the original transaction was already processed, Payroll may need to
reverse it. The cancellation audit trail must distinguish the request,
acknowledgment, and actual completion.

## 6. Security Architecture

The Payroll Processor persona uses:

1. Salesforce Platform license.
2. Custom Aloha Workforce Platform User profile.
3. Aloha Workforce Payroll permission set.
4. Payroll Processors public group.
5. Criteria-based sharing of submitted ECRs.
6. Field-level security and save-time validation rules.

### Record Access

`Payroll_Submitted_Date__c` is a durable handoff fact populated by the
Request Employment Change Flow.

When populated, the criteria-based sharing rule grants record access to
the Payroll Processors public group.

ECI record access is inherited from the parent ECR through master-detail.

Payroll has read access to ECR and read/edit access to ECI, subject to
field-level permissions and other enforcement.

### Request Integrity

The validation rule `Lock_Requested_Values_After_Submission` prevents
changes to these original request facts after submission:

- Change Type
- Requested Value
- Requested Effective Date
- Requested Work Location

This protection was tested successfully after discovering that the
Payroll Processor could otherwise change Requested Value.

The security sprint remains incomplete. Lifecycle-field protection,
Flow access, profile hardening, and regression tests require further work.

## 7. Knowledge Checks

### Question 1: Authorization versus Implementation

An employer requests a job title change from Sales Associate to Sales
Manager. Payroll approves it, but the external payroll system has not
processed it.

What should the ECI status be?

A. Implemented
B. Awaiting Implementation
C. Completed
D. Submitted

**Answer: B — Awaiting Implementation.**

Payroll approval is authorization, not evidence of execution.

### Question 2: Parent Aggregation

Three ECIs belong to one ECR. Two are Implemented, but the third is
Awaiting Implementation.

Should the parent ECR be Completed?

**Answer: No. It remains In Progress.**

The parent completes only after all child items are terminal.

### Question 3: Mixed Outcomes

One ECI is Implemented, one is Rejected, and one is Cancelled.

What should happen to the parent?

**Answer:** The ECR becomes Completed with a Mixed Outcome because
all three child items have reached terminal statuses.

### Question 4: Security

A Payroll Processor can see an ECI and its Requested Value field.
Should Payroll be allowed to modify that value after submission?

**Answer:** No. The original request must remain auditable.
Save-time enforcement protects the original facts.

## 8. Development Principles

- Build enterprise-style solutions with explicit business boundaries.
- Store authoritative facts; derive lifecycle states from those facts.
- Separate authorization from implementation.
- Prefer Auto-Layout for new Salesforce Flows.
- Prefer Dynamic Forms and Dynamic Actions for operational pages.
- Retrieve broadly when necessary; inspect carefully; commit narrowly.
- Validate deployment, license compatibility, and runtime access separately.
- Use GitHub as the permanent source of truth.
- Document architectural decisions and acceptance tests.

## 9. Related Documentation

- [Project README](../README.md)
- [Employment Change Processing](employment-change-processing.md)
- [Development Checkpoint](development-checkpoint.md)

This guide should be updated when architectural decisions change.
