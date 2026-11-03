# Aloha Workforce Solutions | Development Checkpoint

**Last checkpoint review:** 2026-11-03

**Start here:** [Architecture Refresher](architecture-refresher.md)

## Current Project State

**Active sprint:** Payroll Processor Persona and Least-Privilege Security

**Last confirmed Git checkpoint:** `5c323cd`

**Commit message:**
WIP: Build payroll persona security and request integrity controls

**Development environment:**
GitHub Codespaces, repository `joeltahimik/salesforce-ai-architecture-lab`,
branch `main`.

**Salesforce org alias:** `aloha-dev`

**Last confirmed connection:** Connected, org ID `00Dak00001EqrL3EAJ`.

The Codespace was reactivated and automatic deletion was disabled.
Reconfirm its current state when resuming after a long absence.

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

## Outstanding Test Data Issue

**Record:** ECI-000002

**Current test value last observed:**
`SECURITY TEST - SHOULD NOT SAVE`

**Original intended value:** `People Operations`

The active validation rule prevents ordinary updates to submitted
request facts, including restoring the original value.

**Next action:** Inspect the record and active rule, design a
temporary controlled administrative correction, restore the value,
and verify the validation rule remains active.

Do not introduce a permanent unrestricted bypass merely for cleanup.

## Remaining Security Work

- Restore ECI-000002 test data.
- Regression-test legitimate request and lifecycle automation.
- Test permitted Payroll decisions and implementation actions.
- Investigate direct editing of process-controlled lifecycle fields.
- Verify Flow execution access and runtime permissions.
- Refine Payroll app and tab visibility.
- Review and harden inherited Platform profile permissions.
- Document final security matrix and acceptance evidence.
- Commit the completed security sprint.

## Resume Procedure

1. Open the existing GitHub Codespace.
2. Confirm branch and working tree with `git status --short`.
3. Confirm the Salesforce connection with `sf org display --target-org aloha-dev`.
4. Read this checkpoint and `docs/architecture-refresher.md`.
5. Inspect the relevant Salesforce records before changing anything.
6. Work in small, testable steps and commit meaningful checkpoints.

## Future Roadmap

After the Payroll security sprint:

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
