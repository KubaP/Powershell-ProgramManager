function Remove-PMPackage {
	<#
	.SYNOPSIS
		Removes a ProgramManager package from the database.    
		
	.DESCRIPTION
		Erases the data of a ProgramManager.Package object from the database.
		
	.PARAMETER PackageName
		The name of the package to remove.
		
	.PARAMETER RetainFiles
		If removing a local or portable package, which has files/installers saved within the package store, 
		this switch will move those files to a specific location rather than deleting them.
		
	.PARAMETER Path
		To be used in conjunction with -RetainFiles.
		This is the path where the package files will be moved into.
		
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
		
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
		
	.EXAMPLE
		PS C:\> Remove-PMPackage -PackageName "notepad"
		
		This command will remove the package "notepad" from the database and delete any physical files, such as the installer executable.
		
	.EXAMPLE
		PS C:\ Remove-PMPackage -PackageName "notepad" -RetainFiles -Path "~\Downloads\"
		
		This command will remove the package "notepad" from the database, but will not delete any physical files, such as the installer executable.
		It will move the files to the ~\Download\ foder
		
	.EXAMPLE
		PS C:\ Get-PMPackage "notepad" | Remove-PMPackage
		
		This command supports passing in a ProgramManager.Package object, by retrieving it using Get-PMPacakge for example.
		This command will remove the package "notepad" from the database and delete any physical files, such as the installer executable.
				
	.INPUTS
		System.String
		
	.OUTPUTS
		None
		
	#>
	
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
	Param (
		
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
		[AllowEmptyString()]
		[Alias("Name")]
		[string]
		$PackageName,
		
		[Parameter(Position = 1)]
		[switch]
		$RetainFiles,
		
		[Parameter(Position = 2)]
		[AllowEmptyString()]
		[string]
		$Path
		
	)
	
	# Import all PMPackage objects from the database file
	Write-Verbose "Loading existing packages from database"
	$packageList = Import-PackageList
	
	# Check that the name is not empty
	if ([System.String]::IsNullOrWhiteSpace($PackageName) -eq $true) {
		
		Write-Message -Message "The package name cannot be empty" -DisplayWarning
		return
		
	}
	
	# Check if package name exists
	Write-Verbose "Retrieving the ProgramManager.Package Object"
	$package = $packageList | Where-Object { $_.Name -eq $PackageName }
	if ($null -eq $package) {
		
		Write-Message -Message "There is no package called: $PackageName" -DisplayWarning
		return
		
	}
	
	# Check that the path is not empty
	if ($RetainFiles -eq $true -and [System.String]::IsNullOrWhiteSpace($Path) -eq $true) {
		
		Write-Message -Message "The path cannot be empty" -DisplayWarning
		return
		
	}
	
	# Url or chocolatey packages dont store any files
	if ($package.Type -eq "LocalPackage" -or $package.Type -eq "PortablePackage") {
		Write-Verbose "Detected Local-Package or Portable-Package"
		
		# Check in case there is no folder for some reason?
		if ((Test-Path -Path "$script:DataPath\packages\$PackageName\") -eq $false) {
			
			Write-Message -Message "There are no files for this package in the package store. This should not happen." -DisplayError
			return
		}
		
		
		if ($RetainFiles -eq $true) {
			Write-Verbose "Detected -RetainFiles flag"
			
			# Check that the path to move the files to is valid
			if ((Test-Path -Path $Path) -eq $false) {
				
				Write-Message -Message "The file path does not exist" -DisplayWarning
				return
				
			}
			
			# Check that the path doesn't contain any characters which could cause potential issues
			if ($Path -like "*.*" -or $Path -like "*``**" -or $Path -like "*.``**") {
				
				Write-Message -Message "The path contains invalid characters" -DisplayWarning
				return
				
			}
			
			if ($PSCmdlet.ShouldProcess("Package `'$PackageName`'", "Move the package files to $Path")){
				
				# Move the package files to the specified path
				Write-Verbose "Moving package files to $Path"
				Move-Item -Path "$script:DataPath\packages\$PackageName\" -Destination $Path
				
			}
			
		}else {
			
			if ($PSCmdlet.ShouldProcess("Package `'$PackageName`'", "Delete the package files")) {
				
				# Remove the package from the package store
				Write-Verbose "Deleting package files at \packages\$PackageName"
				Remove-Item -Path "$script:DataPath\packages\$PackageName\" -Recurse -Force
				
			}
		
		}
		
	}elseif ($package.Type -eq "UrlPackage" -and $RetainFiles -eq $true) {
		
		# Notify user that -RetainFiles flag has no effect on a url package
		Write-Message -Message "The flag -RetainFiles has no effect on a url package" -DisplayWarning
		
	}
	
	
	if ($PSCmdlet.ShouldProcess("$script:DataPath\packageDatabase.xml", "Remove the package `'$PackageName`'")){
		
		# Remove the PMPackage from the list
		Write-Verbose "Removing package object from list"
		$packageList.Remove($package) | Out-Null
		
		# Export-out package list to xml file
		Write-Verbose "Writing-out data back to database"
		Export-PackageList -PackageList $packageList
		
	}
	
}