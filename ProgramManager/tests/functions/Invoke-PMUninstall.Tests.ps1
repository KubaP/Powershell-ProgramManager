Describe -Verbose "Validating Invoke-PMInstall" {
	$VerbosePreference = "Continue"
	
	# Create a temporary data directory within the Pester temp drive
	# Modify the module datapath to reflect this temporary location
	New-Item -ItemType Directory -Path "TestDrive:\ProgramManager\"
	& (Get-Module ProgramManager) { $script:DataPath = "TestDrive:\ProgramManager" }
	# For use within the test script, since no access to module- $script:DataPath
	$dataPath = "TestDrive:\ProgramManager"
	
	Context "Local and Url Package Validation" {
		
		InModuleScope -ModuleName ProgramManager {
			
			# Mock the functions to then assert if they were called, i.e. if a scriptblock would be executed or an installer would be started
			Mock Invoke-Command { }
			Mock Start-Process { }
			
			It "Given valid parameter -PackageName <PackageName>; It should correctly install package" -TestCases @(
				
				# The different valid test cases for a local package (exe and msi)
				@{ PackageName = "local-exe-none"; Type = "exe"; FileName = "localpackage-1.0.exe"; UninstallScriptblock = {} }
				@{ PackageName = "local-exe-script"; Type = "exe"; FileName = "localpackage-1.0.exe"; UninstallScriptblock = {Write-Host "hello"} }
				
				@{ PackageName = "local-msi-none"; Type = "msi"; FileName = "localpackage-1.0.msi"; UninstallScriptblock = {} }
				@{ PackageName = "local-msi-script"; Type = "msi"; FileName = "localpackage-1.0.msi"; UninstallScriptblock = {Write-Host "hello"} }
				
			) {
				
				# Pass test case data into the test body
				Param ($PackageName, $Type, $FileName, $UninstallScriptblock)
				
				# Copy the test packages from the git repo to the temporary drive
				New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
				Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
				
				# Create the package first to test on
				if ([System.String]::IsNullOrWhiteSpace($UninstallScriptblock.ToString()) -eq $false) {
					
					New-PMPackage -Name $PackageName -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -UninstallScriptblock $UninstallScriptblock
					
				}else {
					
					New-PMPackage -Name $PackageName -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName"
					
				}
				
				# "Install" the pacakge to test on
				Set-PMPackage -PackageName $PackageName -PropertyName "IsInstalled" -PropertyValue $true
				
				# Get the package object pre-uninstall for comparison
				$oldPackage = Get-PMPackage -PackageName $PackageName
				
				# Run the command to test
				Invoke-PMUninstall -PackageName $PackageName
				
				# Get the modified package to compare
				$package = Get-PMPackage -PackageName $PackageName
				
				# Check that the uninstall scriptblock runs
				if ([System.String]::IsNullOrWhiteSpace($UninstallScriptblock.ToString()) -eq $false) {
						
					Assert-MockCalled Invoke-Command -Times 1 -Exactly -Scope It
					
				}
				
				# Check that the installer was called
				Assert-MockCalled Start-Process -Times 1 -Exactly -Scope It
				
				# Check that the package install status was updated
				$package.IsInstalled | Should -Be $false
				
				# Check that the new package differs (since its been edited)
				($package -eq $oldPackage) | Should -Be $false
				
				# Delete the package store and database file for next test
				Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
				Remove-Item -Path "$dataPath\packages\" -Recurse -Force
				Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
				
			}
			
		}
		
	}
	
	Context "Portable Package Validation" {
		
		InModuleScope -ModuleName ProgramManager {
			
			# Mock the functions to then assert if they were called, i.e. if a scriptblock would be executed or package files deleted
			Mock Invoke-Command { }
			Mock Write-Message { }
			
			It "Given valid parameter -PackageName <PackageName>; It should correctly install package" -TestCases @(
				
				# The different valid test cases for a portable package (exe, folder, and zip)
				@{ PackageName = "portable-exe-none"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "\dir\"; UninstallScriptblock = {} }
				@{ PackageName = "portable-exe-script"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "\dir\"; UninstallScriptblock = {Write-Host "hello"} }
				
				@{ PackageName = "portable-zip-none"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "\dir\"; UninstallScriptblock = {} }
				@{ PackageName = "portable-zip-script"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "\dir\"; UninstallScriptblock = {Write-Host "hello"} }
				
				@{ PackageName = "portable-folder-none"; FileName = "PortablePackage_1.0"; InstallDirectory = "\dir\"; UninstallScriptblock = {} }
				@{ PackageName = "portable-folder-script"; FileName = "PortablePackage_1.0"; InstallDirectory = "\dir\"; UninstallScriptblock = {Write-Host "hello"} }
				
			) {
				
				# Pass test case data into the test body
				Param ($PackageName, $Type, $FileName, $InstallDirectory, $UninstallScriptblock)
				
				# Copy the test packages from the git repo to the temporary drive
				New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
				New-Item -ItemType Directory -Path "TestDrive:\$InstallDirectory"
				Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
				
				# Create the package first to test on
				if ([System.String]::IsNullOrWhiteSpace($UninstallScriptblock.ToString()) -eq $false) {
					
					New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\$InstallDirectory" -UninstallScriptblock $UninstallScriptblock
					
				}else {
					
					New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\$InstallDirectory"
					
				}
				
				# "Install" the pacakge to test on
				Invoke-PMInstall -PackageName $PackageName
				
				# Get the package object pre-uninstall for comparison
				$oldPackage = Get-PMPackage -PackageName $PackageName
				
				# Run the command to test
				Invoke-PMUninstall -PackageName $PackageName
				
				# Get the modified package to compare
				$package = Get-PMPackage -PackageName $PackageName
				
				# Check that the uninstall scriptblock runs
				if ([System.String]::IsNullOrWhiteSpace($UninstallScriptblock.ToString()) -eq $false) {
						
					Assert-MockCalled Invoke-Command -Times 1 -Exactly -Scope It
					
				}
				
				# Check that the package has been copied correctly
				Test-Path -Path "TestDrive:\$InstallDirectory\$($package.Name)\" | Should -Be $false
				
				# Check that the package install status was updated
				$package.IsInstalled | Should -Be $false
				
				# Check that the new package differs (since its been edited)
				($package -eq $oldPackage) | Should -Be $false
				
				# Delete the package store and database file for next test
				Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
				Remove-Item -Path "$dataPath\packages\" -Recurse -Force
				Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
				Remove-Item -Path "TestDrive:\$InstallDirectory\" -Recurse -Force
				
			}
			
			It "Given valid parameter -PackageName <PackageName>; with invalid InstallDirectory; It should warn and stop execution" -TestCases @(
				
				# The different invalid test cases for a portable package install directory
				@{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = ".*" }
				@{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "*" }
				@{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "**" }
				@{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "..." }
				@{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "£%afasdfasdf£" }
				@{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "\non-existent-folder\" }
				
			) {
				
				# Pass test case data into the test body
				Param ($PackageName, $FileName, $InstallDirectory)
				
				# Copy the test packages from the git repo to the temporary drive
				New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
				Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
				
				# Create the package first to test on
				New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\$InstallDirectory"
				
				# "Install" the pacakge to test on
				Set-PMPackage -PackageName $PackageName -PropertyName "IsInstalled" -PropertyValue $true
				
				# Run the command to test
				Invoke-PMUninstall -PackageName $PackageName
				
				# Check that the warning message was properly sent
				Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
					$DisplayWarning -eq $true -and
					$Message -eq "Can't find the package at the expected directory. Was the package folder renamed?"
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
			@{ PackageName = ""; MessageText = "1" }
			@{ PackageName = " "; MessageText = "1" }
			@{ PackageName = "*"; MessageText = "2" }
			@{ PackageName = "."; MessageText = "2" }
			@{ PackageName = ".*"; MessageText = "2" }
			@{ PackageName = "asdasdagfsag"; MessageText = "2" }
			@{ PackageName = "afhSDGj%^^7RHDFGH"; MessageText = "2" }
			@{ PackageName = "..."; MessageText = "2" }
			@{ PackageName = "   "; MessageText = "1" }
			
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