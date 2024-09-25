
iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<- EOF
do \$SYSTEM.OBJ.Load("/dur/init/WebTerminal-v4.9.5.xml", "cuk")
do \$SYSTEM.OBJ.Load("/dur/init/zpm-0.7.0.xml", "cuk")
write "zpm, webterminal installed"

// Disable user password expiration as a demo platform
zn "%SYS"
do ##class(Security.Users).UnExpireUserPasswords("*")

set ns="FHIRSERVER"
zn "HSLIB"
set namespace=ns
Set appKey = "/csp/healthshare/fhirserver/fhir/r4"
Set strategyClass = "HS.FHIRServer.Storage.JsonAdvSQL.InteractionsStrategy"
set metadataPackages = $lb("hl7.fhir.r4.core@4.0.1")
Set metadataConfigKey = "HL7v40"

// Install a Foundation namespace and change to it
// Do ##class(HS.HC.Util.Installer).InstallFoundation(namespace)
Do ##class(HS.Util.Installer.Foundation).Install(namespace)
zn namespace

// Install elements that are required for a FHIR-enabled namespace
do ##class(HS.FHIRServer.Installer).InstallNamespace()

// Install an instance of a FHIR Service into the current namespace
if '##class(HS.FHIRServer.ServiceAdmin).EndpointExists(appKey) { do ##class(HS.FHIRServer.Installer).InstallInstance(appKey, strategyClass, metadataPackages) }

set strategy = ##class(HS.FHIRServer.API.InteractionsStrategy).GetStrategyForEndpoint(appKey)
set config = strategy.GetServiceConfigData()
set config.DebugMode = 4
do strategy.SaveServiceConfigData(config)

write "FHIRServer installed"

//zn ns
//zpm "version"
//zpm "load /dur/package/ -v":1:1

exit
halt
EOF

exit 0
