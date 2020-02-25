Describe -Verbose "Validating Remove-PMPacakge" {
	$VerbosePreference = "Continue"
	
	# Create a temporary data directory within the Pester temp drive
	# Modify the module datapath to reflect this temporary location
	New-Item -ItemType Directory -Path "TestDrive:\ProgramManager\"
	& (Get-Module ProgramManager) { $script:DataPath = "TestDrive:\ProgramManager" }
	# For use within the test script, since no access to module- $script:DataPath
	$dataPath = "TestDrive:\ProgramManager"
	
	It "Given valid parameters: PackageName <PackageName>; of type <Type> <FileName>; It should correctly remove data and delete files" -TestCases @(
		
		# The different valid test cases for a local package (exe and msi)
		@{ Type = "Local"; PackageName = "local-package"; FileName = "localpackage-1.0.exe" }
		@{ Type = "Local"; PackageName = "local-package"; FileName = "localpackage-1.0.msi" }
		@{ Type = "Portable"; PackageName = "portable-package"; FileName = "PortablePackage_1.3.zip" }
		@{ Type = "Portable"; PackageName = "portable-package"; FileName = "portablepackage-1.0.exe" }
		@{ Type = "Portable"; PackageName = "portable-package"; FileName = "PortablePackage_1.0\" }
		@{ Type = "Url"; PackageName = "url-package"; FileName = "" }
		
	) {
		
		# Pass test case data into the test body
		Param ($Type, $PackageName, [AllowEmptyString()]$FileName)
		
		# Copy the test packages from the git repo to the temporary drive
		New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
		Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
		
		# Create a package entry so then test the removal of said package
		if ($Type -eq "Local") {
			
			New-PMPackage -Name $PackageName -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName"       
			
		}elseif ($Type -eq "Portable") {
			
			New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\"        
			
		}elseif ($Type -eq "Url") {
			
			New-PMPackage -Name $PackageName -UrlPackage -PackageLocation "https://somewhere"
			
		}elseif ($Type -eq "Chocolatey") {
			
			# TODO: implement chocolatey support
			
		}
		
		# Read the database back in to ensure the package was added properly
		$packageList = Import-PackageList
		$packageList.Count | Should -Be 1
		if ($Type -eq "Local" -or $Type -eq "Portable") {
			# Check that the package files haven't been left behind in the original directory
			Test-Path -Path "TestDrive:\RawPackages\$FileName" | Should -Be $false
		}
		
		# Run the command
		Remove-PMPackage -PackageName $PackageName
		
		# Read the database back in to validate that the package was removed properly
		$packageList = Import-PackageList
		$packageList.Count | Should -Be 0
		
		if ($Type -eq "Local" -or $Type -eq "Portable") {
			# Check that the package files haven't been left behind in the package store
			Test-Path -Path "$dataPath\packages\$PackageName" | Should -Be $false
		}
		
		
		# Delete the package store and database file for next test
		Remove-Item -Path "$dataPath\packageDatabase.xml" -Force -ErrorAction SilentlyContinue
		Remove-Item -Path "$dataPath\packages" -Recurse -Force
		Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
		
	}
	
	It "Given valid parameters: PackageName <PackageName>; of type <Type> <FileName>; -RetainFiles Path <Path>; It should correctly remove data and move files" -TestCases @(
		
		# The different valid test cases for a local package (exe and msi)
		@{ Type = "Local"; PackageName = "local-package"; FileName = "localpackage-1.0.exe"; Path = "TestDrive:\moveDir" }
		@{ Type = "Local"; PackageName = "local-package"; FileName = "localpackage-1.0.msi"; Path = "TestDrive:\moveDir" }
		@{ Type = "Portable"; PackageName = "protable-package"; FileName = "PortablePackage_1.3.zip"; Path = "TestDrive:\moveDir" }
		@{ Type = "Portable"; PackageName = "protable-package"; FileName = "portablepackage-1.0.exe"; Path = "TestDrive:\moveDir" }
		@{ Type = "Portable"; PackageName = "protable-package"; FileName = "PortablePackage_1.0\"; Path = "TestDrive:\moveDir" }
		
	) {
		
		# Pass test case data into the test body
		Param ($Type, $PackageName, $FileName, $Path)
		
		# Copy the test packages from the git repo to the temporary drive
		New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
		Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
		New-Item -ItemType Directory -Path "TestDrive:\moveDir\"
		
		# Create a package entry so then test the removal of said package
		if ($Type -eq "Local") {
			New-PMPackage -Name $PackageName -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName"          
		}elseif ($Type -eq "Portable") {
			New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\"        
		}
		
		# Read the database back in to ensure the package was added properly
		$packageList = Import-PackageList
		$packageList.Count | Should -Be 1
		
		# Check that the package files haven't been left behind in the original directory
		Test-Path -Path "TestDrive:\RawPackages\$FileName" | Should -Be $false
		
		# Run the command
		Remove-PMPackage -PackageName $PackageName -RetainFiles -Path $Path
		
		# Read the database back in to validate that the package was removed properly
		$packageList = Import-PackageList
		$packageList.Count | Should -Be 0
		
		# Check that the package files haven't been left behind in the package store
		Test-Path -Path "$dataPath\packages\$PackageName" | Should -Be $false
		
		# Check that the package files have been moved to the new location
		Test-Path -Path "$Path\$PackageName\" | Should -Be $true
		
		# Delete the package store and database file for next test
		Remove-Item -Path "$dataPath\packageDatabase.xml" -Force -ErrorAction SilentlyContinue
		Remove-Item -Path "$dataPath\packages" -Recurse -Force
		Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
		Remove-Item -Path "TestDrive:\moveDir" -Recurse -Force
		
	}
	
	InModuleScope -ModuleName ProgramManager {
		
		# Stop any message outputting to screen
		Mock Write-Message { }
		
		It "Given invalid parameter -PackageName <PackageName>; It should stop and warn" -TestCases @(
			
			# The different invalid test cases for a local filepath
			@{ PackageName = "" }
			@{ PackageName = " " }
			@{ PackageName = "." }
			@{ PackageName = "*" }
			@{ PackageName = ".*" }
			@{ PackageName = "asg%346£^ehah$%^47434!*" }
			@{ PackageName = "..." }
			@{ PackageName = "***" }
			@{ PackageName = "     " }
			
		) {
			
			# Pass test case data into the test body
			Param ([AllowEmptyString()]$PackageName)
			
			# Copy over pre-populated database file from git to check for name clashes
			Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
			
			# Run the command
			Remove-PMPackage -PackageName $PackageName 
			
			# Check that the warning message was properly sent
			Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
				$DisplayWarning -eq $true
			}
			
			
			# Delete the package store and database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			
		}
		
		It "Given invalid parameter -RetainFiles -Path <Path>; On a invalid \packages\ directory; It should stop and error" -TestCases @(
			
			# The different invalid test cases for a local filepath
			@{ Path = ""; PackageName = "existing-local-package" }
			@{ Path = " "; PackageName = "existing-local-package" }
			@{ Path = "*"; PackageName = "existing-local-package" }
			@{ Path = ".*"; PackageName = "existing-local-package" }
			@{ Path = "."; PackageName = "existing-local-package" }
			@{ Path = "asdasd"; PackageName = "existing-local-package" }
			
		) {
			
			# Pass test case data into the test body
			Param ([AllowEmptyString()]$Path, $PackageName)
			
			# Copy over pre-populated database file
			Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
			
			# Run the command
			Remove-PMPackage -PackageName $PackageName -RetainFiles -Path $Path
			
			# Check that the warning message was properly sent
			if ([System.String]::IsNullOrWhiteSpace($Path) -eq $true) {
				Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
					$DisplayWarning -eq $true
				}
			}else {
				Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
					$DisplayError -eq $true
				}
			}
			
			
			# Delete the package store and database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			
		}
		
		It "Given invalid parameter -RetainFiles -Path <Path>; On a valid \packages\ directory; It should stop and warn" -TestCases @(
			
			# The different invalid test cases for a local filepath
			@{ Path = ""; PackageName = "new-package" }
			@{ Path = " "; PackageName = "new-package" }
			@{ Path = "*"; PackageName = "new-package" }
			@{ Path = ".*"; PackageName = "new-package" }
			@{ Path = "asdasdas"; PackageName = "new-package" }
			@{ Path = "**"; PackageName = "new-package" }
			@{ Path = "."; PackageName = "new-package" }
			@{ Path = ""; PackageName = "new-package" }
			
		) {
			
			# Pass test case data into the test body
			Param ([AllowEmptyString()]$Path, $PackageName)
			
			# Copy the test packages from the git repo to the temporary drive
			New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
			Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
			# Copy over pre-populated database file
			Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
			
			# Add the package entry
			New-PMPackage -Name $PackageName -LocalPackage "TestDrive:\RawPackages\localpackage-1.0.exe"
			
			# Run the command
			Remove-PMPackage -PackageName $PackageName -RetainFiles -Path $Path
			
			# Check that the warning message was properly sent
			Assert-MockCalled Write-Message -Times 1 -Scope It -ParameterFilter { # TODO:  -Exactly flag was causing issues; fix
				$DisplayWarning -eq $true
			}
			
			
			# Delete the package store and database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			Remove-Item -Path "$dataPath\packages" -Recurse -Force -ErrorAction SilentlyContinue
			Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
			
		}
		
		It "Given parameter -RetainFiles -Path <Path>; On a url-package; It should continue and warn" -TestCases @(
			
			# The different invalid test cases for a local filepath
			@{ Path = "TestDrive:\"; PackageName = "existing-package" }
			@{ Path = ""; PackageName = "existing-package" }
			@{ Path = " "; PackageName = "existing-package" }
			@{ Path = "*"; PackageName = "existing-package" }
			@{ Path = "."; PackageName = "existing-package" }
			@{ Path = ".*"; PackageName = "existing-package" }
			@{ Path = "adasd"; PackageName = "existing-package" }
			
		) {
			
			# Pass test case data into the test body
			Param ([AllowEmptyString()]$Path, $PackageName)
			
			# Copy over pre-populated database file
			Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
			
			# Run the command
			Remove-PMPackage -PackageName $PackageName -RetainFiles -Path $Path
			
			# Check that the warning message was properly sent
			Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
				$DisplayWarning -eq $true
			}
			
			
			# Delete the package store and database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			
		}
		
	}
	
	
}