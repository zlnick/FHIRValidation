\[ [English](README.md) | 中文 \]

本演示程序用于展示如何采用自定义FHIR profile来验证数据合规性。自定义FHIR实施指南基于[FHIR R4版本](https://hl7.org/fhir/R4/index.html)开发，在本例中实现了对[Organization](https://hl7.org/fhir/R4/organization.html)资源的扩展并用于验证数据的合规性。

# 安装
1. 通过Git clone下载本项目。
2. 执行docker-compose up -d构建并启动容器，初次执行时需执行需10～15分钟（视配置变化）。将构建InterSystems IRIS for Health镜像，安装FHIR服务器，导入自定义FHIR规范，使自定义FHIR 规范可用于验证数据。
3. 在Postman中导入TestCases中的测试用例文件，查看各类FHIR约束的测试效果
4. 容器启动后可查看[自定义IG](http://localhost:52880/csp/FullIG/index.html)内容

# 项目代码结构
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
      ├─ FullIG
      ├─ IGPackages
      │  ├─ hl7.fhir.uv.extensions.r4#5.1.0.tgz
      │  ├─ hl7.terminology.r4#6.0.2.tgz
      │  └─ package.tgz
      └─ init
         └─ init.sh

```
## ExampleIG
该子目录下的所有文件为本项目所采用的自定义FHIR规范[SUSHI](https://fshschool.org/docs/sushi/)源码，供用户定义FHIR规约时参考使用。
## TestCases
该子目录下存放基于FHIR REST API的测试用例脚本，需导入到Postman中使用
## image-iris
该子目录下存放nterSystems IRIS for Health镜像所需的文件，其中：
└─ src
    ├─ FullIG 该目录中存放SUSHI生成的自定义FHIR IG
    ├─ IGPackages 该目录中存放自定义FHIR IG的 [package](#fhir-package) 文件
    └─ init 该目录中存放IRIS的Docker镜像初始化脚本


# FHIR package简介
HL7组织推荐使用实施指南（[Implementation Guild](https://build.fhir.org/ig/FHIR/ig-guidance/)）来解释如何使用FHIR规范。除用于开发人员阅读的说明（如html）外，实施指南中通常也包括可直接被机器读取和应用的工件（artifacts），可被用于驱动代码生成和数据验证等任务。  
FHIR实施指南采用[NPM Package](https://docs.npmjs.com/cli/v8/configuring-npm/package-json)规范管理依赖。指南涉及的所有StructureDefinition，ValueSet等资源将被打包在一块，形成可被FHIR Server用于读取规范，生成客户端代码或执行数据质量校验的资源包。  
通过SUSHI工具生成的实施指南中就包含若干package文件。如本例中，image-iris/src/IGPackages/package.tgz即为生成的package包，可被IRIS FHIR Server直接导入使用。应当注意到的是，除核心资源包（如[hl7.fhir.r4.core](https://hl7.org/fhir/R4/downloads.html)）外，完整的FHIR规范还需要引用术语、扩展等额外的资源包。  
目前FHIR规范引用机制的文档尚不完善。如基于R4版的FHIR规范除引用hl7.fhir.r4.core外，还需引用[hl7.fhir.uv.extensions.r4#5.1.0](https://simplifier.net/packages/hl7.fhir.uv.extensions.r4/5.1.0)与[hl7.terminology.r4#6.0.2](https://terminology.hl7.org/downloads.html)，但这些引用关系在[R5版本](https://hl7.org/fhir/packages.html)中方有记录，在R4版文档中并未完整声明，需开发者在开发过程中自行补充。  
在本例中这些包已下载在image-iris/src/IGPackages文件夹下，将作为依赖在自定义FHIR实施指南之前加载。

# FHIR validation简介
参见FHIR规范[Validating Resources](https://hl7.org/fhir/R4/validation.html)一节。FHIR规范已经设计了对数据结构、属性基数、值域、代码绑定和约束等一系列机制在内的数据质量校验机制。HL7组织在FHIR规范中并未强制要求遵循何种强度的质量控制，但建议采用[宽进严出](https://hl7.org/fhir/R4/validation.html#correct-use)的原则处理FHIR数据。  
对于保存FHIR资源的FHIR存储库而言，保障FHIR资源的数据质量是使医疗行业具有价值，保障医疗行为安全性的前提条件。因此，在构建基于FHIR存储的数据共享交换方案时，即使不得不保存不满足数据质量要求的数据，也应对其进行校验，标识不符合项，推动数据治理活动的进行，从而保障医疗安全和数据消费者的利益。  
在FHIR规范指出的多种数据校验方式中，FHIR Validator和[FHIR操作](https://hl7.org/fhir/R4/resource-operation-validate.html)对数据质量校验的覆盖最为全面。  
本例将使用InterSystems IRIS for Health所提供的`$`validate操作，通过profile参数对尚未保存的FHIR数据进行校验。使用者也可修改测试用例，构建HTTP POST参数，对存量FHIR资源进行校验。  
还应当注意的是，$validate操作如被正确调用，将通过Http 200返回校验结果，如有不符合项，将在返回的OperationOutcome资源中包裹错误信息，而不通过Http代码标识错误。

# 对FHIR的扩展
在本例中基于FHIR R4对Organization资源进行了如下扩展：
## 1. 修改language的绑定强度
将机构主要语言的绑定强度修改为required

## 2. active字段基数从0..1改为1..1
从而使得数据的状态成为必填字段，有且只有一个元素

## 3. name字段基数从0..1改为1..1
组织机构名称成为必填字段，有且只有一个元素。参考我国医院除医院名称外，如果具备急救中心、胸痛中心等牌照，还可能具有多个名称。但因注意到，这些牌照通常标识了医疗机构提供的服务能力，而非在组织机构注册系统中具备的法定名称，且此类牌照生命周期与医疗机构自身的生命周期并不一致。因此，从牌照获得的名称宜视为该医疗机构的服务能力而非机构的唯一名称。在FHIR中，通过服务能力获得的名称可通过资源HealthcareService提供，该资源与Organization资源间可建立多对一的引用关系，更适合用来表达上述概念。

## 4. 增加医疗机构的组织机构类型
根据中国国家标准GB/T 20091-2021 组织机构类型，分别增加了CodeSystem organizationtype-code-system和ValueSet organizationtype-vs，并通过Extension向Organization资源中添加了扩展mdm-organizationTypeExtension，从而使得该资源可用于表示表示标识中国组织机构类型。  
该扩展通过对Extension切片实现，且基数为1..1，即医疗机构资源必须具有组织机构类型元素。

## 5. 约束医疗机构证件号码
FHIR基础标准并未纳入中国组织机构统一社会信用代码的证件类型，为此增加了CodeSystem cs-identifierType-code-system，并对Identifier按其类型进行了切片，使之必须可以表达社会信用代码。且社会信用代码的格式遵循以下约束：
1. identifier.use必须取值为official，即正式/官方用途
2. identifier.type必须遵循cs-identifierType-code-system要求，system必须为该codesystem的uri，code必须为“USCC”
3. identifier.value必须遵循自定义约束uscc-length-18，该字段长度必须为18位，其中前17位必须为数字，最后1位必须为数字或字母


# 测试用例列表

## 1. Without profile - All OK
未声明资源对应的profile，因此FHIR Server将不对资源中各属性的值进行校验，仅返回All OK。

## 2. Unknow field
在资源中加入了未被定义的属性isNational，因此校验引擎返回了Unrecognized element错误。

## 3. Wrong cardinality - less
在本IG中，修改了Organization资源name属性的基数为1..1，即应有且仅有一个组织机构名称。本测试用例未填写名称，因此数据校验失败。
另外，可以观察到Identifier.type经过扩展，加入了统一社会信用代码作为标识符类型，FHIR R4规范里并不包含这个值，但该字段的代码绑定强度仅为example，不强制约束。因此校验引擎返回了information级的值域代码不符合信息而没有报错。

## 4. Binding strength
在本IG中，组织机构的language属性的代码绑定强度改为了required，则该字段值域必须符合http://hl7.org/fhir/ValueSet/languages，因此，当该字段取值为wrong language时，因不在required值域中，将导致error级错误

## 5. Wrong value
在本IG中，组织机构类型的值域来自于organizationtype-code-system，因此，当类型为mdm-organizationTypeExtension的extension元素中code的值为“999”，不在值域中时，将导致error级错误

## 6. Failing invariant
在本IG中，组织机构的社会信用代码必须遵循自定义约束uscc-length-18（该字段长度必须为18位，其中前17位必须为数字，最后1位必须为数字或字母），因此，当其末位为字符“%”时，违反该约束，将导致error级错误

## 7. Failing profile
对于一个资源定义的一个profile包含了多个约束，因此，在校验时所有不满足profile的问题都将被检出，例如本例中：
1. 错误的language代码
2. 错误的组织机构类型
3. 缺少name字段
可见上述问题都被检出
    