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
 
