# Changelog
## 0.1.2 (2020-03-09)
 - New: Scriptblocks are now passed the ProgramManager.Package object, which allows for more advanced functionality.
 - New: about_ProgramManager_scriptblocks help page.
 - Upd: Documentation now shows accurate scriptblock information.
 - New: Command Invoke-PMUninstall: Supports uninstalling local/url/portable packages, and execution of a on-uninstall scriptblock. 
## 0.1.1 (2020-03-05)
 - Fix: Moved the module storage folder to %appdata%.
## 0.1.0 (2020-02-26)
 - New: Command New-PMPackage: Supports local/url/portable packages and all planned optional parameters.
 - New: Command Get-PMPackage: Passes object down pipeline and has proper formatting types support.
 - New: Command Set-PMPackage: Supports changing existing properties only.
 - New: Command Remove-PMPackage: Removes any package.
 - New: Command Invoke-PMInstall: Supports installing local/url/portable packages and executing scriptblock.
 - New: about_ProgramManager help page.
 - New: ProgramManager.Package object support.