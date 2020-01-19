function Export-Data {
	<#
	.SYNOPSIS
		Exports data to a specified format.
	.DESCRIPTION
		Exports data to a specified format.
	.EXAMPLE
		PS C:\> Export-Data -Object $psobject -Path "$env:appdata\data.xml" -Type "clixml"
		
		Exports $psobject by calling Export-Clixml to the specified path.
	#>
	
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, Position = 0)]
		$Object,
		
		[Parameter(Mandatory = $true, Position = 1)]
		[string]
		$Path,
		
		[Parameter(Mandatory = $true, Position = 2)]
		[ValidateSet("Clixml")]
		[string]
		$Type
	)
	
	
	if ($Type -eq "Clixml") {
		$Object | Export-Clixml -Path $Path
	}
	
	
}