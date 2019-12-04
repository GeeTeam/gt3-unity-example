# gt3-unity-example

## 工程目录说明

```
.
├── Assembly-CSharp-firstpass.csproj
├── Assembly-CSharp.csproj
├── Assets
│   ├── Plugins
│   │   ├── Android
│   │   │   ├── AndroidManifest.xml // Android 清单文件
│   │   │   ├── GT3AndroidUnityHandler.cs // Unity Android 调用 script
│   │   │   ├── geetest_sensebot_android_v4.1.7_20191115.aar // 极验 Android SDK
│   │   │   ├── geetest_unity-release.aar // 原生文件及桥接文件打包的输出文件。若有需求，可参考此文件此文件对极验 SDK 进行封装。
│   │   │   ├── okhttp-3.11.0.jar // 极验 Android SDK 依赖，网络库
│   │   │   ├── okio-1.17.3.jar // 极验 Android SDK 依赖，网络库
│   │   │   └── tbs_sdk_thirdapp_v4.3.0.1072_43646_....jar // 极验sdk依赖的极验 Android SDK 依赖，webview内核库
│   │   └── iOS
│   │       ├── GT3Captcha.bundle // 极验 iOS SDK bundle 文件
│   │       ├── GT3Captcha.framework // 极验 iOS SDK 文件
│   │       ├── GT3CaptchaUnityBridge.h // 桥文件 .h
│   │       ├── GT3CaptchaUnityBridge.m // 桥文件 .m
│   │       └── GT3iOSUnityHandler.cs // Unity iOS 调用 script
│   └── Scenes
│       └── SampleScene.unity // 示例的 scene 文件
├── Builds // 输出文件夹
├── GT3CaptchaUnityExample.sln
├── Library
├── Logs
├── Packages
├── ProjectSettings
├── README.md
├── Temp
├── UserSettings
└── obj
```

## iOS 使用指南

### 集成说明

1. 集成极验 iOS SDK 需要把 `Assets/Plugins/iOS/` 下的 SDK 相关的文件 `GT3Captcha.framework`、`GT3Captcha.bundle`，SDK 调用相关的桥文件 `GT3CaptchaUnityBridge.h`、`GT3CaptchaUnityBridge.m` ，C# 调用文件 `GT3iOSUnityHandler.cs` 导入到工程中的 **Assets** 目录下。
2. 参考 `GT3iOSUnityHandler.cs`  关联 Unity 组件对象的事件，调用验证码模块。
3. 打开 `File - Build Settings`，并选择 iOS 平台。
4. 选择左下角的 `Player Settings - Other Settings`，确认 Xcode 工程相关的信息。真机使用 Device SDK，模拟器使用 Simulator SDK。
5. 选择 Build Settings 右下角的 Build 或 Build And Run，首次需要指定输出路径及文件夹名称。

### 自定义封装说明

如需更一步的封装极验 iOS SDK，您可能需要仔细阅读下列资料:

