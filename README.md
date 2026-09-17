# Salesforce AI Architecture Lab

A portfolio architecture lab for designing and building an enterprise-style Salesforce platform from the CRM foundation through Data 360, Agentforce, retrieval-augmented generation (RAG), integrations, and headless experiences.

The project uses a fictional organization, **Aloha Workforce Solutions**, to explore how Salesforce architecture can evolve from operational workflows into a broader AI-enabled enterprise platform.

> **Current phase:** Salesforce CRM foundation and employment-change operations.

## Project Goals

This lab is designed to demonstrate more than individual Salesforce features. It focuses on architectural decisions, data relationships, automation boundaries, security, maintainability, and the reasoning behind implementation choices.

The long-term architecture will explore:

- Salesforce CRM and custom application architecture
- Flow and Apex automation
- Data 360
- Agentforce
- Retrieval-augmented generation (RAG)
- AWS integrations
- Zero-copy data access
- Headless Salesforce experiences
- APIs and integration patterns
- Model Context Protocol (MCP)
- AI-assisted operational workflows

Features listed above are part of the roadmap unless identified as implemented below.

## Aloha Workforce Solutions

Aloha Workforce Solutions is the fictional business environment used throughout the lab.

The current application, **Aloha Workforce Operations**, provides a centralized Salesforce workspace for managing:

- Service Requests
- Employments
- Employment Change Requests
- Employment Change Items
- Work Locations
- Accounts and Contacts
- Operational reporting

The standard Salesforce `Case` object is presented to business users as **Service Request** while retaining the standard Case data model and platform behavior.

## Current CRM Architecture

The employment-change architecture separates the business transaction from the individual changes being processed.

    Service Request (Case)
            |
            | 0..1
            v
    Employment Change Request
            |
            | 1..*
            v
    Employment Change Item

An affected Employment is associated with the Service Request through `Case_Employment__c`.

### Core Objects

| Object | Purpose |
| --- | --- |
| `Case` | Business-facing Service Request and audit container |
| `Employment__c` | Represents an employee's employment relationship with an employer |
| `Case_Employment__c` | Associates affected Employment records with a Service Request |
| `Employment_Change_Request__c` | Represents the employment-change package for a Service Request and Employment |
| `Employment_Change_Item__c` | Represents one atomic requested employment change |
| `Work_Location__c` | Represents an employer's structured work locations |

## Employment Change Design

A Service Request can have at most **one Employment Change Request**.

The Employment Change Request acts as the package or transaction header. Individual changes are stored as Employment Change Items.

For example:

    Service Request
    └── Employment Change Request
        ├── Job Title → Senior Guest Services Manager
        ├── Department → People Operations
        └── Work Location → Ala Moana

This avoids creating multiple request headers for changes that belong to the same business transaction while allowing each change to maintain its own lifecycle and outcome.

Within one Employment Change Request, each **Change Type may appear only once** in the guided request experience.

## Request Employment Change Flow

The `Request_Employment_Change` Screen Flow provides the guided experience for creating an employment-change package.

Current workflow:

    Service Request
        ↓
    Identify Affected Employment
        ↓
    Select Change Type
        ↓
    Enter Requested Change
        ↓
    Add Another Change?
        ├── Yes → Add another Employment Change Item
        └── No
             ↓
        Review Change Package
             ↓
        Submit
             ↓
    Create one Employment Change Request
             ↓
    Bulk create Employment Change Items
             ↓
        Request Submitted

The flow supports both generic requested values and structured business relationships.

### Structured Work Location Pattern

Work Location demonstrates a deliberate dual-value design.

For a Work Location change, the Employment Change Item stores:

- `Requested_Value__c` as a human-readable snapshot, such as `Ala Moana`
- `Requested_Work_Location__c` as the relationship to the authoritative `Work_Location__c` record

This allows the change record to remain understandable in history and reporting while preserving a structured relationship to authoritative business data.

## Employment Change Lifecycle

Employment Change Items support the following lifecycle:

    Draft
      ↓
    Submitted
      ↓
    Awaiting Payroll Decision
      ↓
    Awaiting Implementation
      ↓
    Implemented

Alternative outcomes include `Rejected` and a separate cancellation path.

Cancellation processing distinguishes between requesting cancellation, Payroll acknowledging the request, and the cancellation actually being completed:

    Cancellation Requested
            ↓
    Awaiting Cancellation Completion
            ↓
    Cancelled

The parent Employment Change Request aggregates the state of its child items and derives its processing status and outcome.

