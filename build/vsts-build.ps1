<#
This script publishes the module to the gallery.
It expects as input an ApiKey authorized to publish the module.

Insert any build steps you may need to take before publishing it here.
#>
param (
	# Key for publishing to psgallery
	$ApiKey,
	
	# Azure pipeline working directory stuff
	$WorkingDirectory,
	
	# Repository to publish to
	$Repository = 'PSGallery',
	
	[switch]
	$LocalRepo,
	
	# Build but don't publish
	[switch]
	$SkipPublish
	
)

# Handle Working Directory Defaults
if (-not $WorkingDirectory) {
	if ($env:RELEASE_PRIMARYARTIFACTSOURCEALIAS) {
		$WorkingDirectory = Join-Path -Path $env:SYSTEM_DEFAULTWORKINGDIRECTORY -ChildPath $env:RELEASE_PRIMARYARTIFACTSOURCEALIAS
	}
	else { $WorkingDirectory = $env:SYSTEM_DEFAULTWORKINGDIRECTORY }
}

# Prepare publish folder
Write-Host "Creating and populating publishing directory"
$publishDir = New-Item -Path $WorkingDirectory -Name publish -ItemType Directory -Force
# Copy the git repo to the publish folder
Copy-Item -Path "$($WorkingDirectory)\ProgramManager" -Destination $publishDir.FullName -Recurse -Force

# Gather text data from scripts to compile
$text = @()
$processed = @()

# Gather stuff to run before
foreach ($line in (Get-Content "$($PSScriptRoot)\filesBefore.txt" | Where-Object { $_ -notlike "#*" })) {
	
	if ([string]::IsNullOrWhiteSpace($line)) { continue }
	
	# Get the full file paths within the publish directory
	$basePath = Join-Path "$($publishDir.FullName)\ProgramManager" $line
	
	# Get each file specified by filesBefore.txt
	foreach ($entry in (Resolve-Path -Path $basePath)) {
		
		# Get the file 
		$item = Get-Item $entry
		
		if ($item.PSIsContainer) { continue }
		if ($item.FullName -in $processed) { continue }
		
		# Add the text content and mark as processed
		$text += [System.IO.File]::ReadAllText($item.FullName)
		$processed += $item.FullName
		
	}
	
}

# Gather commands of all functions and add text content
Get-ChildItem -Path "$($publishDir.FullName)\ProgramManager\internal\functions\" -Recurse -File -Filter "*.ps1" | ForEach-Object {
	
	$text += [System.IO.File]::ReadAllText($_.FullName)
	
}

Get-ChildItem -Path "$($publishDir.FullName)\ProgramManager\functions\" -Recurse -File -Filter "*.ps1" | ForEach-Object {
	
	$text += [System.IO.File]::ReadAllText($_.FullName)
	
}

# Gather stuff to run after
foreach ($line in (Get-Content "$($PSScriptRoot)\filesAfter.txt" | Where-Object { $_ -notlike "#*" })) {
	
	if ([string]::IsNullOrWhiteSpace($line)) { continue }
	
	# Get the full file paths within the publish directory
	$basePath = Join-Path "$($publishDir.FullName)\ProgramManager" $line
		
	# Get each file specified by filesBefore.txt
	foreach ($entry in (Resolve-Path -Path $basePath)) {
		
		# Get the file 
		$item = Get-Item $entry
		
		if ($item.PSIsContainer) { continue }
		if ($item.FullName -in $processed) { continue }
		
		# Add the text content and mark as processed
		$text += [System.IO.File]::ReadAllText($item.FullName)
		$processed += $item.FullName
		
	}
	
}

# Update the psm1 file with all the read-in text content
# This is done to reduce load times for the module, if all code is within the single psm1 file
$fileData = Get-Content -Path "$($publishDir.FullName)\ProgramManager\ProgramManager.psm1" -Raw
# Change the complied flag to true
$fileData = $fileData.Replace('"<was not compiled>"', '"<was compiled>"')
# Paste the text picked up from all files into the psm1 main file, and save
$fileData = $fileData.Replace('"<compile code into here>"', ($text -join "`n`n"))
[System.IO.File]::WriteAllText("$($publishDir.FullName)\ProgramManager\ProgramManager.psm1", $fileData, [System.Text.Encoding]::UTF8)

# Publish
if ($SkipPublish) { return }

if ($LocalRepo) {
	
	# Nuget publish command
	# TODO:
	
}else {
	
	# Publish to PSGallery
	Write-Host "Publishing the ProgramManager module to $($Repository)"
	Publish-Module -Path "$($publishDir.FullName)\ProgramManager" -NuGetApiKey $ApiKey -Force -Repository $Repository
	
}
