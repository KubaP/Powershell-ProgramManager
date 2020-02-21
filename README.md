# ProgramManager
ProgramManager is a powershell module which mimicks some of the features of standard package managers, but is designed for traditional windows installation files. This module allows you to easily add, keep track off, install, and uninstall programs with only a handful of simple-to-use commands. This module works on programs which are:
- .exe/.msi installers located locally
- .exe/.msi installers downloaded from a url
- portable programs, either as a standolone .exe's or as zip folders
- *~~chocolatey packages~~ [TODO]*

<br>

|Latest Build Status|Latest Commit|
|-|-|
|[![Build Status](https://dev.azure.com/KubaP999/ProgramManager/_apis/build/status/ProgramManager_development_CI?branchName=development)](https://dev.azure.com/KubaP999/ProgramManager/_build/latest?definitionId=7&branchName=development)|[![Build Status](https://dev.azure.com/KubaP999/ProgramManager/_apis/build/status/6?branchName=feature-documentation)](https://dev.azure.com/KubaP999/ProgramManager/_build/latest?definitionId=6&branchName=feature-documentation)|


## Getting Started
### Installation
In order to get started with the latest build, simply download the module from the [PSGallery](), or install it from powershell by running:
```powershell
Install-Module ProgramManager
```
Installing this module does not mean that it is loaded automatically on start-up. Powershell supports loading modules on-the-fly since v3, however the first time you run a command it can be a bit slow to tabcomplete parameters or values. If you would like to load this module on shell start-up, add the following line to `~/Documents/Powershell/Profile.ps1` :
```powershell
Import-Module ProgramManager
```

### Requirements
This module requires `powershell core v6.2.1` minimum. Although there is nothing to stop this module from working on `v5.1`, it has not been tested so proceed at own risk.

This module only works on **Windows**, since it's designed around windows-based executables/programs.

## Usage
### Add new packages
Firstly, add new packages to the database. 

If you are adding an **installer** which is located **locally**, run this:
```powershell
New-PMPackage -Name "<name to display>" -LocalPackage -PackageLocation "<path to installer>"
```
If you are adding an **installer** which is downloaded from a **url**, run this:
```powershell
New-PMPackage -Name "<name to display>" -UrlPackage -PackageLocation "<download url>"
```
When specifying the url, you can give a download button url. The program will follow any redirects until it finds the actual file.

If you are adding a **portable** program, run this:
```powershell
New-PMPackage -Name "<name to display>" -PortablePackage -PackageLocation "<path to program>" -InstallDirectory "<target directory>"
```
When adding a portable program, `-PackageLocation` can point to either a:
- standalone .exe file
- folder containing the program files
- zip folder containing the program files

<br>

When adding a new package to the database, the package files (if located locally) are moved to a storage location and kept there untill the package is removed. These files are stored at `<path>`. It is **highly** recommended to not directly modify anything within this directory.

### Installing a package
To install a package, run this command:
```powershell
Invoke-PMInstall -PackageName "<name>"
```
You can specify an array for `-PackageName` and the command will install all consecutively.

If the package is an installer type (local or url), the installation wizard will open.
If the package is a portable type, the program files will be copied to the configured installation directory.

### Removing a package
To remove a package, simply run this command:
```powershell
Remove-PMPackage -PackageName "<name>"
```
This command will remove the entry from the database and delete any package files (if locally stored). To retain the original installer/program files, run the command with the `-RetainFiles` flag:
```powershell
Remove-PMPackage -PackageName "<name>" -RetainFiles -Path "<path to move the files to>"
```

### Retrieving details of a package
To get the details of a package, run this command:
```powershell
Get-PMPackage -PackageName "<name>"
```
This will list all the properties of the package.

### Changing details of a package
To set a property of a package, run this command:
```powershell
Set-PMPackage -PackageName "<name>" -PropertyName "<property name>" -PropertyValue "<new value>"
```
This will replace the package property value with the newly specified value.


### Extra features
#### Tab completion
The functions support advanced tab-completion for values:
- Any `-PackageName` parameters support tab-completion.
- The `-PropertyName` parameter supports tab-completion once a `-PackageName` is given in.

#### Custom scriptblock support
When adding a new package, you can pass in a scriptblock for `-PreInstallScriptblock` or `-PostInstallScriptblock`. These scriptblocks will execute during package installation.

#### -WhatIf and -Confirm support
All functions in this module support these parameters when appropiate.

Use `-WhatIf` to see what changes a function will do.
Use `-Confirm` to require a prompt for every major change.

## Build Instructions
### Prerequesites
Install the following:
- Powershell Core 6.2.1
- Pester 4.9.0
- PSScriptAnalyzer 1.18.3

### Clone the git repo
```
git clone https://github.com/KubaP/Powershell-ProgramManager.git
```

### Run the build scripts
*[TODO]*

*Run the following commands in this order:*
```powershell
& .\build\vsts-prerequisites.ps1
& .\build\vsts-valiate.ps1
& .\build\vsts-build.ps1
```

### Run tests manually
Navigate to the root of the git repo. Then run the following to initiate all tests:
```powershell
Invoke-Pester .\ProgramManager\tests\pester.ps1
```
General file integrity tests are located in `\ProgramManager\tests\general\`

Function specific tests are located in `\ProgramManager\tests\functions\`

## Support
If there is a bug/issue please file it on the github repo issue tracker.

## Contributing
Feel free to make pull requests if you have an improvement. Only submit a single feature at a time, and make sure that the code is cleanly formatted, readable, and well commented.

## License 
This project is licensed under the MIT license - see [LICENSE.md](./LICENSE) file for details.

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

## Acknowledgements
The module framework has been based of the [psframework](https://github.com/PowershellFrameworkCollective/psframework) module template.