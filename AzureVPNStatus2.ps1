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
$tempbody = "C:\CustomScript\tempbody.txt"
Write-Host $tempbody
$VPNStatuslog="C:\CustomScript\VPNStatus.txt"
Write-Host $VPNStatuslog
$VPNErrorlog="C:\CustomScript\VPNErrorlog"
#--------------------Azure input parameters--------#
# Name of the subscription to use
$subscriptionName = "SEN Fit" 
#Get-AzurePublishSettingsFile
$subscriptionId="287a5b24-6a3b-4eac-a045-8be37098fc53"
$publishsettingfile="C:\CustomScript\SenFit.publishsettings"
Import-Module Azure

Import-AzurePublishSettingsFile -PublishSettingsFile  $publishsettingfile
Set-AzureSubscription -SubscriptionName $subscriptionName -PassThru
Select-AzureSubscription $subscriptionName
#Get-AzureVNetConfig -ExportToFile "C:\Users\c360agentinstall\Downloads\MyAzNets.netcfg"
#Name of Virtual Network OCSAZWEU1DCVNET ocsazpridcvnet
$VirtualNetworkSiteName="SENFIT-VNET01"
function sendmail
{
    $Attachment1 = "C:\CustomScript\VPNStatus.txt"
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
foreach($conn in $Connection)
{
if($Conn.ConnectivityState -match "Connected")
{
$status= $Conn.ConnectivityState
$vnetsitename=$Conn.LocalNetworkSiteName

Add-Content $VPNStatuslog "*****************************************************************"
Add-Content $VPNStatuslog "$VirtualNetworkSiteName VPN Tunnel i.e $vnetsitename $status on $dt at $time "
Add-Content $VPNStatuslog "*****************************************************************"
}
else
{
Add-Content $VPNStatuslog "*****************************************************************"
Add-Content $VPNStatuslog "$VirtualNetworkSiteName VPN Tunnel i.e $vnetsitename notConnected Status is $status on $dt at $time"
Add-Content $VPNStatuslog "*****************************************************************"
}

}
}
try
{
VPN-Status
$var1=Get-Content C:\CustomScript\VPNStatus.txt |Select-String -Pattern "notConnected"
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





