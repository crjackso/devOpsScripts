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

 function AppPool(){
   echo "=====================Working on App Pool====================="
   if (!(DoesAppPoolExists $iisAppPoolName)){
     CreateAppPool $iisAppPoolName $iisAppPoolDotNetVersion
   }
  echo "=====================App Pool completed====================="
  echo ""
 }

 function Website(){
  echo "=====================Working on Website====================="
   cd IIS:\Sites\
   if (!(DoesWebSiteExist $iisSiteName))
   {
     CreateDirectory $iisSiteFolder
     CreateWebsite $iisSiteName $iisSiteFolder $iisAppPoolName
     CreateBindings $iisSiteName $bindingPort
   }
  echo "=====================Website completed====================="
  echo ""
 }

 function Application(){
   echo "=====================Working on Application====================="
   if (!(DoesAppExists $iisSiteName $iisAppName))
   {
     CreateDirectory $pathToApplication
     CreateApplication $iisAppName $iisSiteName $pathToApplication $iisAppPoolName
   }
   echo "=====================Application completed====================="
 }

 function StopAppPool($appPool){
   echo "Stopping App pool $appPool.."
   Stop-WebAppPool -Name $appPool -ErrorAction SilentlyContinue
   echo "App pool successfully stopped"
 }

  function StartAppPool($appPool){
   echo "Starting App pool $appPool.."
   Start-WebAppPool -Name $appPool -ErrorAction SilentlyContinue
   echo "App pool successfully started"
 }

 function CreateAppPool($appPool, $appPoolDotnetVersion){
   echo "Creating App pool $appPool.."
   New-WebAppPool $appPool
   Set-ItemProperty IIS:\AppPools\$appPool managedRuntimeVersion $iisAppPoolDotNetVersion
   echo "App pool successfully created"
 }

 function DoesAppPoolExists($appPool){
   return (Test-Path $appPool -pathType container)
 }

  function DoesWebSiteExist($siteName){
   return (Test-Path $siteName -pathType container)
 }

  function DoesAppExists($siteName, $appName){
    return (Test-Path "IIS:\Sites\$siteName\$appName" -pathType container)
 }

 function CreateDirectory($folderToCreate){
   echo "Creating new directory $folderToCreate.."
   New-Item -ItemType Directory -Force -Path $folderToCreate
   echo "Folder successfully created"
 }

 function CreateWebsite($websiteName, $siteFolder, $appPoolName){
  echo "Creating new website $websiteName in directory $siteFolder"
  $var = New-WebSite -Name $websiteName -PhysicalPath $siteFolder -ApplicationPool $appPoolName -Force
  echo "New website successfully created"
 }

 function CreateBindings($siteName, $port){
   RemoveBinding $siteName $port
   AddBinding $siteName $port
 }

 function RemoveBinding($siteName, $port){
  $IISSite = "IIS:\Sites\$siteName"
  echo "Removing default bindings for site $siteName on port 80.."
  Get-WebBinding -Port 80 -Name $siteName | Remove-WebBinding
  #Remove-WebBinding -Name $IISSite -IPAddress "*" -Port $port -Protocol "http"
  echo "Bindings successfully removed"
 }

 function AddBinding($siteName, $port){
   $IISSite = "IIS:\Sites\$siteName"
   echo "Adding bindings for site $siteName on port $port.."
   New-WebBinding -Name $siteName -IPAddress "*" -Port $port -Protocol "http"
   echo "Bindings successfully added.."
 }


 function CreateApplication($appName, $siteName, $pathToApp, $poolName){
   echo "Creating new Application $appName on in directory $pathToApp.."
   New-WebApplication -Name $appName -Site $siteName -PhysicalPath $pathToApp -ApplicationPool $poolName
   echo "Application successfully created"
 }

 AppPool
 Website
 Application
} -Credential $ServerCredentials -ArgumentList $hostname, $iisAppPoolName, $iisAppName, $iisSiteName, $iisSiteFolder, $bindingPort