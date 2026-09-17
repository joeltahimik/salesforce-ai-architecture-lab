# Employment Change Processing Architecture

## Purpose and Architecture Boundary

The Aloha Workforce Solutions employment-change subsystem models a workforce change as a traceable business transaction from the original request through Payroll authorization and final implementation.

The central processing model is:

```text
Requested
    |
    v
Payroll Authorized
    |
    v
Implemented
```

These stages are intentionally separate. The value requested by a workforce user is not necessarily the value Payroll authorizes, and the value Payroll authorizes must still be distinguished from what is ultimately implemented.

This separation preserves original business intent, Payroll authority, implementation history, audit attribution, and future integration boundaries.

At the current architecture boundary, request creation and Payroll decision processing are implemented and acceptance-tested. Recording final implementation is the next processing capability.

---

## Transaction Model

Employment changes use three transaction layers:

```text
Service Request (Case)
        |
        | 0..1
        v
Employment Change Request
        |
        | 1..*
        v
Employment Change Item
```

### Service Request

The standard Salesforce `Case` object is presented to users as **Service Request**. It is the business-facing transaction and audit container.

### Employment Change Request

`Employment_Change_Request__c` represents the employment-change package for a Service Request and Employment. The architecture permits at most one Employment Change Request per Service Request.

Multiple changes belonging to the same business transaction are represented as child Employment Change Items rather than separate request headers.

### Employment Change Item

`Employment_Change_Item__c` represents one atomic employment change, such as Job Title, Department, or Work Location.

The Employment Change Item is the **atomic Payroll decision unit**. This is important because changes within the same request can have different Payroll outcomes.

For example:

```text
Employment Change Request
    |
    +-- Job Title       -> Approved
    +-- Department      -> Rejected
    +-- Work Location   -> Modified
```

The parent request can therefore represent a mixed outcome without losing the decision history of any individual change.

---

## Requested -> Payroll Authorized -> Implemented

The subsystem deliberately separates three representations of a change.

### Requested

Requested fields preserve what the requester asked Payroll to change. Examples include:

- `Requested_Value__c`
- `Requested_Effective_Date__c`
- `Requested_Work_Location__c`

These values remain part of the transaction history even if Payroll later modifies the request.

### Payroll Authorized

Payroll authorization represents what Payroll approves as authoritative. Key fields include:

- `Payroll_Decision__c`
- `Payroll_Decision_By__c`
- `Payroll_Decision_Date__c`
- `Payroll_Authorized_Value__c`
- `Payroll_Authorized_Effective_Date__c`
- `Payroll_Authorized_Work_Location__c`
- `Payroll_Rejection_Reason__c`

`Payroll_Decision_By__c` references the Salesforce User who recorded the decision because this field represents the authenticated system actor responsible for the transaction.

### Implemented

Implementation represents what was actually applied. Implementation fields include:

- `Implemented_Value__c`
- `Implemented_Effective_Date__c`
- `Implemented_Work_Location__c`
- `Payroll_Transaction_ID__c`

The implementation stage is intentionally separate from authorization. An approved change is not assumed to have been implemented merely because Payroll authorized it.

---

## Payroll Acknowledgment

`Payroll_Acknowledged_Date__c` records when Payroll begins processing an Employment Change Item. Acknowledgment is separate from the Payroll decision.

```text
Submitted
    |
    | Payroll acknowledges the item
    v
Awaiting Payroll Decision
```

### Why the Payroll Transaction ID Is Not an Acknowledgment Flag

During design exploration, `Payroll_Transaction_ID__c` was considered as a possible indication that Payroll had begun processing an item. The architecture was refined because these facts have different meanings:

```text
Payroll acknowledgment
        !=
External Payroll transaction
```

`Payroll_Acknowledged_Date__c` therefore records acknowledgment independently. `Payroll_Transaction_ID__c` remains reserved for correlation with the external Payroll transaction associated with implementation.

This prevents one field from representing two different business events.

---

## Payroll Decision Architecture

Payroll makes a decision independently for each Employment Change Item.

### Approved

Payroll accepts the request as submitted. The requested value and effective date become the Payroll-authorized values.

