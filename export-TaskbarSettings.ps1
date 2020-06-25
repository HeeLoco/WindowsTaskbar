#date 22.06.2020
#author HeeLoco

#I wrote the environment variables into my own variables to be flexible if they differ from the default configuration. e.g changing OneDrive (private) Path.
#I also sometimes add parameters afterwards. 

#get and set some vars 
$myUserName = $env:USERNAME; #maybe someday needful to fix the issue with "run as" with different admin accounts
$myComputerName = $env:COMPUTERNAME; #

#path to desired OneDrive folder
$myOneDriveDestinationPath = "C:\Users\" + $myUserName + "\OneDrive\some Configs and Profiles\WindowsTaskbar";

#taskbar icons
$myTaskbarIcons = "C:\Users\" + $myUserName + "\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar";
$myTaskbarDestinationPath = $myOneDriveDestinationPath + "\TaskbarIcons\" + $myComputerName;

#reg values
$myRegEntry = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
$myRegEntryDestinationPath = $myOneDriveDestinationPath + "\regEntry\"  + $myComputerName #+ "\pinnedApps.xlm";

#functions 
function Export-RegTree([string]$RegKey,[string]$ExportPath){
    $data = @()
    $createobject = {
        param($k,$n)
        [pscustomobject] @{
            Name = @{$true='(Default)';$false=$n}[$n -eq '']
            Value = $k.GetValue($n)
            Path = $k.PSPath
            Type = $k.GetValueKind($n)
        }
    }
    get-item $RegKey -PipelineVariable key| %{
        $key.GetValueNames() | %{$data += . $createobject $key $_}
    }
    gci $RegKey -Recurse -Force -PipelineVariable key | %{
        $key.GetValueNames() | %{$data += . $createobject $key $_}
    }
   $data | Export-Clixml $ExportPath
}

#check for admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if(!($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))){
    Write-Error "Please run as Administrator!"
    Start-Sleep -Seconds 5
    return 666;
}

#check paths
if( !(Test-Path -Path $myTaskbarDestinationPath -PathType Container)){
    New-Item -Path $myTaskbarDestinationPath -ItemType Directory
}

if( !(Test-Path -Path $myRegEntryDestinationPath -PathType Container)){
    New-Item -Path $myRegEntryDestinationPath -ItemType Directory
}

#get taskbar links and copy them to OneDrive destination
Get-ChildItem -Path $myTaskbarIcons | Copy-Item -Destination $myTaskbarDestinationPath -Force;

#export regentry 
Export-RegTree "$myRegEntry" ("$myRegEntryDestinationPath" + "\pinnedApps.xml");
