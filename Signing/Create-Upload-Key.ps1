$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (Test-Path 'active-code-upload.jks') { throw 'Keystore already exists. Keep it; never replace your existing signing key.' }
$tool = Get-Command keytool -ErrorAction SilentlyContinue
if (-not $tool) { throw 'Install JDK 21 and reopen PowerShell so keytool is on PATH.' }
& keytool -genkeypair -v -storetype PKCS12 -keystore active-code-upload.jks -alias active-code-upload -keyalg RSA -keysize 3072 -validity 10000
if ($LASTEXITCODE -ne 0) { throw 'Key generation did not finish. Do not run release until a complete keystore exists.' }
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'active-code-keystore-base64.txt'), [Convert]::ToBase64String([IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'active-code-upload.jks'))))
Write-Host 'Created PRIVATE keystore and base64 file. Keep both out of the repository and release ZIP.'
Write-Host 'Alias: active-code-upload. PKCS12 key password is the same as the store password.'
