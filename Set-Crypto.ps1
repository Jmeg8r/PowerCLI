#Author: James Cruce
#Date: 6/27/2018
# Version 1.0
# Script assumes you have vCenter admin rights and are currently connected to the vCenter with all the vms in the vms.txt file
# The script will load the list of vms to configure cipher settings and then copy over the needed IISCrypto CLI program 
# ( https://www.nartac.com/Products/IISCrypto ) as well as the needed template files and the bat files to execute the 
# IISCrypto cli command which will apply the correct template on the operating system version.
# It will then clean up the unneeded files and IISCrypto folder on the remote vm.
# It will loop through the entire list until completed.



$vmname = $null

$name = $null

$vms = $null

$wmi = $null



$vms = get-content -Path C:\IISCrypto\vms.txt

#$vm = Get-VM SDF09A

foreach ($vm in $vms)
{
    $name = Get-VM $vm 
    $vmname = ($name.name)

    Write-Verbose -Message "Starting copy of needed IISCrypto files for $vmname" -Verbose

    Copy-Item \\fileserver\IISCryptoShare\ -Destination \\$vmname\c$ -Recurse

    $wmi = Get-WmiObject -Query "select Version from Win32_OperatingSystem" -ComputerName $vmname



    If (($wmi.version) -like "*10.*")
    {
        Write-Verbose -Message 'Configuring CipherSuite Settings' -Verbose
        $ConfigCipherSuites = 'C:\IISCrypto\ConfigCrypto16.bat'
        Invoke-VMScript -ScriptText $ConfigCipherSuites -VM $vmname -ScriptType Bat
    }

    If (($wmi.version) -like "*6.*")
    {
        Write-Verbose -Message 'Configuring CipherSuite Settings' -Verbose
        $ConfigCipherSuites = 'C:\IISCrypto\ConfigCrypto12.bat'
        Invoke-VMScript -ScriptText $ConfigCipherSuites -VM $vmname -ScriptType Bat

    }


    Write-Verbose -Message "Cleaning Up IISCrypto Folder and Files on $vmname" -Verbose
    $DelIISCrypto = 'Remove-Item C:\IISCrypto\* -Recurse;
                   Remove-Item C:\IISCrypto'

    Invoke-VMScript -ScriptText $DelIISCrypto -VM $vmname -ScriptType Powershell

}

Write-Verbose -Message 'The script is finished' -Verbose









