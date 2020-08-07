# gt3-unity-example

## 工程目录说明

```
.
├── Assembly-CSharp-firstpass.csproj
├── Assembly-CSharp.csproj
├── Assets
│   ├── Plugins
│   │   ├── Android
│   │   │   ├── libs
│   │   │   │   ├── geetest_sensebot_android_v4.2.3_20191115.aar // 极验 Android SDK
│   │   │   │   ├── gt3_unity_android_v4.2.3_20200807.aar // 原生文件及桥接文件打包的输出文件。若有需求，可参考此文件此文件对极验 SDK 进行封装。
│   │   │   │   ├── okhttp-3.11.0.jar // 极验 Android SDK 依赖，网络库
│   │   │   │   ├── okio-1.17.3.jar   // 极验 Android SDK 依赖，网络库
│   │   │   │   └── tbs_sdk_thirdapp_v4.3.0.1072_43646_....jar // 极验sdk依赖的极验 Android SDK 依赖，webview内核库
│   │   │   ├── AndroidManifest.xml // Android 清单文件
│   │   │   ├── GT3AndroidUnityHandler.cs // Unity Android 调用 script
│   │   │   └── debug.keystore // 调试用签名文件
│   │   └── iOS
│   │       ├── GT3Captcha.bundle // 极验 iOS SDK bundle 文件
│   │       ├── GT3Captcha.framework // 极验 iOS SDK 文件
│   │       ├── GT3CaptchaUnityBridge.h // 桥文件 .h
│   │       ├── GT3CaptchaUnityBridge.m // 桥文件 .m
│   │       └── GT3iOSUnityHandler.cs // Unity iOS 调用 script
│   └── Scenes
│       ├── SampleSceneAndroid.unity // Android 示例的 scene 文件
│       └── SampleSceneiOS.unity // iOS 示例的 scene 文件
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
2. 参考 `GT3iOSUnityHandler.cs` 和 `SampleSceneiOS.unity` 关联 Unity 组件对象的事件，调用验证码模块。
3. 打开 `File - Build Settings`，并在平台中选择 iOS，场景中勾选 iOS 相应的场景。
4. 选择左下角的 `Player Settings - Other Settings`，确认 Xcode 工程相关的信息。真机使用 Device SDK，模拟器使用 Simulator SDK。
5. 选择 Build Settings 右下角的 Build 或 Build And Run，首次需要指定输出路径及文件夹名称。
6. 构建新的 Xcode 工程后，需要在项目的 **TARGETS - UnityFramework - Build Settings - Other Linker Flags** 中添加 `-ObjC`,  并在 **TARGETS - Unity-iPhone - Copy Bundle Resources** 添加 `GT3Captcha.bundle`。
7. 运行 Xcode 工程。

### 自定义封装说明

如需更一步的封装极验 iOS SDK，您可能需要仔细阅读下列资料:

* 桥文件 `GT3CaptchaUnityBridge.m`、C# 调用文件 `GT3iOSUnityHandler.cs` ，以更进一步了解极验 iOS SDK 的 Unity 封装。
* [极验 iOS 官方文档](https://docs.geetest.com/install/deploy/client/ios) 和 官方 Xcode Project示例，以了解极验 iOS SDK 的原生使用方式。

## Android 使用指南

### 集成说明

1. 集成极验 Android SDK 需要把 `Assets/Plugins/Android/` 下的 SDK 相关的文件 `geetest_sensebot_android_v4.1.7_20191115.aar`，SDK 相关的依赖文件 `okhttp-3.11.0.jar`、`okio-1.17.3.jar`、`tbs_sdk_thirdapp_v4.3.0.1072_43646_sharewithdownloadwithfile_withoutGame_obfs_20190429_175122.jar`，SDK 调用相关的桥文件 `gt3_unity_android_v4.2.3_20200807.aar`，C# 调用文件 `GT3AndroidUnityHandler.cs` 导入到工程中的 **Assets** 目录下。
2. 参考 `GT3AndroidUnityHandler.cs` 和 `SampleSceneAndroid.unity` 关联 Unity 组件对象的事件，调用验证码模块。
3. 打开 `File - Build Settings`，并在平台中选择 Android，场景中勾选 Android 相应的场景。
4. 选择左下角的 `Player Settings - Other Settings`，确认 Android 工程相关的信息。
5. 选择 Build Settings 右下角的 Build 或 Build And Run，首次需要指定输出路径及文件夹名称，运行结果将以apk包形式安装到手机。

### 自定义封装说明

如需更一步的封装极验 Android SDK，请阅读下面的指导步骤:

1. 创建一个新的 Android studio 工程，新建一个 module，[极验 Android 官方文档](https://docs.geetest.com/install/deploy/client/android)。
2. 必要的验证方法以及验证流程封装可参考 `Gt3Manager.java` 文件。
3. 完成自定义需求后，将 module 打包为新的 `gt3_unity_android_vx.x.x_xxxxxxxx.aar` 文件。
4. 在 unity 工程中替换此文件，按需求调用，重新编译打成 apk 包。

```java
public class Gt3Manager {
    private static final String TAG = Gt3Manager.class.getSimpleName();
    /**
     * 当前对象
     */
    private volatile static Gt3Manager gt3Manager;

