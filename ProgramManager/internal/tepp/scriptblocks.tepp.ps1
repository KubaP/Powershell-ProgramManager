$argCompleter_PackageNames = {
    param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
    # Import all PMPackage objects from the database file
	$packageList = Import-PackageList	
	
	if ($packageList.Count -eq 0) {
		Write-Output ""
	}
	
    $packageList.Name | Where-Object { $_ -like "$wordToComplete*" }
    
}