function Invoke-Chocolatey {

  <#
  .SYNOPSIS
  Invokes Chocolatey 

  .DESCRIPTION
  Upon calling Invoke-Chocolatey 
  Copyright (c) 2011-Present Rob Reynolds
  Committers and Contributors: Rob Reynolds, Rich Siegel, Matt Wrock, Anthony Mastrean, Alan Stevens
  Crediting contributions by Chris Ortman, Nekresh, Staxmanade, Chrissie1, AnthonyMastrean, Rich Siegel, Matt Wrock and other contributors from the community.
  Big thanks to Keith Dahlby for all the powershell help! 
  Apache License, Version 2.0 - http://www.apache.org/licenses/LICENSE-2.0

  ## Set the culture to invariant

  .PARAMETER command
  command to send to chocolatey

  .PARAMETER packageName
  packagename

  .PARAMETER source
  url of feed

  .PARAMETER version
  The package version

  .Example
  Invoke-Pester

  This will find all *.tests.* files and run their tests. No exit code will be returned and no log file will be saved.

  .Example
  Chocolatey Install

  This will run chocolatey intall

  .Example
  Chocolatey Version

  This run list the version of the package you are interested in

  .LINK
  Describe
  about_chocolatey

  #>

  param(
    $MyInvocation,
    [string]$command,
    [string]$packageName='',
    [string]$source='',
    [string]$version='',
    [alias("all")][switch] $allVersions = $false,
    [alias("ia","installArgs")][string] $installArguments = '',
    [alias("o","override","overrideArguments","notSilent")]
    [switch] $overrideArgs = $false,
    [switch] $force = $false,
    [alias("pre")][switch] $prerelease = $false,
    [alias("lo")][switch] $localonly = $false,
    [alias("verbose")][switch] $verbosity = $false,
    [switch] $debug,
    [string] $name
  )

  $currentThread = [System.Threading.Thread]::CurrentThread;
  $culture = [System.Globalization.CultureInfo]::InvariantCulture;
  $currentThread.CurrentCulture = $culture;
  $currentThread.CurrentUICulture = $culture;

  #Let's get Chocolatey!
  $chocVer = '0.9.8.20-beta1'

  $MyInvocation.BoundParameters
  $nugetChocolateyPath = (Split-Path -parent $MyInvocation.MyCommand.Definition)
  $nugetPath = (Split-Path -Parent $nugetChocolateyPath)
  $nugetExePath = Join-Path $nuGetPath 'bin'
  $nugetLibPath = Join-Path $nuGetPath 'lib'
  $extensionsPath = Join-Path $nugetPath 'extensions'
  $chocInstallVariableName = "ChocolateyInstall"
  $nugetExe = Join-Path $nugetChocolateyPath 'nuget.exe'
  $h1 = '====================================================='
  $h2 = '-------------------------'
  $globalConfig = ''
  $userConfig = ''
  $env:ChocolateyEnvironmentDebug = 'false'
  $RunNote = "DarkCyan"
  $Warning = "Magenta"
  $Error = "Red"
  $Note = "Green"


  $DebugPreference = "SilentlyContinue"
  if ($debug) {
    $DebugPreference = "Continue";
    $env:ChocolateyEnvironmentDebug = 'true'
  }

  $installModule = Join-Path $nugetChocolateyPath (Join-Path 'helpers' 'chocolateyInstaller.psm1')
  Import-Module $installModule

  # grab functions from files
  Resolve-Path $nugetChocolateyPath\functions\*.ps1 | 
      ? { -not ($_.ProviderPath.Contains(".Tests.")) } |
      % { . $_.ProviderPath }


  # load extensions if they exist
  if(Test-Path($extensionsPath)) {
    Write-Debug 'Loading community extensions'
    #Resolve-Path $extensionsPath\**\*\*.psm1 | % { Write-Debug "Importing `'$_`'"; Import-Module $_.ProviderPath }
    Get-ChildItem $extensionsPath -recurse -filter "*.psm1" | Select -ExpandProperty FullName | % { Write-Debug "Importing `'$_`'"; Import-Module $_; }
  }

  #main entry point
  #Remove-LastInstallLog

  switch -wildcard ($command) 
  {
    "install" { Chocolatey-Install $packageName $source $version $installArguments; }
    "installmissing" { Chocolatey-InstallIfMissing $packageName $source $version; }
    "update" { Chocolatey-Update $packageName $source; }
    "uninstall" {Chocolatey-Uninstall $packageName $version $installArguments; }
    "search" { Chocolatey-List $packageName $source; }
    "list" { Chocolatey-List $packageName $source; }
    "version" { Chocolatey-Version $packageName $source; }
    "webpi" { Chocolatey-WebPI $packageName $installArguments; }
    "windowsfeatures" { Chocolatey-WindowsFeatures $packageName; }
    "cygwin" { Chocolatey-Cygwin $packageName $installArguments; }
    "python" { Chocolatey-Python $packageName $version $installArguments; }
    "gem" { Chocolatey-RubyGem $packageName $version $installArguments; }
    "pack" { Chocolatey-Pack $packageName; }
    "push" { Chocolatey-Push $packageName $source; }
    #"help" { Chocolatey-Help; }
    "help" {get-help invoke-chocolatey;break;}
    "sources" { Chocolatey-Sources $packageName $name $source; }
    default { Write-Host 'Please run chocolatey /? or chocolatey help'; }
  }
}

Invoke-Chocolatey $myinvocation @args
