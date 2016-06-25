# SJAPIManager
基于 AFNetworking 封装的 iOS 网络库

本框架把每一个网络请求封装成对象。所以使用SJAPIManager，你的每一个请求都需要继承SJAPIBaseManager类，通过覆盖父类的一些方法来构造指定的网络请求。

本框架提供了以下功能
* 支持按时间, 登陆状态, 版本号缓存网络请求数据
* 支持检查返回的 JSON 是否合法
* 采用delegate方式回调  
* ...

具体使用如下: 
* 设置请求类型     - (SJAPIManagerRequestType)requestType , 
* 设置是否需要缓存(默认需要)     - (BOOL)shouldCache
* 如果需要在某些时刻清除特定缓存, 需实现     - (NSString *)cacheRegexKey 
* 设置url     - (NSString *)requestUrl , 
* 设置参数     - (NSDictionary *)paramsForAPI:(SJAPIBaseManager *)manager , 
* 设置请求头    - (NSDictionary *)headersForAPI:(SJAPIBaseManager *)manager
* 请求数据回调成功后, 可以在拦截器中-(void)beforePerformSuccessWithResponse:(SJAPIResponse *)response 中预处理, 供控制器使用
* 其他使用见源码

