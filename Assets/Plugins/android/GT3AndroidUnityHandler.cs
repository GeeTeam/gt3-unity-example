using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


/// <summary>
/// 验证码集成示例，参考以下示例通过 jni 调用 aar 包中方法
/// An example of captcha integration can be shown below by calling the methods in the AAR package directly from JNI
/// </summary>
public class GT3AndroidUnityHandler : MonoBehaviour
{

    private AndroidJavaClass jc;
    private AndroidJavaObject jo;
    private Button button;

    // Use this for initialization
    void Start()
    {
        // SDK 原生插件管理类
        // SDK Native plugin management classes
        jc = new AndroidJavaClass("com.geetest.sdk.Gt3Manager");
        // SDK 原生插件管理对象
        // SDK Native plugin management instance
        jo = jc.CallStatic<AndroidJavaObject>("with", new object[0]);
    }

    /// <summary>
    ///  插件 SDK 提供的日志打印方法，输出到 Android logcat，仅供调试使用
    ///  The logcat printing method provided by plugin SDK, output to Android Logcat, for debugging only
    /// </summary>
    /// <param name="msg">要打印的日志/The message to output</param>
    public void log(string msg)
    {
        jo.Call("log", msg);
    }

    /// <summary>
    /// 插件 SDK 提供的 Toast 信息提示方法，仅供调试使用
    /// The toast method provided by plugin SDK, show with Android Toast, for debugging only
    /// </summary>
    /// <param name="msg">要弹出的信息/The message to toast</param>
    public void toast(string msg)
    {
        jo.Call("toast", msg, true);// true:Toast.LENGTH_LONG false:Toast.LENGTH_SHORT
    }

    public void OnClick()
    {
        Debug.Log("OnClick");
        //设置api1、api2地址
        //Set the API1, API2 addresses
        jo.Call("initWithAPI", "https://www.geetest.com/demo/gt/register-slide-voice", "https://www.geetest.com/demo/gt/validate-slide-voice");
        //设置webview加载资源的超时时间
        //Set the timeout for the WebView load resource
        jo.Call("useGTViewWithTimeout", 10000);
        //设置点击灰色区域是否消失，默认不显示
        //Sets whether the control disappears by clicking on the gray area of the control, don't disappear as default
        jo.Call("disableBackgroundUserInteraction", false);
        //开始验证流程
        //Start the validation process
        jo.Call("startGTCapcha", new PluginCallback());
        //销毁资源
        //Destroy resources
        jo.Call("geetestDestroy");
    }

    class PluginCallback : AndroidJavaProxy
    {
        public PluginCallback() : base("com.geetest.sdk.PluginCallback") { }

        public void gt3SuccessHandler(string success)
        {
            Debug.Log("ENTER callback onSuccess: " + success);
        }
        public void gt3ErrorHandler(string errorMessage)
        {
            Debug.Log("ENTER callback onFailed: " + errorMessage);
        }
    }

    // Update is called once per frame
    void Update()
    {

    }
}
