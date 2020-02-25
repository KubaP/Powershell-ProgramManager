function New-PMPackage {
	<#
	.SYNOPSIS
		Adds a program to the ProgramManager database.
		
	.DESCRIPTION
		Adds a new ProgramManager.Package to the database for future installation.
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
		A short note/description to explain what the package entry is.
		
	.PARAMETER PreInstallScriptblock
		A script block which will be executed before the main package installation process.
		
	.PARAMETER PostInstallScriptblock
		A script block which will be executed after the main package installation process.
		
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
		
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
		
	.EXAMPLE
		PS C:\> New-PMPackage -Name "notepad" -LocalPackage -PackageLocation "~\Downloads\notepad.msi" -Note "Notepad msi installer"
		
		Adds the locally stored program to the database with the specified name and short note.
		
	.EXAMPLE
		PS C:\> New-PMPackage -Name "notepad" -UrlPackage -PackageLocation "https://download/" -PreInstallScriptblock {Write-Host "installing notepad"}
		
		Adds the url-downloaded program to the database with the specified pre-install scriptblock.
		
	.EXAMPLE
		PS C:\> New-PMPackage -Name "notepad" -PortablePackage -PackageLocation "~\Downloads\program.zip" -InstallDirectory "D:\Programs\"
		
		Adds the portable program to the database with the specified install directory.
		
	.INPUTS
		None
		
	.OUTPUTS
		None
		
	#>	
	
	[CmdletBinding(DefaultParameterSetName = "LocalInstaller", SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
	Param (
		
		[Parameter(ParameterSetName = "LocalPackage", Mandatory = $true, Position = 0)]
		[Parameter(ParameterSetName = "UrlPackage", Mandatory = $true, Position = 0)]
		[Parameter(ParameterSetName = "PortablePackage", Mandatory = $true, Position = 0)]
		[Parameter(ParameterSetName = "ChocolateyPackage", Mandatory = $true, Position = 0)]
		[AllowEmptyString()]
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
		[AllowEmptyString()]
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
	
	# Import all PMPackage objects from the database file
	Write-Verbose "Loading existing packages from database"
	$packageList = Import-PackageList
	
	# Check that the name is not empty
	if ([System.String]::IsNullOrWhiteSpace($Name) -eq $true) {
		
		Write-Message -Message "The name cannot be empty" -DisplayWarning
		return
		
	}
	
	# Check that the name doesn't contain any characters which could cause potential issues
	if ($Name -like "*.*" -or $Name -like "*``**" -or $Name -like "*.``**") {
		
		Write-Message -Message "The name contains invalid characters" -DisplayWarning
		return
		
	}
	
	# Check if name is already taken
	$package = $packageList | Where-Object { $_.Name -eq $Name }
	if ($null -ne $package) {
		
		Write-Message -Message "There already exists a package called: $Name" -DisplayWarning
		return
		
	}
	
	# Check that the scriptblocks actually contain code
	if ($null -ne $PreInstallScriptblock) {
		
		if ([System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $true) {
			
			Write-Message -Message "The Pre-Install Scriptblock cannot be empty" -DisplayWarning
			return
			
		}
		
		if ($PreInstallScriptblock.ToString() -like "``*") {
			
			Write-Message -Message "The Pre-Install Scriptblock cannot just be '*'" -DisplayWarning
			return
			
		}
		
	}
	if ($null -ne $PostInstallScriptblock) {
		
		if ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $true) {
			
			Write-Message -Message "The Post-Install Scriptblock cannot be empty" -DisplayWarning
			return
			
		}
		
		if ($PostInstallScriptblock.ToString() -like "``*") {
			
			Write-Message -Message "The Post-Install Scriptblock cannot just be '*'" -DisplayWarning
			return
			
		}
		
	}
	
	# Create PMpackage object	
	Write-Verbose "Creating new ProgramManager.Package Object"
	$package = New-Object -TypeName psobject 
	$package.PSObject.TypeNames.Insert(0, "ProgramManager.Package")
	
	# Add compulsory properties
	Write-Verbose "Adding universal properties to object: name,type,isinstalled"
	$package | Add-Member -Type NoteProperty -Name "Name" -Value $Name
	$package | Add-Member -Type NoteProperty -Name "Type" -Value $PSCmdlet.ParameterSetName
	$package | Add-Member -Type NoteProperty -Name "IsInstalled" -Value $false
	
	if ((Test-Path -Path "$script:DataPath\packages\") -eq $false) {
		
		if ($PSCmdlet.ShouldProcess("$script:DataPath\packages", "Create the package store")) {
			
			# The packages subfolder doesn't exist. Create it to avoid errors with Move-Item
			New-Item -ItemType Directory -Path "$script:DataPath\packages\" -Confirm:$false | Out-Null
			
		}
		
	}
	
	# Check that the path is not empty
	if ([System.String]::IsNullOrWhiteSpace($Path) -eq $true) {
		
		Write-Message -Message "The path cannot be empty" -DisplayWarning
		return
		
	}
	
	# Check that the path doesn't contain any characters which could cause potential issues or undesirable effects
	if ($PackageLocation -like "." -or $PackageLocation -like ".``*" -or $PackageLocation -like "~" -or $PackageLocation -like ".." `
		-or $PackageLocation -like "...") {
			
		Write-Message -Message "The path provided is not accepted for safety reasons" -DisplayWarning
		return
		
	}
	
	if ($LocalPackage -eq $true) {
		Write-Verbose "Detected Local-Pacakge"
		
		# Check that the path is valid
		if ((Test-Path -Path $PackageLocation) -eq $false) {
			
			Write-Message -Message "There is no valid path pointing to: $PackageLocation" -DisplayWarning
			return
			
		}
		
		# Get the details of the executable and check whether it is actually a file
		$executable = Get-Item -Path $PackageLocation
		if ($executable.PSIsContainer -eq $true -or $executable.GetType().Name -eq "Object[]") {
			
			Write-Message -Message "There is no (single) executable located at the path: $PackageLocation" -DisplayWarning
			return
			
		}
		
		if (($executable.Extension -match ".exe|.msi") -eq $false) {
			
			Write-Message -Message "There is no installer file located at the path: $PackageLocation" -DisplayWarning
			return
			
		}
		
		if ($PSCmdlet.ShouldProcess("File: $PackageLocation", "Move the installer to the package store")) {
			
			# Move the executable to the package store
			Write-Verbose "Copying over installer to \packages\$Name\"
			New-Item -ItemType Directory -Path "$script:DataPath\packages\$Name\" -Confirm:$false | Out-Null
			Move-Item -Path $PackageLocation -Destination "$script:DataPath\packages\$Name\$($executable.Name)"	-Confirm:$false
			
		}
		
		# Add executable properties
		Write-Verbose "Adding properties: executable name & type"
		$package | Add-Member -Type NoteProperty -Name "ExecutableName" -Value $executable.Name
		$package | Add-Member -Type NoteProperty -Name "ExecutableType" -Value $executable.Extension
		
		# Add install directory if passed in
		if ([System.String]::IsNullOrWhiteSpace($InstallDirectory) -eq $false) {
			
			Write-Verbose "Adding property: install directory"
			$package | Add-Member -Type NoteProperty -Name "InstallDirectory" -Value $InstallDirectory
		
		}
		
	}elseif ($UrlPackage -eq $true) {
		Write-Verbose "Detected Url-Pacakge"
		
		# Add url property
		Write-Verbose "Adding property: download link"
		$package | Add-Member -Type NoteProperty -Name "Url" -Value $PackageLocation
		
		# Add install directory if passed in
		if ([System.String]::IsNullOrWhiteSpace($InstallDirectory) -eq $false) {
			
			Write-Verbose "Adding property: install directory"
			$package | Add-Member -Type NoteProperty -Name "InstallDirectory" -Value $InstallDirectory
		
		}
		
	}elseif ($PortablePackage -eq $true) {
		Write-Verbose "Detected Portable-Pacakge"
		
		# Check that a install directory parameter is given in
		if ([System.String]::IsNullOrWhiteSpace($InstallDirectory) -eq $true) {
			
			Write-Message -Message "The install directory path must not be empty" -DisplayWarning
			return
			
		}
		
		# Check that the path is valid
		if ((Test-Path -Path $PackageLocation) -eq $false) {
			
			Write-Message -Message "There is no folder/file located at the path: $PackageLocation" -DisplayWarning
			return
			
		}
		
		Write-Verbose "Retrieving item located at: $PackageLocation"
		$item = Get-Item -Path $PackageLocation
		
		# There are multiple items collected under this file path so reject it
		if ($item.GetType().Name -eq "Object[]") {
			
			Write-Message -Message "You cannot specify multiple items in the filepath" -DisplayWarning
			return
			
		}
		
		if ((Get-Item -Path $PackageLocation).PSIsContainer -eq $true) {
			
			if ($PSCmdlet.ShouldProcess("Folder: $PackageLocation", "Move the package container to the package store")) {
				
				# This is a folder so can be moved straight to the package store
				Write-Verbose "Detected container. Moving folder to \packages\$Name\"
				Move-Item -Path $PackageLocation -Destination "$script:DataPath\packages\$Name" -Confirm:$false
				
			}
			
		}else {
			
			# This is a file so check if its an archive to extract
			$file = Get-Item -Path $PackageLocation
			
			# Check if the file has an 'archive' attribute
			if ($file.Extension -eq ".zip" -or $file.Extension -eq ".tar") {
				
				if ($PSCmdlet.ShouldProcess("Archive: $PackageLocation", "Extract the archive to temporary path")){
					
					# Extract archive to parent location and delete the original
					# Must set do this trickery to stop confirmation prompts, since passing -Confirm:$false to Expand-Archive
					# doen't propogate that to the individual New-Item -Directory commands, and each one would generate a prompt
					Write-Verbose "Detected archive. Extracting archive to \temp\"
					$originalConfirmPrefrence = $ConfirmPreference
					$ConfirmPreference = "None"
					Expand-Archive -Path $PackageLocation -DestinationPath "$script:DataPath\temp"
					$ConfirmPreference = $originalConfirmPrefrence
					Remove-Item -Path $PackageLocation -Force -Confirm:$false
					
				}
				
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
						
						if ($PSCmdlet.ShouldProcess("Folder: $currentDir", "Move the package container to the package store")) {
							Write-Verbose "Moving folder to \packages\$Name\"
							Move-Item -Path $currentDir -Destination "$script:DataPath\packages\$Name" -Confirm:$false
						}
						
					}
					
				} while ($children.Count -eq 1 -and $children[0].PSIsContainer -eq $true)
				
				Write-Verbose "Cleaning up \temp\"
				Remove-Item -Path "$script:DataPath\temp\" -Recurse -Force -Confirm:$false
				
			}elseif ($file.Extension -eq ".exe") {
				
				if ($PSCmdlet.ShouldProcess("File: $PackageLocation", "Move the executable to the package store")) {
					# This is a portable package with only a single exe file
					Write-Verbose "Detected executable. Moving program to \packages\$Name\"
					New-Item -ItemType Directory -Path "$script:DataPath\packages\$Name\" -Confirm:$false | Out-Null
					Move-Item -Path $PackageLocation -Destination "$script:DataPath\packages\$Name\$($file.Name)" -Confirm:$false
				}
				
			}else {
				
				# This is a file of an invalid type for this package type
				Write-Message -Message "The file specified is neither a executable nor an archive" -DisplayWarning
				return
				
			}
			
		}
		
		# Add necessary properties	
		Write-Verbose "Adding property: install directory"
		$package | Add-Member -Type NoteProperty -Name "InstallDirectory" -Value $InstallDirectory
		
	}elseif ($ChocolateyPackage -eq $true) {
		Write-Verbose "Detected Chocolatey-Pacakge"
		
		# Add necessary info for chocolatey to work
		Write-Verbose "Adding property: chocolatey package name"
		$package | Add-Member -Type NoteProperty -Name "PackageName" -Value $PackageName
		
	}
	
	# Add optional note property if passed in
	if ([System.String]::IsNullOrWhiteSpace($Note) -eq $false) {
		
		Write-Verbose "Adding property: note"
		$package | Add-Member -Type NoteProperty -Name "Note" -Value $Note	
			
	}
	
	# Add optional scriptblock proprties if passed in
	if ($null -ne $PreInstallScriptblock) {
		
		Write-Verbose "Adding property: pre-install scriptblock"
		$package | Add-Member -Type NoteProperty -Name "PreInstallScriptblock" -Value $PreInstallScriptblock.ToString()
	
	}
	
	if ($null -ne $PostInstallScriptblock) {
		
		Write-Verbose "Adding property: post-install scriptblock"
		$package | Add-Member -Type NoteProperty -Name "PostInstallScriptblock" -Value $PostInstallScriptblock.ToString()
	
	}
	
	
	if ($PSCmdlet.ShouldProcess("$script:DataPath\packageDatabase.xml", "Add the package `'$Name`'")) {
		
		# Add new PMPackage to list
		$packageList.Add($package)
		
		# Export-out package list to xml file
		Write-Verbose "Writing-out data back to database"
		Export-PackageList -PackageList $packageList
		
	}
	
	
}