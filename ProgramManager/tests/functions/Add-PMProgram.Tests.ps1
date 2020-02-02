Describe "Validating Add-PMProgram" {
    
    # Create a temporary data directory within the Pester temp drive
    # Modify the module datapath to reflect this temporary location
    New-Item -ItemType Directory -Path "TestDrive:\ProgramManager\"
    & (Get-Module ProgramManager) { $script:DataPath = "TestDrive:\ProgramManager" }
    
    # Copy the test packages from the git repo to the temporary drive
    New-Item -ItemType Directory -Path "TestDrive:\RawPackages\"
    Copy-Item -Path "$script:ModuleRoot\tests\files\packages\*" -Destination "TestDrive:\RawPackages\*"
    
    
    Context "Local Package Validation" {
        
        It "Given valid parameters: Extension '<Extension>'; Path 'TestDrive:\RawPackages\<Name>'; InstallDir '<InstallDir>'; Note '<Note>', It should correctly write the data" -TestCases @(
            
            # The different valid test cases for a local package (exe and msi)
            @{ Extension = "exe"; Name = "localpackage-1.0.exe"; InstallDir = ""; Note = "" }
            @{ Extension = "exe"; Name = "localpackage-1.0.exe"; InstallDir = "TestDrive:\"; Note = "" }
            @{ Extension = "exe"; Name = "localpackage-1.0.exe"; InstallDir = ""; Note = "A descriptive note" }
            @{ Extension = "msi"; Name = "localpackage-1.0.msi"; InstallDir = ""; Note = "" }
            @{ Extension = "msi"; Name = "localpackage-1.0.msi"; InstallDir = "TestDrive:\"; Note = "" }
            @{ Extension = "msi"; Name = "localpackage-1.0.msi"; InstallDir = ""; Note = "A descriptive note" }
            
        ) {
            
            # Pass test case data into the test body
            Param ($Extension, $Name, $InstallDir, $Note)
            
            # Run the command
            Add-PMProgram -Name "test-package" -LocalPackage -PackageLocation $Path -InstallDirectory $InstallDir -Note $Note
            
            # Read the written data back into the psobject
            $packageList = Import-Package
            $package = $packageList[0]
            
            # Check the property values are correct
            $package.Name | Should -Be "test-package"
            $package.Type | Should -Be "LocalPackage"
            $package.IsInstalled | Should -Be $false
            $package.ExecutableName | Should -Be $Name
            $package.ExecutableType | Should -Be ".$Extension"
            
            if ([System.String]::IsNullOrWhiteSpace($InstallDir) -eq $true) {
                $package.InstallDirectory | Should -Be $null
            }else {
                $package.InstallDirectory | Should -Be $InstallDir
            }
            
            if ([System.String]::IsNullOrWhiteSpace($Note) -eq $true) {
                $package.Note | Should -Be $null
            }else {
                $package.Note | Should -Be $InstallDir
            }
            
            # Get the packages copied over into the store
            $packageFiles = Get-ChildItem -Path "$script:DataPath\packages" -Recurse            
            $packageFiles.Count | Should -Be 1
            
            # Check that the executable hasn't been left behind in its original directory
            (Test-Path -Path "TestDrive:\RawPackages\$Name") | Should -Be $false
            
            # Check that the executable has been correctly moved over
            (Test-Path -Path "$script:DataPath\packages\test-package\$($package.ExecutableName)") | Should -Be $true
            
            
            # Delete the package store and database file for next test
            Remove-Item -Path "$script:DataPath\packageDatabase.xml" -Force
            Remove-Item -Path "$script:DataPath\packages" -Recurse -Force
            
        }
        
        It "Given invalid parameter -Path" -TestCases @(
           
            @{ Path = "" }
        
        ) {
            
            # Pass test case data into the test body
            Param ($Path)
            
            
        }
        
        # Delete the package store and database file for next test
        Remove-Item -Path "$script:DataPath\packageDatabase.xml" -Force
        Remove-Item -Path "$script:DataPath\packages" -Recurse -Force
        
    }
    
    Context "Url Package Validation" {
        
    }
    
    Context "Chocolatey Package Validation" {
        
    }
    
}