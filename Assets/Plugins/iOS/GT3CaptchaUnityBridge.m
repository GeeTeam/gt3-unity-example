//
//  GT3CaptchaUnityBridge.m
//  Unity-iPhone
//
//  Created by kidd wang on 2019/11/14.
//

#import "GT3CaptchaUnityBridge.h"
#import <GT3Captcha/GT3Captcha.h>

//#warning 配置以下参数
//#define DefaultRegisterAPI @"http://www.geetest.com/demo/gt/register-slide"
//#define DefaultValidateAPI @"http://www.geetest.com/demo/gt/validate-slide"
////C#中监听回调的类
//static const char * GT3HandlerName = "GT3Handler";

#define GT3UnityErrorCodeKey @"error_code"
#define GT3UnityMessageKey @"message"

#if defined(__cplusplus)
extern "C"{
#endif
    extern void __iOSGT3SDKInit(const char *api_1, const char *api_2);
    extern void __iOSStartCaptcha(const char *callBackObjectName, const char *rejectCallBackName, char *resolveCallBackName);
    extern void __iOSSetGTViewWithTimeout(double timeout);
    extern void __iOSDisableBackgroundUserInteraction(int disable);
    extern void __iOSEnableDebug(int enable);
    extern void __iOSCloseCaptchaView();
#if defined(__cplusplus)
}
#endif

@interface GT3CaptchaUnityBridge () <GT3CaptchaManagerDelegate, GT3CaptchaManagerViewDelegate>

@property (strong, nonatomic) GT3CaptchaManager *manager;

//回调对象监听的名字
@property (copy, nonatomic) NSString *callBackObjectName;
//行为验证SDK抛出错误的回调方法名
@property (copy, nonatomic) NSString *rejectCallBackName;
//收到验证结果的回调方法名
@property (copy, nonatomic) NSString *resolveCallBackName;


@end

static GT3CaptchaUnityBridge *mySDK = nil;

@implementation GT3CaptchaUnityBridge

// 以单例形式创建
+(instancetype)sharedBridge {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySDK = [[GT3CaptchaUnityBridge alloc] init];
    });
    return mySDK;
}

-(GT3CaptchaManager *)registerManagerWithApi1:(NSString *)api1 api2:(NSString *)api2 timout:(NSTimeInterval)timeout {
    if (!_manager) {
        _manager = [[GT3CaptchaManager alloc] initWithAPI1:api1 API2:api2 timeout:timeout];
        _manager.delegate = self;
        _manager.viewDelegate = self;
        [_manager setMaskColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
        [_manager registerCaptcha:^{
            //注册完成
        }];
    }
    return _manager;
}

//开始验证
-(void)startCaptcha {
    [self.manager startGTCaptchaWithAnimated:YES];
}

#pragma mark -- iOS to Unity   iOS调用Unity方法

+ (void)sendU3dMessage:(NSString *)messageName withParam:(NSDictionary *)dict {
    NSString *param = @"";
    if ( nil != dict ) {
        for (NSString *key in dict) {
            if ([param length] == 0) {
                param = [param stringByAppendingFormat:@"%@=%@", key, [dict valueForKey:key]];
            }
            else {
                param = [param stringByAppendingFormat:@"&%@=%@", key, [dict valueForKey:key]];
            }
        }
    }
    UnitySendMessage([mySDK.callBackObjectName UTF8String], [messageName UTF8String], [param UTF8String]);
}

#pragma mark -- GT3CaptchaManagerViewDelegate
- (void)gtCaptchaWillShowGTView:(GT3CaptchaManager *)manager {
    // TO-DO
    // 图形验证将要展示的时候，会通过该入口进行通知
}

#pragma mark -- GT3CaptchaManagerDelegate
// 以下两个回调是验证过程中所必须的，其他例如修改api1/api2请求，或不使用默认api1/api2请求等可选回调，依据项目业务需求实现，具体可参考极验行为验证demo
// 收到验证结果的回调
- (void)gtCaptcha:(GT3CaptchaManager *)manager didReceiveSecondaryCaptchaData:(NSData *)data response:(NSURLResponse *)response error:(GT3Error *)error decisionHandler:(void (^)(GT3SecondaryCaptchaPolicy))decisionHandler {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (!error) {
        //二次验证通过
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        decisionHandler(GT3SecondaryCaptchaPolicyAllow);
        
        if (self.rejectCallBackName && dataStr) {
            UnitySendMessage([mySDK.callBackObjectName UTF8String], [self.rejectCallBackName UTF8String], [dataStr UTF8String]);
        }
    }
    else {
        //二次验证发生错误
        decisionHandler(GT3SecondaryCaptchaPolicyForbidden);
        [dic setValue:error.error_code forKey:@"error_code"];
        [dic setValue:error.gtDescription forKey:@"gtDescription"];
        
        if (self.resolveCallBackName) {
            [GT3CaptchaUnityBridge sendU3dMessage:self.resolveCallBackName withParam:dic];
        }
    }
}

// 内部抛出错误的回调
- (void)gtCaptcha:(GT3CaptchaManager *)manager errorHandler:(GT3Error *)error {
    //处理验证中返回的错误
    if (error.code == -999) {
        // 请求被意外中断, 一般由用户进行取消操作导致, 可忽略错误
    }
    else if (error.code == -10) {
        // 预判断时被封禁, 不会再进行图形验证
    }
    else if (error.code == -20) {
        // 尝试过多
    }
    else {
        // 网络问题或解析失败, 更多错误码参考开发文档
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:error.error_code     forKey:GT3UnityErrorCodeKey];
    [dict setValue:error.gtDescription  forKey:GT3UnityMessageKey];
    
    if (self.rejectCallBackName) {
        [GT3CaptchaUnityBridge sendU3dMessage:self.rejectCallBackName withParam:dict];
    }
}


#if defined(__cplusplus)
extern "C"{
#endif
    
#pragma mark -- Func for Unity   供u3d调用的c函数
    
    //初始化
    void __iOSGT3SDKInit(const char *api_1, const char *api_2) {
        [[GT3CaptchaUnityBridge sharedBridge] registerManagerWithApi1:[NSString stringWithUTF8String:api_1] api2:[NSString stringWithUTF8String:api_2] timout:5.0]; // default timeout 5.0s
    }
    
    //开启验证
    void __iOSStartCaptcha(const char *callBackObjectName, const char *rejectCallBackName, char *resolveCallBackName) {
        if(mySDK == NULL || mySDK == nil) {
//            __iOSGT3SDKInit();
            return;
        }
        mySDK.callBackObjectName = [NSString stringWithUTF8String:callBackObjectName];
        mySDK.rejectCallBackName = [NSString stringWithUTF8String:rejectCallBackName];
        mySDK.resolveCallBackName = [NSString stringWithUTF8String:resolveCallBackName];
        [mySDK startCaptcha];
    }
    
    //设置图形验证超时的时长
    void __iOSSetGTViewWithTimeout(double timeout) {
        NSTimeInterval realTimeout = timeout/1000;
        [mySDK.manager useGTViewWithTimeout:realTimeout];
    }
    
    //验证背景交互事件的开关
    void __iOSDisableBackgroundUserInteraction(int disable) {
        [mySDK.manager disableBackgroundUserInteraction:disable];
    }
    
    //开启debugMode,在开启验证之前调用此方法
    void __iOSEnableDebug(int enable) {
        [mySDK.manager enableDebugMode:enable];
    }
    
    //关闭验证界面
    void __iOSCloseCaptchaView() {
        [mySDK.manager closeGTViewIfIsOpen];
    }
    
#if defined(__cplusplus)
}
#endif

@end
