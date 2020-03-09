Describe -Verbose "Validating Remove-PMPacakge" {
	$VerbosePreference = "Continue"
	
	# Create a temporary data directory within the Pester temp drive
	# Modify the module datapath to reflect this temporary location
	New-Item -ItemType Directory -Path "TestDrive:\ProgramManager\"
	& (Get-Module ProgramManager) { $script:DataPath = "TestDrive:\ProgramManager" }
	# For use within the test script, since no access to module- $script:DataPath
	$dataPath = "TestDrive:\ProgramManager"
	
	It "Given valid parameters: PackageName <PackageName>; of type <Type> <FileName>; It should correctly remove data and delete files" -TestCases @(
		
		# The different valid test cases for a local/portable/url package
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
		
		# Create a package entry to then test the removal of said package
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
		
		# Check that the package files have been correctly moved when adding package
		if ($Type -eq "Local" -or $Type -eq "Portable") {
			
			Test-Path -Path "TestDrive:\RawPackages\$FileName" | Should -Be $false
			
		}
		
		# Run the command to test
		Remove-PMPackage -PackageName $PackageName
		
		# Read the database back in to validate that the package was removed properly
		$packageList = Import-PackageList
		$packageList.Count | Should -Be 0
		
		# Check that the package files haven't been left behind in the package store
		if ($Type -eq "Local" -or $Type -eq "Portable") {
			
			Test-Path -Path "$dataPath\packages\$PackageName" | Should -Be $false
			
		}
		
		# Delete the package store and database file for next test
		Remove-Item -Path "$dataPath\packageDatabase.xml" -Force -ErrorAction SilentlyContinue
		Remove-Item -Path "$dataPath\packages" -Recurse -Force
		Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
		
	}
	
	It "Given valid parameters: PackageName <PackageName>; of type <Type> <FileName>; -RetainFiles Path <Path>; It should correctly remove data and move files" -TestCases @(
		
		# The different valid test cases for a local/portable package
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
		
		# Create a package entry to then test the removal of said package
		if ($Type -eq "Local") {
			
			New-PMPackage -Name $PackageName -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName"      
			    
		}elseif ($Type -eq "Portable") {
			
			New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\"  
			      
		}
		
		# Read the database back in to ensure the package was added properly
		$packageList = Import-PackageList
		$packageList.Count | Should -Be 1
		
		# Check that the package files have been correctly moved when adding package
		Test-Path -Path "TestDrive:\RawPackages\$FileName" | Should -Be $false
		
		# Run the command to test
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
		
		# Mock the function to then assert if it was called, i.e. if a message would be printed to screen
		Mock Write-Message { }
		
		It "Given invalid parameter -PackageName <PackageName>; It should warn and stop execution" -TestCases @(
			
			# The different invalid test cases for package name which doesn't exist
			@{ PackageName = ""; MessageText = "1" }
			@{ PackageName = " "; MessageText = "1" }
			@{ PackageName = "."; MessageText = "2" }
			@{ PackageName = "*"; MessageText = "2" }
			@{ PackageName = ".*"; MessageText = "2" }
			@{ PackageName = "asg%346£^ehah$%^47434!*"; MessageText = "2" }
			@{ PackageName = "..."; MessageText = "2" }
			@{ PackageName = "***"; MessageText = "2" }
			@{ PackageName = "     "; MessageText = "1" }
			
		) {
			
			# Pass test case data into the test body
			Param ([AllowEmptyString()]$PackageName, $MessageText)
			
			# Copy over pre-populated database file from git to check for name clashes
			Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
			
			# Run the command to test
			Remove-PMPackage -PackageName $PackageName 
			
			# Get the correct warning message that should be displayed in each test case
			switch ($MessageText) {
					
				"1" { $MessageText = "The package name cannot be empty" }
				"2" { $MessageText = "There is no package called: $PackageName" }
				
			}
			
			# Check that the warning message was properly sent
			Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
				$DisplayWarning -eq $true -and
				$Message -eq $MessageText
			}
			
			# Delete the package store and database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			
		}
		
		It "Given invalid parameter -RetainFiles -Path <Path>; On a invalid \packages\ directory; It should warn/error and stop" -TestCases @(
			
			# The different invalid test cases for an invalid Move-Path on an \packages\ directory which has been corrupted/modified externally
			@{ Path = ""; PackageName = "existing-local-package"; MessageText = "1" }
			@{ Path = " "; PackageName = "existing-local-package"; MessageText = "1" }
			@{ Path = "*"; PackageName = "existing-local-package"; MessageText = "2" }
			@{ Path = ".*"; PackageName = "existing-local-package"; MessageText = "2" }
			@{ Path = "."; PackageName = "existing-local-package"; MessageText = "2" }
			@{ Path = "asdasd"; PackageName = "existing-local-package"; MessageText = "2" }
			
		) {
			
			# Pass test case data into the test body
			Param ([AllowEmptyString()]$Path, $PackageName, $MessageText)
			
			# Copy over pre-populated database file
			Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
			
			# Run the command to test
			Remove-PMPackage -PackageName $PackageName -RetainFiles -Path $Path
			
			# Get the correct warning message that should be displayed in each test case
			switch ($MessageText) {
					
				"1" { $MessageText = "The path cannot be empty" }
				"2" { $MessageText = "There are no files for this package in the package store. This should not happen." }
				
			}
			
			# Check that the warning/error message was properly sent
			if ([System.String]::IsNullOrWhiteSpace($Path) -eq $true) {
				
				Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
					$DisplayWarning -eq $true -and
					$Message -eq $MessageText
				}
				
			}else {
				
				Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
					$DisplayError -eq $true -and
					$Message -eq $MessageText
				}
				
			}
			
			# Delete the package store and database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			
		}
		
		It "Given invalid parameter -RetainFiles -Path <Path>; On a valid \packages\ directory; It should stop and warn" -TestCases @(
			
			# The different invalid test cases for an invalid Move-Path on an \packages\ directory which is fine
			@{ Path = ""; PackageName = "new-package"; MessageText = "1" }
			@{ Path = " "; PackageName = "new-package"; MessageText = "1" }
			@{ Path = "*"; PackageName = "new-package"; MessageText = "3" }
			@{ Path = ".*"; PackageName = "new-package"; MessageText = "3" }
			@{ Path = "asdasdas"; PackageName = "new-package"; MessageText = "2" }
			@{ Path = "**"; PackageName = "new-package"; MessageText = "3" }
			@{ Path = "."; PackageName = "new-package"; MessageText = "3" }
			
		) {
			
			# Pass test case data into the test body
			Param ([AllowEmptyString()]$Path, $PackageName, $MessageText)
			
			# Copy the test packages from the git repo to the temporary drive
			New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
			Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
			
			# Copy over pre-populated database file
			Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
			
			# Add the package entry to test on
			New-PMPackage -Name $PackageName -LocalPackage "TestDrive:\RawPackages\localpackage-1.0.exe"
			
			# Run the command to test
			Remove-PMPackage -PackageName $PackageName -RetainFiles -Path $Path
			
			# Get the correct warning message that should be displayed in each test case
			switch ($MessageText) {
					
				"1" { $MessageText = "The path cannot be empty" }
				"2" { $MessageText = "The file path does not exist" }
				"3" { $MessageText = "The path contains invalid characters" }
				
			}
			
			# Check that the warning message was properly sent
			Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
				$DisplayWarning -eq $true -and
				$Message -eq $MessageText
			}
			
			# Delete the package store and database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			Remove-Item -Path "$dataPath\packages" -Recurse -Force -ErrorAction SilentlyContinue
			Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
			
		}
		
		It "Given parameter -RetainFiles -Path <Path>; On a url-package; It should warn but continue execution" -TestCases @(
			
			# The different valid and invalid test cases for a path when handling a url-package, which doesn't store any files
			@{ Path = "TestDrive:\"; PackageName = "existing-package" }
			@{ Path = "*"; PackageName = "existing-package" }
			@{ Path = "."; PackageName = "existing-package" }
			@{ Path = ".*"; PackageName = "existing-package" }
			@{ Path = "adasd"; PackageName = "existing-package" }
			
		) {
			
			# Pass test case data into the test body
			Param ([AllowEmptyString()]$Path, $PackageName)
			
			# Copy over pre-populated database file
			Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
			
			# Run the command to test
			Remove-PMPackage -PackageName $PackageName -RetainFiles -Path $Path
			
			# Check that the warning message was properly sent
			Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
				$DisplayWarning -eq $true -and
				$Message -eq "The flag -RetainFiles has no effect on a url package"
			}
			
			# Delete the package store and database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			
		}
		
	}
	
	
}