### Payroll Processing Architecture

Post-submission processing separates three distinct business facts:

**Requested -> Payroll Authorized -> Implemented**

The original request is preserved, Payroll records an authoritative decision for each Employment Change Item, and final implementation is tracked separately.

Payroll can **Approve**, **Modify**, or **Reject** an individual change. This allows one Employment Change Request to contain multiple items with independent outcomes while preserving the original requested values.

Detailed design decisions, lifecycle rules, Flow architecture, acceptance-test evidence, and engineering practices are documented in [Employment Change Processing Architecture](docs/employment-change-processing.md).

## Implemented Features

The CRM foundation currently includes:

- Aloha Workforce Operations Lightning application
- Service Request business experience using standard Case
- Employment and Work Location data model
- Service Request-to-Employment association
- Employment Change Request and Employment Change Item architecture
- One-Employment-Change-Request-per-Service-Request enforcement
- Guided Request Employment Change Screen Flow
- Multi-item employment-change packages
- Duplicate Change Type prevention in the guided request flow
- Employer-filtered Work Location selection
- Review-before-submit experience
- Bulk Employment Change Item creation
- Employment Change Item lifecycle automation
- Employment Change Request status/outcome aggregation
- Payroll acknowledgment tracking
- Per-item Payroll decision processing with Approved, Modified, and Rejected outcomes
- Requested-versus-Payroll-authorized value preservation
- Payroll decision actor and timestamp auditing
- Structured Payroll-authorized Work Location handling
- Flow-level Payroll processing eligibility enforcement
- Employment-change cancellation workflow
- Dynamic Forms and Dynamic Actions for contextual processing experiences
- Lightning record-page and page-layout customization
- Permission-set-based access to custom functionality
- Repository-level structural Flow analysis

## Architecture Principles

Several principles guide the project:

**Business transaction first**

The Service Request remains the audit and business transaction container.

**Atomic changes**

Each Employment Change Item represents one independently processable change.

**Facts before derived status**

Lifecycle statuses are derived from authoritative processing facts where appropriate rather than duplicating state unnecessarily.

**Structured data when authoritative records exist**

Generic fields provide consistent change history, while lookup fields preserve relationships to authoritative business records.

**Bulk-safe automation**

Record collections are prepared before DML rather than performing database operations inside loops.

**Defense in depth**

The guided user experience prevents common mistakes, while important business invariants can also be enforced at the data or automation layer.

**Portfolio architecture, not feature accumulation**

New Salesforce and AI capabilities are added only when they have a defined responsibility in the overall architecture.

## Technology

Current development environment:

- Salesforce Platform
- Salesforce CLI (`sf`)
- Salesforce Flow
- Lightning App Builder
- Salesforce metadata
- Git
- GitHub
- GitHub Codespaces
- VS Code

Future phases will introduce additional technologies as the architecture evolves.

## Roadmap

### Phase 1: CRM Foundation

**In progress**

Build the operational Salesforce data model, employment-change lifecycle, user experience, security model, automation, and processing workflows.

### Phase 2: Data 360

**Planned**

Introduce enterprise data architecture, identity/data modeling, ingestion patterns, and zero-copy concepts.

### Phase 3: Agentforce

**Planned**

Add AI-assisted operational experiences with clearly defined actions, permissions, grounding, and human oversight.

### Phase 4: RAG and External AI Architecture

**Planned**

Explore retrieval-augmented generation, AWS services, external knowledge, and integration patterns.

### Phase 5: Headless and MCP Architecture

**Planned**

Explore API-first experiences, headless Salesforce patterns, and Model Context Protocol integrations.

## Repository and Security

This repository contains source-controlled Salesforce metadata and project documentation.

Authentication files, credentials, tokens, environment secrets, and local Salesforce CLI state are intentionally excluded from source control.

Temporary CLI and diagnostic output is also excluded from the repository.

## Project Status

The **Request Employment Change v1** workflow has completed end-to-end acceptance testing, including a multi-item request containing both a standard field change and a structured Work Location change.

Post-submission **Payroll decision processing** has also completed acceptance testing across Approved, Modified, Rejected, and ineligible-record paths.

**Record Implementation** has completed acceptance testing for both generic field changes and structured Work Location changes. Implementation is recorded independently from Payroll authorization and requires the actual implemented value, implemented effective date, and external Payroll transaction identifier. Structured Work Location changes additionally preserve the implemented Work Location relationship.

The employment-change processing architecture now supports the complete auditable progression from **Requested → Payroll Authorized → Implemented**.
