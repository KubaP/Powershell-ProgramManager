function Set-PMPackage {
    <#
    .SYNOPSIS
        Sets a property of a package.
        
    .DESCRIPTION
        Modifies an existing or creates a new property for a PMPackage object.
        
    .PARAMETER PackageName
        The name of the pacakge to modify.
        
    .PARAMETER PropertyName
        The name of the property to modify.
        
    .PARAMETER PropertyValue
        The new value of the property to set.
    
    .PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
		
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
		
    .EXAMPLE
        PS C:\> Set-PMPackage -PackageName "notepad" -PropertyName "Note" -PropertyValue "A new description"
        
        This will set the 'Note' property to the passed in value for the 'notepad' package.
        If this property already exists, it will be modified. If this property doesn't exist, it will be created.
    #>
    
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        
        [Parameter(Mandatory = $true, Position = 0)]
        [AllowEmptyString()]
        [string]
        $PackageName,
        
        [Parameter(Mandatory = $true, Position = 1)]
        [AllowEmptyString()]
        [string]
        $PropertyName,
        
        [Parameter(Mandatory = $true, Position = 2)]
        [AllowEmptyString()]
        [string]
        $PropertyValue
        
    )
    
    # Import all PMPackage objects from the database file
	$packageList = Import-PackageList	
	
	# Check that the name is not empty
	if ([System.String]::IsNullOrWhiteSpace($PackageName) -eq $true) {
		Write-Message -Message "The package name cannot be empty" -DisplayWarning
		return
	}
	
	# Check if package name exists
	$package = $packageList | Where-Object { $_.Name -eq $PackageName }
	if ($null -eq $package) {
		Write-Message -Message "There is no package called: $PackageName" -DisplayWarning
		return
	}
	
	# Check that the property name is not empty
	if ([System.String]::IsNullOrWhiteSpace($PropertyName) -eq $true) {
		Write-Message -Message "The property name cannot be empty" -DisplayWarning
		return
    }
    
    # Check that the property name is valid
    $property = $package.psobject.properties | Where-Object { $_.Name -eq $PropertyName }
    if ($null -eq $property) {
        Write-Message -Message "There is no property called: $PropertyName in package $PackageName" -DisplayWarning
        return
    }
    
    # Set the value to the newly specified value
    $property.Value = $PropertyValue
        
    if ($PSCmdlet.ShouldProcess("$script:DataPath\packageDatabase.xml", "Edit the package `'$PackageName`'")){
        
        # Export-out package list to xml file
        Export-PackageList -PackageList $packageList
        
	}
    
    
}