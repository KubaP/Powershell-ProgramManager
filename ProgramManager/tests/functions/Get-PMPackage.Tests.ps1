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
		@{ PackageName = "local-package1"; Type = "LocalPackage"; IsInstalled = "false"; Url = ""; ExecutableName = "localpackage-1.0.exe"; ExecutableType = ".exe"; InstallDir = ""; Note = ""; PreInstallScript = {}; PostInstallScript = {} }    
		@{ PackageName = "local-package2"; Type = "LocalPackage"; IsInstalled = "false"; Url = ""; ExecutableName = "localpackage-1.0.exe"; ExecutableType = ".exe"; InstallDir = "C:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {} }    
		@{ PackageName = "local-package3"; Type = "LocalPackage"; IsInstalled = "false"; Url = ""; ExecutableName = "localpackage-1.0.exe"; ExecutableType = ".exe"; InstallDir = ""; Note = "description"; PreInstallScript = {}; PostInstallScript = {} }
		@{ PackageName = "local-package4"; Type = "LocalPackage"; IsInstalled = "false"; Url = ""; ExecutableName = "localpackage-1.0.exe"; ExecutableType = ".exe"; InstallDir = "C:\"; Note = "description"; PreInstallScript = {}; PostInstallScript = {} }    
		@{ PackageName = "local-package5"; Type = "LocalPackage"; IsInstalled = "true"; Url = ""; ExecutableName = "localpackage-1.0.exe"; ExecutableType = ".exe"; InstallDir = ""; Note = ""; PreInstallScript = {}; PostInstallScript = {} }   
		@{ PackageName = "url-package1"; Type = "UrlPackage"; IsInstalled = "false"; Url = "https://"; ExecutableName = ""; ExecutableType = ""; InstallDir = ""; Note = ""; PreInstallScript = {}; PostInstallScript = {} }
		@{ PackageName = "url-package2"; Type = "UrlPackage"; IsInstalled = "false"; Url = "https://"; ExecutableName = ""; ExecutableType = ""; InstallDir = "C:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {} }
		@{ PackageName = "url-package3"; Type = "UrlPackage"; IsInstalled = "false"; Url = "https://"; ExecutableName = ""; ExecutableType = ""; InstallDir = ""; Note = "description"; PreInstallScript = {}; PostInstallScript = {} }
		@{ PackageName = "url-package4"; Type = "UrlPackage"; IsInstalled = "false"; Url = "https://"; ExecutableName = ""; ExecutableType = ""; InstallDir = "C:\"; Note = "description"; PreInstallScript = {}; PostInstallScript = {} }
		@{ PackageName = "url-package5"; Type = "UrlPackage"; IsInstalled = "true"; Url = "https://"; ExecutableName = ""; ExecutableType = ""; InstallDir = ""; Note = ""; PreInstallScript = {}; PostInstallScript = {} }
		@{ PackageName = "portable-package1"; Type = "PortablePackage"; IsInstalled = "false"; Url = ""; ExecutableName = ""; ExecutableType = ""; InstallDir = "C:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {} }
		@{ PackageName = "portable-package2"; Type = "PortablePackage"; IsInstalled = "false"; Url = ""; ExecutableName = ""; ExecutableType = ""; InstallDir = "C:\"; Note = "description"; PreInstallScript = {}; PostInstallScript = {} }
		@{ PackageName = "portable-package3"; Type = "PortablePackage"; IsInstalled = "true"; Url = ""; ExecutableName = ""; ExecutableType = ""; InstallDir = "C:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {} }
		
		@{ PackageName = "local-package6"; Type = "LocalPackage"; IsInstalled = "false"; Url = ""; ExecutableName = "localpackage-1.0.exe"; ExecutableType = ".exe"; InstallDir = ""; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
		@{ PackageName = "local-package7"; Type = "LocalPackage"; IsInstalled = "false"; Url = ""; ExecutableName = "localpackage-1.0.exe"; ExecutableType = ".exe"; InstallDir = ""; Note = ""; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
		@{ PackageName = "url-package6"; Type = "UrlPackage"; IsInstalled = "false"; Url = "https://"; ExecutableName = ""; ExecutableType = ""; InstallDir = ""; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
		@{ PackageName = "url-package7"; Type = "UrlPackage"; IsInstalled = "false"; Url = "https://"; ExecutableName = ""; ExecutableType = ""; InstallDir = ""; Note = ""; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
		@{ PackageName = "portable-package4"; Type = "PortablePackage"; IsInstalled = "false"; Url = ""; ExecutableName = ""; ExecutableType = ""; InstallDir = "C:\"; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
		@{ PackageName = "portable-package5"; Type = "PortablePackage"; IsInstalled = "false"; Url = ""; ExecutableName = ""; ExecutableType = ""; InstallDir = "C:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
		
	) {
		
		# Pass test case data into the test body
		Param ($PackageName, $Type, $IsInstalled, [AllowEmptyString()]$Url, [AllowEmptyString()]$ExecutableName, [AllowEmptyString()]$ExecutableType, [AllowEmptyString()]$InstallDir, [AllowEmptyString()]$Note, $PreInstallScript, $PostInstallScript)
		
		# Copy over pre-populated database file from git to check for name clashse as well...
		Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
		
		# Run the command
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
		if ([System.String]::IsNullOrWhiteSpace($InstallDir) -eq $true) {
			$package.InstallDirectory | Should -Be $null
		}else {
			$package.InstallDirectory | Should -Be $InstallDir
		}
		
		if ([System.String]::IsNullOrWhiteSpace($Note) -eq $true) {
			$package.Note | Should -Be $null
		}else {
			$package.Note | Should -Be $Note
		}
		
		# Check that the scriptblocks have been properly added
		([Scriptblock]::Create($package.PreInstallScriptBlock) -like $PreInstallScript) | Should -Be $true
		([Scriptblock]::Create($package.PostInstallScriptBlock) -like $PostInstallScript) | Should -Be $true
		
		# Delete the database file for next test
		Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
		
	}
	
	InModuleScope -ModuleName ProgramManager {
		
		# Stop any message outputting to screen
		Mock Write-Message { }
		
		It "Given invalid parameter -PackageName <PackageName>" -TestCases @(
			
			# The different valid test cases for a local package (exe and msi)
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
			
			# Copy over pre-populated database file from git to check for name clashse as well...
			Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
			
			# Run the command
			Get-PMPackage -PackageName $PackageName
			
			# Check that the warning message was properly sent
			Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
				$DisplayWarning -eq $true
			}
			
			# Delete the database file for next test
			Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
			
		}
		
	}
	
}