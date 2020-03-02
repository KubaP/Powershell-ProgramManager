# Run internal pester tests
$codeCov = & "$PSScriptRoot\..\ProgramManager\tests\pester.ps1"
<# TODO: get code coverage working
# Export pester code coverage to json, for upload
Export-CodeCovIoJson -CodeCoverage $codeCov.CodeCoverage -RepoRoot "$PSScriptRoot\..\" -Path "codecov.json"

# Download codecov bash upload script
Invoke-WebRequest -Uri "https://codecov.io/bash" -OutFile codecov.sh
#>