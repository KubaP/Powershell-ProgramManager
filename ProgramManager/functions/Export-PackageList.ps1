function Export-PackageList {
	<#
	.SYNOPSIS
		Exports data to a specified format.
		
	.DESCRIPTION
		Exports data to a specified format.
		
	.PARAMETER PackageList
		The System.Collections.Generic.List[psobject] of packages to export back.

	.EXAMPLE
		PS C:\> Export-Data -PackageList $packages
		
		Exports the $packages list to the module root folder
	#>
	
	[CmdletBinding()]
	Param (
		
		[Parameter(Mandatory = $true, Position = 0)]
		[System.Collections.Generic.List[psobject]]
		$PackageList
		
	)
	
	Export-Clixml -Path "$script:DataPath\packageDatabase.xml" -InputObject $PackageList
	
	
}