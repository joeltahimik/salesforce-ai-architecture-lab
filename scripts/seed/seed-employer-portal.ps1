#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^00D[A-Za-z0-9]{15}$')]
    [string] $ExpectedOrgId,
    [switch] $Apply,
    [switch] $AutomationReviewed,
    [switch] $RequireComplete,
    [switch] $RollbackPlan,
    [string] $OwnerUsername,
    [string] $ManifestPath = (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'AlohaWorkforce\employer-portal-v1.manifest.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if ($Apply -and ($RollbackPlan -or $RequireComplete -or !$AutomationReviewed -or !$OwnerUsername)) {
    throw 'Apply requires -OwnerUsername and -AutomationReviewed. Run validation and rollback preview separately.'
}
$fixtureFile = Join-Path $PSScriptRoot 'employer-portal-v1.json'
$fixtureJson = Get-Content -Raw -LiteralPath $fixtureFile -Encoding UTF8
$fixture = $fixtureJson | ConvertFrom-Json
# Hash LF text so Windows Git checkouts preserve compatibility with the original manifest.
$fixtureBytes = [Text.Encoding]::UTF8.GetBytes(($fixtureJson -replace '\r\n', [string][char]10))
$fixtureStream = [IO.MemoryStream]::new($fixtureBytes)
try { $hash = (Get-FileHash -InputStream $fixtureStream -Algorithm SHA256).Hash }
finally { $fixtureStream.Dispose() }
$api = "/services/data/v$($fixture.apiVersion)"
$manifestPath = [IO.Path]::GetFullPath($ManifestPath)
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..')).TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
if ($manifestPath.StartsWith($repo, [StringComparison]::OrdinalIgnoreCase)) { throw 'Keep the manifest outside the repository.' }

function Invoke-SfJson([string[]] $Arguments, [string] $Body) {
    if ($PSBoundParameters.ContainsKey('Body')) { $output = $Body | & sf @Arguments }
    else { $output = & sf @Arguments }
    if ($LASTEXITCODE -ne 0) { throw "Salesforce CLI failed for $($Arguments[0..2] -join ' ')." }
    $output -join [Environment]::NewLine | ConvertFrom-Json
}

function Read-Soql([string] $Query, [switch] $Tooling, [switch] $AllRows) {
    $arguments = @('data','query','-o',$fixture.orgAlias,'--api-version',$fixture.apiVersion,'--json','-q',$Query)
    if ($Tooling) { $arguments += '--use-tooling-api' }
    if ($AllRows) { $arguments += '--all-rows' }
    $result = (Invoke-SfJson $arguments).result
    if (!$result.done -or @($result.records).Count -ne $result.totalSize) { throw 'Incomplete query results.' }
    $result.records
}

