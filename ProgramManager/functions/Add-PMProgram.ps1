function Add-PMProgram {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, Position = 0)]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateSet("exe","msi","chocolatey","zip")]
		[string]
		$ProgramType,
		
		[Parameter(Mandatory = $true, Position = 2)]
		[string]
		$InstallerPath,
		
		[Parameter(Mandatory = $true, Position = 2)]
		[string]
		$InstallDirectory,
		
		[Parameter()]
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
	$program | Add-Member -Type NoteProperty -Name "InstallDirectory" -Value $InstallDirectory
	
	# Add optional properties if passed in
	if ($Note -ne "") {
		$program | Add-Member -Type NoteProperty -Name "Note" -Value $Note		
	}
		
	# Add new PMProgram to list
	$programList.Add($program)
		
	# Export-out list to xml file
	Export-Data -Object $programList -Path "$env:USERPROFILE\Documents\Powershell\programManagerDatabase.xml" `
		-Type "Clixml"
	
	
}