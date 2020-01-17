function Add-PMProgram {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, Position = 0)]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true, Position = 1)]
		[string]
		$ProgramType,
		
		[Parameter(Mandatory = $true, Position = 2)]
		[string]
		$InstallerPath
	)
	
	
	# Check if the xml database already exists
	if ((Test-Path -Path "$env:USERPROFILE\Documents\Powershell\programManagerDatabase.xml") -eq $true) {
		# The xml database exists
		# Load all existing PMPrograms into a list
		$xmlData = Import-Data -Path "$env:USERPROFILE\Documents\Powershell\programManagerDatabase.xml" -Type "Clixml"
	}
	
	# Create list of all PMProgram objects
	
	# 
	# Check whether name is already taken
	#   Offer to update existing program entry with newly specified values?
	#
		
	
	
	# Create PMProgram psobject
	$programObject = [PSCustomObject]@{
		
		Name = $Name
		Type = $ProgramType
		InstallerPath = $InstallerPath
		
	}
	
	# Add new object to list
	
	# Export out list to xml file
	
	
	
}