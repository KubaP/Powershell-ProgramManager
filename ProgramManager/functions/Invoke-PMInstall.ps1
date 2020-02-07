function Invoke-PMInstall {
    <#
    .SYNOPSIS
        Installs a ProgramManager package.
        
    .DESCRIPTION
        Installs a ProgramManager package from the database.
        
    .PARAMETER PackageName
        The name of the ProgramManager package to install.
        
    .PARAMETER ShowUI
        A switch to show the installation UI for msi installers.
        This does not affect exe installers since they have no standard switches.
        This does not affect portable packages or chocolatey packages either.
        
    .EXAMPLE
        PS C:\> Invoke-PMInstall -Name "chrome"
        
        Will install the package named "chrome" found within the database.
    #>
    
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]
        $PackageName,
        
        [Parameter(Position = 1)]
        [switch]
        $ShowUI
        
    )
            
    
	# Check if the xml database  exists
    if ((Test-Path -Path "$script:DataPath\packageDatabase.xml") -eq $true) {
        
		# Load all existing PMPrograms into a list
		$packageList = Import-PackageList
		
	}else {
        
        # The xml database doesn't exist, abort
        Write-Message -Message "The database file doesn't exist. Run Add-PMPackage to initialise it." -DisplayWarning
        return
        
    }
    
    # Iterate through all passed package names
    foreach ($name in $PackageName) {
        
        # Check if the package has a pre-install scriptblock and run it
        if ($null -ne $package.PreInstallScriptblock) {
            $package.PreInstallScriptblock()
        }
    
        # Get the package by name
        $package = $packageList | Where-Object { $_.Name -eq $name }
        if ($null -eq $package) {
            Write-Message -Message "There is no package called: $Name" -DisplayWarning
            return
        }
        
        # If its a url package, download it and set some properties to allow the installation code to run
        if ($package.Type -eq "UrlPackage") {
            
            # Get the absolute url after any redirection
            $url = [System.Net.HttpWebRequest]::Create($package.Url).GetResponse().ResponseUri.AbsoluteUri
            
            # Get the file extension in order to save it correctly
            $regex = [regex]::Match($url, ".*\.(.*)")
            $extension = $regex.Groups[1].Value
            
            # Download the installer from the url    
            Invoke-WebRequest -Uri $url -OutFile "$script:DataPath\$($package.Name)\installer.$extension"
            
            # Set executable properties in the package object to allow later code to run correctly
            $package | Add-Member -Type NoteProperty -Name "ExecutableName" -Value "installer.$extension"
            $package | Add-Member -Type NoteProperty -Name "ExecutableType" -Value $extension
            
        }
        
        # Installation logic
        if ($package.Type -eq "LocalPackage" -or $package.Type -eq "UrlPackage") {
            
            if ($package.ExecutableType -eq ".exe") {
                
                # Start the exe installer
                Start-Process -FilePath $script:DataPath\$package.Name\$package.ExecutableName
                
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
                    $logArgument = "/l*v `"$script:DataPath\install-$($apckage.Name)-$(Get-Date -Format "yyyy/MM/dd HH:mm").txt`""
                }
                
                # If the package has a defined install directory, set the msiexec argument(s) to that
                if ([System.String]::IsNullOrWhiteSpace($package.InstallDirectory) -eq $false) {
                    $paramArgument += "INSTALL_PREFIX_1=`"$($package.InstallDirectory)`" "
                    $paramArgument += "TARGETDIR=`"$($package.InstallDirectory)`" "
                    $paramArgument += "INSTALLDIR=`"$($package.InstallDirectory)`" "
                    $paramArgument += "INSTALLDIRECTORY=`"$($package.InstallDirectory)`" "
                    $paramArgument += "TARGETDIRECTORY=`"$($package.InstallDirectory)`" "
                    $paramArgument += "TARGETPATH=`"$($package.InstallDirectory)`" "
                    $paramArgument += "INSTALLPATH=`"$($package.InstallDirectory)`" "  
                }
                
                # Set the msiexec arguments
                $processStartupInfo = New-Object System.Diagnostics.ProcessStartInfo -Property @{
                    FileName = "msiexec.exe"
                    Arguments = "$script:DataPath\packages\$($package.Name)\$($package.ExecutableName) " + $dislayArgument + $logArgument + $paramArgument
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
                Write-Message -Message "The install directory is invalid: $($package.InstallDirectory)" -DisplayWarning
                return
            }
                    
            # Copy package folder to install directory
            Copy-Item -Path "$script:DataPath\packages\$($package.Name)" -Destination $package.InstallDirectory -Container -Recurse
            
        }elseif ($package.Type -eq "ChocolateyPackage") {
            
            # TODO: Invoke chocolatey
            
        }
        
        # Check if the package has a post-install scriptblock and run it
        if ($null -ne $package.PostInstallScriptblock) {
            $package.PostInstallScriptblock()
        }
        
        # Set the installed flag for the package
        $package.IsInstalled = $true
    
    }
    
    # Export-out package list (with modified package properties) to xml file
	Export-Data -Object $packageList -Path "$script:DataPath\packageDatabase.xml" -Type "Clixml"	
            
    
}