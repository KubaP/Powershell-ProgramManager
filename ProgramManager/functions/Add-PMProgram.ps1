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
		
	.PARAMETER InstallerPath
		The path which points to the installer package.
		
	.PARAMETER Url
		The url which points to a direct download link for a package.
		
	.PARAMETER PackageName
		The name of a chocolatey package.
		
	.PARAMETER InstallDirectory
		The directory into which to extract the contents of a zip package (manual install).
		
	.PARAMETER Note
		A short note/description to explain what the package entry is.
		
	.EXAMPLE
		PS C:\> Add-PMProgram -Name "chrome" -InstallerPath "C:\Users\<user>\Downloads\chrome.msi" -Note "Chrome msi package"
		
		Adds the program to the database with the specified name and short note.
		
	.NOTES
		There is no need to specify between exe or msi pacakges. The module automatically detects that.
	#>	
	
	[CmdletBinding(DefaultParameterSetName = "LocalInstaller")]
	Param (
		[Parameter(ParameterSetName = "LocalInstaller", Mandatory = $true, Position = 0)]
		[Parameter(ParameterSetName = "UrlInstaller", Mandatory = $true, Position = 0)]
		[Parameter(ParameterSetName = "Chocolatey", Mandatory = $true, Position = 0)]
		[Parameter(ParameterSetName = "Zip", Mandatory = $true, Position = 0)]
		[string]
		$Name,
		
		[Parameter(ParameterSetName = "LocalInstaller", Mandatory = $true, Position = 1)]
		[string]
		$InstallerPath,
		
		[Parameter(ParameterSetName = "UrlInstaller", Mandatory = $true, Position = 1)]
		[Parameter(ParameterSetName = "Zip", Mandatory = $true, Position = 1)]
		[string]
		$Url,
		
		[Parameter(ParameterSetName = "Chocolatey", Mandatory = $true, Position = 1)]
		[string]
		$PackageName,
		
		[Parameter(ParameterSetName = "Zip", Mandatory = $true, Position = 2)]
		[string]
		$InstallDirectory,
				
		[Parameter(ParameterSetName = "LocalInstaller")]
		[Parameter(ParameterSetName = "UrlInstaller")]
		[Parameter(ParameterSetName = "Chocolatey")]
		[Parameter(ParameterSetName = "Zip")]
		[string]
		$Note
	)
	
	# Create list of all PMProgram objects
	$programList = [System.Collections.Generic.List[psobject]]@()
	
	# Check if the xml database already exists
	if ((Test-Path -Path "$env:USERPROFILE\Documents\Powershell\programManagerDatabase.xml") `
			-eq $true) {
		# The xml database exists
		# Load all existing PMPrograms into a list
		$xmlData = Import-Data -Path "$env:USERPROFILE\Documents\Powershell\programManagerDatabase.xml" `
			-Type "Clixml"
		
		# Iterate through all imported objects
		foreach ($obj in $xmlData) {
			# Only operate on PMProgram objects
			if ($obj.psobject.TypeNames[0] -eq "Deserialized.ProgramManager.Program") {
				# Create new PMProgram objects
				$existingProgram = New-Object -TypeName psobject 
				$existingProgram.PSObject.TypeNames.Insert(0, "ProgramManager.Program")
				
				# Copy the properties from the Deserialized object into the new one
				foreach ($property in $obj.psobject.Properties) {
					$existingProgram | Add-Member -Type NoteProperty -Name $property.Name -Value $property.Value
				}
				
				$programList.Add($existingProgram)
			}
		}
		
		# Check if name is already taken
		$program = $programList | Where-Object { $_.Name -eq $Name }
		if ($null -ne $program) {
			"There already exists a program called: $Name" | Write-Host
			break
		}
	}
		
	# Create PMProgram object	
	$program = New-Object -TypeName psobject 
	$program.PSObject.TypeNames.Insert(0, "ProgramManager.Program")
	
	# Add compulsary properties
	$program | Add-Member -Type NoteProperty -Name "Name" -Value $Name
	$program | Add-Member -Type NoteProperty -Name "ProgramType" -Value $ProgramType
	$program | Add-Member -Type NoteProperty -Name "InstallerPath" -Value $InstallerPath
	
	# Add optional properties if passed in
	if ([System.String]::IsNullOrWhiteSpace($Note)) {
		$program | Add-Member -Type NoteProperty -Name "Note" -Value $Note		
	}
		
	# Add new PMProgram to list
	$programList.Add($program)
		
	# Export-out list to xml file
	Export-Data -Object $programList -Path "$env:USERPROFILE\Documents\Powershell\programManagerDatabase.xml" `
		-Type "Clixml"
	
	
}