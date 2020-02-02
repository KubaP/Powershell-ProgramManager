function Import-PackageList {
    
    # Create list of all PMPackage objects
	$packageList = [System.Collections.Generic.List[psobject]]@()
    
    # Check if the xml database exists
	if ((Test-Path -Path "$script:DataPath\packageDatabase.xml") -eq $true) {
		
		# The xml database exists
		# Load all existing PMPrograms into a list
		$xmlData = Import-Clixml -Path "$script:DataPath\packageDatabase.xml"
		
		# Iterate through all imported objects
		foreach ($obj in $xmlData) {
			# Only operate on PMPackage objects
			if ($obj.psobject.TypeNames[0] -eq "Deserialized.ProgramManager.Package") {
				# Create new PMPackage objects
				$existingPackage = New-Object -TypeName psobject 
				$existingPackage.PSObject.TypeNames.Insert(0, "ProgramManager.Package")
				
				# Copy the properties from the Deserialized object into the new one
				foreach ($property in $obj.psobject.Properties) {
					$existingPackage | Add-Member -Type NoteProperty -Name $property.Name -Value $property.Value
				}
				
				$packageList.Add($existingPackage)
				
			}
		}        
        
    }
    
    return $packageList
    
}