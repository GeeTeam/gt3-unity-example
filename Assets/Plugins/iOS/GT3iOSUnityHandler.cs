﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.InteropServices;

public class GT3iOSUnityHandler : MonoBehaviour
{

    //导入定义到.m文件中的C函数
    [DllImport("__Internal")]
    private static extern void __iOSGT3SDKInit(string api_1, string api_2);
    [DllImport("__Internal")]
    private static extern void __iOSStartCaptcha(string callBackObjectName, string rejectCallBackName, string resolveCallBackName);
    [DllImport("__Internal")]
    private static extern void __iOSSetGTViewWithTimeout(double timeout);
    [DllImport("__Internal")]
    private static extern void __iOSDisableBackgroundUserInteraction(bool disable);
    [DllImport("__Internal")]
    private static extern void __iOSEnableDebug(bool enable);
    [DllImport("__Internal")]
    private static extern void __iOSCloseCaptchaView();

    // Start is called before the first frame update
    void Start()
    {
        __iOSGT3SDKInit("http://www.geetest.com/demo/gt/register-slide", "http://www.geetest.com/demo/gt/validate-slide");
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void click() // 提供给 unity 对象触发验证的方法
    {
        //参数一：回调监听的对象
        //参数二：gt3产生错误的回调方法名
        //参数三：gt3收到验证结果的回调方法名
        __iOSStartCaptcha("GT3Handler", "gt3ErrorHandler", "gt3SuccessHandler");
    }

    // 处理错误的回调函数
    void gt3ErrorHandler(string str)
    {
        // TO-DO: 错误处理
        // str 的格式为 {"code": -1001, "error_code":"-100103","message":""}
        print("\nError: \n");
        print(str);
        print("\n");
    }

    // 处理成功数据的回调函数
    void gt3SuccessHandler(string str)
    {
        // TO-DO: 成功处理
        // str 为 api2 返回的数据
        print("\nSuccess: \n");
        print(str);
        print("\n");
    }
}
