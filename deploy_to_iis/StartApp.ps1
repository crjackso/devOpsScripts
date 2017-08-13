param (
   $hostname = "DEFAULT_HOST_NAME",
   $userName = "USER_NAME",
   $executeScriptAs = "$hostName\$userName",
   $password = "DEFAULT_PASSWORD",
   $iisAppPoolName = "integrationtests",
   $iisAppName = "IIS_APP_NAME_HERE",
   $iisSiteName = "IntegrationTests",
   $iisSiteFolder = "C:\IntegrationTests",
   $bindingPort = 8082
)

echo "Setting up winrm"
winrm set winrm/config/client "@{TrustedHosts=""$hostname""}";
echo "winrm set"


$pass= $password|ConvertTo-SecureString -AsPlainText -Force
$ServerCredentials = New-Object System.Management.Automation.PsCredential($executeScriptAs, $pass)


invoke-command -ComputerName $hostname -ScriptBlock {
param($hostName, $iisAppPoolName, $iisAppName, $iisSiteName, $iisSiteFolder, $bindingPort)

 Import-Module WebAdministration
 $iisAppPoolDotNetVersion = "v4.0"
 $pathToApplication = $iisSiteFolder +"\"+ $iisAppName
 $iisAppPoolPath = "IIS:\AppPools\"
 echo "Navigating to IIS:\AppPools\"
 cd IIS:\AppPools\

 function StartAppPool(){
   echo "Starting App pool $iisAppPoolName.."
   Start-WebAppPool -Name $iisAppPoolName -ErrorAction SilentlyContinue
   echo "App pool successfully started"
 }

 function StartSite(){
  echo "Starting Website $iisSiteName.."
  Start-WebSite $iisSiteName
 }

 StartAppPool
 StartSite
} -Credential $ServerCredentials -ArgumentList $hostname, $iisAppPoolName, $iisAppName, $iisSiteName, $iisSiteFolder, $bindingPort