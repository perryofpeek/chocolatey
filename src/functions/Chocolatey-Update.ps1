﻿function Chocolatey-Update {
param(
  [string] $packageName ='', 
  [string] $source = ''
)
  if ($packageName -eq '') {$packageName = 'chocolatey';}
  Write-Debug "Running 'Chocolatey-Update' for $packageName with source:`'$source`'.";
  
  $packages = $packageName
  if ($packageName -eq 'all') {
    $packageFolders = Get-ChildItem $nugetLibPath | sort name
    $packages = $packageFolders -replace "(\.\d{1,})+"|gu 
  }

  foreach ($package in $packages) {
    $versions = Chocolatey-Version $package $source
    if ($versions -ne $null -and $versions.'foundCompare' -lt $versions.'latestCompare') {
        Chocolatey-NuGet $package $source
    } elseif ($versions -ne $null -and $force -and $versions.'foundCompare' -eq $versions.'latestCompare') {
        Invoke-ChocolateyFunction "Chocolatey-Nuget" @($package,$source)
    } else {
      Write-Debug "$packageName - you have either a newer version or the same version already available"
    }
  }
}