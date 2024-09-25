//校验统一社会信用代码长度（）
Invariant:   uscc-length-18
Description: "中国统一社会信用代码长度为18位,含17位数字和最后1位校验码"
Severity:    #error
Expression:  "value.matches('^[0-9]{17}[0-9A-Za-z]$')"
XPath:       "f:value"


//校验统一社会信用代码格式，使用正则表达式

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
// identifier字段切片，用于指定组织机构所持统一社会信用代码
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "type"
* identifier ^slicing.rules = #open
* identifier ^slicing.ordered = false   // can be omitted, since false is the default
* identifier ^slicing.description = "identifier字段切片，用于容纳组织机构所持统一社会信用代码"
// identifier contains规则
* identifier contains
    uscc 1..1 MS
// 统一社会信用代码切片
* identifier[uscc] ^short = "统一社会信用代码"
* identifier[uscc] ^definition = "统一社会信用代码"
* identifier[uscc].use = $iduse#official
* identifier[uscc].type = ChineseIdentifierTypeCS#USCC "统一社会信用代码"
* identifier[uscc] obeys uscc-length-18

// 对社会信用代码字段添加约束


Instance: OrganizationExample
InstanceOf: MDMOrganization
Description: "An example of a Organization with a name."
* active = true 
* name = "长宁市奉孝区中心医院"
* extension[mdmorganizationTypeExtension].valueCoding = OrganizationTypeCS#121 "事业单位法人"
* identifier[uscc].use = $iduse#official
* identifier[uscc].type = ChineseIdentifierTypeCS#USCC "统一社会信用代码"
* identifier[uscc].value = "12330000470051726F"

