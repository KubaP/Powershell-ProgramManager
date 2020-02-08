function Remove-PMPackage {
	<#
	.SYNOPSIS
		Removes a package from the database.    
	
	.DESCRIPTION
		Erases the data of a PMPackage from the database.
		
	.PARAMETER PackageName
		The name of the pacakge to remove.
		
	.EXAMPLE
		PS C:\> Remove-PMPackage -PackageName "notepad"
		
		This will erase the package "notepad" from the database and delete any physical files, such as the installer executable.
		
	#>
	
	[CmdletBinding()]
	Param (
		
		[Parameter(Mandatory = $true, Position = 0)]
		[AllowEmptyString()]
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
	$packageList = Import-PackageList	
	
	# Check that the name is not empty
	if ([System.String]::IsNullOrWhiteSpace($PackageName) -eq $true) {
		Write-Message -Message "The package name cannot be empty" -DisplayWarning
		return
	}
	
	# Check if package name exists
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
		
		# Check in case there is no folder for some reason?
		if ((Test-Path -Path "$script:DataPath\packages\$PackageName\") -eq $false) {
			Write-Message -Message "There are no files for this package in the package store. This should not happen." -DisplayError
			return
		}
		
		if ($RetainFiles -eq $true) {
			
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
			
			# Move the package files to the specified path
			Move-Item -Path "$script:DataPath\packages\$PackageName\" -Destination $Path
			
		}else {
			
			# Remove the package from the store
			Remove-Item -Path "$script:DataPath\packages\$PackageName\" -Recurse -Force
		
		}
		
	}elseif ($package.Type -eq "UrlPackage" -and $RetainFiles -eq $true) {
		
		# Notify user that -RetainFiles flag has no effect on a url package
		Write-Message -Message "The flag -RetainFiles has no effect on a url package" -DisplayWarning
		
	}
	
	# Remove the package from the list
	$packageList.Remove($package) | Out-Null
	
	# Export-out (modified) list to xml file
	Export-Data -Object $packageList -Path "$script:DataPath\packageDatabase.xml" -Type "Clixml"	
	
	
}