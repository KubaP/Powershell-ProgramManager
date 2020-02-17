Describe -Verbose "Validating New-PMPackage" {
    $VerbosePreference = "Continue"
    
    # Create a temporary data directory within the Pester temp drive
    # Modify the module datapath to reflect this temporary location
    New-Item -ItemType Directory -Path "TestDrive:\ProgramManager\"
    & (Get-Module ProgramManager) { $script:DataPath = "TestDrive:\ProgramManager" }
    # For use within the test script, since no access to module- $script:DataPath
    $dataPath = "TestDrive:\ProgramManager"
        
    Write-Verbose "TestDrive is: $((Get-PSDrive TestDrive).Root)"
    Write-Verbose "DataPath is: $($dataPath)"
        
    Context "Local Package Validation" {
        
        It "Given valid parameters: PackageLocation TestDrive:\RawPackages\<FileName>; InstallDir <InstallDir>; Note <Note>; PreInstallScriptblock <PreInstallScript>; PostInstallScriptblock <PostInstallScript>; It should correctly write the data" -TestCases @(
            
            # The different valid test cases for a local package (exe and msi)
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = ""; Note = ""; PreInstallScript = {}; PostInstallScript = {} }
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {} }
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = ""; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {} }
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = ""; Note = ""; PreInstallScript = ""; PostInstallScript = {} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = ""; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {} }
            
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = ""; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = ""; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = ""; Note = ""; PreInstallScript = ""; PostInstallScript = {} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = ""; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = ""; Note = ""; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = ""; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = ""; Note = ""; PreInstallScript = ""; PostInstallScript = {Write-Host "hello"} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = ""; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = ""; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = ""; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            @{ Extension = "exe"; FileName = "localpackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = ""; Note = ""; PreInstallScript = ""; PostInstallScript = {Write-Host "hello"} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = ""; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            @{ Extension = "msi"; FileName = "localpackage-1.0.msi"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            
        ) {
            
            # Pass test case data into the test body
            Param ($Extension, $FileName, [AllowEmptyString()]$InstallDir, [AllowEmptyString()]$Note, $PreInstallScript, $PostInstallScript)
            
            
            # Copy the test packages from the git repo to the temporary drive
            New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
            Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
            
            if ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {
                
                # Run the command
                New-PMPackage -Name "test-package" -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDir -Note $Note -PreInstallScriptblock $PreInstallScript -PostInstallScriptblock $PostInstallScript
             
            }elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {
                
                # Run the command
                New-PMPackage -Name "test-package" -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDir -Note $Note -PreInstallScriptblock $PreInstallScript
                
            }elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false) {
                
                # Run the command
                New-PMPackage -Name "test-package" -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDir -Note $Note -PostInstallScriptblock $PostInstallScript
            
            }else {
                
                # Run the command
                New-PMPackage -Name "test-package" -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDir -Note $Note
                
            }
                        
            # Check that the database has been created
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
            
            # Stop any message outputting to screen
            Mock Write-Message { }
            
            It "Given invalid parameter -Name <Name>; It should stop and warn" -TestCases @(
                
                # The different invalid test cases for a name
                @{ Name = "" }
                @{ Name = " " }
                @{ Name = "." }
                @{ Name = "*" }
                @{ Name = ".*" }
                @{ Name = "asg%346£^ehah$%^47434!*" }
                @{ Name = "..." }
                @{ Name = "***" }
                @{ Name = "existing-package" }
                @{ Name = "     " }
                
            ) {
                
                # Pass test case data into the test body
                Param ([AllowEmptyString()]$Name)
                
                
                # Copy over pre-populated database file from git to check for name clashse as well...
                Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
                # Copy the test packages from the git repo to the temporary drive
                New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
                Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
                
                # Run the command
                New-PMPackage -Name $Name -LocalPackage -PackageLocation "TestDrive:\RawPackages\localpackage-1.0.exe"
                
                # Check that the warning message was properly sent
                Assert-MockCalled Write-Message -Times 1 -ParameterFilter {
                    $DisplayWarning -eq $true
                }
                
                # Check that the executable hasn't been moved from the original directory
                Test-Path -Path "TestDrive:\RawPackages\localpackage-1.0.exe" | Should -Be $true
                
                
                # Delete the package store and database file for next test
                Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
                Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
                
            }
        
            It "Given invalid parameter -Path <Path>; It should stop and warn" -TestCases @(
            
                # The different invalid test cases for a local filepath
                @{ Path = "b" }
                @{ Path = "TestDrive:\non-existent-folder" }
                @{ Path = "TestDrive:\non-existent-folder\non-existent-file" }
                @{ Path = "TestDrive:\non-existent-folder\non-existent-file." }
                @{ Path = "TestDrive:\non-existent-folder\non-existent-file.*" }
                @{ Path = "TestDrive:\non-existent-folder\non-existent-file.file" }
                @{ Path = "TestDrive:\non-existent-folder\" }
                @{ Path = "TestDrive:\non-existent-folder\." }
                @{ Path = "TestDrive:\non-existent-folder\*" }
                @{ Path = " " }
                @{ Path = "~" }
                @{ Path = "." }
                @{ Path = ".." }
                @{ Path = "..." }
                @{ Path = "*" }
                @{ Path = "****" }
                @{ Path = "asd9udfh87d78yd7nydf7bfy79sd6fjik2l" }
                @{ Path = "^£$%*&^$" }                
                @{ Path = "TestDrive:\RawPackages\" }
                @{ Path = "TestDrive:\RawPackages\." }
                @{ Path = "TestDrive:\RawPackages\*" }
                @{ Path = "TestDrive:\RawPackages\localpackage-1.0" }
                @{ Path = "TestDrive:\RawPackages\localpackage-1.0." }
                @{ Path = "TestDrive:\RawPackages\localpackage-1.0.*" }
                @{ Path = "TestDrive:\RawPackages\localpackage-1.0.file" }
                @{ Path = "TestDrive:\RawPackages\localpackage-1.0.*." }
                @{ Path = "TestDrive:\RawPackages\localpackage-1.0.*\" }
                @{ Path = "TestDrive:\RawPackages\localpackage-1.0*" }
                @{ Path = "TestDrive:\RawPackages\localpackage*" }
                @{ Path = "TestDrive:\RawPackages\PortablePackage_1.3.zip" }
                @{ Path = "TestDrive:\RawPackages\PortablePackage_1.0" }
                @{ Path = "TestDrive:\RawPackages\PortablePackage_1.0\" }
                @{ Path = "TestDrive:\RawPackages\*package*" }
                @{ Path = "TestDrive:\RawPackages\*package*.*" }
                
            ) {
                
                # Pass test case data into the test body
                Param ([AllowEmptyString()]$Path)
                
                
                # Copy the test packages from the git repo to the temporary drive
                New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
                Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
                
                # Run the command
                New-PMPackage -Name "test-package" -LocalPackage -PackageLocation $Path
                
                # Check that the warning message was properly sent
                Assert-MockCalled Write-Message -Times 1 -ParameterFilter {
                    $DisplayWarning -eq $true
                }
                
                # Check that the database file hasn't been created (by some accident)
                Test-Path -Path "$dataPath\packageDatabase.xml" | Should -Be $false
                Test-Path -Path "$dataPath\packages\*" | Should -Be $false
                
                # Delete the packages for next test
                Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
                Remove-Item -Path "$dataPath\packages" -Recurse -Force
            }
            
            It "Given invalid parameter -PreInstallScriptBlock <PreInstallScript>; It should stop and warn" -TestCases @(
                
                # The dfferent invalid test cases for a preinstallscriptblock
                @{ PreInstallScript = {} }
                @{ PreInstallScript = {   } }
                @{ PreInstallScript = {*} }
                
            ) {
                
                # Pass the test case data into the test case body
                Param($PreInstallScript)
                
                # Copy the test packages from the git repo to the temporary drive
                New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
                Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
                                
                # Run the command
                New-PMPackage -Name "test-package" -LocalPackage -PackageLocation "TestDrive:\RawPackages\localpackage-1.0.exe" -PreInstallScriptblock $PreInstallScript
                                
                # Check that the warning message was properly sent
                Assert-MockCalled Write-Message -Times 1 -ParameterFilter {
                    $DisplayWarning -eq $true
                }
                
                # Check that the executable hasn't been moved from the original directory
                Test-Path -Path "TestDrive:\RawPackages\localpackage-1.0.exe" | Should -Be $true
                
                
                # Delete the package store and database file for next test
                Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force        
                
            }
            
            It "Given invalid parameter -PostInstallScriptBlock <PostInstallScript>; It should stop and warn" -TestCases @(
                
                # The dfferent invalid test cases for a PostInstallScriptblock
                @{ PostInstallScript = {} }
                @{ PostInstallScript = {   } }
                @{ PostInstallScript = {*} }
                
            ) {
                
                # Pass the test case data into the test case body
                Param($PostInstallScript)
                
                # Copy the test packages from the git repo to the temporary drive
                New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
                Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
                                
                # Run the command
                New-PMPackage -Name "test-package" -LocalPackage -PackageLocation "TestDrive:\RawPackages\localpackage-1.0.exe" -PostInstallScriptBlock $PostInstallScript
                                
                # Check that the warning message was properly sent
                Assert-MockCalled Write-Message -Times 1 -ParameterFilter {
                    $DisplayWarning -eq $true
                }
                
                # Check that the executable hasn't been moved from the original directory
                Test-Path -Path "TestDrive:\RawPackages\localpackage-1.0.exe" | Should -Be $true
                
                
                # Delete the package store and database file for next test
                Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force        
                
            }
            
            
        }
        
        
        # Delete the package store and database file for next set of tests
        Remove-Item -Path "$dataPath\packageDatabase.xml" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$dataPath\packages" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "TestDrive:\RawPackages" -Recurse -Force -ErrorAction SilentlyContinue
        
        
    }
        
    Context "Url Package Validation" {
        
        It "Given valid parameters: Name <Name>; PackageLocation <Url>; InstallDir <InstallDir>; Note <Note>; PreInstallScriptblock <PreInstallScript>; PostInstallScriptblock <PostInstallScript>; It should correctly write the data" -TestCases @(
        
            # The different valid test cases for a url package
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = ""; PreInstallScript = {}; PostInstallScript = {} }
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {} }
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {} }
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {} }
            
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = ""; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = ""; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            @{ Name = "url-package"; PackageLocation = "https:\\website"; InstallDirectory = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
        
        ) {
            
            #Pass test case data into the test body
            Param ($Name, $PackageLocation, [AllowEmptyString()]$InstallDir, [AllowEmptyString()]$Note, $PreInstallScript, $PostInstallScript)
            
            
            if ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {
                
                # Run the command
                New-PMPackage -Name $Name -UrlPackage -PackageLocation $PackageLocation -InstallDirectory $InstallDir -Note $Note -PreInstallScriptblock $PreInstallScript -PostInstallScriptblock $PostInstallScript
                
            }elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {
                
                # Run the command
                New-PMPackage -Name $Name -UrlPackage -PackageLocation $PackageLocation -InstallDirectory $InstallDir -Note $Note -PreInstallScriptblock $PreInstallScript
                
            }elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false) {
                
                # Run the command
                New-PMPackage -Name $Name -UrlPackage -PackageLocation $PackageLocation -InstallDirectory $InstallDir -Note $Note -PostInstallScriptblock $PostInstallScript
            
            }else {
                
                # Run the command
                New-PMPackage -Name $Name -UrlPackage -PackageLocation $PackageLocation -InstallDirectory $InstallDir -Note $Note
                
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
            
            
            # Delete the package database file for next test
            Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
            
        }
        
        InModuleScope -ModuleName ProgramManager {
            
            # Stop any message outputting to screen
            Mock Write-Message { }
            
            It "Given invalid parameter -Name <Name>; It should stop and warn" -TestCases @(
                
                # The different invalid test cases for a name
                @{ Name = "" }
                @{ Name = " " }
                @{ Name = "." }
                @{ Name = "*" }
                @{ Name = ".*" }
                @{ Name = "asg%346£^ehah$%^47434!*" }
                @{ Name = "..." }
                @{ Name = "***" }
                @{ Name = "existing-package" }
                @{ Name = "     " }
                
            ) {
                
                # Pass test case data into the test body
                Param ([AllowEmptyString()]$Name)
                
                
                # Copy over pre-populated database file from git to check for name clashse as well...
                Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
                
                # Run the command
                New-PMPackage -Name $Name -UrlPackage -PackageLocation "https://somewhere"
                
                # Check that the warning message was properly sent
                Assert-MockCalled Write-Message -Times 1 -ParameterFilter {
                    $DisplayWarning -eq $true
                }
                
                
                # Delete the package store and database file for next test
                Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
                
            }
            
            It "Given invalid parameter -PreInstallScriptBlock <PreInstallScript>; It should stop and warn" -TestCases @(
                
                # The dfferent invalid test cases for a preinstallscriptblock
                @{ PreInstallScript = {} }
                @{ PreInstallScript = {   } }
                @{ PreInstallScript = {*} }
                
            ) {
                
                # Pass the test case data into the test case body
                Param($PreInstallScript)
                               
                # Run the command
                New-PMPackage -Name "test-package" -UrlPackage -PackageLocation "https://somewhere" -PreInstallScriptBlock $PreInstallScript
                                
                # Check that the warning message was properly sent
                Assert-MockCalled Write-Message -Times 1 -ParameterFilter {
                    $DisplayWarning -eq $true
                }
                                
                
            }
            
            It "Given invalid parameter -PostInstallScriptBlock <PostInstallScript>; It should stop and warn" -TestCases @(
                
                # The dfferent invalid test cases for a PostInstallScriptblock
                @{ PostInstallScript = {} }
                @{ PostInstallScript = {   } }
                @{ PostInstallScript = {*} }
                
            ) {
                
                # Pass the test case data into the test case body
                Param($PostInstallScript)
                                
                # Run the command
                New-PMPackage -Name "test-package" -UrlPackage -PackageLocation "https://somwhere" -PostInstallScriptBlock $PostInstallScript
                                
                # Check that the warning message was properly sent
                Assert-MockCalled Write-Message -Times 1 -ParameterFilter {
                    $DisplayWarning -eq $true
                }
                
            }
            
            
        }
        
    }
    
    Context "Portable Package Validation" {
        
        It "Given valid parameters: PackageLocation TestDrive:\RawPackages\<FileName>; InstallDir <InstallDir>; Note <Note>; PreInstallScriptBlock <PreInstallScript>; PostInstallScriptBlock <PostInstallScript>; It should correctly write the data" -TestCases @(
            
            # The different valid test cases for a portable package (archive, folder, and exe)
            @{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {} }
            @{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {} }
            @{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {} }
            @{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {} }
            @{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {} }
            @{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {} }
            
            @{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            @{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            @{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            @{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            @{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            @{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {} }
            
            @{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            @{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            @{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            @{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            @{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            @{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello"} }
            
            @{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            @{ Type = "exe"; FileName = "portablepackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            @{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            @{ Type = "zip"; FileName = "PortablePackage_1.3.zip"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            @{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDir = "TestDrive:\"; Note = ""; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
            @{ Type = "folder"; FileName = "PortablePackage_1.0\"; InstallDir = "TestDrive:\"; Note = "A descriptive note"; PreInstallScript = {Write-Host "hello"}; PostInstallScript = {Write-Host "hello"} }
                   
        ) {
            
            # Pass test case data into the test body
            Param ($Type, $FileName, $InstallDir, [AllowEmptyString()]$Note, $PreInstallScript, $PostInstallScript)
            
            # Copy the test packages from the git repo to the temporary drive
            New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
            Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
            
            if ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {
                
                # Run the command
                New-PMPackage -Name "test-package" -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDir -Note $Note -PreInstallScriptblock $PreInstallScript -PostInstallScriptblock $PostInstallScript
                
            }elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {
                
                # Run the command
                New-PMPackage -Name "test-package" -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDir -Note $Note -PreInstallScriptblock $PreInstallScript
                
            }elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false) {
                
                # Run the command
                New-PMPackage -Name "test-package" -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDir -Note $Note -PostInstallScriptblock $PostInstallScript
            
            }else {
                
                # Run the command
                New-PMPackage -Name "test-package" -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory $InstallDir -Note $Note
                
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
            
            # Stop any message outputting to screen
            Mock Write-Message { }
            
            It "Given invalid parameter -Name <Name>; It should stop and warn" -TestCases @(
                
                # The different invalid test cases for a name
                @{ Name = "" }
                @{ Name = " " }
                @{ Name = "." }
                @{ Name = "*" }
                @{ Name = ".*" }
                @{ Name = "asg%346£^ehah$%^47434!*" }
                @{ Name = "..." }
                @{ Name = "***" }
                @{ Name = "existing-package" }
                @{ Name = "     " }
                
            ) {
                
                # Pass test case data into the test body
                Param ([AllowEmptyString()]$Name)
                
                
                # Copy over pre-populated database file from git to check for name clashse as well...
                Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
                # Copy the test packages from the git repo to the temporary drive
                New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
                Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
                
                # Run the command
                New-PMPackage -Name $Name -PortablePackage -PackageLocation "TestDrive:\RawPackages\portablepackage-1.0.exe" -InstallDirectory "TestDrive:\"
                
                # Check that the warning message was properly sent
                Assert-MockCalled Write-Message -Times 1 -ParameterFilter {
                    $DisplayWarning -eq $true
                }
                
                # Check that the executable hasn't been moved from the original directory
                Test-Path -Path "TestDrive:\RawPackages\portablepackage-1.0.exe" | Should -Be $true
                
                
                # Delete the package store and database file for next test
                Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
                Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
                
            }
            
            It "Given invalid parameter -Path <Path>; It should stop and warn" -TestCases @(
            
                # The different invalid test cases for a local filepath
                @{ Path = "TestDrive:\non-existent-file" }
                @{ Path = "TestDrive:\non-existent-file." }
                @{ Path = "TestDrive:\non-existent-file.*" }
                @{ Path = "TestDrive:\non-existent-file.file" }
                @{ Path = "TestDrive:\non-existent-file. " }
                @{ Path = "TestDrive:\non-existent-file.**" }
                @{ Path = "TestDrive:\non-existent-file.*\*" }
                @{ Path = "TestDrive:\portablepackage-1.0.exe." }
                @{ Path = "TestDrive:\portablepackage-1.0" }
                @{ Path = "TestDrive:\portablepackage*" }
                @{ Path = "TestDrive:\*package-1.0.exe" }
                @{ Path = "TestDrive:\PortablePackage_1.0\otherfile" }
                @{ Path = "TestDrive:\PortablePackage_1.0\*" }
                @{ Path = " " }
                @{ Path = "~" }
                @{ Path = "." }
                @{ Path = ".." }
                @{ Path = "..." }
                @{ Path = "*" }
                @{ Path = "****" }
                @{ Path = "asd9udfh87d78yd7nydf7bfy79sd6fjik2l" }
                @{ Path = "^£$%*&^$" }
                
            ) {
                
                # Pass test case data into the test body
                Param ([AllowEmptyString()]$Path)
                
                
                # Copy the test packages from the git repo to the temporary drive
                New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
                Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
                
                # Run the command
                New-PMPackage -Name "test-package" -PortablePackage -PackageLocation $Path -InstallDirectory "TestDrive:\"
                
                # Check that the warning message was properly sent
                Assert-MockCalled Write-Message -Times 1 -ParameterFilter {
                    $DisplayWarning -eq $true
                }
                
                # Check that the database file hasn't been created (by some accident)
                Test-Path -Path "$dataPath\packageDatabase.xml" | Should -Be $false
                
                # Delete the packages for next test
                Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
                Remove-Item -Path "$dataPath\packages" -Recurse -Force 
                
            }
            
            It "Given invalid parameter -PreInstallScriptBlock <PreInstallScript>; It should stop and warn" -TestCases @(
                
                # The dfferent invalid test cases for a preinstallscriptblock
                @{ PreInstallScript = {} }
                @{ PreInstallScript = {   } }
                @{ PreInstallScript = {*} }
                
            ) {
                
                # Pass the test case data into the test case body
                Param($PreInstallScript)
                
                # Copy the test packages from the git repo to the temporary drive
                New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
                Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
                                
                # Run the command
                New-PMPackage -Name "test-package" -PortablePackage -PackageLocation "TestDrive:\RawPackages\portablepackage-1.0.exe" -InstallDirectory "TestDrive:\" -PreInstallScriptblock $PreInstallScript
                                
                # Check that the warning message was properly sent
                Assert-MockCalled Write-Message -Times 1 -ParameterFilter {
                    $DisplayWarning -eq $true
                }
                
                # Check that the executable hasn't been moved from the original directory
                Test-Path -Path "TestDrive:\RawPackages\portablepackage-1.0.exe" | Should -Be $true
                
                
                # Delete the package store and database file for next test
                Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force        
                
            }
            
            It "Given invalid parameter -PostInstallScriptBlock <PostInstallScript>; It should stop and warn" -TestCases @(
                
                # The dfferent invalid test cases for a PostInstallScriptblock
                @{ PostInstallScript = {} }
                @{ PostInstallScript = {   } }
                @{ PostInstallScript = {*} }
                                
                
            ) {
                
                # Pass the test case data into the test case body
                Param($PostInstallScript)
                
                # Copy the test packages from the git repo to the temporary drive
                New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
                Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
                                
                # Run the command
                New-PMPackage -Name "test-package" -PortablePackage -PackageLocation "TestDrive:\RawPackages\portablepackage-1.0.exe" -InstallDirectory "TestDrive:\" -PostInstallScriptBlock $PostInstallScript
                                
                # Check that the warning message was properly sent
                Assert-MockCalled Write-Message -Times 1 -ParameterFilter {
                    $DisplayWarning -eq $true
                }
                
                # Check that the executable hasn't been moved from the original directory
                Test-Path -Path "TestDrive:\RawPackages\portablepackage-1.0.exe" | Should -Be $true
                
                
                # Delete the package store and database file for next test
                Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force        
                
            }
            
            
        }
        
    }
    
    
}