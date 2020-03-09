Describe -Verbose "Validating Invoke-PMInstall" {
	$VerbosePreference = "Continue"
	
	# Create a temporary data directory within the Pester temp drive
	# Modify the module datapath to reflect this temporary location
	New-Item -ItemType Directory -Path "TestDrive:\ProgramManager\"
	& (Get-Module ProgramManager) { $script:DataPath = "TestDrive:\ProgramManager" }
	# For use within the test script, since no access to module- $script:DataPath
	$dataPath = "TestDrive:\ProgramManager"
	
	Context "Local Package Validation" {
		
		InModuleScope -ModuleName ProgramManager {
			
			# Mock the functions to then assert if they were called, i.e. if a scriptblock would be executed or an installer would be started
			Mock Invoke-Command { }
			Mock Start-Process { }
			
			It "Given valid parameter -PackageName <PackageName>; It should correctly install package" -TestCases @(
				
				# The different valid test cases for a local package (exe and msi)
				@{ PackageName = "local-exe-none"; Type = "exe"; FileName = "localpackage-1.0.exe"; PreInstallScriptblock = {}; PostInstallScriptblock = {} }
				@{ PackageName = "local-exe-pre"; Type = "exe"; FileName = "localpackage-1.0.exe"; PreInstallScriptblock = {Write-Host "hello world"}; PostInstallScriptblock = {} }
				@{ PackageName = "local-exe-post"; Type = "exe"; FileName = "localpackage-1.0.exe"; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello world"} }
				@{ PackageName = "local-exe-all"; Type = "exe"; FileName = "localpackage-1.0.exe"; PreInstallScriptblock = {Write-Host "hello world"}; PostInstallScriptblock = {Write-Host "hello world"} }
				
				@{ PackageName = "local-msi-none"; Type = "msi"; FileName = "localpackage-1.0.msi"; PreInstallScriptblock = {}; PostInstallScriptblock = {} }
				@{ PackageName = "local-msi-pre"; Type = "msi"; FileName = "localpackage-1.0.msi"; PreInstallScriptblock = {Write-Host "hello world"}; PostInstallScriptblock = {} }
				@{ PackageName = "local-msi-post"; Type = "msi"; FileName = "localpackage-1.0.msi"; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello world"} }
				@{ PackageName = "local-msi-all"; Type = "msi"; FileName = "localpackage-1.0.msi"; PreInstallScriptblock = {Write-Host "hello world"}; PostInstallScriptblock = {Write-Host "hello world"} }
				
			) {
				
				# Pass test case data into the test body
				Param ($PackageName, $Type, $FileName, $PreInstallScriptblock, $PostInstallScriptblock)
				
				# Copy the test packages from the git repo to the temporary drive
				New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
				Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
				
				# Create the package first to test on
				if ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {
					
					New-PMPackage -Name $PackageName -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -PreInstallScriptblock $PreInstallScriptblock -PostInstallScriptblock $PostInstallScriptblock
					
				}elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {
					
					New-PMPackage -Name $PackageName -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -PreInstallScriptblock $PreInstallScriptblock
					
				}elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false) {
					
					New-PMPackage -Name $PackageName -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -PostInstallScriptblock $PostInstallScriptblock
					
				}else {
					
					New-PMPackage -Name $PackageName -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName"
					
				}
				
				# Run the command to test
				Invoke-PMInstall -PackageName $PackageName
				
				# Get the package object
				$package = Get-PMPackage -PackageName $PackageName
				
				# Check that the scriptblocks have been called correctly
				if ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {
					
					Assert-MockCalled Invoke-Command -Times 2 -Exactly -Scope It
					
				}elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {
					
					Assert-MockCalled Invoke-Command -Times 1 -Exactly -Scope It
					
				}elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false) {
					
					Assert-MockCalled Invoke-Command -Times 1 -Exactly -Scope It
					
				}else {
					
					Assert-MockCalled Invoke-Command -Times 0 -Exactly -Scope It
					
				}
				
				# Check that the installer was called
				Assert-MockCalled Start-Process -Times 1 -Exactly -Scope It
				
				# Check that the package install status was updated
				$package.IsInstalled | Should -Be $true
				
				# Delete the package store and database file for next test
				Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
				Remove-Item -Path "$dataPath\packages\" -Recurse -Force
				Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
				
			}
			
		}
		
	}
	<#
	Context "Url Package Validation" {
		
		InModuleScope -ModuleName ProgramManager {
			
			Mock Invoke-Command { }
			Mock Start-Process { }
			
			It "Given valid parameter -PackageName <PackageName>; It should correctly install package" -TestCases @(
				
				# The different valid test cases for a portable package (exe, folder, and zip)
				@{ PackageName = "url-none"; Url = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-GB"; PreInstallScript = {}; PostInstallScript = {} }
				@{ PackageName = "url-pre"; Url = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-GB"; PreInstallScript = {Write-Host "hello world"}; PostInstallScript = {} }
				@{ PackageName = "url-post"; Url = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-GB"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello world"} }
				@{ PackageName = "url-both"; Url = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-GB"; PreInstallScript = {Write-Host "hello world"}; PostInstallScript = {Write-Host "hello world"} }
				
			) {
				
				# Pass test case data into the test body
				Param ($PackageName, $Url, $PreInstallScriptblock, $PostInstallScriptblock)
				
				# Create the package first
				if ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {                    
					New-PMPackage -Name $PackageName -UrlPackage -PackageLocation $Url -PreInstallScriptblock $PreInstallScriptblock -PostInstallScriptblock $PostInstallScriptblock
				
				}elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {                
					New-PMPackage -Name $PackageName -UrlPackage -PackageLocation $Url -PreInstallScriptblock $PreInstallScriptblock
					
				}elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false) {                
					New-PMPackage -Name $PackageName -UrlPackage -PackageLocation $Url -PostInstallScriptblock $PostInstallScriptblock
				
				}else {                
					New-PMPackage -Name $PackageName -UrlPackage -PackageLocation $Url
					
				}
								
				# Run the command
				Invoke-PMInstall -PackageName $PackageName
				
				# Get the package object
				$package = Get-PMPackage -PackageName $PackageName
				
				# Check that the scriptblocks have been called correctly
				if ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {                    
					Assert-MockCalled Invoke-Command -Times 2 -Exactly -Scope It
					
				}elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {                
					Assert-MockCalled Invoke-Command -Times 1 -Exactly -Scope It
					
				}elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false) {                
					Assert-MockCalled Invoke-Command -Times 1 -Exactly -Scope It
				
				}else {
					Assert-MockCalled Invoke-Command -Times 0 -Exactly -Scope It
					
				}
				
				# Check that the installer was called
				Assert-MockCalled Start-Process -Times 1 -Exactly -Scope It
				
				# Check that the package install status was updated
				$package.IsInstalled | Should -Be $true
				
				
				# Delete the package store and database file for next test
				Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
				Remove-Item -Path "$dataPath\packages\" -Recurse -Force
				
			}
			
		}
		
	}#>
	
	Context "Portable Package Validation" {
		
		InModuleScope -ModuleName ProgramManager {
			
			# Mock the functions to then assert if they were called, i.e. if a scriptblock would be executed or an installer would be started
			Mock Invoke-Command { }
			Mock Write-Message { }
			
			It "Given valid parameter -PackageName <PackageName>; It should correctly install package" -TestCases @(
				
				# The different valid test cases for a portable package (exe, folder, and zip)
				@{ PackageName = "portable-exe-none"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "\dir\"; PreInstallScriptblock = {}; PostInstallScriptblock = {}}
				@{ PackageName = "portable-exe-pre"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "\dir\"; PreInstallScriptblock = {Write-Host "hello world"}; PostInstallScriptblock = {}}
				@{ PackageName = "portable-exe-post"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "\dir\"; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello world"}}
				@{ PackageName = "portable-exe-all"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "\dir\"; PreInstallScriptblock = {Write-Host "hello world"}; PostInstallScriptblock = {Write-Host "hello world"}}
				
				@{ PackageName = "portable-zip-none"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "\dir\"; PreInstallScriptblock = {}; PostInstallScriptblock = {}}
				@{ PackageName = "portable-zip-pre"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "\dir\"; PreInstallScriptblock = {Write-Host "hello world"}; PostInstallScriptblock = {}}
				@{ PackageName = "portable-zip-post"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "\dir\"; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello world"}}
				@{ PackageName = "portable-zip-all"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "\dir\"; PreInstallScriptblock = {Write-Host "hello world"}; PostInstallScriptblock = {Write-Host "hello world"}}
				
				@{ PackageName = "portable-folder-none"; FileName = "PortablePackage_1.0"; InstallDirectory = "\dir\"; PreInstallScriptblock = {}; PostInstallScriptblock = {}}
				@{ PackageName = "portable-folder-pre"; FileName = "PortablePackage_1.0"; InstallDirectory = "\dir\"; PreInstallScriptblock = {Write-Host "hello world"}; PostInstallScriptblock = {}}
				@{ PackageName = "portable-folder-post"; FileName = "PortablePackage_1.0"; InstallDirectory = "\dir\"; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello world"}}
				@{ PackageName = "portable-folder-all"; FileName = "PortablePackage_1.0"; InstallDirectory = "\dir\"; PreInstallScriptblock = {Write-Host "hello world"}; PostInstallScriptblock = {Write-Host "hello world"}}
				
			) {
				
				# Pass test case data into the test body
				Param ($PackageName, $Type, $FileName, $InstallDirectory, $PreInstallScriptblock, $PostInstallScriptblock)
				
				# Copy the test packages from the git repo to the temporary drive
				New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
				New-Item -ItemType Directory -Path "TestDrive:\$InstallDirectory"
				Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
				
				# Create the package first to test on
				if ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {
					
					New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\$InstallDirectory" -PreInstallScriptblock $PreInstallScriptblock -PostInstallScriptblock $PostInstallScriptblock
					
				}elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {
					
					New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\$InstallDirectory" -PreInstallScriptblock $PreInstallScriptblock
					
				}elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false) {
					
					New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\$InstallDirectory" -PostInstallScriptblock $PostInstallScriptblock
					
				}else {
					
					New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\$InstallDirectory"
					
				}
				
				# Run the command to test
				Invoke-PMInstall -PackageName $PackageName
				
				# Get the package object
				$package = Get-PMPackage -PackageName $PackageName
				
				# Check that the scriptblocks have been called correctly
				if ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {
					
					Assert-MockCalled Invoke-Command -Times 2 -Exactly -Scope It
					
				}elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {
					
					Assert-MockCalled Invoke-Command -Times 1 -Exactly -Scope It
					
				}elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false) {
					
					Assert-MockCalled Invoke-Command -Times 1 -Exactly -Scope It
					
				}else {
					
					Assert-MockCalled Invoke-Command -Times 0 -Exactly -Scope It
					
				}
				
				# Check that the package has been copied correctly
				Test-Path -Path "TestDrive:\$InstallDirectory\$($package.Name)\" | Should -Be $true
				
				# Check that the package install status was updated
				$package.IsInstalled | Should -Be $true
				
				# Delete the package store and database file for next test
				Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
				Remove-Item -Path "$dataPath\packages\" -Recurse -Force
				Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
				Remove-Item -Path "TestDrive:\$InstallDirectory\" -Recurse -Force
				
			}
			
			It "Given valid parameter -PackageName <PackageName>; with invalid InstallDirectory; It should warn and stop execution" -TestCases @(
				
				# The different invalid test cases for a portable package install directory
				@{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = ".*"; MessageText = "2" }
				@{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "*"; MessageText = "2" }
				@{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "**"; MessageText = "2" }
				@{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "..."; MessageText = "2" }
				@{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "£%afasdfasdf£"; MessageText = "1" }
				@{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "\non-existent-folder\"; MessageText = "1" }
				
			) {
				
				# Pass test case data into the test body
				Param ($PackageName, $FileName, $InstallDirectory, $MessageText)
				
				# Copy the test packages from the git repo to the temporary drive
				New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
				Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
				
				# Create the package first to test on
				New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\$InstallDirectory"
				
				# Run the command to test
				Invoke-PMInstall -PackageName $PackageName
				
				# Get the correct warning message that should be displayed in each test case
				switch ($MessageText) {
					
					"1" { $MessageText = "The install directory doesn't exist: TestDrive:\$InstallDirectory" }
					"2" { $MessageText = "The package install directory contains invalid characters" }
					
				}
				
				# Check that the warning message was properly sent
				Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
					$DisplayWarning -eq $true -and
					$Message -eq $MessageText
				}
				
				# Delete the package store and database file for next test
				Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
				Remove-Item -Path "$dataPath\packages\" -Recurse -Force
				Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
				
			}
			
		}
		
	}
	
	InModuleScope -ModuleName ProgramManager {
			
		# Mock the function to then assert if it was called, i.e. if a message would be printed to screen
		Mock Write-Message { }
		
		It "Given invalid parameter -PackageName <PackageName>; It should warn and stop execution" -TestCases @(
			
			# The different valid test cases for a packagename
			@{ PackageName = ""; Message = "1" }
			@{ PackageName = " "; Message = "1" }
			@{ PackageName = "*"; Message = "2" }
			@{ PackageName = "."; Message = "2" }
			@{ PackageName = ".*"; Message = "2" }
			@{ PackageName = "asdasdagfsag"; Message = "2" }
			@{ PackageName = "afhSDGj%^^7RHDFGH"; Message = "2" }
			@{ PackageName = "..."; Message = "2" }
			@{ PackageName = "   "; Message = "1" }
			
		) {
			
			# Pass test case data into the test body
			Param ([AllowEmptyString()]$PackageName, $MessageText)
			
			# Copy over pre-populated database file from git
			Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
			
			# Run the command to test
			Invoke-PMInstall -PackageName $PackageName
			
			# Get the correct warning message that should be displayed in each test case
			switch ($MessageText) {
					
				"1" { $MessageText = "The name cannot be empty" }
				"2" { $MessageText = "There is no package called: $PackageName" }
				
			}
			
			# Check that the warning message was properly sent
			Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
				$DisplayWarning -eq $true -and
				$Message -eq $MessageText
			}
			
			# Delete the database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			
		}
		
		It "Given no database file present; It should warn and stop execution" -TestCases @(
			
			# The different valid test cases for a packagename
			@{ PackageName = "" }
			@{ PackageName = " " }
			@{ PackageName = "*" }
			@{ PackageName = "." }
			@{ PackageName = ".*" }
			@{ PackageName = "asdasdagfsag" }
			@{ PackageName = "afhSDGj%^^7RHDFGH" }
			@{ PackageName = "..." }
			@{ PackageName = "   " }
			
		) {
			
			# Pass test case data into the test body
			Param ($PackageName)
			
			# Run the command to test
			Invoke-PMInstall -PackageName $PackageName
			
			# Check that the warning message was properly sent
			Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
				$DisplayWarning -eq $true -and
				$Message -eq "The database file doesn't exist. Run New-PMPackage to initialise it."
			}
			
		}
		
	}
	
}