### Modified

Payroll authorizes the change but modifies one or more requested values. The original requested values remain unchanged while the Payroll-authorized fields record the authoritative modification.

### Rejected

Payroll does not authorize the requested change. A rejection reason is required and the Employment Change Item becomes terminal.

This design preserves both the original request and Payroll's authoritative decision rather than overwriting request history.

---

## Structured Work Location Pattern

Work Location changes use both a readable snapshot and a structured relationship.

```text
Requested_Value__c
    = "Ala Moana"

Requested_Work_Location__c
    = Work_Location__c record for Ala Moana
```

The same dual-value pattern is used for Payroll authorization and implementation.

> **Generic fields describe the change consistently. Structured fields preserve relationships to authoritative records when those relationships exist.**

Payroll Work Location choices are filtered by the Employment's Employer so that the selected location belongs to the appropriate employer.

---

## Employment Change Item Lifecycle

The normal processing lifecycle is:

```text
Submitted
    |
    | Payroll_Acknowledged_Date__c recorded
    v
Awaiting Payroll Decision
    |
    +-- Rejected --------------------------> Rejected
    |
    +-- Approved / Modified
              |
              v
      Awaiting Implementation
              |
              | Implementation recorded
              v
          Implemented
```

`Employment_Change_Item_Lifecycle` derives lifecycle status from authoritative business facts. Status therefore describes the processing state rather than replacing the facts that caused the transition.

---

## Cancellation Lifecycle

Cancellation has higher lifecycle priority than normal processing.

```text
Cancellation Requested
        |
        | Payroll acknowledges cancellation
        v
Awaiting Cancellation Completion
        |
        | Cancellation completed
        v
Cancelled
```

The architecture distinguishes cancellation requested, Payroll acknowledgment of the cancellation, and actual cancellation completion. This distinction remains valid even when Payroll has already implemented the original change and must reverse it.

---

## Process Employment Change Flow

`Process_Employment_Change` is the Payroll decision Screen Flow. The Flow processes one Employment Change Item at a time and uses Salesforce Auto-Layout.

Its major execution path is:

```text
Get Employment Change Item
        |
        v
Can Process Item?
   /             \
No                Yes
|                  |
v                  v
Refresh        Needs Payroll
Ineligible     Acknowledgment?
Item               |
|                  v
v              Refresh Item
Cannot             |
Process            v
Item          Review Request
                   |
                   v
             Payroll Decision
              /     |      \
       Approved  Modified  Rejected
```

---

## Eligibility Enforcement

Payroll processing is allowed only when:

```text
(
    Item Status = Submitted
    OR
    Item Status = Awaiting Payroll Decision
)
AND
Payroll Decision is blank
```

This rule is enforced inside the Flow. The Employment Change Item Lightning record page also hides the `Process Employment Change` action when the item is no longer eligible.

The architecture therefore uses two layers:

```text
Dynamic Action visibility
        +
Flow business-rule enforcement
```

Dynamic Action visibility improves the user experience. The Flow remains responsible for protecting the business rule if the expected record-page entry point is bypassed.

---

## Dynamic Forms and Dynamic Actions

The Employment Change Item record page uses Dynamic Forms to present fields according to lifecycle state and Change Type.

Examples include:

- Requested Work Location appears only for Work Location changes.
- Payroll Rejection Reason appears for rejected decisions.
- Payroll-authorized fields appear for Approved or Modified decisions.
- Payroll Authorized Work Location appears only when applicable.
- Cancellation information appears only during cancellation lifecycle states.
- Implementation information appears after implementation is completed.

The `Process Employment Change` Dynamic Action is visible only while the item is Submitted or Awaiting Payroll Decision.

A future `Record Implementation` action is intended for the Awaiting Implementation state.

> **Show the action while work is required. Show the resulting information after the work is completed.**

---

## Aloha Workforce Record Page Standard

New custom-object operational record pages should use Dynamic Forms and Dynamic Actions whenever practical.

Page layouts remain the baseline metadata and security presentation layer. Lightning record pages control contextual field presentation and action visibility.

