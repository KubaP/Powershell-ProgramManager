function Invoke-PMInstall {
	<#
	.SYNOPSIS
		Installs a ProgramManager package.
		
	.DESCRIPTION
		Invokes an installation process on a ProgramManager.Package which has been earlier added to the database.
		
	.PARAMETER PackageName
		The name of the ProgramManager package to install.
		
	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
		
	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.
		
	.EXAMPLE
		PS C:\> Invoke-PMInstall -Name "notepad"
		
		This command will install the package named "notepad", executing any scriptblocks along with it.
		
	.EXAMPLE
		PS C:\> Get-PMPackage "notepad" | Invoke-PMInstall
		
		This command supports passing in a ProgramManager.Package object, by retrieving it using Get-PMPacakge for example.
		This command will install the package named "notepad", executing any scriptblocks along with it.
		
	.INPUTS
		System.String[]
		
	.OUTPUTS
		None
		
	#>
	
	[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
	Param (
		
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
		[AllowEmptyString()]
		[Alias("Name")]
		[string[]]
		$PackageName
		
	)
	
	# Check if the xml database exists
	if ((Test-Path -Path "$script:DataPath\packageDatabase.xml") -eq $true) {
		
		# Load all existing PMPackages into a list
		Write-Verbose "Loading existing packages from database"
		$packageList = Import-PackageList
		
	}else {
		
		# The xml database doesn't exist; warn user
		Write-Message -Message "The database file doesn't exist. Run New-PMPackage to initialise it." -DisplayWarning
		return
		
	}
	
	# Iterate through all passed package names
	foreach ($name in $PackageName) {
		
		Write-Verbose "Installing package:{$name}"
		
		# Check that the name is not empty
		if ([System.String]::IsNullOrWhiteSpace($name) -eq $true) {
			
			Write-Message -Message "The name cannot be empty" -DisplayWarning
			return
			
		}
		
		# Get the package by name
		Write-Verbose "Retrieving the ProgramManager.Package Object"
		$package = $packageList | Where-Object { $_.Name -eq $name }
		
		# Warn the user if the name is invalid
		if ($null -eq $package) {
			
			Write-Message -Message "There is no package called: $Name" -DisplayWarning
			return
			
		}
		
		# Check if the package has a pre-install scriptblock to run
		Write-Verbose "Checking for pre-install scriptblock"
		if ([System.String]::IsNullOrWhiteSpace($package.PreInstallScriptblock) -eq $false) {
			
			if ($PSCmdlet.ShouldProcess("pre-install scriptblock from package:{$name}", "Execute scriptblock")) {
				
				# Convert the string into a scriptblock and execute
				Write-Verbose "Coverting scriptblock and executing it"
				$scriptblock = [scriptblock]::Create($package.PreInstallScriptblock)
				Invoke-Command -ScriptBlock $scriptblock -ArgumentList $package
				
			}
			
		}
		
		# If the package is a url-package, download it and define extra properties to allow the installation code to run correctly
		if ($package.Type -eq "UrlPackage") {
			
			# Get the absolute url, after any redirection, which points to the actual file
			Write-Verbose "Getting absolute url from link given"
			$url = [System.Net.HttpWebRequest]::Create($package.Url).GetResponse().ResponseUri.AbsoluteUri
			
			# Get the file extension in order to save it correctly
			$regex = [regex]::Match($url, ".*\.(.*)")
			$extension = $regex.Groups[1].Value
			
			if ($PSCmdlet.ShouldProcess("installer at url:$url", "Download")){
				
				# Download the installer from the url
				Write-Verbose "Downloading installer to \packages\$($package.Name)\"
				New-Item -ItemType Directory -Path "$script:DataPath\packages\$($package.Name)\" | Out-Null
				Invoke-WebRequest -Uri $url -OutFile "$script:DataPath\packages\$($package.Name)\installer.$extension"
				
			}
			
			# Set executable properties in the package object to allow later code to run correctly
			Write-Verbose "Adding properties to allow for installation"
			$package | Add-Member -Type NoteProperty -Name "ExecutableName" -Value "installer.$extension"
			$package | Add-Member -Type NoteProperty -Name "ExecutableType" -Value ".$extension"
			
		}
		
		# Main installation logic
		if ($package.Type -eq "LocalPackage" -or $package.Type -eq "UrlPackage") {
			
			# Differentiate between exe and msi installers
			if ($package.ExecutableType -eq ".exe") {
				
				if ($PSCmdlet.ShouldProcess(".exe installer:$($package.ExecutableName)", "Start process")){
					
					# Start the exe installer and wait for finish
					Write-Verbose "Starting the .exe installer"
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
				
				if ($PSCmdlet.ShouldProcess(".msi installer:$($package.ExecutableName)", "Start process")) {
					
					# Start the msiexec process and wait for finish
					Write-Verbose "Starting the .msi installer"
					Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $script:DataPath\packages\$($package.Name)\$($package.ExecutableName) /qf /l*v `"$script:DataPath\log-$($package.Name)-$(Get-Date -Format "yyyy-MM-dd HH:mm").txt`"" -Wait
					
				}
				
			}
			
		}elseif ($package.Type -eq "PortablePackage") {
			
			# Check that the install directory doesn't contain any characters which could cause potential issues
			if ($package.InstallDirectory -like "*.``**" -or $package.InstallDirectory -like "*``**" -or $package.InstallDirectory -like "*.*") {
				
				Write-Message -Message "The package install directory contains invalid characters" -DisplayWarning
				return
				
			}
			
			# Check that the install directory exists, otherwise abort
			if ((Test-Path -Path $package.InstallDirectory) -eq $false) {
				
				Write-Message -Message "The install directory doesn't exist: $($package.InstallDirectory)" -DisplayWarning
				return
				
			}
			
			if ($PSCmdlet.ShouldProcess("Package:{$name} files", "Copy to the installation directory")) {
								
				# Copy package folder to install directory
				Write-Verbose "Copying over the package files to $($package.InstallDirectory)"
				Copy-Item -Path "$script:DataPath\packages\$($package.Name)" -Destination $package.InstallDirectory -Container -Recurse
				
			}
			
		}elseif ($package.Type -eq "ChocolateyPackage") {
			
			# TODO: Invoke chocolatey install
			
		}
		
		# Clean up temporary url-package properties
		if ($package.Type -eq "UrlPackage") {
			
			# Remove the executable properties
			Write-Verbose "Cleaning up temporary properties"
			$package.psobject.Properties.Remove("ExecutableName")
			$package.psobject.Properties.Remove("ExecutableType")
			
			# Check in-case the installer wasn't actually downloaded
			if ((Test-Path -Path "$script:DataPath\packages\$($package.Name)") -eq $true) {
				
				if ($PSCmdlet.ShouldProcess("package:{$name} installer", "Delete")) {
					
					# Remove the temporarily downloaded installer
					Write-Verbose "Deleting the downloaded installer"
					Remove-Item -Path "$script:DataPath\packages\$($package.Name)" -Recurse -Force
					
				}
				
			}
			
		}
		
		# Check if the package has a post-install scriptblock to run
		Write-Verbose "Checking for post-install scriptblock"
		if ([System.String]::IsNullOrWhiteSpace($package.PostInstallScriptblock) -eq $false) {
			
			if ($PSCmdlet.ShouldProcess("post-install scriptblock from package:{$name}", "Execute scriptblock")) {
				
				# Convert string to scriptblock and execute
				Write-Verbose "Coverting scriptblock and executing it"
				$scriptblock = [scriptblock]::Create($package.PostInstallScriptblock)
				Invoke-Command -ScriptBlock $scriptblock -ArgumentList $package
				
			}
			
		}
		
		# Set the installed flag for the package
		Write-Verbose "Setting installed flag to true"
		$package.IsInstalled = $true
	
	}
	
	if ($PSCmdlet.ShouldProcess("$script:DataPath\packageDatabase.xml", "Update the package:{$PackageName} installation status")) {
		
		# Override xml database with updated package property
		Write-Verbose "Writing-out data back to database"
		Export-PackageList -PackageList $packageList
		
	}
	
}