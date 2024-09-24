// This is a simple example of a FSH file.
// This file can be renamed, and additional FSH files can be added.
// SUSHI will look for definitions in any file using the .fsh ending.
Profile: MDMOrganization 
Parent: Organization
Description: "An example profile of the Organization resource."
* name 1..1 MS

Instance: OrganizationExample
InstanceOf: MDMOrganization
Description: "An example of a Organization with a name."
* name = "长宁市奉孝区中心医院"