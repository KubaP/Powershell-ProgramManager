Describe -Verbose "Validating New-PMPackage" {
	$VerbosePreference = "Continue"
	
	# Create a temporary data directory within the Pester temp drive
	# Modify the module datapath to reflect this temporary location
	New-Item -ItemType Directory -Path "TestDrive:\ProgramManager\"
	& (Get-Module ProgramManager) { $script:DataPath = "TestDrive:\ProgramManager" }
	# For use within the test script, since this script has no access to module $script:DataPath
	$dataPath = "TestDrive:\ProgramManager"
	
	Context "Local Package Validation" {
		
		It "Given valid parameters: PackageLocation TestDrive:\RawPackages\<FileName>; InstallDirectory <InstallDirectory>; Note <Note>; PreInstallScriptblock <PreInstallScriptblock>; PostInstallScriptblock <PostInstallScriptblock>; UninstallScriptBlock <UninstallScriptblock>; It should correctly write the data" -TestCases @(
			
			# The different valid test cases for a local package (both exe and msi)
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = ""; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = ""; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = ""; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {} }
			
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = ""; PostInstallScriptblock = {}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {Write-Host "hello"} }
			
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {Write-Host "hello"} }
			
		) {
			
			# Pass test case data into the test body
			Param ($Extension, $FileName, [AllowEmptyString()]$InstallDirectory, [AllowEmptyString()]$Note, $PreInstallScriptblock, $PostInstallScriptblock, $UninstallScriptblock)
			
			# Copy the test packages from the git repo to the temporary drive to prevent modification of "master" copy
			New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
			Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
			
			# Run the command to test
			if ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false -and `
				[System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false -and `
				[System.String]::IsNullOrWhiteSpace($UninstallScriptblock.ToString()) -eq $false) {
				
				New-PMPackage -Name "test-package" -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDirectory -Note $Note `
					-PreInstallScriptblock $PreInstallScriptblock -PostInstallScriptblock $PostInstallScriptblock -UninstallScriptblock $UninstallScriptblock
				
			}elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {
				
				New-PMPackage -Name "test-package" -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDirectory -Note $Note `
					-PreInstallScriptblock $PreInstallScriptblock
				
			}elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false) {
				
				New-PMPackage -Name "test-package" -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDirectory -Note $Note `
					-PostInstallScriptblock $PostInstallScriptblock
				
			}elseif ([System.String]::IsNullOrWhiteSpace($UninstallScriptblock.ToString()) -eq $false) {
				
				New-PMPackage -Name "test-package" -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDirectory -Note $Note `
					-UninstallScriptblock $UninstallScriptblock
				
			}else {
				
				New-PMPackage -Name "test-package" -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDirectory -Note $Note
				
			}
			
			# Check that the new database file has been created
			Test-Path -Path "$dataPath\packageDatabase.xml" | Should -Be $true
			
			# Read the written data back in to validate
			$packageList = Import-PackageList
			$package = $packageList[0]
			
			# Check the property values are correct
			$package.Name | Should -Be "test-package"
			$package.Type | Should -Be "LocalPackage"
			$package.IsInstalled | Should -Be $false
			$package.ExecutableName | Should -Be $FileName
			$package.ExecutableType | Should -Be ".$Extension"
			
			# Check the optional property valuse are correct
			if ([System.String]::IsNullOrWhiteSpace($InstallDirectory) -eq $true) {
				$package.InstallDirectory | Should -Be $null
			}else {
				$package.InstallDirectory | Should -Be $InstallDirectory
			}
			
			if ([System.String]::IsNullOrWhiteSpace($Note) -eq $true) {
				$package.Note | Should -Be $null
			}else {
				$package.Note | Should -Be $Note
			}
			
			# Check that the scriptblocks have been properly added
			([Scriptblock]::Create($package.PreInstallScriptBlock) -like $PreInstallScriptblock) | Should -Be $true
			([Scriptblock]::Create($package.PostInstallScriptBlock) -like $PostInstallScriptblock) | Should -Be $true
			([Scriptblock]::Create($package.UninstallScriptBlock) -like $UninstallScriptblock) | Should -Be $true
			
			# Test that there is only one package in the store
			$packageFiles = Get-ChildItem -Path "$dataPath\packages\"
			$packageFiles.Count | Should -Be 1
			
			# Check that the executable hasn't been left behind in its original directory
			Test-Path -Path "TestDrive:\RawPackages\$FileName" | Should -Be $false
			
			# Check that the executable has been correctly moved over
			Test-Path -Path "$dataPath\packages\test-package\$($package.ExecutableName)" | Should -Be $true
			
			# Delete the package store and database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			Remove-Item -Path "$dataPath\packages\" -Recurse -Force
			Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
			
		}
		
		InModuleScope -ModuleName ProgramManager {
			
			# Mock the function to then assert if it was called, i.e. if a message would be printed to screen
			Mock Write-Message { }
			
			It "Given invalid parameter -Name <Name>; It should warn and stop execution" -TestCases @(
				
				# The different invalid test cases for a name
				@{ Name = ""; MessageText = "1" }
				@{ Name = " "; MessageText = "1" }
				@{ Name = "     "; MessageText = "1" }
				@{ Name = "."; MessageText = "2" }
				@{ Name = "*"; MessageText = "2" }
				@{ Name = ".*"; MessageText = "2" }
				@{ Name = "asg%346£^ehah$%^47434!*"; MessageText = "2" }
				@{ Name = "..."; MessageText = "2" }
				@{ Name = "***"; MessageText = "2" }
				@{ Name = "existing-package"; MessageText = "3" }
				
			) {
				
				# Pass test case data into the test body
				Param ([AllowEmptyString()]$Name, $MessageText)
				
				# Copy over pre-populated database file to check for name clashes too
				Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
				
				# Copy the test packages from the git repo to the temporary drive
				New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
				Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
				
				# Run the command to test
				New-PMPackage -Name $Name -LocalPackage -PackageLocation "TestDrive:\RawPackages\localpackage-1.0.exe"
				
				# Get the correct warning message that should be displayed in each test case
				switch ($MessageText) {
					
					"1" { $MessageText = "The name cannot be empty" }
					"2" { $MessageText = "The name contains invalid characters" }
					"3" { $MessageText = "There already exists a package called: $Name" }
					
				}
				
				# Check that the warning message was properly sent
				Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
					$DisplayWarning -eq $true -and
					$Message -eq $MessageText
				}
				
				# Check that the executable hasn't been moved from the original directory
				Test-Path -Path "TestDrive:\RawPackages\localpackage-1.0.exe" | Should -Be $true
				
				# Delete the package store and database file for next test
				Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
				Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
				
			}
			
			It "Given invalid parameter -Path <Path>; It should warn and stop execution" -TestCases @(
			
				# The different invalid test cases for a filepath pointing to exe/msi
				@{ Path = ""; MessageText = "1" }
				@{ Path = " "; MessageText = "1" }
				@{ Path = "           "; MessageText = "1" }
				@{ Path = "~"; MessageText = "6" }
				@{ Path = "."; MessageText = "6" }
				@{ Path = ".."; MessageText = "6" }
				@{ Path = "..."; MessageText = "6" }
				@{ Path = "b"; MessageText = "2" }
				@{ Path = "TestDrive:\non-existent-folder"; MessageText = "2" }
				@{ Path = "TestDrive:\non-existent-folder\non-existent-file"; MessageText = "2" }
				@{ Path = "TestDrive:\non-existent-folder\non-existent-file."; MessageText = "6" }
				@{ Path = "TestDrive:\non-existent-folder\non-existent-file.*"; MessageText = "6" }
				@{ Path = "TestDrive:\non-existent-folder\non-existent-file.file"; MessageText = "2" }
				@{ Path = "TestDrive:\non-existent-folder\"; MessageText = "2" }
				@{ Path = "TestDrive:\non-existent-folder\."; MessageText = "6" }
				@{ Path = "TestDrive:\non-existent-folder\*"; MessageText = "6" }
				@{ Path = "asd9udfh87d78yd7nydf7bfy79sd6fjik2l"; MessageText = "2" }
				@{ Path = "^£$%*&^$"; MessageText = "6" }
				@{ Path = "*"; MessageText = "6" }
				@{ Path = "****"; MessageText = "6" }
				@{ Path = "TestDrive:\RawPackages\"; MessageText = "4" }
				@{ Path = "TestDrive:\RawPackages\."; MessageText = "6" }
				@{ Path = "TestDrive:\RawPackages\*"; MessageText = "6" }
				@{ Path = "TestDrive:\RawPackages\localpackage-1.0"; MessageText = "2" }
				@{ Path = "TestDrive:\RawPackages\localpackage-1.0."; MessageText = "6" }
				@{ Path = "TestDrive:\RawPackages\localpackage-1.0.*"; MessageText = "6" }
				@{ Path = "TestDrive:\RawPackages\localpackage-1.0.file"; MessageText = "2" }
				@{ Path = "TestDrive:\RawPackages\localpackage-1.0.*."; MessageText = "6" }
				@{ Path = "TestDrive:\RawPackages\localpackage-1.0.*\"; MessageText = "6" }
				@{ Path = "TestDrive:\RawPackages\localpackage-1.0*"; MessageText = "6" }
				@{ Path = "TestDrive:\RawPackages\localpackage*"; MessageText = "6" }
				@{ Path = "TestDrive:\RawPackages\PortablePackage_1.3.zip"; MessageText = "5" }
				@{ Path = "TestDrive:\RawPackages\PortablePackage_1.0"; MessageText = "4" }
				@{ Path = "TestDrive:\RawPackages\PortablePackage_1.0\"; MessageText = "4" }
				@{ Path = "TestDrive:\RawPackages\*package*"; MessageText = "6" }
				@{ Path = "TestDrive:\RawPackages\*package*.*"; MessageText = "6" }
				
			) {
				
				# Pass test case data into the test body
				Param ([AllowEmptyString()]$Path, $MessageText)
				
				# Copy the test packages from the git repo to the temporary drive
				New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
				Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
				
				# Run the command to test
				New-PMPackage -Name "test-package" -LocalPackage -PackageLocation $Path
				
				# Get the correct warning message that should be displayed in each test case
				switch ($MessageText) {
					
					"1" { $MessageText = "The path cannot be empty" }
					"2" { $MessageText = "There is no valid path pointing to: $Path" }
					"4" { $MessageText = "There is no (single) executable located at the path: $Path" }
					"5" { $MessageText = "There is no installer file located at the path: $Path" }
					"6" { $MessageText = "The path provided is not accepted for safety reasons" }
					
				}
				
				# Check that the warning message was properly sent
				Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
					$DisplayWarning -eq $true -and
					$Message -eq $MessageText
				}
				
				# Check that the database file hasn't been created (by some accident)
				Test-Path -Path "$dataPath\packageDatabase.xml" | Should -Be $false
				Test-Path -Path "$dataPath\packages\*" | Should -Be $false
				
				# Delete the packages and package store for next test
				Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
				Remove-Item -Path "$dataPath\packages" -Recurse -Force
			}
			
			It "Given invalid parameter <Type>Scriptblock <Scriptblock>; It should warn and stop execution" -TestCases @(
				
				# The different invalid test cases for a scriptblocks
				@{ Type = "Pre-Install"; Scriptblock = {}; MessageText = "1" }
				@{ Type = "Pre-Install"; Scriptblock = {   }; MessageText = "1" }
				@{ Type = "Pre-Install"; Scriptblock = {*}; MessageText = "2" }
				
				@{ Type = "Post-Install"; Scriptblock = {}; MessageText = "1" }
				@{ Type = "Post-Install"; Scriptblock = {   }; MessageText = "1" }
				@{ Type = "Post-Install"; Scriptblock = {*}; MessageText = "2" }
				
				@{ Type = "Uninstall"; Scriptblock = {}; MessageText = "1" }
				@{ Type = "Uninstall"; Scriptblock = {   }; MessageText = "1" }
				@{ Type = "Uninstall"; Scriptblock = {*}; MessageText = "2" }
				
			) {
				
				# Pass the test case data into the test case body
				Param($Type, $Scriptblock, $MessageText)
				
				# Copy the test packages from the git repo to the temporary drive
				New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
				Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
				
				# Run the command to test
				switch ($Type) {
					
					"Pre-Install" { New-PMPackage -Name "test-package" -LocalPackage -PackageLocation "TestDrive:\RawPackages\localpackage-1.0.exe" -PreInstallScriptblock $Scriptblock }
					"Post-Install" { New-PMPackage -Name "test-package" -LocalPackage -PackageLocation "TestDrive:\RawPackages\localpackage-1.0.exe" -PostInstallScriptblock $Scriptblock }
					"Uninstall" { New-PMPackage -Name "test-package" -LocalPackage -PackageLocation "TestDrive:\RawPackages\localpackage-1.0.exe" -UninstallScriptblock $Scriptblock }
					
				}
				
				# Get the correct warning message that should be displayed in each test case
				switch ($MessageText) {
					
					"1" { $MessageText = "The $Type Scriptblock cannot be empty" }
					"2" { $MessageText = "The $Type Scriptblock cannot just be '*'" }
					
				}
				
				# Check that the warning message was properly sent
				Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
					$DisplayWarning -eq $true -and
					$Message -eq $MessageText
				}
				
				# Check that the executable hasn't been moved from the original directory
				Test-Path -Path "TestDrive:\RawPackages\localpackage-1.0.exe" | Should -Be $true
				
				# Check that the database file hasn't been created (by some accident)
				Test-Path -Path "$dataPath\packageDatabase.xml" | Should -Be $false
				Test-Path -Path "$dataPath\packages\*" | Should -Be $false
				
				# Delete the packages for next test
				Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
				
			}
			
		}
		
		# Delete the package store and database file for next set of tests
		Remove-Item -Path "$dataPath\packageDatabase.xml" -Force -ErrorAction SilentlyContinue
		Remove-Item -Path "$dataPath\packages" -Recurse -Force -ErrorAction SilentlyContinue
		Remove-Item -Path "TestDrive:\RawPackages" -Recurse -Force -ErrorAction SilentlyContinue
		
	}
	
	Context "Url Package Validation" {
		
		It "Given valid parameters: Name <Name>; PackageLocation <Url>; InstallDirectory <InstallDirectory>; Note <Note>; PreInstallScriptblock <PreInstallScriptblock>; PostInstallScriptblock <PostInstallScriptblock>; UninstallScriptblock <UninstallScriptblocl>; It should correctly write the data" -TestCases @(
			
			# The different valid test cases for a url package
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptBlock = {} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptBlock = {} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptBlock = {} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptBlock = {} }
			
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptBlock = {} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptBlock = {} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptBlock = {} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptBlock = {} }
			
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptBlock = {} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptBlock = {} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptBlock = {} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptBlock = {} }
			
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptBlock = {Write-Host "hello"} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptBlock = {Write-Host "hello"} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptBlock = {Write-Host "hello"} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptBlock = {Write-Host "hello"} }
			
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptBlock = {Write-Host "hello"} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptBlock = {Write-Host "hello"} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptBlock = {Write-Host "hello"} }
			@{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptBlock = {Write-Host "hello"} }
			
		) {
			
			#Pass test case data into the test body
			Param ($Name, $PackageLocation, [AllowEmptyString()]$InstallDirectory, [AllowEmptyString()]$Note, $PreInstallScriptblock, $PostInstallScriptblock, $UninstallScriptblock)
			
			# Run the command to test
			if ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false -and `
				[System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false -and `
				[System.String]::IsNullOrWhiteSpace($UninstallScriptblock.ToString()) -eq $false) {
				
				New-PMPackage -Name $Name -UrlPackage -PackageLocation $PackageLocation -InstallDirectory $InstallDirectory -Note $Note -PreInstallScriptblock $PreInstallScriptblock -PostInstallScriptblock $PostInstallScriptblock -UninstallScriptblock $UninstallScriptblock
				
			}elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {
				
				New-PMPackage -Name $Name -UrlPackage -PackageLocation $PackageLocation -InstallDirectory $InstallDirectory -Note $Note -PreInstallScriptblock $PreInstallScriptblock
				
			}elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false) {
				
				New-PMPackage -Name $Name -UrlPackage -PackageLocation $PackageLocation -InstallDirectory $InstallDirectory -Note $Note -PostInstallScriptblock $PostInstallScriptblock
				
			}elseif ([System.String]::IsNullOrWhiteSpace($UninstallScriptblock.ToString()) -eq $false) {
				
				New-PMPackage -Name $Name -UrlPackage -PackageLocation $PackageLocation -InstallDirectory $InstallDirectory -Note $Note -UninstallScriptblock $UninstallScriptblock
				
			}else {
				
				New-PMPackage -Name $Name -UrlPackage -PackageLocation $PackageLocation -InstallDirectory $InstallDirectory -Note $Note
				
			}
			
			# Check that the database has been created
			Test-Path -Path "$dataPath\packageDatabase.xml" | Should -Be $true
			
			# Read the written data back in to validate
			$packageList = Import-PackageList
			$package = $packageList[0]
			
			# Check the property values are correct
			$package.Name | Should -Be $Name
			$package.Type | Should -Be "UrlPackage"
			$package.IsInstalled | Should -Be $false
			$package.Url | Should -Be $PackageLocation
			
			# Check the optional property valuse are correct
			if ([System.String]::IsNullOrWhiteSpace($InstallDirectory) -eq $true) {
				$package.InstallDirectory | Should -Be $null
			}else {
				$package.InstallDirectory | Should -Be $InstallDirectory
			}
			
			if ([System.String]::IsNullOrWhiteSpace($Note) -eq $true) {
				$package.Note | Should -Be $null
			}else {
				$package.Note | Should -Be $Note
			}
			
			# Check that the scriptblocks have been properly added
			([Scriptblock]::Create($package.PreInstallScriptBlock) -like $PreInstallScriptblock) | Should -Be $true
			([Scriptblock]::Create($package.PostInstallScriptBlock) -like $PostInstallScriptblock) | Should -Be $true
			([Scriptblock]::Create($package.UninstallScriptBlock) -like $UninstallScriptblock) | Should -Be $true
			
			# Delete the database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			
		}
		
		InModuleScope -ModuleName ProgramManager {
			
			# Mock the function to then assert if it was called, i.e. if a message would be printed to screen
			Mock Write-Message { }
			
			It "Given invalid parameter -Name <Name>; It should warn and stop execution" -TestCases @(
				
				# The different invalid test cases for a name
				@{ Name = ""; MessageText = "1" }
				@{ Name = " "; MessageText = "1" }
				@{ Name = "     "; MessageText = "1" }
				@{ Name = "."; MessageText = "2" }
				@{ Name = "*"; MessageText = "2" }
				@{ Name = ".*"; MessageText = "2" }
				@{ Name = "asg%346£^ehah$%^47434!*"; MessageText = "2" }
				@{ Name = "..."; MessageText = "2" }
				@{ Name = "***"; MessageText = "2" }
				@{ Name = "existing-package"; MessageText = "3" }
				
			) {
				
				# Pass test case data into the test body
				Param ([AllowEmptyString()]$Name, $MessageText)
				
				# Copy over pre-populated database file from git to check for name clashse too
				Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
				
				# Run the command to test
				New-PMPackage -Name $Name -UrlPackage -PackageLocation "https://somewhere"
				
				# Get the correct warning message that should be displayed in each test case
				switch ($MessageText) {
					
					"1" { $MessageText = "The name cannot be empty" }
					"2" { $MessageText = "The name contains invalid characters" }
					"3" { $MessageText = "There already exists a package called: $Name" }
					
				}
				
				# Check that the warning message was properly sent
				Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
					$DisplayWarning -eq $true -and
					$Message -eq $MessageText
				}
				
				# Delete the database file for next test
				Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
				
			}
			
			It "Given invalid parameter <Type>Scriptblock <Scriptblock>; It should warn and stop execution" -TestCases @(
				
				# The dfferent invalid test cases for a scriptblocks
				@{ Type = "Pre-Install"; Scriptblock = {}; MessageText = "1" }
				@{ Type = "Pre-Install"; Scriptblock = {   }; MessageText = "1" }
				@{ Type = "Pre-Install"; Scriptblock = {*}; MessageText = "2" }
				
				@{ Type = "Post-Install"; Scriptblock = {}; MessageText = "1" }
				@{ Type = "Post-Install"; Scriptblock = {   }; MessageText = "1" }
				@{ Type = "Post-Install"; Scriptblock = {*}; MessageText = "2" }
				
				@{ Type = "Uninstall"; Scriptblock = {}; MessageText = "1" }
				@{ Type = "Uninstall"; Scriptblock = {   }; MessageText = "1" }
				@{ Type = "Uninstall"; Scriptblock = {*}; MessageText = "2" }
				
			) {
				
				# Pass the test case data into the test case body
				Param($Type, $Scriptblock, $MessageText)
								
				# Run the command to test
				switch ($Type) {
					
					"Pre-Install" { New-PMPackage -Name "test-package" -UrlPackage -PackageLocation "https://somewhere" -PreInstallScriptblock $Scriptblock }
					"Post-Install" { New-PMPackage -Name "test-package" -UrlPackage -PackageLocation "https://somewhere" -PostInstallScriptblock $Scriptblock }
					"Uninstall" { New-PMPackage -Name "test-package" -UrlPackage -PackageLocation "https://somewhere" -UninstallScriptblock $Scriptblock }
					
				}
				
				# Get the correct warning message that should be displayed in each test case
				switch ($MessageText) {
					
					"1" { $MessageText = "The $Type Scriptblock cannot be empty" }
					"2" { $MessageText = "The $Type Scriptblock cannot just be '*'" }
					
				}
				
				# Check that the warning message was properly sent
				Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
					$DisplayWarning -eq $true -and
					$Message -eq $MessageText
				}
				
				# Check that the database file hasn't been created (by some accident)
				Test-Path -Path "$dataPath\packageDatabase.xml" | Should -Be $false
				
			}
			
		}
		
	}
	
	Context "Portable Package Validation" {
		
		It "Given valid parameters: PackageLocation TestDrive:\RawPackages\<FileName>; InstallDirectory <InstallDirectory>; Note <Note>; PreInstallScriptBlock <PreInstallScriptblock>; PostInstallScriptBlock <PostInstallScriptblock>; UninstallScriptblock <UninstallScriptblock>; It should correctly write the data" -TestCases @(
			
			# The different valid test cases for a portable package (archive, folder, and exe)
			@{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			
			@{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			@{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {}; UninstallScriptblock = {} }
			
			@{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {} }
			@{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {} }
			@{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {} }
			@{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {} }
			@{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {} }
			@{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {} }
			
			@{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {}; PostInstallScriptblock = {}; UninstallScriptblock = {Write-Host "hello"} }
			
			@{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {Write-Host "hello"} }
			@{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScriptblock = {Write-Host "hello"}; PostInstallScriptblock = {Write-Host "hello"}; UninstallScriptblock = {Write-Host "hello"} }
			
		) {
			
			# Pass test case data into the test body
			Param ($Type, $FileName, $InstallDirectory, [AllowEmptyString()]$Note, $PreInstallScriptblock, $PostInstallScriptblock, $UninstallScriptblock)
			
			# Copy the test packages from the git repo to the temporary drive
			New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
			Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
			
			# Run the command to test
			if ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false -and `
				[System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false -and `
				[System.String]::IsNullOrWhiteSpace($UninstallScriptblock.ToString()) -eq $false) {
				
				New-PMPackage -Name "test-package" -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDirectory -Note $Note -PreInstallScriptblock $PreInstallScriptblock -PostInstallScriptblock $PostInstallScriptblock -UninstallScriptblock $UninstallScriptblock
				
			}elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScriptblock.ToString()) -eq $false) {
				
				New-PMPackage -Name "test-package" -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDirectory -Note $Note -PreInstallScriptblock $PreInstallScriptblock
				
			}elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScriptblock.ToString()) -eq $false) {
				
				New-PMPackage -Name "test-package" -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDirectory -Note $Note -PostInstallScriptblock $PostInstallScriptblock
				
			}elseif ([System.String]::IsNullOrWhiteSpace($UninstallScriptblock.ToString()) -eq $false) {
				
				New-PMPackage -Name "test-package" -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDirectory -Note $Note -UninstallScriptblock $UninstallScriptblock
				
			}else {
				
				New-PMPackage -Name "test-package" -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDirectory -Note $Note
				
			}
			
			# Check that the database has been created
			Test-Path -Path "$dataPath\packageDatabase.xml" | Should -Be $true
			
			# Read the written data back in to validate
			$packageList = Import-PackageList
			$package = $packageList[0]
			
			# Check the property values are correct
			$package.Name | Should -Be "test-package"
			$package.Type | Should -Be "PortablePackage"
			$package.IsInstalled | Should -Be $false
			$package.InstallDirectory | Should -Be $InstallDirectory
			
			# Check the optional property valuse are correct
			if ([System.String]::IsNullOrWhiteSpace($Note) -eq $true) {
				$package.Note | Should -Be $null
			}else {
				$package.Note | Should -Be $Note
			}
			
			# Check that the scriptblocks have been properly added
			([Scriptblock]::Create($package.PreInstallScriptblock) -like $PreInstallScriptblock) | Should -Be $true
			([Scriptblock]::Create($package.PostInstallScriptblock) -like $PostInstallScriptblock) | Should -Be $true
			([Scriptblock]::Create($package.UninstallScriptblock) -like $UninstallScriptblock) | Should -Be $true
			
			# Test that there is only one package in the store
			$packageFiles = Get-ChildItem -Path "$dataPath\packages\"
			$packageFiles.Count | Should -Be 1
			
			if ($Type -eq "exe") {
				
				# Check that the original executable has been moved
				Test-Path -Path "TestDrive:\RawPackages\$FileName" | Should -Be $false
				Test-Path -Path "$dataPath\packages\test-package\$FileName" | Should -Be $true
								
			}elseif ($Type -eq "zip" -or $Type -eq "folder") {
				
				# Check that the original archive/folder has been moved
				Test-Path -Path "TestDrive:\RawPackages\$FileName" | Should -Be $false
				Test-Path -Path "$dataPath\packages\test-package\" | Should -Be $true
				
			}			
			
			# Delete the package store and database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			Remove-Item -Path "$dataPath\packages\" -Recurse -Force
			Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
			
		}
		
		InModuleScope -ModuleName ProgramManager {
			
			# Mock the function to then assert if it was called, i.e. if a message would be printed to screen
			Mock Write-Message { }
			
			It "Given invalid parameter -Name <Name>; It should warn and stop execution" -TestCases @(
				
				# The different invalid test cases for a name
				@{ Name = ""; MessageText = "1" }
				@{ Name = " "; MessageText = "1" }
				@{ Name = "     "; MessageText = "1" }
				@{ Name = "."; MessageText = "2" }
				@{ Name = "*"; MessageText = "2" }
				@{ Name = ".*"; MessageText = "2" }
				@{ Name = "asg%346£^ehah$%^47434!*"; MessageText = "2" }
				@{ Name = "..."; MessageText = "2" }
				@{ Name = "***"; MessageText = "2" }
				@{ Name = "existing-package"; MessageText = "3" }
				
			) {
				
				# Pass test case data into the test body
				Param ([AllowEmptyString()]$Name, $MessageText)
				
				# Copy over pre-populated database file from git to check for name clashse as well...
				Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
				
				# Copy the test packages from the git repo to the temporary drive
				New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
				Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
				
				# Run the command to test
				New-PMPackage -Name $Name -PortablePackage -PackageLocation "TestDrive:\RawPackages\portablepackage-1.0.exe" -InstallDirectory "TestDrive:\"
				
				# Get the correct warning message that should be displayed in each test case
				switch ($MessageText) {
					
					"1" { $MessageText = "The name cannot be empty" }
					"2" { $MessageText = "The name contains invalid characters" }
					"3" { $MessageText = "There already exists a package called: $Name" }
					
				}
				
				# Check that the warning message was properly sent
				Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
					$DisplayWarning -eq $true -and
					$Message -eq $MessageText
				}
				
				# Check that the original file hasn't been moved from the original directory
				Test-Path -Path "TestDrive:\RawPackages\portablepackage-1.0.exe" | Should -Be $true
								
				# Delete the package store and database file for next test
				Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
				Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
				
			}
			
			It "Given invalid parameter -Path <Path>; It should warn and stop execution" -TestCases @(
			
				# The different invalid test cases for a local filepath pointing to a folder/exe/zip
				@{ Path = ""; MessageText = "1" }
				@{ Path = " "; MessageText = "1" }
				@{ Path = "           "; MessageText = "1" }
				@{ Path = "~"; MessageText = "6" }
				@{ Path = "."; MessageText = "6" }
				@{ Path = ".."; MessageText = "6" }
				@{ Path = "..."; MessageText = "6" }
				@{ Path = "b"; MessageText = "2" }
				@{ Path = "TestDrive:\non-existent-folder"; MessageText = "2" }
				@{ Path = "TestDrive:\non-existent-folder\non-existent-file"; MessageText = "2" }
				@{ Path = "TestDrive:\non-existent-folder\non-existent-file."; MessageText = "6" }
				@{ Path = "TestDrive:\non-existent-folder\non-existent-file.*"; MessageText = "6" }
				@{ Path = "TestDrive:\non-existent-folder\non-existent-file.file"; MessageText = "2" }
				@{ Path = "TestDrive:\non-existent-folder\"; MessageText = "2" }
				@{ Path = "TestDrive:\non-existent-folder\."; MessageText = "6" }
				@{ Path = "TestDrive:\non-existent-folder\*"; MessageText = "6" }
				@{ Path = "asd9udfh87d78yd7nydf7bfy79sd6fjik2l"; MessageText = "2" }
				@{ Path = "^£$%*&^$"; MessageText = "6" }
				@{ Path = "*"; MessageText = "6" }
				@{ Path = "****"; MessageText = "6" }
				@{ Path = "TestDrive:\RawPackages\portablepackage-1.0"; MessageText = "2" }
				@{ Path = "TestDrive:\RawPackages\portablepackage-1.0."; MessageText = "6" }
				@{ Path = "TestDrive:\RawPackages\portablepackage*"; MessageText = "6" }
				@{ Path = "TestDrive:\RawPackages\*package*"; MessageText = "6" }
				@{ Path = "TestDrive:\RawPackages\*package*.*"; MessageText = "6" }
				
			) {
				
				# Pass test case data into the test body
				Param ([AllowEmptyString()]$Path, $MessageText)
				
				# Copy the test packages from the git repo to the temporary drive
				New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
				Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
				
				# Run the command to test
				New-PMPackage -Name "test-package" -PortablePackage -PackageLocation $Path -InstallDirectory "TestDrive:\"
				
				# Get the correct warning message that should be displayed in each test case
				switch ($MessageText) {
					
					"1" { $MessageText = "The path cannot be empty" }
					"2" { $MessageText = "There is no folder/file located at the path: $Path" }
					"4" { $MessageText = "There is no (single) executable located at the path: $Path" }
					"5" { $MessageText = "There is no installer file located at the path: $Path" }
					"6" { $MessageText = "The path provided is not accepted for safety reasons" }
					
				}
				
				# Check that the warning message was properly sent
				Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
					$DisplayWarning -eq $true -and
					$Message -eq $MessageText
				}
				
				# Check that the database file hasn't been created (by some accident)
				Test-Path -Path "$dataPath\packageDatabase.xml" | Should -Be $false
				Test-Path -Path "$dataPath\packages\*" | Should -Be $false
				
				# Delete the packages for next test
				Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
				Remove-Item -Path "$dataPath\packages" -Recurse -Force 
				
			}
			
			It "Given invalid parameter <Type>Scriptblock <Scriptblock>; It should warn and stop execution" -TestCases @(
				
				# The dfferent invalid test cases for a scriptblocks
				@{ Type = "Pre-Install"; Scriptblock = {}; MessageText = "1" }
				@{ Type = "Pre-Install"; Scriptblock = {   }; MessageText = "1" }
				@{ Type = "Pre-Install"; Scriptblock = {*}; MessageText = "2" }
				
				@{ Type = "Post-Install"; Scriptblock = {}; MessageText = "1" }
				@{ Type = "Post-Install"; Scriptblock = {   }; MessageText = "1" }
				@{ Type = "Post-Install"; Scriptblock = {*}; MessageText = "2" }
				
				@{ Type = "Uninstall"; Scriptblock = {}; MessageText = "1" }
				@{ Type = "Uninstall"; Scriptblock = {   }; MessageText = "1" }
				@{ Type = "Uninstall"; Scriptblock = {*}; MessageText = "2" }
				
			) {
				
				# Pass the test case data into the test case body
				Param($Type, $Scriptblock, $MessageText)
				
				# Copy the test packages from the git repo to the temporary drive
				New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
				Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
				
				# Run the command to test
				switch ($Type) {
					
					"Pre-Install" { New-PMPackage -Name "test-package" -PortablePackage -PackageLocation "TestDrive:\RawPackages\portablepackage-1.0.exe" -InstallDirectory "TestDrive:\" -PreInstallScriptblock $Scriptblock }
					"Post-Install" { New-PMPackage -Name "test-package" -PortablePackage -PackageLocation "TestDrive:\RawPackages\portablepackage-1.0.exe" -InstallDirectory "TestDrive:\" -PostInstallScriptblock $Scriptblock }
					"Uninstall" { New-PMPackage -Name "test-package" -PortablePackage -PackageLocation "TestDrive:\RawPackages\portablepackage-1.0.exe" -InstallDirectory "TestDrive:\" -UninstallScriptblock $Scriptblock }
					
				}
				
				# Get the correct warning message that should be displayed in each test case
				switch ($MessageText) {
					
					"1" { $MessageText = "The $Type Scriptblock cannot be empty" }
					"2" { $MessageText = "The $Type Scriptblock cannot just be '*'" }
					
				}
				
				# Check that the warning message was properly sent
				Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
					$DisplayWarning -eq $true -and
					$Message -eq $MessageText
				}
				
				# Check that the executable hasn't been moved from the original directory
				Test-Path -Path "TestDrive:\RawPackages\portablepackage-1.0.exe" | Should -Be $true
				
				# Check that the database file hasn't been created (by some accident)
				Test-Path -Path "$dataPath\packageDatabase.xml" | Should -Be $false
				Test-Path -Path "$dataPath\packages\*" | Should -Be $false
				
				# Delete the packages for next test
				Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
			}
			
		}
		
	}
	
}