
iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<- EOF

// Disable user password expiration as a demo platform
zn "%SYS"
do ##class(Security.Users).UnExpireUserPasswords("*")
set props("Path") = "/dur/FullIG"
set props("Description") = "A demo FHIR IG web"
do ##class(Security.Applications).Create("/csp/FullIG", .props)

set namespace="FHIRSERVER"
zn "HSLIB"

// Install a Foundation namespace and change to it
// Do ##class(HS.HC.Util.Installer).InstallFoundation(namespace)
Do ##class(HS.Util.Installer.Foundation).Install(namespace)
zn namespace

// Import FHIR packages
SET packageList=$LISTBUILD("/dur/IGPackages/hl7.fhir.uv.extensions.r4#5.1.0/package")
Set rtn = ##Class(HS.FHIRMeta.Load.NpmLoader).importPackages(packageList)
SET packageList=$LISTBUILD("/dur/IGPackages/hl7.terminology.r4#6.0.2/package")
Set rtn = ##Class(HS.FHIRMeta.Load.NpmLoader).importPackages(packageList)
SET packageList=$LISTBUILD("/dur/IGPackages/package")
Set rtn = ##Class(HS.FHIRMeta.Load.NpmLoader).importPackages(packageList)


// Install elements that are required for a FHIR-enabled namespace
Set appKey = "/csp/healthshare/fhirserver/fhir/r4"
Set strategyClass = "HS.FHIRServer.Storage.JsonAdvSQL.InteractionsStrategy"
set metadataPackages = $lb("hl7.fhir.r4.core@4.0.1")
Set metadataConfigKey = "HL7v40"

do ##class(HS.FHIRServer.Installer).InstallNamespace()

// Install an instance of a FHIR Service into the current namespace
if '##class(HS.FHIRServer.ServiceAdmin).EndpointExists(appKey) { do ##class(HS.FHIRServer.Installer).InstallInstance(appKey, strategyClass, metadataPackages) }

set strategy = ##class(HS.FHIRServer.API.InteractionsStrategy).GetStrategyForEndpoint(appKey)
set config = strategy.GetServiceConfigData()
set config.DebugMode = 4
do strategy.SaveServiceConfigData(config)

halt
EOF

echo ""
echo "FHIR Server installation complete."
echo ""

iris stop $ISC_PACKAGE_INSTANCENAME quietly

exit 0