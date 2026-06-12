# Flutter三方库适配指导文档

## 仓库介绍

该仓库基于https://github.com/fluttercommunity/plus_plugins适配OpenHarmony，以package_info_plus-v4.2.0为例。

### 一、安卓平台查看效果

首先，我们需要将三方库中example的安卓样例运行起来，以package_info_plus为例，可以看到，此插件是用来获取应用包的相关信息的。

![image-20240124104027229](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/img_storage/%E5%AE%89%E5%8D%93%E6%95%88%E6%9E%9C.png)

​

### 二、OpenHarmony适配三方插件

#### 1、添加ohos模块

在三方插件（package_info_plus为例）中添加ohos模块，可直接复制此模块，ohos模块结构如下，与android和ios在同一级下。

![添加ohos模块](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/img_storage/%E6%B7%BB%E5%8A%A0ohos%E6%A8%A1%E5%9D%97.png)

#### 2、三方插件目录结构参考

插件目录结构可以参考安卓，写在ohos下面的`src > main > ets`下。

![代码结构](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/img_storage/%E7%9B%AE%E5%BD%95%E7%BB%93%E6%9E%84%E5%AF%B9%E6%AF%94.png)

#### 3、代码适配

代码参考安卓代码逻辑，转化为**arkts**代码，ohos的api可以参考https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/reference/apis/development-intro.md/

#### 4、配置文件修改

1.build-profile.json5

路径：`file:/package_info_plus/package_info_plus/ohos/build-profile.json5`

```
{
  "app": {
    "signingConfigs": [],
    "products": [
      {
        "name": "default",
        "signingConfig": "default",
        "compileSdkVersion": "4.1.0(11)",        // 以api11为例
        "compatibleSdkVersion": "4.1.0(11)",
        "runtimeOS": "HarmonyOS",
      }
    ],
    "buildModeSet": [
      {
        "name": "debug",
      },
      {
        "name": "release"
      }
    ]
  },
  "modules": [
    {
      "name": "packageInfoPlus",
      "srcPath": "./packageInfoPlus"
    }
  ]
}
```

2.index.ets

路径：`file://package_info_plus/package_info_plus/ohos/packageInfoPlus/index.ets`

说明：将三方插件PackageInfoPlugin导出。

```
import {PackageInfoPlugin} from './src/main/ets/dev/fluttercommunity/plus/packageinfo/PackageInfoPlugin';
export default PackageInfoPlugin;
```

3.module.json5

路径：`file://package_info_plus/package_info_plus/ohos/packageInfoPlus/src/main/module.json5`

说明：包名和打包类型。

```
{
  "module": {
    "name": "packageInfoPlus",
    "type": "har",
    "deviceTypes": [
      "default",
    ]
  }
}
```

#### 5、打har包

写完代码，改完配置文件后，即可打har包：

打包工具：DevEco Studio

打包步骤：1、鼠标定位到packageInfoPlus目录；2、点击DevEco Studio中的Build；3、点击Make Module 'packageInfoPlus'选项；4、等待打包完成。

![打har包 ](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/img_storage/%E6%89%93har%E5%8C%85%20.png)

预期结果：

在`packageInfoPlus > build > outputs > default`中有packageInfoPlus.har生成，即为打har包成功。

![打har包成功 ](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/img_storage/%E6%89%93har%E5%8C%85%E6%88%90%E5%8A%9F.png)



### 三、example中添加ohos平台使用样例

需要在examples目录下添加ohos平台使用样例

#### 1、修改pubspec.yaml文件

有两处pubspec.yaml文件文件需要修改；

**修改路径1：**`file:/package_info_plus/package_info_plus/pubspec.yaml`

```
//在flutter.plugin.platforms下添加ohos模块
flutter:
  plugin:
    platforms:
      ohos:
        package: dev.fluttercommunity.plus.packageinfo
        pluginClass: PackageInfoPlugin
```

![修改pubspec1.yaml](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/img_storage/%E4%BF%AE%E6%94%B9pubspec1.yaml.png)

**修改路径2：**`file:/package_info_plus/package_info_plus/example/pubspec.yaml`

```
// 将dependencies下的package_info_plus：修改为path: ../，目的是引用本地插件
dependencies:
  flutter:
    sdk: flutter
  http: ">=0.13.5 <2.0.0"
  package_info_plus:
    path: ../
```

![修改pubspec2.yaml](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/img_storage/%E4%BF%AE%E6%94%B9pubspec2.yaml.png)

#### 2、在example中添加ohos模块

在example目录下，通过命令`flutter create --platforms ohos .` ，添加ohos模块，生成代码如下图所示：

![example中的ohos](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/img_storage/example%E4%B8%AD%E7%9A%84ohos.png)







### 四、打包验证

#### 1、签名

用 `Deveco Studio` 打开三方库的 `example > ohos` 目录；

单击 `File > Project Structure > Project > Signing Configs` 界面勾选 `Automatically generate signature`，等待自动签名完成即可，单击 `OK`；

你也可以使用 [签名工具](https://gitcode.com/openharmony/developtools_hapsigner) 签名，可参考https://gitcode.com/CPF-Flutter/flutter_flutter中的环境配置中第四步，配置签名。

![image-20240122151304602](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/img_storage/%E7%AD%BE%E5%90%8D.png)

#### 2、运行

cd到`example > ohos`目录，使用下列指令运行

```
flutter run --local-engine=<flutter_engine out path>
```

**运行成功效果如下：**

![效果](https://gitcode.com/CPF-Flutter/flutter_plus_plugins/blob/master/img_storage/%E6%95%88%E6%9E%9C.png)
