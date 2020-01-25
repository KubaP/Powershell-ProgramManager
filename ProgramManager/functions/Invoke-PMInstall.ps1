function Invoke-PMInstall {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Name,
        
        [Parameter(Position = 1)]
        [switch]
        $ShowUI
        
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
    
    # If its a url package, download it and set some properties to allow the installation code to run
    if ($package.Type -eq "UrlPackage") {
        
        # Download the installer from the url
        Invoke-WebRequest -Uri $package.Url -OutFile "$dataPath\$($package.Name)\installer.something"
        
        # Set executable properties in the package object to allow later code to run correctly
        $package | Add-Member -Type NoteProperty -Name "ExecutableName" -Value "installer"
        $package | Add-Member -Type NoteProperty -Name "ExecutableType" -Value "something"
        
    }
    
    # Installation logic
    if ($package.Type -eq "LocalPackage" -or $package.Type -eq "UrlPackage") {
        
        if ($package.ExecutableType -eq ".exe") {
            
            # Start the exe installer
            Start-Process -FilePath $dataPath\$package.Name\$package.ExecutableName
            
        }elseif ($package.ExecutableType -eq ".msi") {
                        
            # Set the display argument for msiexec
            if ($ShowUI -eq $true) {
                $dislayArgument = "/qr "
            }else {
                $dislayArgument = "/qn "
            }
            
            # Set the logging argument for msiexec
            if ($NoLog -eq $true) {
                $logArgument = ""
            }else {
                $logArgument = "/l*v `"$dataPath\install-$($apckage.Name)-$(Get-Date -Format "yyyy/MM/dd HH:mm").txt`""
            }
            
            # If the package has a defined install directory, set the msiexec argument to that
            if ([System.String]::IsNullOrWhiteSpace($package.InstallDirectory) -eq $false) {
                $paramArgument = "INSTALL_PREFIX_1=`"$($package.InstallDirectory)`""
            }
            
            # Set the msiexec arguments
            $processStartupInfo = New-Object System.Diagnostics.ProcessStartInfo -Property @{
                FileName = "msiexec.exe"
                Arguments = "$dataPath\packages\$($package.Name)\$($package.ExecutableName) " + $dislayArgument + $logArgument + $paramArgument
                UseShellExecute = $false
            }
            
            # Start msiexec and wait until it's finished
            $process = New-Object System.Diagnostics.Process
            $process.StartInfo = $processStartupInfo
            $process.Start()
            
            $process.WaitForExit()
            $process.Dispose()
                        
        }
        
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