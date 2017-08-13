#addin nuget:http://packages.nuget.org/v1/FeedService.svc?package=Cake.WebDeploy
#addin nuget:http://packages.nuget.org/v1/FeedService.svc?package=CredentialManagement
#addin nuget:http://packages.nuget.org/v1/FeedService.svc?package=Cake.Powershell
#addin nuget:http://packages.nuget.org/v1/FeedService.svc?package=CredentialManagement
#tool nuget:http://packages.nuget.org/v1/FeedService.svc?package=NUnit.ConsoleRunner&version=3.4.0
#addin "MagicChunks"
var configSettings = new Settings();
var credentialTarget = Argument<string>("CredentialTarget", "DEFAULT_CREDENTIAL");
var integrationTestServiceUrl = Argument<string>("IntegrationTestServiceUrl", "");

configSettings.CakeSettings = new CakeSettings(){ Target = Argument<string>("TargetToRun", "Build")};
Setup(() => {
    configSettings.MsBuildPath = Argument("MSBuildPath", "");
    configSettings.RestoreNuget = new RestoreNuget(){ Solution = "SOLUTION_NAME.sln", Configuration = "Debug" };
    configSettings.Compile = new Compile(){ Solution = "SOLUTION_NAME.sln", Configuration = "Debug" };
    configSettings.Package = new Package(){ProjectToBePackaged ="WebApi/PROJECT_TO_PACKAGE.csproj", Configuration = "Debug"};
    configSettings.Test = new Test(){ UnitTestProjects = @"Tests/*/bin/Debug/*.Tests.dll", Configuration = "Debug"};

    configSettings.IntegrationTest = new Test { UnitTestProjects = @"Tests/*.Integration.Tests/bin/Debug/*.Tests.dll", Configuration = "Release", ConfigFile = @"./Tests/IntegrationTests/bin/Release/IntegrationTests.dll.config"};
    var deploymentCredentials = SecretsManager.GetCredentials(credentialTarget, Argument<string>("DeployUsername", string.Empty), Argument<string>("DeployPassword", string.Empty));    
    configSettings.Deployment = new Deployment() {
        Server = Argument<string>("TargetMachineName", "127.0.0.1"),
        UserName = Argument<string>("DeployUsername", deploymentCredentials.Username),
        Password = Argument<string>("DeployPassword", deploymentCredentials.Password),
        PackageLocation = Argument<string>("PackageLocation", @"WebApi/obj/Debug/Package/PACKAGE_NAME.zip"),
        ApplicationName = Argument<string>("ApplicationName", @"DEFAULT_APPLICATION_NAME")
    };
});

Task("RestoreNuget")
    .Does(() => {
    NuGetRestore(configSettings.RestoreNuget.Solution, new NuGetRestoreSettings { MSBuildVersion = NuGetMSBuildVersion.MSBuild14 });
});

Task("Compile")
    .Does(() => {
    MSBuild(configSettings.Compile.Solution, settings => {
        if(!string.IsNullOrEmpty(configSettings.MsBuildPath)) {
            settings.ToolPath = configSettings.MsBuildPath;
        }
        settings.Configuration = configSettings.Compile.Configuration;
        settings.Verbosity = Cake.Core.Diagnostics.Verbosity.Minimal;
        settings.ArgumentCustomization = args => args.Append("/consoleloggerparameters:Summary");
    });
});

Task("Test")
    .IsDependentOn("RestoreNuget")
    .IsDependentOn("Compile")
    .Does(()=>{
        NUnit3(configSettings.Test.UnitTestProjects, new NUnit3Settings {
                Where="cat!=Integration"
            },
            new NUnitSettings {
                Exclude="Tests/*.Integration.Tests/bin/Debug/*.Tests.dll"
            });
});

Task("Package")
    .Does(() => {
    MSBuild(configSettings.Package.ProjectToBePackaged, settings => {
        if(!string.IsNullOrEmpty(configSettings.MsBuildPath)) {
            settings.ToolPath = configSettings.MsBuildPath;
        }
        settings.Configuration = configSettings.Package.Configuration;
        settings.Verbosity = Cake.Core.Diagnostics.Verbosity.Minimal;
        settings.ArgumentCustomization = args => args.Append("/consoleloggerparameters:Summary");
        settings.WithTarget("package");
        configSettings.IsBuildSuccess = true;
    });
});

Task("Build")
    .IsDependentOn("Test")
    .IsDependentOn("Package")
    .Does(()=>{
});

Task("Deploy")
.Description("Deploy to a remote computer with web deployment agent installed")
.Does(() =>
{
  DeployWebsite(new DeploySettings()
      .FromSourcePath(configSettings.Deployment.PackageLocation)
      .UseComputerName(configSettings.Deployment.Server)
      .UseUsername(configSettings.Deployment.UserName)
      .UsePassword(configSettings.Deployment.Password)
    .AddParameter("IIS Web Application Name", configSettings.Deployment.ApplicationName));
    configSettings.IsDeploySuccess = true;
});


Task("TransformAppConfigToUseServiceUrl")
    .Does(() => {
        TransformConfig(configSettings.IntegrationTest.ConfigFile, configSettings.IntegrationTest.ConfigFile,
          new TransformationCollection {
            { "configuration/appsettings/add[@key=\"APP_SETTING_KEY_TO_TRANSFORM\"]/@value", integrationTestServiceUrl }
          });
    });

Task("IntegrationTest")
    .IsDependentOn("Compile")
    .Does(() => {
        NUnit3(configSettings.IntegrationTest.UnitTestProjects);
    });

public class Settings
{
    public string Env { get; set; }
    public string MsBuildPath { get; set; }
    public CakeSettings CakeSettings { get; set; }
    public RestoreNuget RestoreNuget { get; set; }
    public Compile Compile { get; set; }
    public Package Package { get; set; }
    public Test Test { get; set; }
    public Test IntegrationTest {get; set;}
    public Deployment Deployment { get; set; }
    public bool IsBuildSuccess { get; set; }
    public bool IsDeploySuccess { get; set; }
    public ConfigFiles ConfigFiles { get; set; }
}

public class CakeSettings{
    public string Target { get; set;}
}

public class Deployment {
    public string PackageLocation { get; set; }
    public string Server { get; set; }
    public string UserName { get; set; }
    public string Password { get; set; }
    public string ApplicationName { get; set; }
}

public class Package{
    public string ProjectToBePackaged { get; set; }
    public string Configuration { get; set; }
}

public class RestoreNuget{
    public string Solution { get; set; }
    public string Configuration { get; set; }
}

public class Compile{
    public string Solution { get; set; }
    public string Configuration { get; set; }
}

public class Test{
    public string UnitTestProjects { get; set; }
    public string Configuration { get; set; }
    public string ConfigFile {get; set;}
}

public class ConfigFiles{
    public string CocomConfigLocation { get; set; }
    public string CocomPersistLocation { get; set; }
}

public class SlackMessage{
    public static string Success = "*TicketRefund was successfully Built and Deployed*";
    public static string Failure = "*Build was successfull and Failed to Deploy TicketRefund*";
    public static string BuildFailed = "*Failed TicketRefund Build *";
    public static string Channel = "#cake";
}

public class SecretsManager {
    public static CredentialManagement.Credential GetCredentials(string target, string username, string password) {
        var credential = !string.IsNullOrWhiteSpace(username) && !string.IsNullOrWhiteSpace(password) ? 
            new CredentialManagement.Credential(username, password) : 
            new CredentialManagement.Credential { Target = target };
        credential.Load();
        return credential;
    }
}

RunTarget(configSettings.CakeSettings.Target);