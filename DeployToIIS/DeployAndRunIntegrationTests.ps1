param (
   $hostname = "HOST_NAME_HERE",
   $userName = "USER_NAME_HERE",
   $password = "PASSWORD_HERE",
   $iisAppPoolName = "integrationtests",
   $iisAppName = "SomeService",
   $iisSiteName = "IntegrationTests",
   $iisSiteFolder = "C:\IntegrationTests",
   $bindingPort = 8083
)

$ErrorActionPreference = "Stop"

function Start-Job {

    param (
        [parameter(Mandatory=$true)][string]$StringScriptBlock
    )

    $ScriptBlock = $executioncontext.invokecommand.NewScriptBlock($StringScriptBlock)

    pushd
    & $ScriptBlock

    if ($LASTEXITCODE -ne 0)  {
        popd
        exit(1)
    }
    popd
}

"========================= Creating an App on IIS with an App pool ===================="

Start-Job '.\SetupAppInIIS.ps1 -hostname $hostname -username $userName -password $password -iisAppPoolName $iisAppPoolName -iisAppName $iisAppName -iisSiteName $iisSiteName -bindingPort $bindingPort'


"============================== Run Build Package =========================="
Start-Job 'cd ..; .\build.ps1 -TargetToRun="Package"'

$packageFile = Get-ChildItem -Path ../WebApi/obj/debug/Package -Filter *.zip

"Package file =" + $packageFile
"============================== Run Build Deploy =========================="
Start-Job 'cd ..; .\build.ps1 -TargetToRun="deploy" -TargetMachineName="$hostname" -DeployUserName="$userName" -DeployPassword="$password" -ApplicationName="$iisSiteName\$iisAppName" -PackageLocation="./WebApi/obj/debug/Package/$packageFile"'

"============================== Start App on IIS =========================="
Start-Job '.\StartApp.ps1 -hostname $hostname -username $userName -password $password -iisAppPoolName $iisAppPoolName -iisAppName $iisAppName -iisSiteName $iisSiteName -bindingPort $bindingPort'

$serviceUrl = "http://" + $hostname + ":" + $bindingPort + "/" + $iisAppName

"serviceUrl=" + $serviceUrl

"============================== Run Integration Tests =========================="
Start-Job 'cd ..; .\build.ps1 -TargetToRun="IntegrationTest" -IntegrationTestServiceUrl=$serviceUrl -verbosity="Diagnostic"'

