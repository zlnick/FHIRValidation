Extension: MDMOrganizationTypeExtension
Id: mdm-organizationTypeExtension
Title: "组织机构主类型"
Context: MDMOrganization
* value[x] only Coding
* value[x] from OrganizationTypeVS (required)

Profile: MDMOrganization
Id: mdm-organization
Title: "组织机构主数据"
Parent: Organization
Description: "An example profile of the Organization resource."
* active 1..1 MS
* name 1..1 MS
* extension contains MDMOrganizationTypeExtension named mdmorganizationTypeExtension 1..1 MS

Instance: OrganizationExample
InstanceOf: MDMOrganization
Description: "An example of a Organization with a name."
* active = true
* name = "长宁市奉孝区中心医院"
* extension[mdmorganizationTypeExtension].valueCoding.code = OrganizationTypeCS#121
* extension[mdmorganizationTypeExtension].valueCoding.display = "事业单位法人"