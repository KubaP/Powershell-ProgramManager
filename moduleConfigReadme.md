# Description

Insert a useful description for the ProgramManager project here.

Remember, it's the first thing a visitor will see.

# Project Setup Instructions
## Working with the layout

 - Don't touch the psm1 file
 - Place functions you export in `functions/` (can have subfolders)
 - Place private/internal functions invisible to the user in `internal/functions` (can have subfolders)
 - Don't add code directly to the `postimport.ps1` or `preimport.ps1`.
   Those files are designed to import other files only.
 - When adding files you load during `preimport.ps1`, be sure to add corresponding entries to `filesBefore.txt`.
   The text files are used as reference when compiling the module during the build script.
 - When adding files you load during `postimport.ps1`, be sure to add corresponding entries to `filesAfter.txt`.
   The text files are used as reference when compiling the module during the build script.

## Setting up CI/CD

> To create a PR validation pipeline, set up tasks like this:

 - Install Prerequisites (PowerShell Task; VSTS-Prerequisites.ps1)
 - Validate (PowerShell Task; VSTS-Validate.ps1)
 - Publish Test Results (Publish Test Results; NUnit format; Run no matter what)

> To create a build/publish pipeline, set up tasks like this:

 - Install Prerequisites (PowerShell Task; VSTS-Prerequisites.ps1)
 - Validate (PowerShell Task; VSTS-Validate.ps1)
 - Build (PowerShell Task; VSTS-Build.ps1)
 - Publish Test Results (Publish Test Results; NUnit format; Run no matter what)



# bin folder

The bin folder exists to store binary data. And scripts related to the type system.

This may include your own C#-based library, third party libraries you want to include (watch the license!), or a script declaring type accelerators (effectively aliases for .NET types)

For more information on Type Accelerators, see the help on Set-PSFTypeAlias




# XML

This is the folder where project XML files go, notably:

 - Format XML
 - Type Extension XML

External help files should _not_ be placed in this folder!

## Notes on Files and Naming

There should be only one format file and one type extension file per project, as importing them has a notable impact on import times.

 - The Format XML should be named `ProgramManager.Format.ps1xml`
 - The Type Extension XML should be named `ProgramManager.Types.ps1xml`

## Tools

### New-PSMDFormatTableDefinition

This function will take an input object and generate format xml for an auto-sized table.

It provides a simple way to get started with formats.

### Get-PSFTypeSerializationData

```
C# Warning!
This section is only interest if you're using C# together with PowerShell.
```

This function generates type extension XML that allows PowerShell to convert types written in C# to be written to file and restored from it without being 'Deserialized'. Also works for jobs or remoting, if both sides have the `PSFramework` module and type extension loaded.

In order for a class to be eligible for this, it needs to conform to the following rules:

 - Have the `[Serializable]` attribute
 - Be public
 - Have an empty constructor
 - Allow all public properties/fields to be set (even if setting it doesn't do anything) without throwing an exception.

```
non-public properties and fields will be lost in this process!
```




# Setting up the release pipeline for azure function:

## Preliminary

Setting up a release pipeline, set the trigger to do continuous integration against the master branch only.
In Stage 1 set up a tasksequence:

## 1) PowerShell Task: Prerequisites

Have it execute `vsts-prerequisites.ps1`

## 2) PowerShell Task: Validate

Have it execute `vsts-prerequisites.ps1`

## 3) PowerShell Task: Build

Have it execute `vsts-build.ps1`.
The task requires two parameters:

 - `-LocalRepo`
 - `-WorkingDirectory $(System.DefaultWorkingDirectory)/_�name�`

## 4) Publish Test Results

Configure task to pick up nunit type of tests (rather than the default junit).
Configure task to execute, even if previous steps failed or the task sequence was cancelled.

## 5) PowerShell Task: Package Function

Have it execute `vsts-packageFunction.ps1`

## 6) Azure Function AppDeploy

Configure to publish to the correct function app.