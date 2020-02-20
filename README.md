# ProgramManager
ProgramManager is a powershell module which mimicks some of the features of standard package managers, but is designed for traditional windows installation files. This module allows you to easily add, keep track off, install, and uninstall programs with only a handful of simple-to-use commands. This module works on programs which are:
- .exe/.msi installers located locally
- .exe/.msi installers downloaded from a url
- portable programs, either as a standolone .exe's or as zip folders
- *~~chocolatey packages~~ [TODO]*

[![Build Status](https://dev.azure.com/KubaP999/ProgramManager/_apis/build/status/6?branchName=development)](https://dev.azure.com/KubaP999/ProgramManager/_build/latest?definitionId=6&branchName=development)

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
*[TODO]*

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
Feel free to make pull requests as long as the code is cleanly formatted. Only submit a single feature at a time. At the moment there are **no** proper contribution guidelines.

## License 
This project is licensed under the MIT license - see [LICENSE.md](./LICENSE) file for details.

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

## Acknowledgements
The module framework has been based of the [psframework](https://github.com/PowershellFrameworkCollective/psframework) module template.