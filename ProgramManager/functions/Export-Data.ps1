﻿function Export-Data {
	<#
	.SYNOPSIS
		Exports data to a specified format.
		
	.DESCRIPTION
		Exports data to a specified format.
		
	.PARAMETER Object
		Object to export. Object type not specified to allow for flexibility.
		
	.PARAMETER Path
		Path to export the object to.
		
	.PARAMETER Type
		The type of export-object to use.
	
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