function Invoke-PMInstall {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Name
    )
    
    $dataPath = "$env:USERPROFILE\ProgramManager"
        
    # Create list of all PMProgram objects
	$packageList = [System.Collections.Generic.List[psobject]]@()
	
	# Check if the xml database already exists
    if ((Test-Path -Path "$dataPath\packageDatabase.xml") -eq $true) {
        
		# The xml database exists
		# Load all existing PMPrograms into a list
		$xmlData = Import-Data -Path "$dataPath\packageDatabase.xml" -Type "Clixml"
		
		# Iterate through all imported objects
		foreach ($obj in $xmlData) {
			# Only operate on PMProgram objects
			if ($obj.psobject.TypeNames[0] -eq "Deserialized.ProgramManager.Package") {
				# Create new PMProgram objects
				$existingPackage = New-Object -TypeName psobject 
				$existingPackage.PSObject.TypeNames.Insert(0, "ProgramManager.Package")
				
				# Copy the properties from the Deserialized object into the new one
				foreach ($property in $obj.psobject.Properties) {
					$existingPackage | Add-Member -Type NoteProperty -Name $property.Name -Value $property.Value
				}
				
                $packageList.Add($existingPackage)
                
			}
		}
		
	}else {
        
        # The xml database doesn't exist, abort
        "The database file doesn't exist. Run Add-PMProgram to initialise it." | Write-Error
        break
        
    }
    
    # Get the package by name
    $package = $packageList | Where-Object { $_.Name -eq $Name }
    if ($null -eq $package) {
        "There is no package called: $Name" | Write-Error
        break
    }
    
    if ($package.Type -eq "LocalPackage") {
        
        if ($package.ExecutableType -eq ".exe") {
            
        }elseif ($package.ExecutableType -eq ".msi") {
            
            msiexec.exe /i "$dataPath\packages\$($package.Name)\$($package.ExecutableName)" /qb /l*v "$dataPath\latestlog.txt" PARAMETERS
            
        }
        
    }elseif ($package.Type -eq "UrlPackage") {
        
        
    }elseif ($package.Type -eq "PortablePackage") {
        
        # Check that the install directory exists, otherwise abort
        if ((Test-Path -Path $package.InstallDirectory) -eq $false) {
            "The install directory is invalid: $($package.InstallDirectory)" | Write-Error
            break
        }
                
        # Copy package folder to install directory
        Copy-Item -Path "$dataPath\packages\$($package.Name)" -Destination $package.InstallDirectory -Container -Recurse
        
        #
        #! At some point, add support for post-install scriptblock execution
        #       -> mainly for the copying of shortcuts, startup etc
        
    }elseif ($package.Type -eq "ChocolateyPackage") {
        
        
    }
            
    
}