Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"  -OutFile "C:\Windows\Temp\WinGet.msixbundle" 
Add-AppPackage -path "C:\Windows\Temp\WinGet.msixbundle"
winget --version
pause