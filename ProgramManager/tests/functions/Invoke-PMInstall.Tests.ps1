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
            
            Mock Invoke-Command { }
            Mock Start-Process { }
            
            It "Given valid parameter -PackageName <PackageName>; It should correctly install package" -TestCases @(
                
                # The different valid test cases for a local package (exe and msi)                
                @{ PackageName = "local-exe-none"; Type = "exe"; FileName = "localpackage-1.0.exe"; PreInstallScript = {}; PostInstallScript = {} }
                @{ PackageName = "local-exe-pre"; Type = "exe"; FileName = "localpackage-1.0.exe"; PreInstallScript = {Write-Host "hello world"}; PostInstallScript = {} }
                @{ PackageName = "local-exe-post"; Type = "exe"; FileName = "localpackage-1.0.exe"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello world"} }
                @{ PackageName = "local-exe-both"; Type = "exe"; FileName = "localpackage-1.0.exe"; PreInstallScript = {Write-Host "hello world"}; PostInstallScript = {Write-Host "hello world"} }
                
                @{ PackageName = "local-msi-none"; Type = "msi"; FileName = "localpackage-1.0.msi"; PreInstallScript = {}; PostInstallScript = {} }
                @{ PackageName = "local-msi-pre"; Type = "msi"; FileName = "localpackage-1.0.msi"; PreInstallScript = {Write-Host "hello world"}; PostInstallScript = {} }
                @{ PackageName = "local-msi-post"; Type = "msi"; FileName = "localpackage-1.0.msi"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello world"} }
                @{ PackageName = "local-msi-both"; Type = "msi"; FileName = "localpackage-1.0.msi"; PreInstallScript = {Write-Host "hello world"}; PostInstallScript = {Write-Host "hello world"} }
                
            ) {
                
                # Pass test case data into the test body
                Param ($PackageName, $Type, $FileName, $PreInstallScript, $PostInstallScript)
                
                
                # Copy the test packages from the git repo to the temporary drive
                New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
                Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
                
                # Create the package first
                if ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {                    
                    New-PMPackage -Name $PackageName -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -PreInstallScriptblock $PreInstallScript -PostInstallScriptblock $PostInstallScript
                
                }elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {                
                    New-PMPackage -Name $PackageName -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -PreInstallScriptblock $PreInstallScript
                    
                }elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false) {                
                    New-PMPackage -Name $PackageName -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName" -PostInstallScriptblock $PostInstallScript
                
                }else {                
                    New-PMPackage -Name $PackageName -LocalPackage -PackageLocation "TestDrive:\RawPackages\$FileName"
                    
                }
                                
                # Run the command
                Invoke-PMInstall -PackageName $PackageName
                
                # Get the package object
                $package = Get-PMPackage -PackageName $PackageName
                
                # Check that the scriptblocks have been called correctly
                if ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {                    
                    Assert-MockCalled Invoke-Command -Times 2 -Exactly -Scope It
                    
                }elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {                
                    Assert-MockCalled Invoke-Command -Times 1 -Exactly -Scope It
                    
                }elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false) {                
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
                Param ($PackageName, $Url, $PreInstallScript, $PostInstallScript)
                
                # Create the package first
                if ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {                    
                    New-PMPackage -Name $PackageName -UrlPackage -PackageLocation $Url -PreInstallScriptblock $PreInstallScript -PostInstallScriptblock $PostInstallScript
                
                }elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {                
                    New-PMPackage -Name $PackageName -UrlPackage -PackageLocation $Url -PreInstallScriptblock $PreInstallScript
                    
                }elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false) {                
                    New-PMPackage -Name $PackageName -UrlPackage -PackageLocation $Url -PostInstallScriptblock $PostInstallScript
                
                }else {                
                    New-PMPackage -Name $PackageName -UrlPackage -PackageLocation $Url
                    
                }
                                
                # Run the command
                Invoke-PMInstall -PackageName $PackageName
                
                # Get the package object
                $package = Get-PMPackage -PackageName $PackageName
                
                # Check that the scriptblocks have been called correctly
                if ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {                    
                    Assert-MockCalled Invoke-Command -Times 2 -Exactly -Scope It
                    
                }elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {                
                    Assert-MockCalled Invoke-Command -Times 1 -Exactly -Scope It
                    
                }elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false) {                
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
            
            Mock Invoke-Command { }
            # Stop any message outputting to screen
            Mock Write-Message { }
            
            It "Given valid parameter -PackageName <PackageName>; It should correctly install package" -TestCases @(
                
                # The different valid test cases for a portable package (exe, folder, and zip)
                @{ PackageName = "portable-exe-none"; FileName = "portablepackage-1.0.exe"; InstallDir = "\dir\"; PreInstallScript = {}; PostInstallScript = {}}
                @{ PackageName = "portable-exe-pre"; FileName = "portablepackage-1.0.exe"; InstallDir = "\dir\"; PreInstallScript = {Write-Host "hello world"}; PostInstallScript = {}}
                @{ PackageName = "portable-exe-post"; FileName = "portablepackage-1.0.exe"; InstallDir = "\dir\"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello world"}}
                @{ PackageName = "portable-exe-both"; FileName = "portablepackage-1.0.exe"; InstallDir = "\dir\"; PreInstallScript = {Write-Host "hello world"}; PostInstallScript = {Write-Host "hello world"}}
                
                @{ PackageName = "portable-zip-none"; FileName = "PortablePackage_1.3.zip"; InstallDir = "\dir\"; PreInstallScript = {}; PostInstallScript = {}}
                @{ PackageName = "portable-zip-pre"; FileName = "PortablePackage_1.3.zip"; InstallDir = "\dir\"; PreInstallScript = {Write-Host "hello world"}; PostInstallScript = {}}
                @{ PackageName = "portable-zip-post"; FileName = "PortablePackage_1.3.zip"; InstallDir = "\dir\"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello world"}}
                @{ PackageName = "portable-zip-both"; FileName = "PortablePackage_1.3.zip"; InstallDir = "\dir\"; PreInstallScript = {Write-Host "hello world"}; PostInstallScript = {Write-Host "hello world"}}
                
                @{ PackageName = "portable-folder-none"; FileName = "PortablePackage_1.0"; InstallDir = "\dir\"; PreInstallScript = {}; PostInstallScript = {}}
                @{ PackageName = "portable-folder-pre"; FileName = "PortablePackage_1.0"; InstallDir = "\dir\"; PreInstallScript = {Write-Host "hello world"}; PostInstallScript = {}}
                @{ PackageName = "portable-folder-post"; FileName = "PortablePackage_1.0"; InstallDir = "\dir\"; PreInstallScript = {}; PostInstallScript = {Write-Host "hello world"}}
                @{ PackageName = "portable-folder-both"; FileName = "PortablePackage_1.0"; InstallDir = "\dir\"; PreInstallScript = {Write-Host "hello world"}; PostInstallScript = {Write-Host "hello world"}}
                
                
            ) {
                
                # Pass test case data into the test body
                Param ($PackageName, $Type, $FileName, $InstallDir, $PreInstallScript, $PostInstallScript)
                
                # Copy the test packages from the git repo to the temporary drive
                New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
                New-Item -ItemType Directory -Path "TestDrive:\$InstallDir"
                Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
                
                # Create the package first
                if ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {                    
                    New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\$InstallDir" -PreInstallScriptblock $PreInstallScript -PostInstallScriptblock $PostInstallScript
                
                }elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {                
                    New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\$InstallDir" -PreInstallScriptblock $PreInstallScript
                    
                }elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false) {                
                    New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\$InstallDir" -PostInstallScriptblock $PostInstallScript
                
                }else {                
                    New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\$InstallDir"
                    
                }
                                
                # Run the command
                Invoke-PMInstall -PackageName $PackageName
                
                # Get the package object
                $package = Get-PMPackage -PackageName $PackageName
                
                # Check that the scriptblocks have been called correctly
                if ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false -and [System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {                    
                    Assert-MockCalled Invoke-Command -Times 2 -Exactly -Scope It
                    
                }elseif ([System.String]::IsNullOrWhiteSpace($PreInstallScript.ToString()) -eq $false) {                
                    Assert-MockCalled Invoke-Command -Times 1 -Exactly -Scope It
                    
                }elseif ([System.String]::IsNullOrWhiteSpace($PostInstallScript.ToString()) -eq $false) {                
                    Assert-MockCalled Invoke-Command -Times 1 -Exactly -Scope It
                
                }else {
                    Assert-MockCalled Invoke-Command -Times 0 -Exactly -Scope It
                    
                }
                
                # Check that the package has been copied correctly
                Test-Path -Path "TestDrive:\$InstallDir\$($package.Name)\" | Should -Be $true
                
                # Check that the package install status was updated
                $package.IsInstalled | Should -Be $true
                
                
                # Delete the package store and database file for next test
                Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
                Remove-Item -Path "$dataPath\packages\" -Recurse -Force
                Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
                Remove-Item -Path "TestDrive:\$InstallDir\" -Recurse -Force
                                
            }
            
            It "Given valid parameter -PackageName <PackageName>; with invalid InstallDirectory; It should stop and warn" -TestCases @(
                
                # The different invalid test cases for a portable package install directory
                @{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDir = ".*" }
                @{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDir = "*" }
                @{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDir = "**" }
                @{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDir = "..." }
                @{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDir = "£%afasdfasdf£" }
                @{ PackageName = "portable-exe"; FileName = "portablepackage-1.0.exe"; InstallDir = "\non-existent-folder\" }
                
            ) {
                
                # Pass test case data into the test body
                Param ($PackageName, $FileName, $InstallDir)
                
                # Copy the test packages from the git repo to the temporary drive
                New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
                Copy-Item -Path "$PSScriptRoot\..\files\packages\*" -Destination "TestDrive:\RawPackages\"
                
                # Create the package first
                New-PMPackage -Name $PackageName -PortablePackage -PackageLocation "TestDrive:\RawPackages\$FileName" -InstallDirectory "TestDrive:\$InstallDir"
                
                # Run the command
                Invoke-PMInstall -PackageName $PackageName
                
                # Check that the warning message was properly sent
                Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
                    $DisplayWarning -eq $true
                }
                
                # Delete the package store and database file for next test
                Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
                Remove-Item -Path "$dataPath\packages\" -Recurse -Force
                Remove-Item -Path "TestDrive:\RawPackages\" -Recurse -Force
                                
            }
            
        }
        
    }    
    
    InModuleScope -ModuleName ProgramManager {
            
        # Stop any message outputting to screen
        Mock Write-Message { }
        
        It "Given invalid parameter -PackageName <PackageName>" -TestCases @(
        
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
            
            # Copy over pre-populated database file from git to check for name clashse as well...
            Copy-Item -Path "$PSScriptRoot\..\files\data\existingPackage-packageDatabase.xml" -Destination "$dataPath\packageDatabase.xml"
            
            # Run the command
            Invoke-PMInstall -PackageName $PackageName
            
            # Check that the warning message was properly sent
            Assert-MockCalled Write-Message -Times 1 -Exactly -Scope It -ParameterFilter {
                $DisplayWarning -eq $true
            }
            
            # Delete the database file for next test
            Remove-Item -Path "$dataPath\packageDatabase.xml" -Force
            
        }
        
    }  
    
}