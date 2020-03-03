# The modules which are required for testing
$modules = @("Pester", "PSScriptAnalyzer")

# Install each module
foreach ($module in $modules) {
    
    Write-Host "Installing $module" -ForegroundColor Cyan
    Install-Module $module -Force -SkipPublisherCheck
    Import-Module $module -Force -PassThru
    
}