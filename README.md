# Update-CryptoFileScreen
Script to enable and/or update an FSRM File screen to block writes of known ransomware file extensions

This script is a slighly modified version of "CryptoBlocker" by Maurice Daly.  The original blog post describing use of this script is here: https://www.scconfigmgr.com/2017/03/21/protect-file-servers-from-ransomware-with-sccm-cicb/

I have made just a couple of small changes.  I added the ability to add exclusions to the File Group created for the file screen, by placing a list of files to be excluded in "Exclusions.txt".  I also removed a section of code which was checking the latest list from fileextensions.txt against the existing list of extensions in the file screen.  That section was not creating the desired result, instead it was alternating between 'new' and 'old' extensions every time the script ran if the fileextensions.txt list had been changed. 
