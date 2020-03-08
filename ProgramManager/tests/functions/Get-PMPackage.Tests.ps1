Describe -Verbose "Validating Get-PMPackage" {
	$VerbosePreference = "Continue"
	
	# Create a temporary data directory within the Pester temp drive
	# Modify the module datapath to reflect this temporary location
	New-Item -ItemType Directory -Path "TestDrive:\ProgramManager\"
	& (Get-Module ProgramManager) { $script:DataPath = "TestDrive:\ProgramManager" }
	# For use within the test script, since no access to module- $script:DataPath
	$dataPath = "TestDrive:\ProgramManager"
	
	It "Given valid parameters: PackageName <PackageName>; It should correctly output object" -TestCases @(
		
		# The different valid test cases for a local package (exe and msi)
		@{ PackageName = "local-package1"; Type = "LocalPackage"; IsInstalled = "false"; Url = ""; ExecutableName = "localpackage-1.0.exe"; ExecutableType = ".exe"; InstallDirectory = ""; Note = ""; PreInstallScriptbloc = {}; PostInstallScriptbloc = {} }    
		@{ PackageName = "local-package2"; Type = "LocalPackage"; IsInstalled = "false"; Url = ""; ExecutableName = "localpackage-1.0.exe"; ExecutableType = ".exe"; InstallDirectory = "C:\"; Note = ""; PreInstallScriptbloc = {}; PostInstallScriptbloc = {} }    
		@{ PackageName = "local-package3"; Type = "LocalPackage"; IsInstalled = "false"; Url = ""; ExecutableName = "localpackage-1.0.exe"; ExecutableType = ".exe"; InstallDirectory = ""; Note = "description"; PreInstallScriptbloc = {}; PostInstallScriptbloc = {} }
		@{ PackageName = "local-package4"; Type = "LocalPackage"; IsInstalled = "false"; Url = ""; ExecutableName = "localpackage-1.0.exe"; ExecutableType = ".exe"; InstallDirectory = "C:\"; Note = "description"; PreInstallScriptbloc = {}; PostInstallScriptbloc = {} }    
		@{ PackageName = "local-package5"; Type = "LocalPackage"; IsInstalled = "true"; Url = ""; ExecutableName = "localpackage-1.0.exe"; ExecutableType = ".exe"; InstallDirectory = ""; Note = ""; PreInstallScriptbloc = {}; PostInstallScriptbloc = {} }   
		@{ PackageName = "url-package1"; Type = "UrlPackage"; IsInstalled = "false"; Url = "https://"; ExecutableName = ""; ExecutableType = ""; InstallDirectory = ""; Note = ""; PreInstallScriptbloc = {}; PostInstallScriptbloc = {} }
		@{ PackageName = "url-package2"; Type = "UrlPackage"; IsInstalled = "false"; Url = "https://"; ExecutableName = ""; ExecutableType = ""; InstallDirectory = "C:\"; Note = ""; PreInstallScriptbloc = {}; PostInstallScriptbloc = {} }
		@{ PackageName = "url-package3"; Type = "UrlPackage"; IsInstalled = "false"; Url = "https://"; ExecutableName = ""; ExecutableType = ""; InstallDirectory = ""; Note = "description"; PreInstallScriptbloc = {}; PostInstallScriptbloc = {} }
		@{ PackageName = "url-package4"; Type = "UrlPackage"; IsInstalled = "false"; Url = "https://"; ExecutableName = ""; ExecutableType = ""; InstallDirectory = "C:\"; Note = "description"; PreInstallScriptbloc = {}; PostInstallScriptbloc = {} }
		@{ PackageName = "url-package5"; Type = "UrlPackage"; IsInstalled = "true"; Url = "https://"; ExecutableName = ""; ExecutableType = ""; InstallDirectory = ""; Note = ""; PreInstallScriptbloc = {}; PostInstallScriptbloc = {} }
		@{ PackageName = "portable-package1"; Type = "PortablePackage"; IsInstalled = "false"; Url = ""; ExecutableName = ""; ExecutableType = ""; InstallDirectory = "C:\"; Note = ""; PreInstallScriptbloc = {}; PostInstallScriptbloc = {} }
		@{ PackageName = "portable-package2"; Type = "PortablePackage"; IsInstalled = "false"; Url = ""; ExecutableName = ""; ExecutableType = ""; InstallDirectory = "C:\"; Note = "description"; PreInstallScriptbloc = {}; PostInstallScriptbloc = {} }
		@{ PackageName = "portable-package3"; Type = "PortablePackage"; IsInstalled = "true"; Url = ""; ExecutableName = ""; ExecutableType = ""; InstallDirectory = "C:\"; Note = ""; PreInstallScriptbloc = {}; PostInstallScriptbloc = {} }
		
		@{ PackageName = "local-package6"; Type = "LocalPackage"; IsInstalled = "false"; Url = ""; ExecutableName = "localpackage-1.0.exe"; ExecutableType = ".exe"; InstallDirectory = ""; Note = ""; PreInstallScriptbloc = {Write-Host "hello"}; PostInstallScriptbloc = {} }
		@{ PackageName = "local-package7"; Type = "LocalPackage"; IsInstalled = "false"; Url = ""; ExecutableName = "localpackage-1.0.exe"; ExecutableType = ".exe"; InstallDirectory = ""; Note = ""; PreInstallScriptbloc = {}; PostInstallScriptbloc = {Write-Host "hello"} }
		@{ PackageName = "url-package6"; Type = "UrlPackage"; IsInstalled = "false"; Url = "https://"; ExecutableName = ""; ExecutableType = ""; InstallDirectory = ""; Note = ""; PreInstallScriptbloc = {Write-Host "hello"}; PostInstallScriptbloc = {} }
		@{ PackageName = "url-package7"; Type = "UrlPackage"; IsInstalled = "false"; Url = "https://"; ExecutableName = ""; ExecutableType = ""; InstallDirectory = ""; Note = ""; PreInstallScriptbloc = {}; PostInstallScriptbloc = {Write-Host "hello"} }
		@{ PackageName = "portable-package4"; Type = "PortablePackage"; IsInstalled = "false"; Url = ""; ExecutableName = ""; ExecutableType = ""; InstallDirectory = "C:\"; Note = ""; PreInstallScriptbloc = {Write-Host "hello"}; PostInstallScriptbloc = {} }
		@{ PackageName = "portable-package5"; Type = "PortablePackage"; IsInstalled = "false"; Url = ""; ExecutableName = ""; ExecutableType = ""; InstallDirectory = "C:\"; Note = ""; PreInstallScriptbloc = {}; PostInstallScriptbloc = {Write-Host "hello"} }
		
	) {
		
		# Pass test case data into the test body
		Param ($PackageName, $Type, $IsInstalled, [AllowEmptyString()]$Url, [AllowEmptyString()]$ExecutableName, [AllowEmptyString()]$ExecutableType, [AllowEmptyString()]$InstallDirectory, [AllowEmptyString()]$Note, $PreInstallScriptblock, $PostInstallScriptblock)
		
		# Copy over pre-populated database file from git to check for name clashes too
		Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
		
		# Run the command to test
		$package = Get-PMPackage -PackageName $PackageName
		
		# Check that the property values are correct
		$package.Name | Should -Be $PackageName
		$package.Type | Should -Be $Type
		$package.IsInstalled | Should -Be $IsInstalled
		
		if ($Type -eq "LocalPackage") {
			$package.ExecutableName | Should -Be $ExecutableName
			$package.ExecutableType | Should -Be $ExecutableType
		}elseif ($Type -eq "UrlPackage") {
			$package.Url | Should -Be $Url
		}
		
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
		
		# Delete the database file for next test
		Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
		
	}
	
	InModuleScope -ModuleName ProgramManager {
		
		# Mock the function to then assert if it was called, i.e. if a message would be printed to screen
		Mock Write-Message { }
		
		It "Given invalid parameter -PackageName <PackageName>" -TestCases @(
			
			# The different invalid test cases for package names which don't exist
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
			
			# Copy over pre-populated database file from git to check for name clashes too
			Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
			
			# Run the command to test
			Get-PMPackage -PackageName $PackageName
			
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
		
	}
	
}