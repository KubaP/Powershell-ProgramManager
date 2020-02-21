function Invoke-PMInstall {
    <#
    .SYNOPSIS
        Installs a ProgramManager package.
        
    .DESCRIPTION
        Installs a ProgramManager package from the database.
        
    .PARAMETER PackageName
        The name of the ProgramManager package to install.
        
    .EXAMPLE
        PS C:\> Invoke-PMInstall -Name "chrome"
        
        Will install the package named "chrome" found within the database.
    #>
    
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
    Param (
        
        [Parameter(Mandatory = $true, Position = 0)]
        [string[]]
        $PackageName

    )    
    
	# Check if the xml database  exists
    if ((Test-Path -Path "$script:DataPath\packageDatabase.xml") -eq $true) {
        
		# Load all existing PMPrograms into a list
		$packageList = Import-PackageList
		
	}else {
        
        # The xml database doesn't exist, abort
        Write-Message -Message "The database file doesn't exist. Run New-PMPackage to initialise it." -DisplayWarning
        return
        
    }
    
    # Iterate through all passed package names
    foreach ($name in $PackageName) {
        
        # Get the package by name
        $package = $packageList | Where-Object { $_.Name -eq $name }
        if ($null -eq $package) {
            Write-Message -Message "There is no package called: $Name" -DisplayWarning
            return
        }
        
        # Check if the package has a pre-install scriptblock and run it
        if ([System.String]::IsNullOrWhiteSpace($package.PreInstallScriptblock) -eq $false) {
            
            if ($PSCmdlet.ShouldProcess("pre-installation scriptblock from package $name", "Execute command")) {
                
                # Convert the string into a scriptblock and execute
                $scriptblock = [scriptblock]::Create($package.PreInstallScriptblock)
                Invoke-Command -ScriptBlock $scriptblock
                
            }
            
        }
        
        # If its a url package, download it and set some properties to allow the installation code to run
        if ($package.Type -eq "UrlPackage") {
                        
            # Get the absolute url after any redirection
            $url = [System.Net.HttpWebRequest]::Create($package.Url).GetResponse().ResponseUri.AbsoluteUri
            
            # Get the file extension in order to save it correctly
            $regex = [regex]::Match($url, ".*\.(.*)")
            $extension = $regex.Groups[1].Value
            
            if ($PSCmdlet.ShouldProcess("installer file from url", "Download")){
                
                # Download the installer from the url
                New-Item -ItemType Directory -Path "$script:DataPath\packages\$($package.Name)\" | Out-Null
                Invoke-WebRequest -Uri $url -OutFile "$script:DataPath\packages\$($package.Name)\installer.$extension"
                
            }
            
            # Set executable properties in the package object to allow later code to run correctly
            $package | Add-Member -Type NoteProperty -Name "ExecutableName" -Value "installer.$extension"
            $package | Add-Member -Type NoteProperty -Name "ExecutableType" -Value ".$extension"
            
        }
        
        # Installation logic
        if ($package.Type -eq "LocalPackage" -or $package.Type -eq "UrlPackage") {
            
            if ($package.ExecutableType -eq ".exe") {
                
                if ($PSCmdlet.ShouldProcess(".exe installer", "Start process")){
                    
                    # Start the exe installer
                    Start-Process -FilePath "$script:DataPath\packages\$($package.Name)\$($package.ExecutableName)" -Wait
                    
                }
                
            }elseif ($package.ExecutableType -eq ".msi") {
                <# SET PROPERTIES OF MSI INSTALLER, removed for now since very few msi installers around anyway
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
                }#>
                
                # Set the msiexec arguments
                $processStartupInfo = New-Object System.Diagnostics.ProcessStartInfo -Property @{
                    FileName = "msiexec.exe"
                    Arguments = "/i $script:DataPath\packages\$($package.Name)\$($package.ExecutableName) /qf /l*v `"$script:DataPath\log-$($package.Name)-$(Get-Date -Format "yyyy-MM-dd HH:mm").txt`""
                    UseShellExecute = $false
                }
                
                if ($PSCmdlet.ShouldProcess("msiexec installer", "Start process")) {
                    
                    # Start msiexec and wait until it's finished
                    $process = New-Object System.Diagnostics.Process
                    $process.StartInfo = $processStartupInfo
                    $process.Start() | Out-Null
                    
                    $process.WaitForExit()
                    $process.Dispose()  
                      
                }
                
            }
            
        }elseif ($package.Type -eq "PortablePackage") {
            
            # Check that the install directory exists, otherwise abort
            if ((Test-Path -Path $package.InstallDirectory) -eq $false) {
                Write-Message -Message "The install directory is invalid: $($package.InstallDirectory)" -DisplayWarning
                return
            }
            
            if ($PSCmdlet.ShouldProcess("Package $name files", "Copy to the installation directory")) {
                
                # Copy package folder to install directory
                Copy-Item -Path "$script:DataPath\packages\$($package.Name)" -Destination $package.InstallDirectory -Container -Recurse
                
            }
            
        }elseif ($package.Type -eq "ChocolateyPackage") {
            
            # TODO: Invoke chocolatey
            
        }
        
        # Clean up temporary url package properties
        if ($package.Type -eq "UrlPackage") {
            
            # Get the package object without the executable properties
            $package.psobject.Properties.Remove("ExecutableName")    
            $package.psobject.Properties.Remove("ExecutableType")    
            
            # Remove the temporarily downloaded installer
            if ((Test-Path -Path "$script:DataPath\packages\$($package.Name)") -eq $true) {
                
                if ($PSCmdlet.ShouldProcess("package $($package.Name) installer", "Delete")) {
                    Remove-Item -Path "$script:DataPath\packages\$($package.Name)" -Recurse -Force
                }
                
            }
            
        }  
        
        # Check if the package has a post-install scriptblock and run it
        if ([System.String]::IsNullOrWhiteSpace($package.PostInstallScriptblock) -eq $false) {
            
            if ($PSCmdlet.ShouldProcess("post-installation scriptblock from package $name", "Execute command")) {
                
                # Convert string to scriptblock and execute
                $scriptblock = [scriptblock]::Create($package.PostInstallScriptblock)
                Invoke-Command -ScriptBlock $scriptblock
                
            }
            
        }
        
        # Set the installed flag for the package
        $package.IsInstalled = $true
    
    }
    
    if ($PSCmdlet.ShouldProcess("$script:DataPath\packageDatabase.xml", "Update the package `'$PackageName`' installation status")){
        
        # Export-out package list to xml file with updated property
        Export-PackageList -PackageList $packageList
        
    }
    
}