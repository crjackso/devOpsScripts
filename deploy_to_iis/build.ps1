$NUGET_EXE = ".nuget\NuGet.exe"
$TOOLS_DIR = "Tools"
$CAKE_EXE = "$TOOLS_DIR\Cake\Cake.exe"
$ENV:CAKE_EXE = $CAKE_EXE
$ENV:NUGET_EXE = $NUGET_EXE
& $NUGET_EXE install $TOOLS_DIR\packages.config -ExcludeVersion -OutputDirectory $TOOLS_DIR
if ($LASTEXITCODE -ne 0)
{
    exit $LASTEXITCODE
}
& $CAKE_EXE build.cake $args
exit $LASTEXITCODE