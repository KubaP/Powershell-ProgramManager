function Get-PMPackage {
    <#
    .SYNOPSIS
        Get information about a specified package.
    
    .DESCRIPTION
        Returns the specified PMPackage object, for display to terminal.
    
    .PARAMETER PackageName
        The name of the package to retrieve.
    
    .PARAMETER ShowFullDetail
        Toggles whether it shows a overview of the package with the usually important properties,
        or whether it shows every single property of the package, some of which will not have much use for the user.
    
    .EXAMPLE
        PS C:\> Get-PMPackage -PackageName "notepad"
        
        Returns information about the "notepad" package.
    #>
    
    [CmdletBinding()]
    Param (
        
        [Parameter(Mandatory = $true, Position = 0)]
        [AllowEmptyString()]
        [string]
        $PackageName,
        
        [Parameter(Position = 1)]
        [switch]
        $ShowFullDetail
        
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
    <#
        TODO: figure out how exactly custom format types work
    # Append the View object type to control the visual output of the object depending on the user's preference
    if ($ShowFullDetail -eq $true) {        
        $package.PSObject.TypeNames.Insert(1, "ProgramManager.Package-View.Full")        
    }else {        
        $package.PSObject.TypeNames.Insert(1, "ProgramManager.Package-View.Overview")        
    }
    #>
    
    # Output the package object
    Write-Output $package
    
}