Dynamic visibility is a usability mechanism and is not treated as the sole security or business-rule enforcement layer.

---

## Aloha Workforce Flow Standard

New Flows should use Auto-Layout whenever practical. Every production Flow element should participate in a valid execution path. Obsolete placeholders and disconnected development artifacts should be removed before activation.

The repository includes `scripts/analyze-flow.py` as a structural Flow metadata guardrail.

Current checks include:

- Auto-Layout enabled
- no orphaned Flow elements
- all connector targets exist

A successful Salesforce deployment does not by itself prove that a Flow graph is structurally clean. The analyzer adds a repository-level validation step before a Flow change is committed.

---

## Acceptance-Test Evidence

The Payroll decision architecture was acceptance-tested against the primary decision paths and a direct negative eligibility test.

### Approved Path

ECI-000003 represented a Job Title change. The test demonstrated Payroll acknowledgment, an Approved decision, decision actor and timestamp, requested values copied to Payroll-authorized values, and transition to Awaiting Implementation.

### Rejected Path

ECI-000004 represented a Department change. The test demonstrated Payroll acknowledgment, a Rejected decision, required rejection reason, decision actor and timestamp, and transition to Rejected.

### Modified Work Location Path

ECI-000005 represented a Work Location change.

Requested:

```text
Work Location: Ala Moana
Effective Date: November 1, 2026
```

Payroll authorized:

```text
Work Location: Waikiki
Effective Date: November 15, 2026
```

The test demonstrated that the original request remained intact while Payroll's modified authoritative values were stored independently. The item transitioned to Awaiting Implementation.

### Negative Eligibility Test

After ECI-000005 had already received a Modified decision, the record was passed directly into version 7 of `Process_Employment_Change` using Flow Debug.

At test time:

```text
Item Status      = Awaiting Implementation
Payroll Decision = Modified
```

The Flow evaluated the processing eligibility rule as false and routed the record to the terminal Cannot Process Item screen. The screen displayed:

```text
Current Status: Awaiting Implementation
```

This demonstrated that the processing rule remains enforced even when normal Dynamic Action visibility is bypassed.

---

## Service Request Classification Decision

The architecture currently uses standard `Case.Type` to classify Service Requests. `Employment Change` is an available Case Type.

A Case Record Type was intentionally not introduced because the current Service Request categories do not yet require materially different fields, statuses, processes, or page experiences.

```text
Type
    = What kind of Service Request is this?

Record Type
    = Does this kind require a different Salesforce
      process or user experience?
```

Record Types can be introduced later if Service Request categories diverge enough to justify the additional complexity.

---

## Engineering Practice: Salesforce Metadata and Git

Salesforce metadata retrieval is treated as a discovery and synchronization operation, not automatic authorization to commit every retrieved file.

A broad metadata retrieve can return substantially more metadata than the architectural change actually requires.

The repository therefore follows this workflow:

1. Inspect the working tree with `git status --short`.
2. Run `git diff --check` and inspect the diff scope.
3. Inspect suspicious tracked changes individually.
4. Restore unintended retrieved changes.
5. Preview untracked cleanup before deleting files.
6. Explicitly preserve intentional metadata.
7. Remove only confirmed retrieval artifacts.
8. Reinspect the working tree.
9. Stage files according to architectural intent.
10. Inspect the staged diff before committing.

> **Retrieve broadly when discovery requires it. Inspect carefully. Commit narrowly according to architectural intent.**

This practice keeps source control focused on deliberate architecture rather than incidental metadata returned by Salesforce.

---

## Current Architecture Boundary

At this milestone:

```text
Requested                 COMPLETE
    |
Payroll Acknowledgment    COMPLETE
    |
Payroll Decision          COMPLETE
    |
Payroll Authorized        COMPLETE
    |
Record Implementation     NEXT
    |
Implemented
```

The next processing capability is **Record Implementation**.

That capability is intended to capture:

- implemented value,
- implemented effective date,
- implemented Work Location when applicable,
- and the Payroll transaction identifier.

Once implementation facts are recorded, lifecycle automation can derive the final Implemented state.
