﻿@{
	# Script module or binary module file associated with this manifest
	RootModule = 'ProgramManager.psm1'
	
	# Version number of this module.
	ModuleVersion = '0.1.2'
	
	# ID used to uniquely identify this module
	GUID = '7572858c-6870-4911-bd85-5b4aef2427b6'
	
	# Author of this module
	Author = 'KubaP'
	
	# Company or vendor of this module
	CompanyName = ' '
	
	# Copyright statement for this module
	Copyright = 'Copyright (c) 2020 KubaP'
	
	# Description of the functionality provided by this module
	Description = 'A simple program manager which emulates some of the functionality of a package manager, but with a focus on ease-of-use and quick customizability.'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.0'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	<#!
	RequiredModules = @(
		@{ ModuleName='PSFramework'; ModuleVersion='1.1.59' }
	)#>
	
	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\ProgramManager.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\ProgramManager.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @('xml\ProgramManager.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport = @(
		'New-PMPackage',
		'Get-PMPackage',
		'Set-PMPackage',
		'Remove-PMPackage',
		'Invoke-PMInstall',
		'Invoke-PMUninstall'
	)
	
	# Cmdlets to export from this module
	CmdletsToExport = ''
	
	# Variables to export from this module
	VariablesToExport = ''
	
	# Aliases to export from this module
	AliasesToExport = ''
	
	# List of all modules packaged with this module
	ModuleList = @()
	
	# List of all files packaged with this module
	FileList = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @("Windows","Automation","PackageManagement","PSEdition_Core","PSEdition_Desktop")
			
			# A URL to the license for this module.
			LicenseUri = 'https://mit-license.org/'
			
			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/KubaP/Powershell-ProgramManager'
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			ReleaseNotes = 'https://github.com/KubaP/Powershell-ProgramManager/blob/master/ProgramManager/changelog.md'
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}