function Get-PMPackage {
    <#
    .SYNOPSIS
        Get information about a specified package.
    
    .DESCRIPTION
        Returns the specified PMPackage object, for display to terminal.
        
    .PARAMETER PackageName
        The name of the package to retrieve.
    
    .EXAMPLE
        PS C:\> Get-PMPackage -PackageName "notepad"
        
        Returns information about the "notepad" package.
    #>
    
    [CmdletBinding()]
    Param (
        
        [Parameter(Mandatory = $true, Position = 0)]
        [AllowEmptyString()]
        [string]
        $PackageName
        
    )
    
    # Import all PMPackage objects from the database file
    $packageList = Import-PackageList
    
    # Check that the name is not empty
	if ([System.String]::IsNullOrWhiteSpace($PackageName) -eq $true) {
		Write-Message -Message "The name cannot be empty" -DisplayWarning
		return
    }
    
    # Check if package exists
	$package = $packageList | Where-Object { $_.Name -eq $PackageName }
	if ($null -eq $package) {
		Write-Message -Message "There is no package called: $PackageName" -DisplayWarning
		return
	}
    
    # Output the package object
    Write-Output $package
    
}