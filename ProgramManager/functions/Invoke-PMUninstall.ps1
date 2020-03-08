function Invoke-PMUninstall {
	<#
	.SYNOPSIS
		Uninstalls a ProgramManager package.
		
	.DESCRIPTION
		Invokes an uninstallation process on a ProgramManager.Package that is already installed.
		
	.PARAMETER PackageName
		The name of the ProgramManager package to uninstall.
		
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
		
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
		
	.EXAMPLE
		PS C:\> Invoke-PMUninstall -Name "notepad"
		
		This command will uninstall the package named "notepad".
		
	.EXAMPLE
		PS C:\> Get-PMPackage "notepad" | Invoke-PMUninstall
		
		This command supports passing in a ProgramManager.Package object, by retrieving it using Get-PMPacakge for example.
		This command will uninstall the package named "notepad".
		
	.INPUTS
		System.String[]
		
	.OUTPUTS
		None
		
	#>
	
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
	Param (
		
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
		[AllowEmptyString()]
		[Alias("Name")]
		[string[]]
		$PackageName
		
	)
	
	# Check if the xml database exists
	if ((Test-Path -Path "$script:DataPath\packageDatabase.xml") -eq $true) {
		
		# Load all existing PMPackages into a list
		Write-Verbose "Loading existing packages from database"
		$packageList = Import-PackageList
		
	}else {
		
		# The xml database doesn't exist; warn user
		Write-Message -Message "The database file doesn't exist. Run New-PMPackage to initialise it." -DisplayWarning
		return
		
	}
	
	# Iterate through all passed package names
	foreach ($name in $PackageName) {
		
		Write-Verbose "Uninstalling package:{$name}"
		
		# Check that the name is not empty
		if ([System.String]::IsNullOrWhiteSpace($name) -eq $true) {
			
			Write-Message -Message "The name cannot be empty" -DisplayWarning
			return
			
		}
		
		# Get the package by name
		Write-Verbose "Retrieving the ProgramManager.Package Object"
		$package = $packageList | Where-Object { $_.Name -eq $name }
		# Warn the user if the name is invalid
		if ($null -eq $package) {
			
			Write-Message -Message "There is no package called: $name" -DisplayWarning
			return
			
		}
		
		# Check that the package is actually installed
		if ($package.IsInstalled -eq $false) {
			
			Write-Message -Message "The package:{$name} is not installed." -DisplayWarning
			return
			
		}
		
		# Check if the package has a on-uninstall scriptblock to run
		Write-Verbose "Checking for uninstall scriptblock"
		if ([System.String]::IsNullOrWhiteSpace($package.UninstallScriptblock) -eq $false) {
			
			if ($PSCmdlet.ShouldProcess("uninstall scriptblock from package:{$name}", "Execute scriptblock")) {
				
				# Convert the string into a scriptblock and execute
				Write-Verbose "Coverting scriptblock and executing it"
				$scriptblock = [scriptblock]::Create($package.UninstallScriptblock)
				Invoke-Command -ScriptBlock $scriptblock -ArgumentList $package
				
			}
			
		}
		
		# Main uninstallation logic
		if ($package.Type -eq "LocalPackage" -or $package.Type -eq "UrlPackage") {
			
			# Launch control panel to allow user to uninstall program, since there is no real
			# way of uninstalling programs installed through a standard exe installer
			Write-Verbose "Launching Control Panel"
			Start-Process appwiz.cpl
			
		}elseif ($package.Type -eq "PortablePackage") {
			
			# Check whether the folder the package was installed to actually exists
			if ((Test-Path -Path "$($package.InstallDirectory)\$($package.Name)") -eq $false) {
				
				Write-Message "Can't find the package at the expected directory. Was the package folder renamed?" -DisplayWarning
				return
				
			}
			
			# Delete the package files
			Write-Verbose "Deleting package files"
			Remove-Item -Path "$($package.InstallDirectory)\$($package.Name)" -Recurse -Force
			
		}elseif ($package.Type -eq "ChocolateyPackage") {
			
			# TODO: invoke chocolatey uninstall
			
		}
		
		# Set the installed flag for the package
		Write-Verbose "Setting installed flag to false"
		$package.IsInstalled = $false		
		
	}
	
	if ($PSCmdlet.ShouldProcess("$script:DataPath\packageDatabase.xml", "Update the package:{$PackageName} installation status")) {
		
		# Override xml database with updated package property
		Write-Verbose "Writing-out data back to database"
		Export-PackageList -PackageList $packageList
		
	}
	
}