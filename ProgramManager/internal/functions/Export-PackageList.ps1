function Export-PackageList {
	<#
	.SYNOPSIS
		Exports package list
		
	.DESCRIPTION
		Exports ProgramManager.Package List to xml database.
		
	.PARAMETER PackageList
		The System.Collections.Generic.List[psobject] of packages to serialise.
		
	.EXAMPLE
		PS C:\> Export-Data -PackageList $packages
		
		Exports the $packages list to the module root folder
		
	#>
	
	[CmdletBinding()]
	Param (
		
		[Parameter(Mandatory = $true, Position = 0)]
		[System.Collections.Generic.List[psobject]]
		[AllowEmptyCollection()]
		$PackageList
		
	)
	
	Export-Clixml -Path "$script:DataPath\packageDatabase.xml" -InputObject $PackageList
	
	
}