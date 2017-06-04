$logonBgDir = "C:\Windows\System32\oobe\info\backgrounds"
$logonBgFile = "backgroundDefault.jpg"

#First run, need admin access to create folder and file for first time, set permissions
if (!(Test-Path "$logonBgDir")) {#TODO Or permissions are not good enough
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "Need Administrator access to set background the first time"
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        #-NoExit
        exit
    }

    Write-Host "Creating logon background folder"
    New-Item -ItemType directory -Path "$logonBgDir" > $null
    
    $Acl = Get-Acl "$logonBgDir"
    #TODO Limit access to just the current user
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.SetAccessRule($Ar)
    Set-Acl "$logonBgDir" $Acl
}

function Get-RegValue([String] $KeyPath, [String] $ValueName) {
    (Get-ItemProperty -LiteralPath $KeyPath -Name $ValueName).$ValueName
}

$bgFile = Get-RegValue 'HKCU:\Software\Microsoft\Internet Explorer\Desktop\General' 'WallpaperSource'

#group policy: Computer Configuration\Administrative Templates\System\Logon\Always use custom logon background must be enabled

#Get primary monitor resolution
Add-Type -AssemblyName System.Windows.Forms
$primaryMonitor = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize

#Find smaller dimension (usually height)
Write-Host "Desktop is $($primaryMonitor.Width)x$($primaryMonitor.Height)"
if ($primaryMonitor.Height -lt $primaryMonitor.Width) {
    $limitingDimension = $primaryMonitor.Height
} else {
    $limitingDimension = $primaryMonitor.Width
}

#Get current bg image resolution
$image = New-Object -ComObject Wia.ImageFile
$image.LoadFile(“$bgFile”)
Write-Host "Image: $bgFile is $($image.Width)x$($image.Height)"

$imageProcess = New-Object -ComObject Wia.ImageProcess
$scaleFilter = $imageProcess.FilterInfos.Item("Scale").FilterID
$imageProcess.Filters.Add($scaleFilter)
#Keep Aspect Ratio is enabled by default
$imageProcess.Filters.Item(1).Properties.Item("MaximumWidth").Value = 1920
$imageProcess.Filters.Item(1).Properties.Item("MaximumHeight").Value = 1080
$image = $imageProcess.Apply($image)

Write-Host "Resized file to: $($image.Width)x$($image.Height)"

if (Test-Path "$logonBgDir\$logonBgFile") {
    Write-Host "Removing old file"
    Remove-Item "$logonBgDir\$logonBgFile"
}

Write-Host "Saving resized file"
$image.SaveFile("$logonBgDir\$logonBgFile")

$imageSize = (Get-Item "$logonBgDir\$logonBgFile").length
Write-Host "Image size is: $imageSize" #262144
if ($imageSize -gt 262144) {
    Write-Error "Image size is too large for Windows to handle"
    #TODO Resize again
}
