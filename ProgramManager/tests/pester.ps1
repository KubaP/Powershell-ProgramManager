param (
	# Whether to run general tests
	$TestGeneral = $true,
	
	# Whether to run function tests
	$TestFunctions = $true,
	
	# Controls how much verbose output pester shows during running
	[ValidateSet('None', 'Default', 'Passed', 'Failed', 'Pending', 'Skipped', 'Inconclusive', 'Describe', 'Context', 'Summary', 'Header', 'Fails', 'All')]
	$Show = "None",
	
	# Files to include
	$Include = "*",
	
	# File to exclude
	$Exclude = ""
)

Write-Host "Starting Tests"
Write-Host "Importing Module"

# Remove and re-import the module
Remove-Module ProgramManager -ErrorAction Ignore
Import-Module "$PSScriptRoot\..\ProgramManager.psd1"
Import-Module "$PSScriptRoot\..\ProgramManager.psm1" -Force

# Create the test results directory
Write-Host "Creating test result folder"
New-Item -Path "$PSScriptRoot\..\.." -Name TestResults -ItemType Directory -Force | Out-Null

# Keep count of # of tests
$totalFailed = 0
$totalRun = 0

$allTestResults = @()
$failedTestResults = @()

# Run General Tests
if ($TestGeneral) {
	Write-Host "Modules imported, proceeding with general tests"
	
	# Run through every test file located in \general\
	foreach ($file in (Get-ChildItem "$PSScriptRoot\general" | Where-Object Name -like "*.Tests.ps1")) {
		
		Write-Host "  Executing $($file.Name)"
		
		# Run the tests and save pester output to results file
		$TestOutputFile = Join-Path "$PSScriptRoot\..\..\TestResults" "TEST-$($file.BaseName).xml"
		$results = Invoke-Pester -Script $file.FullName -Show $Show -PassThru -OutputFile $TestOutputFile -OutputFormat NUnitXml
		
		foreach ($result in $results) {
			
			# Add the test results to counter
			$totalRun += $result.TotalCount
			$totalFailed += $result.FailedCount
			
			# If a test fails, add it to the list
			$result.TestResult | Where-Object { -not $_.Passed } | ForEach-Object {
				$name = $_.Name
				$failedTestResults += [pscustomobject]@{
					Describe = $_.Describe
					Context  = $_.Context
					Name	 = "It $name"
					Result   = $_.Result
					Message  = $_.FailureMessage
				}
				
			}
			
		}
		
	}
	
}

# Test Commands
if ($TestFunctions) {
	Write-Host "Proceeding with individual tests"
	
	# Run through every test file located in \functions\
	foreach ($file in (Get-ChildItem "$PSScriptRoot\functions" -Recurse -File | Where-Object Name -like "*Tests.ps1")) {
		
		# Check that the file matches the given filters
		if ($file.Name -notlike $Include) { continue }
		if ($file.Name -like $Exclude) { continue }
		
		Write-Host "  Executing $($file.Name)"
		$functionFile = $file.Name -replace ".Tests",""
		
		# Run the tests and save pester output to results file
		$TestOutputFile = Join-Path "$PSScriptRoot\..\..\TestResults" "TEST-$($file.BaseName).xml"
		$results = Invoke-Pester -Script $file.FullName -Show $Show -CodeCoverage "$PSScriptRoot\..\functions\$functionFile" -PassThru -OutputFile $TestOutputFile -OutputFormat NUnitXml
		
		foreach ($result in $results) {
			
			# Add the test results to counter
			$totalRun += $result.TotalCount
			$totalFailed += $result.FailedCount
			$allTestResults += $result
			
			# If a test fails, add it to the list
			$result.TestResult | Where-Object { -not $_.Passed } | ForEach-Object {
				$name = $_.Name
				$failedTestResults += [pscustomobject]@{
					Describe = $_.Describe
					Context  = $_.Context
					Name	 = "It $name"
					Result   = $_.Result
					Message  = $_.FailureMessage
				}
				
			}
			
		}
		
	}
	
}

# Show all failed test results in detail
$failedTestResults | Sort-Object Describe, Context, Name, Result, Message | Format-List

# Display a message at the end
if ($totalFailed -eq 0) {
	
	Write-Host "All $totalRun tests executed without a single failure!"
	 
}else { 
	
	Write-Host "$totalFailed tests out of $totalRun tests failed!" 
	
}

# Throw an error if any tests failed
if ($totalFailed -gt 0) {
	
	throw "$totalFailed / $totalRun tests failed!"
	
}

# Return test results for use in code coverage
Write-Output $allTestResults -NoEnumerate