<#
This script publishes the module to the gallery.
It expects as input an ApiKey authorized to publish the module.

Insert any build steps you may need to take before publishing it here.
#>
param (
	$ApiKey,
	
	$WorkingDirectory,
	
	$Repository = 'PSGallery',
	
	[switch]
	$LocalRepo,
	
	[switch]
	$SkipPublish,
	
	[switch]
	$AutoVersion
)

#region Handle Working Directory Defaults
if (-not $WorkingDirectory) {
	if ($env:RELEASE_PRIMARYARTIFACTSOURCEALIAS) {
		$WorkingDirectory = Join-Path -Path $env:SYSTEM_DEFAULTWORKINGDIRECTORY -ChildPath $env:RELEASE_PRIMARYARTIFACTSOURCEALIAS
	}
	else { $WorkingDirectory = $env:SYSTEM_DEFAULTWORKINGDIRECTORY }
}
#endregion Handle Working Directory Defaults

# Prepare publish folder
Write-Host "Creating and populating publishing directory"
$publishDir = New-Item -Path $WorkingDirectory -Name publish -ItemType Directory -Force
Copy-Item -Path "$($WorkingDirectory)\ProgramManager" -Destination $publishDir.FullName -Recurse -Force

#region Gather text data to compile
$text = @()
$processed = @()

# Gather Stuff to run before
foreach ($line in (Get-Content "$($PSScriptRoot)\filesBefore.txt" | Where-Object { $_ -notlike "#*" })) {
	if ([string]::IsNullOrWhiteSpace($line)) { continue }
	
	$basePath = Join-Path "$($publishDir.FullName)\ProgramManager" $line
	foreach ($entry in (Resolve-Path -Path $basePath)) {
		$item = Get-Item $entry
		if ($item.PSIsContainer) { continue }
		if ($item.FullName -in $processed) { continue }
		$text += [System.IO.File]::ReadAllText($item.FullName)
		$processed += $item.FullName
	}
}

# Gather commands
Get-ChildItem -Path "$($publishDir.FullName)\ProgramManager\internal\functions\" -Recurse -File -Filter "*.ps1" | ForEach-Object {
	$text += [System.IO.File]::ReadAllText($_.FullName)
}
Get-ChildItem -Path "$($publishDir.FullName)\ProgramManager\functions\" -Recurse -File -Filter "*.ps1" | ForEach-Object {
	$text += [System.IO.File]::ReadAllText($_.FullName)
}

# Gather stuff to run afterwards
foreach ($line in (Get-Content "$($PSScriptRoot)\filesAfter.txt" | Where-Object { $_ -notlike "#*" })) {
	if ([string]::IsNullOrWhiteSpace($line)) { continue }
	
	$basePath = Join-Path "$($publishDir.FullName)\ProgramManager" $line
	foreach ($entry in (Resolve-Path -Path $basePath)) {
		$item = Get-Item $entry
		if ($item.PSIsContainer) { continue }
		if ($item.FullName -in $processed) { continue }
		$text += [System.IO.File]::ReadAllText($item.FullName)
		$processed += $item.FullName
	}
}
#endregion Gather text data to compile

#region Update the psm1 file
$fileData = Get-Content -Path "$($publishDir.FullName)\ProgramManager\ProgramManager.psm1" -Raw
$fileData = $fileData.Replace('"<was not compiled>"', '"<was compiled>"')
$fileData = $fileData.Replace('"<compile code into here>"', ($text -join "`n`n"))
[System.IO.File]::WriteAllText("$($publishDir.FullName)\ProgramManager\ProgramManager.psm1", $fileData, [System.Text.Encoding]::UTF8)
#endregion Update the psm1 file

#region Updating the Module Version
if ($AutoVersion) {
	Write-Host "Updating module version numbers."
	try { [version]$remoteVersion = (Find-Module 'ProgramManager' -Repository $Repository -ErrorAction Stop).Version 
	}catch {
		#Stop-PSFFunction -Message "Failed to access $($Repository)" -EnableException $true -ErrorRecord $_
		Write-Host "Failed to access $($Repository)"
		break
	}
	
	if (-not $remoteVersion) {
		#Stop-PSFFunction -Message "Couldn't find ProgramManager on repository $($Repository)" -EnableException $true
		Write-Host "Couldn't find ProgramManager on repository $($Repository)"
		break
	}
	$newBuildNumber = $remoteVersion.Build + 1
	[version]$localVersion = (Import-PowerShellDataFile -Path "$($publishDir.FullName)\ProgramManager\ProgramManager.psd1").ModuleVersion
	Update-ModuleManifest -Path "$($publishDir.FullName)\ProgramManager\ProgramManager.psd1" -ModuleVersion "$($localVersion.Major).$($localVersion.Minor).$($newBuildNumber)"
}
#endregion Updating the Module Version

#region Publish
if ($SkipPublish) { return }
if ($LocalRepo) {
	# Dependencies must go first
	Write-Host "Publishing locally is not available until new New-PSMDModuleNugetPackage function is written."
	#Write-Host "Creating Nuget Package for module: ProgramManager"
	#New-PSMDModuleNugetPackage -ModulePath "$($publishDir.FullName)\ProgramManager" -PackagePath .
}else {
	# Publish to Gallery
	Write-Host "Publishing the ProgramManager module to $($Repository)"
	Publish-Module -Path "$($publishDir.FullName)\ProgramManager" -NuGetApiKey $ApiKey -Force -Repository $Repository
}
#endregion Publish