Describe -Verbose "Validating Set-PMPackage" {
	$VerbosePreference = "Continue"
	
	# Create a temporary data directory within the Pester temp drive
	# Modify the module datapath to reflect this temporary location
	New-Item -ItemType Directory -Path "TestDrive:\ProgramManager\"
	& (Get-Module ProgramManager) { $script:DataPath = "TestDrive:\ProgramManager" }
	# For use within the test script, since no access to module- $script:DataPath
	$dataPath = "TestDrive:\ProgramManager"
	
	It "Given valid parameters: PackageName <PackageName>; PropertyName <PropertyName>; PropertyValue <PropertyValue>; It should correctly edit the data" -TestCases @(
		
		# The different valid test cases for package and associated property names
		@{ PackageName = "local-package4"; PropertyName = "IsInstalled"; PropertyValue = "true" }
		@{ PackageName = "local-package4"; PropertyName = "InstallDirectory"; PropertyValue = "C:\Users" }
		@{ PackageName = "local-package4"; PropertyName = "Note"; PropertyValue = "A different description" }
		@{ PackageName = "portable-package2"; PropertyName = "IsInstalled"; PropertyValue = "true" }
		@{ PackageName = "portable-package2"; PropertyName = "InstallDirectory"; PropertyValue = "C:\Users" }
		@{ PackageName = "portable-package2"; PropertyName = "Note"; PropertyValue = "A different description" }
		@{ PackageName = "url-package4"; PropertyName = "Url"; PropertyValue = "https://some/website" }
		@{ PackageName = "url-package4"; PropertyName = "IsInstalled"; PropertyValue = "true" }
		@{ PackageName = "url-package4"; PropertyName = "InstallDirectory"; PropertyValue = "C:\Users" }
		@{ PackageName = "url-package4"; PropertyName = "Note"; PropertyValue = "A different description" }
		
	) {
		
		# Pass test case data into the test body
		Param ($PackageName, $PropertyName, $PropertyValue)
		
		# Copy over pre-populated database file from git to check for name clashse as well...
		Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
		
		# Get the package pre-modification
		$oldPackage = Get-PMPackage -PackageName $PackageName
		
		# Run the command to test
		Set-PMPackage -PackageName $PackageName -PropertyName $PropertyName -PropertyValue $PropertyValue
		
		# Read the written data back in to validate
		$packageList = Import-PackageList
		$package = $packageList | Where-Object { $_.Name -eq $PackageName }
		
		# Check that the property value has been updated
		$package.$PropertyName | Should -Be $PropertyValue
		
		# Check that the new package differs (since its been edited)
		($package -eq $oldPackage) | Should -Be $false
		
		# Delete the database file for next test
		Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
		
	}
	
	InModuleScope -ModuleName ProgramManager {
		
		# Mock the function to then assert if it was called, i.e. if a message would be printed to screen
		Mock Write-Message { }
		
		It "Given invalid parameter -PackageName <PackageName>" -TestCases @(
			
			# The different invalid values for a package name
			@{ PackageName = ""; MessageText = "1" }
			@{ PackageName = " "; MessageText = "1" }
			@{ PackageName = "*"; MessageText = "2" }
			@{ PackageName = "."; MessageText = "2" }
			@{ PackageName = ".*"; MessageText = "2" }
			@{ PackageName = "ajkf32toir930fow"; MessageText = "2" }
			@{ PackageName = "asdfSAGTWTEGrae4GTQ£TGw"; MessageText = "2" }
			
		) {
			
			# Pass test case data into the test body
			Param ([AllowEmptyString()]$PackageName, $MessageText)
			
			# Copy over pre-populated database file from git
			Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
			
			# Run the command to test
			Set-PMPackage -PackageName $PackageName -PropertyName "" -PropertyValue ""
			
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
			
			# Delete the database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			
		}
		
		It "Given invalid parameter -PropertyName <PropertyName>" -TestCases @(
			
			# The different invalid values for a property name on an existing package
			@{ PropertyName = ""; MessageText = "1" }
			@{ PropertyName = "."; MessageText = "2" }
			@{ PropertyName = "*"; MessageText = "2" }
			@{ PropertyName = ".*"; MessageText = "2" }
			@{ PropertyName = "  "; MessageText = "1" }
			@{ PropertyName = "..."; MessageText = "2" }
			@{ PropertyName = "asdasfaf3qgesdf"; MessageText = "2" }
			@{ PropertyName = "6163rqf3^!"; MessageText = "2" }
			
		) {
			
			# Pass test case data into the test body
			Param ([AllowEmptyString()]$PropertyName, $MessageText)
			
			# Copy over pre-populated database file from git to check for name clashse as well...
			Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
			
			# Run the command to test
			Set-PMPackage -PackageName "existing-package" -PropertyName $PropertyName -PropertyValue ""
			
			# Get the correct warning message that should be displayed in each test case
			switch ($MessageText) {
				
				"1" { $MessageText = "The property name cannot be empty" }
				"2" { $MessageText = "There is no property called: $PropertyName in package existing-package" }
				
			}
			
			# Check that the warning message was properly sent
			Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
				$DisplayWarning -eq $true -and
				$Message -eq $MessageText
			}
			
			# Delete the database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			
		}
		
	}
	
}