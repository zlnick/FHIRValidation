\[ English | [中文](README_zh.md) \]

This demo program is used to show how a custom FHIR profile can be employed to validate data compliance. The custom FHIR implementation guide was developed based on [FHIR Version R4](https://hl7.org/fhir/R4/index.html), and in this example implements the [Organization](https://hl7.org/fhir/R4/organization.html) resource extension to validating data compliance.

# Installation
1. Download the project via Git clone.
2. Execute docker-compose up -d to build and start the container, the initial execution will download required container images and executing the script will take another 5 to 10 minutes (depending on the machine). InterSystems IRIS for Health image will be built, then FHIR server will be installed, and the custom FHIR specification will be imported so that it can be used to validate the data.
3. import the test case files from TestCases in Postman to see how the various FHIR constraints are validated
4. you can directly unzip the full-ig.zip file in the ExampleIG folder to view the contents of the customized IG (Chinese description)

# Code Structure
```
FHIRValidation
├─ ExampleIG                        
│  ├─ ig.ini
│  ├─ input
│  │  ├─ fsh
│  │  │  ├─ alias.fsh
│  │  │  ├─ codesystems.fsh
│  │  │  ├─ organization.fsh
│  │  │  └─ valuesets.fsh
│  │  └─ pagecontent
│  │     └─ index.md
│  └─ sushi-config.yaml
├─ README.md
├─ README_zh.md
├─ TestCases
│  └─ FHIR Profile-based Validation  testcases.postman_collection.json
├─ docker-compose.yml
└─ image-iris
   ├─ Dockerfile
   └─ src
      ├─ IGPackages
      │  ├─ hl7.fhir.uv.extensions.r4#5.1.0.tgz
      │  ├─ hl7.terminology.r4#6.0.2.tgz
      │  └─ package.tgz
      └─ init
         └─ init.sh

```
## ExampleIG
All files in this subdirectory are [SUSHI](https://fshschool.org/docs/sushi/) source codes of the customized FHIR specification.
## TestCases
This subdirectory holds test case scripts based on the FHIR REST API, which need to be imported into Postman.
## image-iris
This subdirectory holds the files required for InterSystems IRIS for Health image:
└─ src
    ├─ IGPackages This directory holds the [package](#fhir-package-introduction) files for custom FHIR IGs
    └─ init This directory holds the IRIS Docker image initialization scripts


# FHIR package introduction
The HL7 organization recommends the use of implementation guides ([Implementation Guild](https://build.fhir.org/ig/FHIR/ig-guidance/)) to explain how to use the FHIR specification. In addition to instructions for developers to read (e.g., html), implementation guides typically include artifacts that are directly machine-readable and applicable and can be used to drive tasks such as code generation and data validation.  
The FHIR Implementation Guide uses the [NPM Package](https://docs.npmjs.com/cli/v8/configuring-npm/package-json) specification to manage dependencies. All StructureDefinition, ValueSet, and other resources covered by the guide are packaged together in a single package that can be used by FHIR Server to read the specification, generate client code, or perform data quality checks.  
The implementation guide generated by the SUSHI tool contains several package files. In this example, image-iris/src/IGPackages/package.tgz is the generated package, which can be directly imported by IRIS FHIR Server. It should be noted that in addition to the core resource packages (e.g., [hl7.fhir.r4.core](https://hl7.org/fhir/R4/downloads.html)), the complete FHIR specification needs to refer to additional resource packages such as terminology, extensions, and so on.  
The current documentation of the FHIR specification referencing mechanism is not yet complete. For example, based on the R4 version of the FHIR specification in addition to referencing hl7.fhir.r4.core, it also needs to reference [hl7.fhir.uv.extensions.r4#5.1.0](https://simplifier.net/packages/hl7.fhir.uv.extensions.r4/ 5.1.0) and [hl7.terminology.r4#6.0.2](https://terminology.hl7.org/downloads.html), these references are documented in the [R5 version](https://hl7.org/fhir/packages.html)but not declared in the R4 version, so the developer needs to add them during the development process.  
In this case these packages have been downloaded in the image-iris/src/IGPackages folder and will be loaded as dependencies before customizing the FHIR implementation guide.

# FHIR validation introduction
See the [Validating Resources](https://hl7.org/fhir/R4/validation.html) section of the FHIR specification. The FHIR specification has been designed with data quality checking mechanisms for a range of mechanisms including data structures, attribute bases, value fields, code bindings, and constraints, etc. The HL7 organization in the FHIR specification does not mandate what intensity of quality control to follow, but recommends that the principle of [leniency](https://hl7.org/fhir/R4/validation.html#correct-use) be applied to FHIR data.  
For FHIR repositories that hold FHIR resources, guaranteeing the data quality of FHIR resources is a prerequisite for making the healthcare industry valuable and guaranteeing the safety of healthcare practices. Therefore, when building a data sharing and exchange scheme based on FHIR repositories, even if data that does not meet data quality requirements has to be saved, it should be calibrated to mark non-conformities and promote data governance activities to safeguard healthcare security and the interests of data consumers.  
Of the multiple data validation methods indicated by the FHIR specification, FHIR Validator and [FHIR Operations](https://hl7.org/fhir/R4/resource-operation-validate.html) provide the most comprehensive coverage of data quality validation.  
This example will use the `$`validate operation provided by InterSystems IRIS for Health to validate FHIR data that has not yet been saved via the profile parameter. Users can also modify the test case to construct an HTTP POST parameter to validate the stock FHIR resource.  
It should also be noted that the $validate operation, if called correctly, will return the validation result via Http 200, and if there are any non-conformities, an error message will be wrapped in the returned OperationOutcome resource instead of identifying the error via the Http code.

# Extensions to FHIR R4
The following extensions were made to the Organization resource based on FHIR R4:
## 1. Modify the binding strength of language
Change the binding strength of the organization's primary language to required

## 2. Active field cardinality changed from 0...1 to 1...1
This makes the status of active field a required field, with one and only one element

## 3. Name field cardinality changed from 0..1 to 1..1
The name of the organization becomes a required field with one and only one element. For reference, hospitals in China may have more than one name in addition to the hospital name if they have licenses as an Emergency Center, an Chest Pain Center, and so on. However, it is noted that these licenses usually identify the capacity of the services provided by the healthcare institution rather than the legal name it has in the organization registration system, and the life cycle of such licenses does not coincide with the life cycle of the healthcare institution itself. Therefore, the name obtained from the license is appropriately considered to be the service capability of the healthcare organization rather than the unique name of the organization. In FHIR, the name derived from the service capability can be provided through the resource HealthcareService, which can be more appropriately used to express the above concept by establishing a many-to-one referencing relationship with the Organization resource.


## 4. Increase in the type of organization of medical institutions
According to the Chinese national standard GB/T 20091-2021 organization types, CodeSystem organizationtype-code-system and ValueSet organizationtype-vs are added respectively, and the extension mdm-organizationTypeExtension is added to the Organization resource through Extension. Extension mdm-organizationTypeExtension is added to the Organization resource so that the resource can be used to represent the organization type that identifies Chinese organization types.  
The extension is implemented by slicing the Extension with a cardinality of 1..1 so that the Healthcare Organization resource must have an organization type element.

## 5. Constraints on healthcare organization identification numbers
The FHIR base standard does not include the type of the unified social credit code for Chinese organizations, for this reason the CodeSystem cs-identifierType-code-system is added and the Identifier is sliced according to its type, so that it must be able to express the social credit code. And the format of the social credit code follows the following constraints:
1. identifier.use must take the value official, i.e. official/official use
2. identifier.type MUST follow cs-identifierType-code-system, system MUST be the uri of the codesystem, and code MUST be “USCC”.
3. identifier.value must follow the custom constraint uscc-length-18, the field must be 18 digits long, of which the first 17 digits must be numeric and the last 1 digit must be numeric or alpha


# Test Case List

## 1. Without profile - All OK
The resource's corresponding profile is not declared, so FHIR Server will not validate the values of the attributes in the resource and will only return All OK.

## 2. Unknow field
An undefined attribute isNational was added to the resource, so the validation engine returned an Unrecognized element error.

## 3. Wrong cardinality - less
In this IG, the cardinality of the Organization resource name attribute was modified to 1..1, which means that there should be and only one organization name. The name is not filled in this test case and hence the data validation fails.
In addition, it can be observed that Identifier.type has been extended to include the Uniform Social Credit Code as an identifier type, which is not included in the FHIR R4 specification, but the strength of the code binding for this field is only EXAMPLE, which does not force constraints. Therefore, the validation engine returns the information level value field code non-conformance information without reporting an error.

## 4. Binding strength
In this IG, the code binding strength of the organization's language attribute is changed to required, then the field value field must conform to http://hl7.org/fhir/ValueSet/languages, therefore, when the field takes the value of 'wrong language', it is not in the required value value, which will result in an error level error

## 5. Wrong valie
In this IG, the value field for the organization type comes from organizationtype-code-system, so when the value of code in the extension element of type mdm-organizationTypeExtension, which has a value of “999 ”, which is not in the value field, will result in an error-level error

## 6. Failing invariant
In this IG, the social credit code of an organization must follow the custom constraint uscc-length-18 (the field must be 18 digits long, where the first 17 digits must be numeric, and the last 1 digit must be numeric or alphabetic), and therefore violating this constraint when the last digit is the character “%” will result in an error

## 7. Failing profile
A single profile for a resource definition contains multiple constraints, so all issues that do not satisfy the profile will be detected during validation, such as the following issues in this example:
1. wrong language code
2. wrong organization type
3. missing name field
    