function Quote-Soql([string] $Value) { "'" + $Value.Replace('\','\\').Replace("'","\'") + "'" }
function Ref([string] $Key) { "@{$Key.id}" }

function New-Block([string] $Name) {
    [pscustomobject]@{
        Name = $Name
        Operations = [Collections.Generic.List[object]]::new()
        Records = [Collections.Generic.List[object]]::new()
    }
}

function Add-Record($Block, [string] $Key, [string] $Object, [hashtable] $Fields) {
    $record = [pscustomobject]@{ Key = $Key; Object = $Object; Expected = $Fields.Clone() }
    $Block.Records.Add($record)
    $Block.Operations.Add([pscustomobject]@{ Key = $Key; Object = $Object; Method = 'POST'; Fields = $Fields; Target = '' })
    $record
}

function Add-Transition($Block, $Record, [string] $Step, [hashtable] $Fields) {
    $Block.Operations.Add([pscustomobject]@{
        Key = "$($Record.Key)_$Step"; Object = $Record.Object; Method = 'PATCH'; Fields = $Fields; Target = (Ref $Record.Key)
    })
    foreach ($field in $Fields.Keys) { $Record.Expected[$field] = $Fields[$field] }
}

function New-SeedPlan {
    $time = $fixture.timeline
    foreach ($employer in $fixture.employers) {
        $code = $employer.code
        $prefix = "$($fixture.dataset)-$code"
        $account = "$($code)_account"
        $representative = "$($code)_contact1"
        $base = New-Block "$($code)_foundation"
        $accountRecord = Add-Record $base $account Account @{ Name = $employer.name; OwnerId = '__OWNER__' }
        # All currently active Case escalation entries require a nonblank Account SLA.
        $accountRecord.Expected.SLA__c = $null
        $accountRecord.Expected.BillingCountry = $null
        foreach ($person in $employer.people) {
            $n = $person.number
            $contact = "$($code)_contact$n"
            $null = Add-Record $base $contact Contact @{
                FirstName = $person.firstName; LastName = $person.lastName; Email = "$prefix-$n@example.invalid".ToLowerInvariant()
                AccountId = (Ref $account); OwnerId = '__OWNER__'
            }
            $fields = @{
                Employee__c = (Ref $contact); Employer__c = (Ref $account); OwnerId = '__OWNER__'
                Employment_Status__c = $person.status; Employee_Number__c = "$prefix-$n"
                Job_Title__c = $person.jobTitle; Hire_Date__c = $person.hireDate; Termination_Date__c = $null
            }
            if ($person.PSObject.Properties['terminationDate']) { $fields.Termination_Date__c = $person.terminationDate }
            $null = Add-Record $base "$($code)_employment$n" Employment__c $fields
        }
        $authorization = Add-Record $base "$($code)_authorization" Contact_Authorization__c @{
            Account__c = (Ref $account); Contact__c = (Ref $representative); Authorization_Type__c = 'Employee Changes'
            Effective_Date__c = '2026-01-01'; Expiration_Date__c = $null; OwnerId = '__OWNER__'
        }
        $authorization.Expected.Active__c = $true
        $base

        foreach ($request in $employer.requests) {
            $key = "$($code)_request$($request.number)"
            $block = New-Block $key
            $employment = Ref "$($code)_employment$($request.employee)"
            $case = "$($key)_case"
            $caseStatus = if ($request.status -eq 'Completed') { 'Closed' } else { 'Working' }
            $null = Add-Record $block $case Case @{
                Subject = "$prefix-R$($request.number) Employment Change"; AccountId = (Ref $account)
                ContactId = (Ref $representative); Type = 'Employment Change'; Origin = 'Web'; Status = $caseStatus
                Priority = 'Medium'; OwnerId = '__OWNER__'
            }
            $null = Add-Record $block "$($key)_junction" Case_Employment__c @{
                Case__c = (Ref $case); Employment__c = $employment; Status__c = 'Confirmed Affected'
            }
            $ecr = Add-Record $block "$($key)_ecr" Employment_Change_Request__c @{
                Case__c = (Ref $case); Employment__c = $employment; OwnerId = '__OWNER__'
                Processing_Status__c = 'Draft'; Outcome_Summary__c = 'Pending'; Payroll_Submitted_Date__c = $time.submitted
            }
            $ecr.Expected.Processing_Status__c = $request.status
            $ecr.Expected.Outcome_Summary__c = $request.outcome
            $ecr.Expected.Payroll_Request_ID__c = $null
            $items = @()
            foreach ($item in $request.items) {
                $items += Add-Record $block "$($key)_item$($items.Count + 1)" Employment_Change_Item__c @{
                    Employment_Change_Request__c = (Ref $ecr.Key); Item_Status__c = 'Submitted'
                    Change_Type__c = $item.type; Requested_Value__c = $item.value; Requested_Effective_Date__c = $time.effective
                }
            }
            for ($i = 0; $i -lt $items.Count; $i++) {
                $item = $request.items[$i]
                $record = $items[$i]
                switch ($item.target) {
                    'Submitted' {}
                    'Cancelled' {
                        Add-Transition $block $record cancel @{ Cancellation_Requested_Date__c = $time.cancellationRequested; Cancellation_Reason__c = 'Fixture request withdrawn before payroll processing.' }
                        Add-Transition $block $record cancelAck @{ Payroll_Cancellation_Acknowledged_Date__c = $time.cancellationAcknowledged }
                        Add-Transition $block $record cancelDone @{ Cancellation_Completed_Date__c = $time.cancellationCompleted }
                    }
                    { $_ -in 'Awaiting Implementation','Implemented','Rejected' } {
                        Add-Transition $block $record ack @{ Payroll_Acknowledged_Date__c = $time.acknowledged }
                        $decision = @{ Payroll_Decision_Date__c = $time.decided; Payroll_Decision_By__c = '__OWNER__' }
                        if ($item.target -eq 'Rejected') {
                            $decision.Payroll_Decision__c = 'Rejected'
                            $decision.Payroll_Rejection_Reason__c = 'Fixture change was outside the approved staffing plan.'
                        } else {
                            $decision.Payroll_Decision__c = 'Approved'
                            $decision.Payroll_Authorized_Value__c = $item.value
                            $decision.Payroll_Authorized_Effective_Date__c = $time.effective
                        }
                        Add-Transition $block $record decision $decision
                        if ($item.target -eq 'Implemented') {
                            Add-Transition $block $record implement @{
                                Implemented_Value__c = $item.value; Implemented_Effective_Date__c = $time.effective
                                Payroll_Transaction_ID__c = "$($fixture.dataset)-$($record.Key)"
                            }
                        }
                    }
                    default { throw "Unsupported item status $($item.target)." }
                }
                $record.Expected.Item_Status__c = $item.target
                foreach ($field in 'Requested_Work_Location__c','Payroll_Authorized_Work_Location__c','Implemented_Work_Location__c') {
                    $record.Expected[$field] = $null
                }
            }
            $block
        }
    }
}

function Resolve-Value($Value, [string[]] $LocalKeys) {
    if ($Value -isnot [string]) { return $Value }
    if ($Value -ceq '__OWNER__') { return $manifest.ownerId }
    if ($Value -cmatch '@\{([A-Za-z0-9_]+)\.id\}') {
        $key = $Matches[1]
        if ($key -in $LocalKeys) { return $Value }
        if (!$manifest.ids.ContainsKey($key)) { throw "Unresolved fixture reference $key." }
        return $Value.Replace($Matches[0], $manifest.ids[$key])
    }
    $Value
}

function Assert-Schema {
    foreach ($group in ($records | Group-Object Object)) {
        $object = $group.Name
        $schema = (Invoke-SfJson @('sobject','describe','-s',$object,'-o',$fixture.orgAlias,'--api-version',$fixture.apiVersion,'--json')).result
        if (!$schema.queryable -or !$schema.createable) { throw "$object must support query and create." }
        $fields = @{}
        foreach ($field in $schema.fields) { $fields[$field.name] = $field }
        foreach ($op in ($operations | Where-Object Object -eq $object)) {
            foreach ($name in $op.Fields.Keys) {
                $field = $fields[$name]
                if (!$field -or ($op.Method -eq 'POST' -and !$field.createable) -or
                    ($op.Method -eq 'PATCH' -and !$field.updateable)) { throw "$object.$name cannot be written by $($op.Method)." }
                if ($field.type -eq 'picklist' -and $op.Fields[$name] -cnotin @($field.picklistValues | Where-Object active | ForEach-Object value)) {
                    throw "Unavailable fixture picklist value on $object.$name."
                }
            }
            if ($op.Method -eq 'POST') {
                foreach ($field in $schema.fields) {
                    if ($field.createable -and !$field.nillable -and !$field.defaultedOnCreate -and
                        (!$op.Fields.ContainsKey($field.name) -or $null -eq $op.Fields[$field.name])) {
                        throw "Missing required field $object.$($field.name)."
                    }
                }
            }
        }
        foreach ($record in $group.Group) {
            foreach ($name in $record.Expected.Keys) {
                $field = $fields[$name]
                $value = $record.Expected[$name]
                if (!$field) { throw "Missing field $object.$name." }
                if ($null -ne $value -and $field.type -eq 'picklist' -and
                    $value -cnotin @($field.picklistValues | Where-Object active | ForEach-Object value)) {
                    throw "Unavailable expected picklist value on $object.$name."
                }
                if ($field.type -in 'string','textarea','email','url','phone' -and
                    $value -is [string] -and $field.length -gt 0 -and $value.Length -gt $field.length) {
                    throw "Fixture value exceeds the length of $object.$name."
                }
                if ($value -is [string] -and $value -cmatch '^@\{([A-Za-z0-9_]+)\.id\}$') {
                    $target = $recordsByKey[$Matches[1]].Object
                    if ($field.type -ne 'reference' -or $target -cnotin $field.referenceTo) { throw "$object.$name does not reference $target." }
                }
            }
                if ($value -is [string] -and $value -ceq '__OWNER__' -and
                    ($field.type -ne 'reference' -or 'User' -cnotin $field.referenceTo)) {
                    throw "$object.$name does not reference an internal user."
                }
        }
        Write-Host "Schema verified: $object"
    }
}

function Assert-Automation {
    $active = @(Read-Soql 'SELECT DeveloperName,ActiveVersion.VersionNumber FROM FlowDefinition WHERE ActiveVersionId != null' -Tooling)
    if ($active.Count -ne @($fixture.activeFlows.PSObject.Properties).Count) { throw 'Active Flow inventory changed.' }
    foreach ($flow in $active) {
        $version = $fixture.activeFlows.PSObject.Properties[$flow.DeveloperName]
        if (!$version -or $version.Value -ne $flow.ActiveVersion.VersionNumber) { throw "Active Flow changed: $($flow.DeveloperName)." }
    }
    if (@(Read-Soql "SELECT Name FROM ApexTrigger WHERE Status = 'Active'" -Tooling).Count) { throw 'Active Apex trigger inventory changed.' }
    if (@(Read-Soql 'SELECT Name FROM WorkflowRule' -Tooling).Count) { throw 'Workflow rule inventory changed.' }
    $assignment = @(Read-Soql "SELECT Name FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true")
    $duplicate = @(Read-Soql "SELECT DeveloperName FROM DuplicateRule WHERE IsActive = true AND SobjectType IN ('Account','Contact')" | ForEach-Object DeveloperName | Sort-Object)
    if ($assignment.Count -ne 1 -or $assignment[0].Name -cne 'Standard' -or
        ($duplicate -join ',') -cne 'Standard_Account_Duplicate_Rule,Standard_Contact_Duplicate_Rule') {
        throw 'Case assignment or Account/Contact duplicate rule inventory changed.'
    }
    Write-Host "Automation: $($active.Count) expected active flows; $($assignment.Count) active Case assignment rule(s); $($duplicate.Count) active Account/Contact duplicate rule(s)."
    Write-Host 'Review notification, escalation, and integration behavior before Apply.'
}

function Get-IdClause([string] $Field, [string] $Object) {
    $ids = @($records | Where-Object { $_.Object -eq $Object -and $manifest.ids.ContainsKey($_.Key) } |
        ForEach-Object { Quote-Soql $manifest.ids[$_.Key] })
    if ($ids.Count) { "$Field IN ($($ids -join ','))" }
}

function Get-AccountDisplayNames([string] $SeedName) {
    $SeedName
    # The approved display rename removed the seed label and kept the employer name.
    if ($SeedName.StartsWith('Fixture ', [StringComparison]::Ordinal)) {
        $SeedName.Substring('Fixture '.Length)
    }
}

function Assert-Existing {
    $prefix = Quote-Soql "$($fixture.dataset)-%"
    $accountDisplayNames = @($fixture.employers | ForEach-Object { Get-AccountDisplayNames $_.name })
    if (@($accountDisplayNames | Sort-Object -Unique).Count -ne $accountDisplayNames.Count) {
        throw 'Fixture Account display names overlap.'
    }
    $accountNames = @($accountDisplayNames | ForEach-Object { Quote-Soql $_ }) -join ','
    $scopes = @{
        Account = @("Name IN ($accountNames)")
        Contact = @("Email LIKE $prefix"; Get-IdClause AccountId Account)
        Employment__c = @("Employee_Number__c LIKE $prefix"; Get-IdClause Employer__c Account; Get-IdClause Employee__c Contact)
        Contact_Authorization__c = @(Get-IdClause Account__c Account; Get-IdClause Contact__c Contact)
        Case = @("Subject LIKE $prefix"; Get-IdClause AccountId Account; Get-IdClause ContactId Contact)
        Case_Employment__c = @(Get-IdClause Case__c Case; Get-IdClause Employment__c Employment__c)
        Employment_Change_Request__c = @(Get-IdClause Case__c Case; Get-IdClause Employment__c Employment__c)
        Employment_Change_Item__c = @(Get-IdClause Employment_Change_Request__c Employment_Change_Request__c)
    }
    foreach ($group in ($records | Group-Object Object)) {
        $object = $group.Name
        $conditions = @($scopes[$object]; Get-IdClause Id $object)
        if (!$conditions.Count) { continue }
        $fields = @($group.Group | ForEach-Object { $_.Expected.Keys } | Sort-Object -Unique)
        $rows = @(Read-Soql "SELECT Id,IsDeleted,$($fields -join ',') FROM $object WHERE $($conditions -join ' OR ')" -AllRows)
        $owned = @{}
        foreach ($record in $group.Group) {
            if ($manifest.ids.ContainsKey($record.Key)) { $owned[$manifest.ids[$record.Key]] = $record }
        }
        if (@($rows | Where-Object { !$owned.ContainsKey($_.Id) }).Count) {
            throw "$object has untracked or ambiguous fixture candidates, including possible deleted records. Restore or reconcile the original manifest before retrying."
        }
        if ($rows.Count -ne $owned.Count -or @($rows | Where-Object IsDeleted).Count) {
            throw "$object has missing or deleted manifest records. Reconcile before retrying."
        }
        foreach ($row in $rows) {
            $record = $owned[$row.Id]
            foreach ($field in $fields) {
                $expected = Resolve-Value $record.Expected[$field]
                $actual = $row.$field
                if ($object -ceq 'Account' -and $field -ceq 'Name' -and
                    $actual -cin @(Get-AccountDisplayNames $expected)) { continue }
                if ($expected -is [datetime] -or $expected -is [DateTimeOffset] -or
                    ($expected -is [string] -and $expected -match '^\d{4}-\d{2}-\d{2}T')) {
                    if ($null -ne $actual -and ([DateTimeOffset]$actual) -eq ([DateTimeOffset]$expected)) { continue }
                } elseif ($null -eq $expected -and $null -eq $actual) {
                    continue
                } elseif ($null -ne $expected -and $null -ne $actual -and [string]$expected -ceq [string]$actual) {
                    continue
                }
                throw "Unexpected existing-record drift: $($record.Key).$field."
            }
        }
    }
}

function Save-Manifest {
    $temporary = "$manifestPath.tmp"
    [IO.File]::WriteAllText($temporary, ($manifest | ConvertTo-Json -Depth 8), [Text.UTF8Encoding]::new($false))
    if ([IO.File]::Exists($manifestPath)) { [IO.File]::Replace($temporary, $manifestPath, [NullString]::Value) }
    else { [IO.File]::Move($temporary, $manifestPath) }
}

function Invoke-Block($Block) {
    $keys = @($Block.Records | ForEach-Object Key)
    $requests = @(foreach ($op in $Block.Operations) {
        $body = @{}
        foreach ($field in $op.Fields.Keys) { $body[$field] = Resolve-Value $op.Fields[$field] $keys }
        $url = "$api/sobjects/$($op.Object)"
        if ($op.Target) { $url += "/$(Resolve-Value $op.Target $keys)" }
        $request = @{ method = $op.Method; referenceId = $op.Key; url = $url; body = $body }
        if ($op.Object -in 'Account','Case') { $request.httpHeaders = @{ 'Sforce-Auto-Assign' = 'FALSE' } }
        $request
    })
    $payload = @{ allOrNone = $true; collateSubrequests = $false; compositeRequest = $requests } | ConvertTo-Json -Depth 10 -Compress
    $manifest.pending = $Block.Name
    Save-Manifest
    $response = Invoke-SfJson @('api','request','rest',"$api/composite",'-o',$fixture.orgAlias,'-X','POST','-b','-') -Body $payload
    $results = @($response.compositeResponse)
    if ($results.Count -ne $requests.Count) { throw "Incomplete response for $($Block.Name). Reconcile the pending block." }
    for ($i = 0; $i -lt $results.Count; $i++) {
        $result = $results[$i]
        if ($result.referenceId -cne $requests[$i].referenceId -or $result.httpStatusCode -notin 201,204) {
            throw "Composite block $($Block.Name) failed at $($requests[$i].referenceId), HTTP $($result.httpStatusCode). Reconcile the pending block."
        }
    }
    foreach ($result in $results | Where-Object { $_.referenceId -cin $keys }) {
        if (!$result.body.success -or $result.body.id -cnotmatch '^[A-Za-z0-9]{18}$') { throw 'Missing create ID. Reconcile the pending block.' }
        $manifest.ids[$result.referenceId] = $result.body.id
    }
    $manifest.pending = $null
    Save-Manifest
    Assert-Existing
}

function Assert-PayrollSharing {
    $group = @(Read-Soql "SELECT Id FROM Group WHERE Type = 'Regular' AND DeveloperName = 'Aloha_Workforce_Payroll_Processors'")
    if ($group.Count -ne 1) { throw 'Expected a single payroll public group.' }
    $parents = Get-IdClause ParentId Employment_Change_Request__c
    $grants = @(Read-Soql "SELECT ParentId FROM Employment_Change_Request__Share WHERE $parents AND UserOrGroupId = '$($group[0].Id)' AND RowCause = 'Rule' AND AccessLevel = 'Edit'")
    if (@($grants | ForEach-Object ParentId | Sort-Object -Unique).Count -ne @($records | Where-Object Object -eq Employment_Change_Request__c).Count) {
        throw 'Expected payroll ECR shares are not all visible. Check sharing calculation and rerun read-only validation.'
    }
}

$lock = $null
try {
    $org = @(Read-Soql 'SELECT Id FROM Organization')
    if ($org.Count -ne 1 -or $org[0].Id -cne $ExpectedOrgId) { throw 'Unexpected Salesforce organization.' }
    Write-Host "Verified org alias $($fixture.orgAlias)."
    if ($Apply) {
        [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($manifestPath))
        $lock = [IO.File]::Open("$manifestPath.lock", 'OpenOrCreate', 'ReadWrite', 'None')
    }
    $manifest = @{ orgId = $ExpectedOrgId; hash = $hash; ownerId = $null; pending = $null; ids = @{} }
    if (Test-Path -LiteralPath $manifestPath) {
        $stored = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
        if ($stored.orgId -cne $ExpectedOrgId -or $stored.hash -cne $hash -or $stored.pending) {
            throw 'Manifest belongs to another org or fixture revision, or contains a pending transaction. Reconcile before proceeding.'
        }
        $manifest.ownerId = $stored.ownerId
        foreach ($property in $stored.ids.PSObject.Properties) {
            if ($property.Value -cnotmatch '^[A-Za-z0-9]{18}$') { throw 'Invalid record ID in manifest.' }
            $manifest.ids[$property.Name] = $property.Value
        }
    }
    if ($OwnerUsername -or $manifest.ownerId) {
        $filter = if ($OwnerUsername) { "Username = $(Quote-Soql $OwnerUsername)" } else { "Id = $(Quote-Soql $manifest.ownerId)" }
        $owner = @(Read-Soql "SELECT Id FROM User WHERE $filter AND IsActive = true AND UserType = 'Standard'")
        if ($owner.Count -ne 1 -or ($manifest.ownerId -and $owner[0].Id -cne $manifest.ownerId)) {
            throw 'Fixture owner must be one active internal standard user and match the manifest.'
        }
        $manifest.ownerId = $owner[0].Id
    }
    $blocks = @(New-SeedPlan)
    $records = @($blocks | ForEach-Object { $_.Records | ForEach-Object { $_ } })
    $operations = @($blocks | ForEach-Object { $_.Operations | ForEach-Object { $_ } })
    $recordsByKey = @{}
    foreach ($record in $records) {
        if ($recordsByKey.ContainsKey($record.Key)) { throw "Duplicate fixture key $($record.Key)." }
        $recordsByKey[$record.Key] = $record
    }
    foreach ($key in $manifest.ids.Keys) {
        if (!$recordsByKey.ContainsKey($key)) { throw "Unknown manifest key $key." }
    }
    if (@($manifest.ids.Values | Sort-Object -Unique).Count -ne $manifest.ids.Count) { throw 'Duplicate IDs in manifest.' }
    $missing = @(foreach ($block in $blocks) {
        if ($block.Operations.Count -gt 25) { throw "Composite request exceeds the limit: $($block.Name)." }
        $present = @($block.Records | Where-Object { $manifest.ids.ContainsKey($_.Key) }).Count
        if ($present -eq 0) { $block }
        elseif ($present -ne $block.Records.Count) { throw "Incomplete manifest block $($block.Name)." }
    })
    Assert-Schema
    Assert-Automation
    Assert-Existing
    $records | Group-Object Object | ForEach-Object {
        $count = @($_.Group | Where-Object { !$manifest.ids.ContainsKey($_.Key) }).Count
        [pscustomobject]@{ Object = $_.Name; Expected = $_.Count; ToCreate = $count }
    } | Format-Table -AutoSize | Out-Host

    if ($RollbackPlan) {
        $reverse = $records.Clone()
        [array]::Reverse($reverse)
        foreach ($entry in $reverse) {
            if ($manifest.ids.ContainsKey($entry.Key)) {
                [pscustomobject]@{ Object = $entry.Object; Key = $entry.Key; Id = $manifest.ids[$entry.Key] }
            }
        }
        Write-Host 'Preview only. Review dependencies and activity before any separate cleanup.'
    } elseif ($Apply) {
        foreach ($block in $missing) { Invoke-Block $block }
        Assert-PayrollSharing
        Write-Host 'Apply verified. Run Plan with -RequireComplete to validate idempotency.'
    } elseif ($RequireComplete -and $missing.Count) {
        throw 'The dataset is incomplete. Review the Plan counts.'
    } else {
        if ($RequireComplete) { Assert-PayrollSharing }
        Write-Host 'Read-only Plan complete.'
    }
} finally {
    if ($lock) { $lock.Dispose() }
}
