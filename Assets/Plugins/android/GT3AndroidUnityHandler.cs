using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


//验证集成示例，可如下直接通过jni调用aar包中方法
public class GT3AndroidUnityHandler : MonoBehaviour {

	// Use this for initialization
	void Start () {
        Button btn = this.GetComponent<Button> ();
        btn.onClick.AddListener (OnClick);
	}
	public void OnClick()
    {
        AndroidJavaClass jc = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
        AndroidJavaObject jo = jc.GetStatic<AndroidJavaObject>("currentActivity");
        //设置api1、api2地址
		jo.Call("initWithAPI","https://www.geetest.com/demo/gt/register-slide-voice","https://www.geetest.com/demo/gt/validate-slide-voice");
		//设置webview加载资源超时时间
        jo.Call("useGTViewWithTimeout",10000);
        //设置点击灰色区域是否消失，默认不显示
		jo.Call("disableBackgroundUserInteraction",false);
        //开始验证流程
		jo.Call("startGTCapcha", new PluginCallback());
        //销毁资源
        jo.Call("geetestDestroy");
    }
	
	class PluginCallback : AndroidJavaProxy
    {
        public PluginCallback() : base("com.geetest.geetest_unity.PluginCallback") { }

        public void gt3SuccessHandler(string success) {
            Debug.Log("ENTER callback onSuccess: " + success);
        }
        public void gt3ErrorHandler(string errorMessage)
        {
            Debug.Log("ENTER callback onFailed: " + errorMessage);
        }
    }

    // Update is called once per frame
    void Update () {
		
	}
}
