#Script for detaching LUNs asynchronously
#https://medium.com/@theredpot

$vCenter = ""
$cred = Get-Credential

Disconnect-VIServer *
Connect-VIServer $vcenter -Credential $cred

$hostFile = "./host_list.csv"
$hostsESXi = import-csv $hostFile -delimiter ";"
$esxiObjects = Get-VMHost $hostsESXi.hostname

$lunFile = "./lun_list.csv"
$luns = import-csv $lunFile -delimiter ";"
$lunObjects = $luns.lun

foreach ($lun in $lunObjects){
	
	foreach ($esxi in $esxiObjects){
		write-host “Starting $esxi”
		
		$storSys = Get-View $esxi.ExtensionData.ConfigManager.StorageSystem
		
		$scsiLun = Get-ScsiLun -VmHost $esxi | where {$_.CanonicalName -eq $lun}
		$lunUUID = $scsiLun.ExtensionData.Uuid
		
		write-host "Detaching " $scsiLun.CanonicalName
		$task= $storSys.DetachScsiLunEx_Task($lunUuid)
	}
}
