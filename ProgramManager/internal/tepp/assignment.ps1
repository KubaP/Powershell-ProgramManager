Register-ArgumentCompleter -CommandName Invoke-PMInstall -ParameterName PackageName -ScriptBlock $argCompleter_PackageNames
Register-ArgumentCompleter -CommandName Invoke-PMUninstall -ParameterName PackageName -ScriptBlock $argCompleter_PackageNames
Register-ArgumentCompleter -CommandName Get-PMPackage -ParameterName PackageName -ScriptBlock $argCompleter_PackageNames
Register-ArgumentCompleter -CommandName Set-PMPackage -ParameterName PackageName -ScriptBlock $argCompleter_PackageNames
Register-ArgumentCompleter -CommandName Remove-PMPackage -ParameterName PackageName -ScriptBlock $argCompleter_PackageNames

Register-ArgumentCompleter -CommandName Set-PMPackage -ParameterName PropertyName -ScriptBlock $argCompleter_PackagePropertyName
