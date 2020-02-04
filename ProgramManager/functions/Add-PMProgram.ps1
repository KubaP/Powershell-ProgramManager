function Add-PMProgram {
	<#
	.SYNOPSIS
		Adds a program to the ProgramManager database.
		
	.DESCRIPTION
		Adds a program to the ProgramManager database for future installation.
		Accepts the following:
		- msi/exe installer (local file or url download)
		- zip binary
		- chocolatey package
		
	.PARAMETER Name
		The name of the program to add to the database.
		
	.PARAMETER LocalPackage
		Specifies the use of a local installer file located at an available path.
	
	.PARAMETER UrlPackage
		Specifies the use of an installer file located at a url.
	
	.PARAMETER PortablePackage
		Specifies the use of a portable binary file located at a path or url.
	
	.PARAMETER ChocolateyPackage
		Specifies the use of a chocolatey package.
	
	.PARAMETER PackageLocation
		The location of the package.
		- For LocalPackage: file path pointing to the executable
		- For UrlPackage: url pointing to download link
		- For PortablePackaage: file path pointing to the folder
		
	.PARAMETER InstallDirectory
		The directory to which install the pacakge to.
		
	.PARAMETER PackageName
		The name of a chocolatey package. To be used with the -ChocolateyPackage switch.
	
	.PARAMETER Note
		A short note/description to explain what the package entry is. Optonal
		
	.PARAMETER PreInstallScriptblock
		A script block which will be executed before the main package installation process.
		
	.PARAMETER PostInstallScriptblock
		A script block which will be executed after the main package installation process.
		
	.EXAMPLE
		PS C:\> Add-PMProgram -Name "chrome" -LocalPackage -PackageLocation "C:\Users\<user>\Downloads\chrome.msi" -Note "Chrome msi installer"
		
		Adds the program to the database with the specified name and short note.

	#>	
	
	[CmdletBinding(DefaultParameterSetName = "LocalInstaller")]
	Param (
		[Parameter(ParameterSetName = "LocalPackage", Mandatory = $true, Position = 0)]
		[Parameter(ParameterSetName = "UrlPackage", Mandatory = $true, Position = 0)]
		[Parameter(ParameterSetName = "PortablePackage", Mandatory = $true, Position = 0)]
		[Parameter(ParameterSetName = "ChocolateyPackage", Mandatory = $true, Position = 0)]
		[string]
		$Name,
		
		
		[Parameter(ParameterSetName = "LocalPackage", Mandatory = $true, Position = 1)]
		[switch]
		$LocalPackage,
		
		[Parameter(ParameterSetName = "UrlPackage", Mandatory = $true, Position = 1)]
		[switch]
		$UrlPackage,
		
		[Parameter(ParameterSetName = "PortablePackage", Mandatory = $true, Position = 1)]
		[switch]
		$PortablePackage,
		
		[Parameter(ParameterSetName = "ChocolateyPackage", Mandatory = $true, Position = 1)]
		[switch]
		$ChocolateyPackage,
		
		
		[Parameter(ParameterSetName = "LocalPackage", Mandatory = $true, Position = 2)]
		[Parameter(ParameterSetName = "UrlPackage", Mandatory = $true, Position = 2)]
		[Parameter(ParameterSetName = "PortablePackage", Mandatory = $true, Position = 2)]
		[string]
		$PackageLocation,
		
		[Parameter(ParameterSetName = "LocalPackage", Position = 3)]
		[Parameter(ParameterSetName = "UrlPackage", Position = 3)]		
		[Parameter(ParameterSetName = "PortablePackage", Mandatory = $true, Position = 3)]
		[AllowEmptyString()]
		[string]
		$InstallDirectory,
				
		[Parameter(ParameterSetName = "ChocolateyPackage", Mandatory = $true, Position = 2)]
		[string]
		$PackageName,
		
		
		[Parameter(ParameterSetName = "LocalPackage")]
		[Parameter(ParameterSetName = "UrlPackage")]
		[Parameter(ParameterSetName = "PortablePackage")]
		[Parameter(ParameterSetName = "ChocolateyPackage")]
		[AllowEmptyString()]
		[string]
		$Note,
		
		[Parameter(ParameterSetName = "LocalPackage")]
		[Parameter(ParameterSetName = "UrlPackage")]
		[Parameter(ParameterSetName = "PortablePackage")]
		[Parameter(ParameterSetName = "ChocolateyPackage")]
		[AllowEmptyString()]
		[scriptblock]
		$PreInstallScriptblock,
		
		[Parameter(ParameterSetName = "LocalPackage")]
		[Parameter(ParameterSetName = "UrlPackage")]
		[Parameter(ParameterSetName = "PortablePackage")]
		[Parameter(ParameterSetName = "ChocolateyPackage")]
		[AllowEmptyString()]
		[scriptblock]
		$PostInstallScriptblock
		
	)
	
	# If no name specified, abort
	if ([System.String]::IsNullOrWhiteSpace($Name)) {
		break
	}
	
	# Import all PMPackage objects from the database file
	$packageList = Import-PackageList
	if ($null -eq $packageList) {
		$packageList = [System.Collections.Generic.List[psobject]]@()
	}
	
	# Check if name is already taken
	$package = $packageList | Where-Object { $_.Name -eq $Name }
	if ($null -ne $package) {
		"There already exists a package called: $Name" | Write-Error
		break
	}
		
	# Create PMpackage object	
	$package = New-Object -TypeName psobject 
	$package.PSObject.TypeNames.Insert(0, "ProgramManager.Package")
	
	# Add compulsary properties
	$package | Add-Member -Type NoteProperty -Name "Name" -Value $Name
	$package | Add-Member -Type NoteProperty -Name "Type" -Value $PSCmdlet.ParameterSetName
	$package | Add-Member -Type NoteProperty -Name "IsInstalled" -Value $false
	
	if ((Test-Path -Path "$script:DataPath\packages\") -eq $false) {
		# The packages subfolder doesn't exist. Create it to avoid errors with Move-Item
		New-Item -ItemType Directory -Path "$script:DataPath\packages\"
	}
	
	if ($LocalPackage -eq $true) {	
		
		# Check that the path is valid
		if ((Test-Path -Path $PackageLocation) -eq $false) {
			"There is no executable located at the path: $PackageLocation" | Write-Error
			break
		}
		
		# Get the details of the executable and move it to the package store
		$executable = Get-Item -Path $PackageLocation
		New-Item -ItemType Directory -Path "$script:DataPath\packages\$Name\"
		Move-Item -Path $PackageLocation -Destination "$script:DataPath\packages\$Name\$($executable.Name)"
		
		# Add executable properties
		$package | Add-Member -Type NoteProperty -Name "ExecutableName" -Value $executable.Name
		$package | Add-Member -Type NoteProperty -Name "ExecutableType" -Value $executable.Extension
		
		# Add install directory if passed in
		if ([System.String]::IsNullOrWhiteSpace($InstallDirectory) -eq $false) {
			$package | Add-Member -Type NoteProperty -Name "InstallDirectory" -Value $InstallDirectory
		}
		
	}elseif ($UrlPackage -eq $true) {	
		
		# Add url property	
		$package | Add-Member -Type NoteProperty -Name "Url" -Value $PackageLocation
		
		# Add install directory if passed in
		if ([System.String]::IsNullOrWhiteSpace($InstallDirectory)) {
			$package | Add-Member -Type NoteProperty -Name "InstallDirectory" -Value $InstallDirectory
		}
		
	}elseif ($PortablePackage -eq $true) {
		
		# Check that the path is valid
		if ((Test-Path -Path $PackageLocation) -eq $false) {
			"There is no folder/file located at the path: $PackageLocation" | Write-Error
			break
		}
		
		if ((Get-Item -Path $PackageLocation).PSIsContainer -eq $true) {
			
			# This is a folder so can be moved straight to the package store
			Move-Item -Path $PackageLocation -Destination "$script:DataPath\packages\$Name"
						
			Remove-Item -Path "$script:DataPath\temp" -Recurse -Force
			
		}else {
			
			# This is a file so check if its an archive to extract
			$file = Get-Item -Path $PackageLocation
			
			# Check if the file has an 'archive' attribute
			if ($file.Extension -eq ".zip" -or $file.Extension -eq ".tar") {
				
				# Extract archive to parent location
				Expand-Archive -Path $PackageLocation -DestinationPath "$script:DataPath\temp"
				
				# Set the current directory to the extracted-archive location, initialising for the do-loop
				$currentDir = "$script:DataPath\temp"
				
				# Recursively look into the folder heirarchy until there is no more folders containing a single folder
				# i.e. stops having folder1 -> folder2 -> folder3 -> contents
				do {
					
					# Get all children within the current folder
					$children = Get-ChildItem -Path $currentDir
					
					# If there is only a single child and its a folder, move down the tree
					# Otherwise move the item to the package store
					if ($children.Count -eq 1 -and $children[0].PSIsContainer -eq $true) {
						$currentDir = $children.FullName
					}else {
						Move-Item -Path $currentDir -Destination "$script:DataPath\packages\$Name"
					}
					
				} while ($children.Count -eq 1 -and $children[0].PSIsContainer -eq $true)
														
			}elseif ($file.Extension -eq ".exe") {
				
				# This is a portable package with only a single exe file				
				New-Item -Path "$script:DataPath\packages\$Name-$($file.BaseName)" -ItemType Directory			
				Move-Item -Path $PackageLocation -Destination "$script:DataPath\packages\$Name\$($file.Name)"
				
			}
			
		}		
		
		# Add necessary properties	
		$package | Add-Member -Type NoteProperty -Name "InstallDirectory" -Value $InstallDirectory
		
	}elseif ($ChocolateyPackage -eq $true) {
		
		# Add necessary info for chocolatey to work
		$package | Add-Member -Type NoteProperty -Name "PackageName" -Value $PackageName
		
	}
	
	# Add optional note property if passed in
	if ([System.String]::IsNullOrWhiteSpace($Note) -eq $false) {
		$package | Add-Member -Type NoteProperty -Name "Note" -Value $Note		
	}
	
	# Add optional scriptblock properties if passed in
	if ([System.String]::IsNullOrWhiteSpace($PreInstallScriptblock) -eq $false) {
		$package | Add-Member -Type NoteProperty -Name "PreInstallScriptblock" -Value $PreInstallScriptblock
	}
	
	if ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock) -eq $false) {
		$package | Add-Member -Type NoteProperty -Name "PostInstallScriptblock" -Value $PostInstallScriptblock
	}
	
	
	# Add new PMpackage to list
	$packageList.Add($package)
		
	# Export-out list to xml file
	Export-Data -Object $packageList -Path "$script:DataPath\packageDatabase.xml" -Type "Clixml"	
	
	
}