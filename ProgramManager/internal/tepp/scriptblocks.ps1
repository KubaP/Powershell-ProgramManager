$argCompleter_PackageNames = {
    param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    # Create list of all PMProgram objects
	$packageList = [System.Collections.Generic.List[psobject]]@()
    
    # Check if the xml database already exists
    if ((Test-Path -Path "$dataPath\packageDatabase.xml") -eq $true) {
        
		# The xml database exists
		# Load all existing PMPrograms into a list
		$xmlData = Import-Data -Path "$dataPath\packageDatabase.xml" -Type "Clixml"
		
		# Iterate through all imported objects
		foreach ($obj in $xmlData) {
			# Only operate on PMProgram objects
			if ($obj.psobject.TypeNames[0] -eq "Deserialized.ProgramManager.Package") {
				# Create new PMProgram objects
				$existingPackage = New-Object -TypeName psobject 
				$existingPackage.PSObject.TypeNames.Insert(0, "ProgramManager.Package")
				
				# Copy the properties from the Deserialized object into the new one
				foreach ($property in $obj.psobject.Properties) {
					$existingPackage | Add-Member -Type NoteProperty -Name $property.Name -Value $property.Value
				}
				
                $packageList.Add($existingPackage)
                
			}
		}
		
	}else {
        
        return ""
                
    }
    
    $packageList | Where-Object { $_.Name -like "$wordToComplete*" }
    
}