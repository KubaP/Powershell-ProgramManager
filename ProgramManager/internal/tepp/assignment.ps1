Register-ArgumentCompleter -CommandName Invoke-PMInstall -ParameterName PackageName -ScriptBlock $argCompleter_PackageNames
Register-ArgumentCompleter -CommandName Get-PMPackage -ParameterName PackageName -ScriptBlock $argCompleter_PackageNames
Register-ArgumentCompleter -CommandName Remove-PMPackage -ParameterName PackageName -ScriptBlock $argCompleter_PackageNames