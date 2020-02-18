# List of functions that should be ignored
$global:FunctionHelpTestExceptions = @(
    'New-PMPackage' # Fails validation on InstallDirectory parameter because it has varying Mandatory requirements based on different parameter sets. Awaiting fix
)

<#
  List of arrayed enumerations. These need to be treated differently. Add full name.
  Example:

  "Sqlcollaborative.Dbatools.Connection.ManagementConnectionType[]"
#>
$global:HelpTestEnumeratedArrays = @(
	
)

<#
  Some types on parameters just fail their validation no matter what.
  For those it becomes possible to skip them, by adding them to this hashtable.
  Add by following this convention: <command name> = @(<list of parameter names>)
  Example:

  "Get-DbaCmObject"       = @("DoNotUse")
#>
$global:HelpTestSkipParameterType = @{
  "New-PMPackage" = @("InstallDirectory")
}
