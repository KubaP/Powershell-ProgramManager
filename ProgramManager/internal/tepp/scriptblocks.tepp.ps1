$argCompleter_PackageNames = {
    param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    # Import all PMPackage objects from the database file
	$packageList = Import-PackageList	
	
	if ($packageList.Count -eq 0) {
		Write-Output ""
	}
	
    $packageList.Name | Where-Object { $_ -like "$wordToComplete*" }
    
}

$argCompleter_PackagePropertyName = {
    param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
	
	# Get the already typed in package name
	$packageName = $fakeBoundParameters.PackageName
	
	if ($null -ne $packageName) {
		
		# Import all PMPackage objects from the database file
		$packageList = Import-PackageList
		
		# Get the package object
		$package = $packageList | Where-Object { $_.Name -eq $packageName }
		
		if ($null -ne $package){
			
			# Get all properties and return ones which match the filter
			$properties = $package.psobject.properties.Name			
			$properties | Where-Object { $_ -like "$wordToComplete*" }
			
		}
		
	}
	
	
}