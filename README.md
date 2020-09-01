# WindowsTaskbar
Two Scripts, that allows you to export and import all your Windows taskbar settings.

In my opinion, this is useful if you want to change computers without losing all the settings you are used to. I use about 3 machines with different Taskbar settings.

Because I use OneDrive I set the default var of the export destination to an OneDrive folder. 

## What do the scripts do?
- They copy the taskbar icons from and to "C:\Users\" + $myUserName + "\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
- They export and import the followig RegEntrys "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband"
- They create the destination folder if they are not available
- The import script has to stop the explorer.exe before it can import the RegEntry, after that is starts the explorer again

## Usage
- Change vars in scripts if needed (e.g. $myOneDriveDestinationPath)
- Use the .bat files to start the scripts easily without changing the execution policy
- If you run the import script it gets interactive. Here you have to type in the desired folder/PC name


**Note:** Paths to the icons can change over the time. Have a closer look at the paths if the icons are not displayed correctly (e.g. install dir)
