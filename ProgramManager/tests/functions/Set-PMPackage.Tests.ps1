Describe -Verbose "Validating Set-PMPackage" {
    $VerbosePreference = "Continue"
    
    # Create a temporary data directory within the Pester temp drive
    # Modify the module datapath to reflect this temporary location
    New-Item -ItemType Directory -Path "TestDrive:\ProgramManager\"
    & (Get-Module ProgramManager) { $script:DataPath = "TestDrive:\ProgramManager" }
    # For use within the test script, since no access to module- $script:DataPath
    $dataPath = "TestDrive:\ProgramManager"
        
    Write-Verbose "TestDrive is: $((Get-PSDrive TestDrive).Root)"
    Write-Verbose "DataPath is: $($dataPath)"
    
    It "Given valid parameters: PackageName <PackageName>; PropertyName <PropertyName>; PropertyValue <PropertyValue>; It should correctly edit the data" -TestCases @(
        
        # The different valid test cases for a local package (exe and msi)
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
        
        # Run the command
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
    
}