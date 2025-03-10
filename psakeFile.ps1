properties {
    if (Get-Alias Get-Metadata -ErrorAction SilentlyContinue) {
        Set-Alias -Name Get-Metadata -Value BuildHelpers\Get-Metadata -Scope Global
    }

    & dotnet tool restore
    $PSBPreference.General.ModuleVersion = (dotnet nbgv get-version -f json | ConvertFrom-Json).SimpleVersion
    $PSBPreference.Build.CompileModule = $true
    $PSBPreference.Help.DefaultLocale = 'en-US'
    $PSBPreference.Test.OutputFile = 'out/testResults.xml'
    $PSBPreference.Docs.RootDir = './docs/commands'

    $psake.context.tasks.stagefiles.PostAction = {
        $outputManifestPath = [io.path]::Combine($PSBPreference.Build.ModuleOutDir, "$($PSBPreference.General.ModuleName).psd1")
        Write-Verbose "Updating ModuleVersion in output manifest '$outputManifestPath' to NBGV-based version $($PSBPreference.General.ModuleVersion)"
        Update-Metadata -Path $outputManifestPath -Value $PSBPreference.General.ModuleVersion
        Write-Verbose "Converting root module to UTF8 since PowerShellBuild generates a Unicode file on Windows PowerShell"
        Import-Module (Join-Path $env:BHProjectPath 'tests/MetaFixers.psm1')
        $rootModulePath = Join-Path -Path $env:BHBuildOutput -ChildPath "$($env:BHProjectName).psm1"
        Get-Item $rootModulePath | ConvertTo-UTF8
    }
}

task Default -depends Test

task Test -FromModule PowerShellBuild -minimumVersion '0.6.2'
