function Export-Data {
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