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

## Validation and access boundaries

The post-rename validation recognized the same 65 records and proposed zero
creates. Account display names can change while record identity and ownership
stay stable. Duplicate or ambiguous matches stop validation.

Payroll Processor had Read Only on all six ECRs and Read/Edit on all eleven
ECIs through the existing payroll sharing design. Payroll Processor has
object-level Read on Employment. Record-level access to the fifteen fixture
Employments remained denied. Permanent Employment sharing remains future work
under Option A.

When external identities are available, verify same-employer visibility and
cross-employer denial through both lists and direct links. Use a same-employer
Contact without authorization to test the distinction between membership and
permission to submit a change.
