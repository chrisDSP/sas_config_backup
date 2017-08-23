<#
.SYNOPSIS
SAS Registry and sasv9.cfg backup script. 

Run this on admin SAS machines to back up the SAS Registry and the sasv9.cfg. 

Default path vars assume workstations with a user profile manager installed (User/ENTERPRISE_USER homedir).

.DESCRIPTION
Developed by Chris Vincent.

Run this script to attempt to copy a machine's SAS Registry and sasv9.cfg to \\network-share\SAS profiles\<user>_<datestamp>

.PARAMETER primary_config

Full path to the primary expected location of the sasv9.cfg file. A default value is programmed by the SAS administrator.
Value defaults to C:\Program Files\SASHome\SASFoundation\9.4\nls\en\sasv9.cfg.

.PARAMETER alt_config

Full path to the alternate expected location of the sasv9.cfg file, in the case of multiple SAS deployments on one workstation. 
Value defaults to C:\Program Files\SASHome2\SASFoundation\9.4\nls\en\sasv9.cfg.

.PARAMETER profile_dir

The location of the user's SAS profile. Ususally %HOMEDRIVE%\%HOMEPATH%\My SAS Files\9.4. 
Value defaults to C:\Users\ENTERPRISE_USER\Documents\My SAS Files\9.4.
 
.PARAMETER backup_target

Path where the script will create a folder (time/date/user stamped) containing a copy of the sasv9.cfg config file and the user's SAS profile folder. 
 
#>

param (    
    [string]$primary_config = "C:\Users\Chris\Desktop\sasv9.cfg",
    [string]$alt_config = "C:\Program Files\SASHome2\SASFoundation\9.4\nls\en\sasv9.cfg",
    [string]$profile_dir = "C:\Users\ENTERPRISE_USER\Documents\My SAS Files\9.4",
    [string]$backup_target = "\\network-share\SAS License\SAS profiles"    
)

function Create-UniqueFolderName { 
  $DateObjInst = Get-Date

    #Retrieve desired date object properties and create a timestamped file/folder prefix for naming the file objects created by this script. 
    $DayOfWeek = $DateObjInst.DayOfWeek
    $Day = $DateObjInst.Day
    $Mon = $DateObjInst.Month
    $Year = $DateObjInst.Year
    $Hour = $DateObjInst.Hour
    $Min =$DateObjInst.Minute
    $Sec = $DateObjInst.Second

    $global:folder_name = "$env:USERNAME`_$DayOfWeek.$Mon$Day$Year`_$Hour$Min$Sec"

                            }

function Create-BackupTargetDir {
    if (!(Test-Path "$backup_target\")) {
        Write-Host "Backup target is invalid or cannot be accessed. Exiting...`n"
        exit
    }
    if (Test-Path "$backup_target\$folder_name") {
        Write-Host "Folder already exists. Skipping creation."
        return
    }
    try {(New-Item -Path "$backup_target\$folder_name" -ItemType Directory -ErrorAction Stop -ErrorVariable $session_err) | Out-Null} catch {Write-Host "Attempt to create a folder on the backup target failed. No backup can be made. Exiting...`n"}    
            if ($session_err -ne $null) 
            {exit}    
    }
  

function Copy-SASConfigFile {
    try {[boolean]$prim = Test-Path -Path $primary_config -ErrorAction Stop} catch {[boolean]$prim = $false}
    try {[boolean]$alt = Test-Path -Path $alt_config -ErrorAction Stop} catch {[boolean]$alt = $false}
    if ((Test-Path -Path "$backup_target\$folder_name" -PathType Container)) {
        if ($prim -eq $true) {
                Write-Host "OK! Primary path found. Attempting to copy...`n"
                try {Copy-Item -Path $primary_config -Destination "$backup_target\$folder_name" -ErrorAction Stop -ErrorVariable $session_err} catch {return "`tUnable to copy sasv9.cfg to the target directory. Attempt to copy this manually.`n"}
                return "`tSuccess.`n"
            }
        elseif ($alt -eq $true) {           
                Write-Host "OK! Alternate path found. Attempting to copy...`n"
                try {Copy-Item -Path $alt_config -Destination "$backup_target\$folder_name" -ErrorAction Stop -ErrorVariable $session_err} catch {return "`tUnable to copy sasv9.cfg to the target directory. Attempt to copy this manually.`n"}
                return "`tSuccess."
        }
        else {        
            Write-Host "Unable to find sasv9.cfg. Find this file and be sure to back it up manually.`nExiting..."
            exit
            }
            
    }
        else {
            Write-Host "No target folder found. Exiting...`n"
            exit             
            }
            
}


function Copy-SASRegistry {
    if ((Test-Path -Path "$profile_dir" )) 
        {
            Write-Host "OK! SAS Registry found. Attempting to copy...`n"
            try {Copy-Item -Path "$profile_dir" -Destination "$backup_target\$folder_name\9.4" -Recurse -ErrorAction Stop -ErrorVariable $session_err} catch {return "`tThere was a problem copying your SAS Registry/My SAS Files to the remote location. Copy these manually.`n"}
            return "`tSuccess.`n"
        }
    else {Write-Host "Your 'My SAS Files' folder isn't in the default directory. Make sure you find and manually back up this folder!`n"}

    if ($session_err -ne $null) 
            {exit}  
}

#MAIN BEGIN
#Program actually starts here.

Create-UniqueFolderName

#Start-Transcript -Path "$backup_target\$folder_name\ps_session.log" -Force


Create-BackupTargetDir
Copy-SASConfigFile
Copy-SASRegistry

#Stop-Transcript

Write-Host "Script has finished! You may close this window.`n"
pause

#Program ends here. 
#MAIN END