#------------------------------------------------#
#script Will monitor VPN tunnel Status
#Date- 15/06/2016
#Author- Y Lakshmoji Rao (409997)
#------------------------------------------------#

#-------------------------------------------------#
$dt = get-date -format D
$time = get-date -format t
$From = "cloud360sharedservices@cognizant.com"
$To = "lakshmoji.raoy@cognizant.com"
$Cc1 = "Sumanth.Kumar@cognizant.com"
$Cc2 = "cloud360sharedservices@cognizant.com"
$tempbody = "C:\tempbody.txt"
Write-Host $tempbody
$VPNStatuslog="C:\VPNStatus.txt"
Write-Host $VPNStatuslog
$VPNErrorlog="C:\VPNErrorlog"
#--------------------Azure input parameters--------#
# Name of the subscription to use
$subscriptionName = "Azure Primary DC" 
#Get-AzurePublishSettingsFile
$subscriptionId="27ebcd4b-858d-4361-84a8-fcc28e24896f"
$publishsettingfile="C:\Users\c360agentinstall\Downloads\ocsazureconfig.publishsettings"
Import-Module Azure
Import-AzurePublishSettingsFile -PublishSettingsFile  $publishsettingfile
#Get-AzureVNetConfig -ExportToFile "C:\Users\c360agentinstall\Downloads\MyAzNets.netcfg"
#Name of Virtual Network OCSAZWEU1DCVNET ocsazpridcvnet
$VirtualNetworkSiteName="OCSAZWEU1DCVNET"
function sendmail
{
    $Attachment1 = "C:\VPNStatus.txt"
    $Subject ="Priority1:VPNStatus-check for Azure $VirtualNetworkSiteName $dt at $time"
    echo "Hi,`n" ,"Azure VPN $VirtualNetworkSiteName Status.\n`" `Please find the attachment.`n" , "Regards," , "Cloud360 Automation." |out-File $tempbody -width 240
    $Body = Get-Content $tempbody | Out-String
    $SMTPServer = "213.199.154.87"
    $SMTPPort = "25"
    Send-MailMessage -From $From -to $To -Subject $Subject `
    -Body $Body -Cc $Cc1,$Cc2  -SmtpServer $SMTPServer `
    -Attachments $VPNStatuslog


}


function VPN-Status
{
$Connection=Get-AzureVNetConnection -VNetName $VirtualNetworkSiteName
$ConnectionStatus=$Connection.ConnectivityState
Write-Host $ConnectionStatus
if($ConnectionStatus -cmatch "Connected")
{

Add-Content $VPNStatuslog "*****************************************************************"
Add-Content $VPNStatuslog "$VirtualNetworkSiteName VPN Tunnel is $ConnectionStatus on $dt at $time "
Add-Content $VPNStatuslog "*****************************************************************"
}
else
{
Add-Content $VPNStatuslog "*****************************************************************"
Add-Content $VPNStatuslog "$VirtualNetworkSiteName VPN Tunnel is notConnected Status is $ConnectionStatus on $dt at $time"
Add-Content $VPNStatuslog "*****************************************************************"
sendmail
}
}
try
{
VPN-Status
$var1=Get-Content C:\VPNStatus.txt |Select-String -Pattern "notConnected"
if($var1.Length -gt 1)
{
sendmail
}

}
catch
{
 $Error[0]
 Add-content $VPNErrorlog
 $Error.Clear()
}





