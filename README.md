# ProgramManager
ProgramManager is a powershell module which mimicks some of the features of standard package managers, but is designed for traditional windows installation files. This module allows you to easily add, keep track off, install, and uninstall programs with only a handful of simple-to-use commands. This module works on programs which are:
- .exe/.msi installers located locally
- .exe/.msi installers downloaded from a url
- portable programs, either as a standolone .exe's or as folders
- *~~chocolatey packages~~ [TODO]*

This module is primarily aimed at someone who wants to easily add new software to a package manager, but doesn't want to deal with the complexity of creating their own local package for chocolatey.

<br>

[![Azure DevOps builds](https://img.shields.io/azure-devops/build/KubaP999/3d9148d2-04d0-4835-b7cb-7bf89bdbf11b/7?label=latest%20build&logo=azure-pipelines)](https://dev.azure.com/KubaP999/ProgramManager/_build/latest?definitionId=7&branchName=development)
[![Azure DevOps coverage](https://img.shields.io/azure-devops/coverage/KubaP999/ProgramManager/7?logo=codecov&logoColor=white)](https://dev.azure.com/KubaP999/ProgramManager/_build/latest?definitionId=7&branchName=development)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/ProgramManager?logo=powershell&logoColor=white)](https://www.powershellgallery.com/packages/ProgramManager)
![PowerShell Gallery Platform](https://img.shields.io/powershellgallery/p/ProgramManager?logo=windows)
[![License](https://img.shields.io/badge/license-MIT-blue)](./LICENSE)

## Getting Started
### Installation
In order to get started with the latest build, simply download the module from the [PSGallery](https://www.powershellgallery.com/packages/ProgramManager), or install it from powershell by running:
```powershell
Install-Module ProgramManager
```
Installing this module does not mean that it is loaded automatically on start-up. Powershell supports loading modules on-the-fly since v3, however the first time you run a command it can be a bit slow to tabcomplete parameters or values. If you would like to load this module on shell start-up, add the following line to `~/Documents/Powershell/Profile.ps1` :
```powershell
Import-Module ProgramManager
```

### Requirements
This module requires `powershell 5.1` minimum. Works with `powershell core` as well.

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

When adding a new package to the database, the package files (if located locally) are moved to a storage location and kept there untill the package is removed. These files are stored at `<!path>`. It is **highly** recommended to not directly modify anything within this directory.

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

For details, see `about_ProgramManager_scriptblocks`.

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

Run the following commands in this order:
```powershell
& .\build\vsts-prerequisites.ps1
& .\build\vsts-valiate.ps1
& .\build\vsts-build.ps1 -WorkingDirectory .\ -SkipPublish
```
The built module will be located in the `.\publish` folder.

## Support
If there is a bug/issue please file it on the github issue tracker.

## Contributing
Feel free to make pull requests if you have an improvement. Only submit a single feature at a time, and make sure that the code is cleanly formatted, readable, and well commented.

## License 
This project is licensed under the MIT license - see [LICENSE.md](./LICENSE) file for details.


## Acknowledgements
The module framework has been based of the [psframework](https://github.com/PowershellFrameworkCollective/psframework) module template.