﻿function Get-PMPackage {
	<#
	.SYNOPSIS
		Get information about a specified ProgramManager package.
		
	.DESCRIPTION
		Returns the specified ProgramManager.Package object, for display to terminal, or for passing down the pipeline.
		
	.PARAMETER PackageName
		The name of the package to retrieve.
		
	.PARAMETER ShowFullDetail
		Toggles whether it shows a overview of the package with the "usually" important properties,
		or whether it shows every single property of the package, some of which will not have much use for the user.
		
	.EXAMPLE
		PS C:\> Get-PMPackage -PackageName "notepad"
		
		Returns information about the "notepad" package.
		
	.INPUTS
		None
		
	.OUTPUTS
		None
		
	#>
	
	[CmdletBinding()]
	Param (
		
		[Parameter(Mandatory = $true, Position = 0)]
		[AllowEmptyString()]
		[string]
		$PackageName,
		
		[Parameter(Position = 1)]
		[switch]
		$ShowFullDetail
		
	)
	
	# Import all PMPackage objects from the database file
	Write-Verbose "Loading existing packages from database"
	$packageList = Import-PackageList
	
	# Check that the name is not empty
	if ([System.String]::IsNullOrWhiteSpace($PackageName) -eq $true) {
		
		Write-Message -Message "The name cannot be empty" -DisplayWarning
		return
		
	}
	
	# Check if package exists
	$package = $packageList | Where-Object { $_.Name -eq $PackageName }
	if ($null -eq $package) {
		
		Write-Message -Message "There is no package called: $PackageName" -DisplayWarning
		return
		
	}
	
	# Append the View object type to control the visual output of the object depending on the user's preference
	if ($ShowFullDetail -eq $true) {
		
		Write-Verbose "Detected -ShowFullDetail flag."
		$package.PSObject.TypeNames.Insert(1, "ProgramManager.Package-View.Full")
		
	}else {
		
		Write-Verbose "Not detected -ShowFullDetail flag."
		$package.PSObject.TypeNames.Insert(1, "ProgramManager.Package-View.Overview")
		
	}
	
	# Output the package object
	Write-Output $package
	
}