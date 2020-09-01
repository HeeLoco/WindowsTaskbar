#date 22.06.2020
#author HeeLoco


#I wrote the environment variables into my own variables to be flexible if they differ from the default configuration. e.g changing OneDrive (private) Path.
#I also sometimes add parameters afterwards. 

#check for admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if(!($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))){
    Write-Error "Please run as Administrator!"
    Start-Sleep -Seconds 5
    return 666;
}
#get and set some vars 
$myUserName = $env:USERNAME; #maybe someday needful to fix the issue with "run as"

$myOneDriveDestinationPath = "C:\Users\" + $myUserName + "\OneDrive\some Configs and Profiles\WindowsTaskbar";

#interactive!!!
#I need this part to choose the desired export 
#in my case I use about 3 machines with different Taskbar settings
Write-Host "some entries found!";
#show existing folders
(Get-ChildItem -Path ($myOneDriveDestinationPath + "\TaskbarIcons") -Exclude "*.*").Name
#read host for correct folder
$myComputerName = Read-Host -Prompt ("What is the desired PC name/folder");

#taskbar icons
$myTaskbarIcons = "C:\Users\" + $myUserName + "\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar";
$myTaskbarDestinationPath = $myOneDriveDestinationPath + "\TaskbarIcons\" + $myComputerName;

#reg values
$myRegEntry = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
$myRegEntryDestinationPath = $myOneDriveDestinationPath + "\regEntry\"  + $myComputerName #+ "\pinnedApps.xlm";

#functions 
function Import-RegTree([string][ValidateScript({Test-Path $_})]$XmlFile){
    Import-Clixml $XmlFile | %{
        if (!(Test-Path $_.Path)){md $_.Path -Force | out-null}
        New-ItemProperty -Path $_.Path -Name $_.Name -Value $_.Value -PropertyType $_.Type -Force
    }
}


#check paths
if( !(Test-Path -Path $myTaskbarDestinationPath -PathType Container)){
    Write-Host "Path not found";
    return 666;
}

if( !(Test-Path -Path $myRegEntryDestinationPath -PathType Container)){
     Write-Host "Path not found";
     return 666;
}

#get local taskbar links and delete them 
#Get-ChildItem -Path $myTaskbarIcons | Remove-Item -Force; #maybe not? 
#copy new from OneDrive destination
Get-ChildItem -Path $myTaskbarDestinationPath | Copy-Item -Destination $myTaskbarIcons -Force;

#stop explorer.exe
taskkill /F /IM explorer.exe

#import regentry 
Import-RegTree ("$myRegEntryDestinationPath" + "\pinnedApps.xml"); #fix (~ line 35)

#start explorer
Start-Process explorer
