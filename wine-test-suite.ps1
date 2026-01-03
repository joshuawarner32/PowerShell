# PowerShell Wine Fidelity Test Suite
# Now with working output using --NonInteractive flag!

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "PowerShell Wine Fidelity Test Results" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Executed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Host "Platform: $($PSVersionTable.Platform)"
Write-Host "================================================================"
Write-Host ""

$passCount = 0
$failCount = 0
$expectedFailCount = 0

function Test-Feature {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [bool]$ExpectedToFail = $false
    )

    Write-Host -NoNewline "$Name... " -ForegroundColor Yellow

    try {
        $result = & $Test
        if ($ExpectedToFail) {
            Write-Host "[UNEXPECTED PASS]" -ForegroundColor Magenta
            Write-Host "  Result: $result"
            $script:passCount++
        } else {
            Write-Host "[PASS]" -ForegroundColor Green
            Write-Host "  Result: $result"
            $script:passCount++
        }
    } catch {
        if ($ExpectedToFail) {
            Write-Host "[EXPECTED FAIL]" -ForegroundColor Yellow
            Write-Host "  (This is expected in Wine)"
            $script:expectedFailCount++
        } else {
            Write-Host "[FAIL]" -ForegroundColor Red
            Write-Host "  Error: $($_.Exception.Message)"
            $script:failCount++
        }
    }
    Write-Host ""
}

# Test 1: Basic Math
Test-Feature "Basic Math Operations" {
    $result = 2 + 2
    return "2 + 2 = $result"
}

# Test 2: String Manipulation
Test-Feature "String Manipulation" {
    $result = 'hello world'.ToUpper()
    return "Uppercase: $result"
}

# Test 3: Pipeline Operations
Test-Feature "Pipeline Operations" {
    $result = 1..10 | Where-Object { $_ % 2 -eq 0 } | ForEach-Object { $_ * 2 }
    return "Even numbers doubled: $($result -join ', ')"
}

# Test 4: Array Operations
Test-Feature "Array Operations" {
    $sum = (@(1,2,3,4,5) | Measure-Object -Sum).Sum
    return "Sum of 1..5: $sum"
}

# Test 5: Version Information
Test-Feature "Version Information" {
    return "PSVersion: $($PSVersionTable.PSVersion), Edition: $($PSVersionTable.PSEdition)"
}

# Test 6: Environment Variables
Test-Feature "Environment Variables" {
    return "User: $env:USERNAME, Computer: $env:COMPUTERNAME"
}

# Test 7: File System
Test-Feature "File System Navigation" {
    $location = Get-Location
    $count = (Get-ChildItem | Measure-Object).Count
    return "Location: $location, Items: $count"
}

# Test 8: .NET Framework
Test-Feature ".NET Framework Access" {
    $now = [DateTime]::Now.ToString("HH:mm:ss")
    $guid = [Guid]::NewGuid().ToString().Substring(0, 8)
    return "Time: $now, GUID: $guid..."
}

# Test 9: Process Management
Test-Feature "Process Management" {
    $count = (Get-Process | Measure-Object).Count
    return "Process count: $count, Current PID: $PID"
}

# Test 10: HashTables
Test-Feature "HashTables and Collections" {
    $hash = @{a=1; b=2; c=3}
    $keys = $hash.Keys -join ', '
    return "Hash keys: $keys, Count: $($hash.Count)"
}

# Test 11: JSON Processing
Test-Feature "JSON Processing" {
    $obj = @{Name='Test'; Value=42}
    $json = $obj | ConvertTo-Json -Compress
    $parsed = $json | ConvertFrom-Json
    return "Name: $($parsed.Name), Value: $($parsed.Value)"
}

# Test 12: String and Regex
Test-Feature "String and Regex" {
    $text = "PowerShell in Wine"
    $match = $text -match 'PowerShell'
    return "Match 'PowerShell': $match, Replaced: $($text -replace 'Wine', 'Docker+Wine')"
}

# Test 13: Functions and Script Blocks
Test-Feature "Functions and ScriptBlocks" {
    function Add-Numbers { param([int]$x, [int]$y); return $x + $y }
    $funcResult = Add-Numbers -x 10 -y 20
    $sb = { param($n) $n * $n }
    $sbResult = & $sb 7
    return "Function: $funcResult, ScriptBlock: $sbResult"
}

# Test 14: Error Handling
Test-Feature "Error Handling" {
    try {
        Get-Item "C:\NonExistent" -ErrorAction Stop
    } catch {
        $errorType = $_.Exception.GetType().Name
    }
    return "Caught error type: $errorType"
}

# Test 15: Performance Measurement
Test-Feature "Performance Measurement" {
    $measure = Measure-Command { 1..1000 | ForEach-Object { $_ * 2 } }
    $ms = [math]::Round($measure.TotalMilliseconds, 2)
    return "Processed 1000 items in ${ms}ms"
}

# Test 16: Custom Objects
Test-Feature "Custom Objects" {
    $objects = @(
        [PSCustomObject]@{Name='Alice'; Age=30}
        [PSCustomObject]@{Name='Bob'; Age=25}
    )
    $avgAge = ($objects | Measure-Object -Property Age -Average).Average
    return "Created $($objects.Count) objects, Average age: $avgAge"
}

# Test 17: Modules
Test-Feature "Module Management" {
    $available = (Get-Module -ListAvailable | Measure-Object).Count
    $loaded = (Get-Module | Measure-Object).Count
    return "Available: $available, Loaded: $loaded"
}

# Test 18: WMI/CIM (Expected to fail in Wine)
Test-Feature "WMI/CIM Queries" {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
    return "OS: $($os.Caption)"
} -ExpectedToFail $true

# Test 19: COM Objects (Expected to fail in Wine)
Test-Feature "COM Objects" {
    $shell = New-Object -ComObject WScript.Shell -ErrorAction Stop
    return "COM object created successfully"
} -ExpectedToFail $true

# Test 20: Advanced Pipeline
Test-Feature "Advanced Pipeline" {
    $result = 1..100 |
        Where-Object { $_ % 3 -eq 0 } |
        ForEach-Object { [PSCustomObject]@{Number=$_; Square=$_*$_} } |
        Measure-Object -Property Square -Sum
    return "Sum of squares of multiples of 3 (1-100): $($result.Sum)"
}

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  PASSED:         $passCount" -ForegroundColor Green
Write-Host "  FAILED:         $failCount" -ForegroundColor Red
Write-Host "  EXPECTED FAILS: $expectedFailCount" -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

$successRate = if (($passCount + $failCount) -gt 0) {
    [math]::Round(($passCount / ($passCount + $failCount)) * 100, 1)
} else { 0 }

Write-Host "Success Rate: $successRate%" -ForegroundColor $(if ($successRate -gt 80) { "Green" } else { "Yellow" })
Write-Host ""
Write-Host "PowerShell is $(if ($failCount -eq 0) { 'fully functional' } else { 'mostly functional' }) in Wine!" -ForegroundColor Cyan
