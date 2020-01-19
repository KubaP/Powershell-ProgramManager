function Import-Data {
	<#
	.SYNOPSIS
		Imports data from a specified format.
	.DESCRIPTION
		Imports data from a specified format.
	.EXAMPLE
		PS C:\> Import-Data -Path "$env:appdata\data.xml" -Type "clixml"
		
		Imports data from a clixml (serialized object) file.
	#>
	
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, Position = 0)]
		[string]
		$Path,
		
		[Parameter(Mandatory = $true, Position = 1)]
		[ValidateSet("Clixml")]
		[string]
		$Type
	)
	
	# Test the path to ensure the file exists before importing
	if ((Test-Path -Path $Path) -eq $false) {
		"Error on importing data. Could not find file: $Path" | `
			Write-Error -Category InvalidData
		break
	}
	
	if ($Type -eq "Clixml") {
		# Import serialised psobjects from the xml file
		$importData = Import-Clixml -Path $Path
	}
	
	# Return the data
	return $importData
	
}