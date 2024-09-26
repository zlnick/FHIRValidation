iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<- EOF
// Disable user password expiration as a demo platform
zn "%SYS"
do ##class(Security.Users).UnExpireUserPasswords("*")

set ns="FHIRSERVER"
zn ns

// Import packages to be validated against
// To make FHIR R4 'complete', according to SUSHI community comments, hl7.fhir.uv.extensions.r4 and hl7.terminology.r4 packages are also needed
SET packageList=$LISTBUILD("/dur/IGPackages/hl7.fhir.uv.extensions.r4#5.1.0/package","/dur/IGPackages/hl7.terminology.r4#6.0.2/package","/dur/IGPackages/package")
Set rtn = ##Class(HS.FHIRMeta.Load.NpmLoader).importPackages(packageList)
zw rtn


exit
halt
EOF

echo ""
echo "Installation complete."
echo ""

echo "stop iris and purge unnecessary files..."
iris stop $ISC_PACKAGE_INSTANCENAME quietly
rm -rf $ISC_PACKAGE_INSTALLDIR/mgr/journal.log 
rm -rf $ISC_PACKAGE_INSTALLDIR/mgr/IRIS.WIJ
rm -rf $ISC_PACKAGE_INSTALLDIR/mgr/journal/*
rm -rf /dur/*

exit 0
