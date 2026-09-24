param([string]$InstallDir = (Split-Path -Parent $MyInvocation.MyCommand.Path))
$ErrorActionPreference='Stop'
$repo='cybertech7921/CYBER-TECH'
$api="https://api.github.com/repos/$repo/releases/latest"
function Ui($t){ Add-Type -AssemblyName PresentationFramework -ErrorAction SilentlyContinue; [System.Windows.MessageBox]::Show($t,'CYBER TECH Updater',[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information) | Out-Null }
try {
  $local='1.1.0'; $cfg=Join-Path $InstallDir 'update-config.json'
  if(Test-Path $cfg){$c=Get-Content $cfg -Raw|ConvertFrom-Json; if($c.appVersion){$local=[string]$c.appVersion}}
  $rel=Invoke-RestMethod -Uri $api -Headers @{ 'User-Agent'='CYBER-TECH-Updater' }
  $remote=[string]$rel.tag_name; if($remote.StartsWith('v')){$remote=$remote.Substring(1)}
  try{$cmp=[version]$remote -gt [version]$local}catch{$cmp=$remote -ne $local}
  if(-not $cmp){Ui ("CYBER TECH is up to date."+[Environment]::NewLine+"Installed version: v$local"); exit 0}
  $asset=$rel.assets|Where-Object {$_.name -eq 'CYBER-TECH-update.zip'}|Select-Object -First 1
  if(-not $asset){ throw 'The latest GitHub release does not contain CYBER-TECH-update.zip.' }
  $tmp=Join-Path $env:TEMP ("CYBER-TECH-update-{0}.zip" -f ([guid]::NewGuid()))
  Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tmp -UseBasicParsing
  $extract=Join-Path $env:TEMP ("CYBER-TECH-extract-{0}" -f ([guid]::NewGuid()))
  Expand-Archive $tmp $extract -Force
  $src=Join-Path $extract 'CyberTech'; if(-not(Test-Path $src)){$src=$extract}
  Get-ChildItem $src -Force | ForEach-Object { Copy-Item $_.FullName $InstallDir -Recurse -Force }
  if(Test-Path $cfg){$o=Get-Content $cfg -Raw|ConvertFrom-Json}else{$o=[pscustomobject]@{}}
  $o.appVersion=$remote; $o.repository=$repo; $o.releaseAsset='CYBER-TECH-update.zip'
  $o|ConvertTo-Json|Set-Content $cfg -Encoding UTF8
  Remove-Item $tmp,$extract -Recurse -Force -ErrorAction SilentlyContinue
  Ui ("CYBER TECH updated successfully to v$remote."+[Environment]::NewLine+"Your application data was not replaced.")
  $launcher=Join-Path $InstallDir 'CyberTech.vbs'; if(Test-Path $launcher){Start-Process wscript.exe -ArgumentList ('"'+$launcher+'"')}
}catch{ Ui ("Update failed."+[Environment]::NewLine+[Environment]::NewLine+$_.Exception.Message); exit 1 }