    // api1，需替换成自己的服务器URL
    private String captchaURL;
    // api2，需替换成自己的服务器URL
    private String validateURL;
    private GT3ConfigBean gt3ConfigBean;
    private GT3GeetestUtils gt3GeetestUtils;
    private boolean outside;
    private int webviewTimeout;

    /**
     * 空构造方法
     */
    private Gt3Manager() {
    }

    /**
     * 初始化
     *
     * @return <>当前的对象</>
     */
    public static Gt3Manager with() {
        if (gt3Manager == null) {
            synchronized (Gt3Manager.class) {
                if (gt3Manager == null) {
                    gt3Manager = new Gt3Manager();
                }
            }
        }
        return gt3Manager;
    }

    public void log(String msg) {
        Log.d(TAG, "[Unity]" + msg);
    }

    public void toast(String msg) {
        toast(msg, true);
    }

    public void toast(String msg, final boolean longToast) {
        final String toastMsg = TextUtils.isEmpty(msg) ? "$null" : msg;
        UnityPlayer.currentActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(UnityPlayer.currentActivity.getApplicationContext(), toastMsg, longToast ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT).show();
            }
        });
    }

    /* JADX WARNING: type inference failed for: r1v0, types: [android.content.Context, com.geetest.geetest_unity.MainActivity] */
    public void initWithAPI(String api1, String api2) {
        captchaURL = api1;
        validateURL = api2;
        this.gt3GeetestUtils = new GT3GeetestUtils(UnityPlayer.currentActivity);
    }

    public void startGTCapcha(final PluginCallback callback) {
        UnityPlayer.currentActivity.runOnUiThread(new Runnable() {
            public void run() {
                verify(callback);
            }
        });
    }

    public void useGTViewWithTimeout(int timeout) {
        this.webviewTimeout = timeout;
    }

    public void disableBackgroundUserInteraction(boolean disableOutside) {
        this.outside = disableOutside;
    }

    public void verify(final PluginCallback callback) {
        this.gt3ConfigBean = new GT3ConfigBean();
        this.gt3ConfigBean.setPattern(1);
        this.gt3ConfigBean.setCanceledOnTouchOutside(this.outside);
        this.gt3ConfigBean.setLang((String) null);
        this.gt3ConfigBean.setTimeout(this.webviewTimeout);
        this.gt3ConfigBean.setWebviewTimeout(10000);
        this.gt3ConfigBean.setListener(new GT3Listener() {

            /**
             * 验证码加载完成
             * @param duration 加载时间和版本等信息，为json格式
             */
            @Override
            public void onDialogReady(String duration) {
                Log.e(TAG, "GT3BaseListener-->onDialogReady-->" + duration);
            }

            /**
             * 图形验证结果回调
             * @param code 1为正常 0为失败
             */
            @Override
            public void onReceiveCaptchaCode(int code) {
                Log.e(TAG, "GT3BaseListener-->onReceiveCaptchaCode-->" + code);
            }

            /**
             * 自定义api2回调
             * @param result，api2请求上传参数
             */
            @Override
            public void onDialogResult(String result) {
                Log.e(TAG, "GT3BaseListener-->onDialogResult-->" + result);
                new RequestAPI2().execute(new String[]{result});
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
                callback.gt3SuccessHandler(result);
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
                new RequestAPI1().execute();
            }
        });
        this.gt3GeetestUtils.init(this.gt3ConfigBean);
        this.gt3GeetestUtils.startCustomFlow();
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

    public void onConfigurationChanged() {
        // 横竖屏切换
        gt3GeetestUtils.changeDialogLayout();
    }
}
```