* 桥文件 `GT3CaptchaUnityBridge.m`、C# 调用文件 `GT3iOSUnityHandler.cs` ，以更进一步了解极验 iOS SDK 的 Unity 封装。
* [极验 iOS 官方接入文档](https://docs.geetest.com/install/deploy/client/ios) 和 官方 Xcode Project示例，以了解极验 iOS SDK 的原生使用方式。

## Android 使用指南

### 集成说明

1. 集成极验 Android SDK 需要把 `Assets/Plugins/Android/` 下的 SDK 相关的文件 `geetest_sensebot_android_v4.1.7_20191115.aar`，SDK 相关的依赖文件 `okhttp-3.11.0.jar`、`okio-1.17.3.jar`、`tbs_sdk_thirdapp_v4.3.0.1072_43646_sharewithdownloadwithfile_withoutGame_obfs_20190429_175122.jar`，SDK 调用相关的桥文件 `geetest_unity-release.aar`，C# 调用文件 `GT3AndroidUnityHandler.cs` 导入到工程中的 **Assets** 目录下。
2. 参考 `GT3AndroidUnityHandler.cs`  关联 Unity 组件对象的事件，调用验证码模块。
3. 打开 `File - Build Settings`，并选择 Android 平台。
4. 选择 Build Settings 右下角的 Build 或 Build And Run，首次需要指定输出路径及文件夹名称。

### 自定义封装说明

如需更一步的封装极验 Android SDK，请阅读下面的指导步骤:

1. 创建一个新的 Android studio 工程，新建一个 module，集成极验 SDK ，集成方式可参考[极验 Android 官方接入文档](https://docs.geetest.com/install/deploy/client/android)。
2. 必要的验证方法以及验证流程封装可参考 `MainActivity.java` 文件。 
3. 完成自定义需求后，将 module 打包为新的 `geetest_unity-release.aar` 文件。
4. 在 unity 工程中替换此文件，按需求调用，重新编译打成 apk 包。

```java
public class MainActivity extends UnityPlayerActivity {

    private int webviewTimeout;
    private boolean outside;

    private static final String TAG = MainActivity.class.getSimpleName();

    // api1，需替换成自己的服务器URL
    private static String captchaURL ;
    // api2，需替换成自己的服务器URL
    private static String validateURL ;

    private GT3GeetestUtils gt3GeetestUtils;
    private GT3ConfigBean gt3ConfigBean;

    public void initWithAPI(String api1, String api2){
        captchaURL = api1;
        validateURL = api2;
        gt3GeetestUtils = new GT3GeetestUtils(this);
    }

    public void startGTCapcha(final PluginCallback callback){
        UnityPlayer.currentActivity.runOnUiThread(new Runnable()
        {
            public void run()
            {
               verify(callback);
            }
        });
    }

    public void useGTViewWithTimeout(int timeout){
        this.webviewTimeout = timeout;
    }

    public void disableBackgroundUserInteraction(boolean disableOutside){
        this.outside = disableOutside;
    }

    public void verify(final PluginCallback callback) {
        // 配置bean文件，也可在oncreate初始化
        gt3ConfigBean = new GT3ConfigBean();
        // 设置验证模式，1：bind，2：unbind
        gt3ConfigBean.setPattern(1);
        // 设置点击灰色区域是否消失，默认不消息
        gt3ConfigBean.setCanceledOnTouchOutside(outside);
        // 设置语言，如果为null则使用系统默认语言
        gt3ConfigBean.setLang(null);
        // 设置webview加载超时
        gt3ConfigBean.setTimeout(webviewTimeout);
        // 设置webview请求超时
        gt3ConfigBean.setWebviewTimeout(10000);
        // 设置回调监听
        gt3ConfigBean.setListener(new GT3Listener() {

            /**
             * api1结果回调
             * @param result
             */
            @Override
            public void onApi1Result(String result) {
                Log.e(TAG, "GT3BaseListener-->onApi1Result-->" + result);
            }

            /**
             * 验证码加载完成
             * @param duration 加载时间和版本等信息，为json格式
             */
            @Override
            public void onDialogReady(String duration) {
                Log.e(TAG, "GT3BaseListener-->onDialogReady-->" + duration);
            }

            /**
             * 验证结果
             * @param result
             */
            @Override
            public void onDialogResult(String result) {
                Log.e(TAG, "GT3BaseListener-->onDialogResult-->" + result);
                // 开启自定义api2逻辑
                new MainActivity.RequestAPI2().execute(result);
            }

            /**
             * api2回调
             * @param result
             */
            @Override
            public void onApi2Result(String result) {
                Log.e(TAG, "GT3BaseListener-->onApi2Result-->" + result);
            }

            /**
             * 统计信息，参考接入文档
             * @param result
             */
            @Override
            public void onStatistics(String result) {
                Log.e(TAG, "GT3BaseListener-->onStatistics-->" + result);
            }

            /**
             * 验证码被关闭
             * @param num 1 点击验证码的关闭按钮来关闭验证码, 2 点击屏幕关闭验证码, 3 点击返回键关闭验证码
             */
            @Override
            public void onClosed(int num) {
                Log.e(TAG, "GT3BaseListener-->onClosed-->" + num);
            }

            /**
             * 验证成功回调
             * @param result
             */
            @Override
            public void onSuccess(String result) {
                Log.e(TAG, "GT3BaseListener-->onSuccess-->" + result);
                callback.gt3SuccessHandler("success");
            }

            /**
             * 验证失败回调
             * @param errorBean 版本号，错误码，错误描述等信息
             */
            @Override
            public void onFailed(GT3ErrorBean errorBean) {
                Log.e(TAG, "GT3BaseListener-->onFailed-->" + errorBean.toString());
                callback.gt3ErrorHandler(errorBean.toString());
            }

            /**
             * 自定义api1回调
             */
            @Override
            public void onButtonClick() {
                new MainActivity.RequestAPI1().execute();
            }
        });
        gt3GeetestUtils.init(gt3ConfigBean);
        // 开启自定义验证
        gt3GeetestUtils.startCustomFlow();
    }

    /**
     * 请求api1
     */
    class RequestAPI1 extends AsyncTask<Void, Void, JSONObject> {

        @Override
        protected JSONObject doInBackground(Void... params) {
            String string = HttpUtils.requestGet(captchaURL + "?t=" + System.currentTimeMillis());
            Log.e(TAG, "doInBackground: " + string);
            JSONObject jsonObject = null;
            try {
                jsonObject = new JSONObject(string);
            } catch (Exception e) {
                e.printStackTrace();
            }
            return jsonObject;
        }

        @Override
        protected void onPostExecute(JSONObject parmas) {
            // 继续验证
            Log.i(TAG, "RequestAPI1-->onPostExecute: " + parmas);
            // SDK可识别格式为
            // {"success":1,"challenge":"06fbb267def3c3c9530d62aa2d56d018","gt":"019924a82c70bb123aae90d483087f94","new_captcha":true}
            // TODO 设置返回api1数据，即使为null也要设置，SDK内部已处理
            gt3ConfigBean.setApi1Json(parmas);
            // 继续api验证
            gt3GeetestUtils.getGeetest();
        }
    }

    /**
     * 请求api2
     */
    class RequestAPI2 extends AsyncTask<String, Void, String> {

        @Override
        protected String doInBackground(String... params) {
            if (!TextUtils.isEmpty(params[0])) {
                return HttpUtils.requestPost(validateURL+ "?t=" + System.currentTimeMillis(), params[0]);
            } else {
                return null;
            }
        }

        @Override
        protected void onPostExecute(String result) {
            Log.i(TAG, "RequestAPI2-->onPostExecute: " + result);
            if (!TextUtils.isEmpty(result)) {
                try {
                    JSONObject jsonObject = new JSONObject(result);
                    String status = jsonObject.getString("status");
                    if ("success".equals(status)) {
                        gt3GeetestUtils.showSuccessDialog();
                    } else {
                        gt3GeetestUtils.showFailedDialog();
                    }
                } catch (Exception e) {
                    gt3GeetestUtils.showFailedDialog();
                    e.printStackTrace();
                }
            } else {
                gt3GeetestUtils.showFailedDialog();
            }
        }
    }

    public void userCloseCaptchaView() {
        gt3GeetestUtils.dismissGeetestDialog();
    }

    public void geetestDestroy(){
        gt3GeetestUtils.destory();
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
        // TODO 销毁资源，务必添加
        gt3GeetestUtils.destory();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        // 横竖屏切换
        gt3GeetestUtils.changeDialogLayout();
    }
}
```