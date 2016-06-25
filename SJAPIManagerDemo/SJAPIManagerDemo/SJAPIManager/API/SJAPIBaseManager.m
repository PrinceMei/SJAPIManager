//
//  SJAPIBaseManager.m
//  SJFramework
//
//  Created by Sharejoy on 15/6/12.
//  Copyright (c) 2015年 sharejoy. All rights reserved.
//


#import "SJCache.h"
#import "SJAPIBaseManager.h"
#import "AFNetworkReachabilityManager.h"
#import "SJApiProxy.h"
#import "NSString+SJExtension.h"
#import "MBProgressHUD+MJ.h"

#define AXCallAPI(REQUEST_METHOD, REQUEST_ID)                                                       \
{                                                                                       \
REQUEST_ID = [[SJApiProxy sharedInstance] call##REQUEST_METHOD##WithParams:apiParams url:self.child.requestUrl headers:headers methodName:self.getMethodName success:^(SJAPIResponse *response) { \
[self successedOnCallingAPI:response];                                          \
} fail:^(SJAPIResponse *response) {                                                \
[self failedOnCallingAPI:response withErrorType:SJAPIManagerErrorTypeDefault];  \
}];                                                                                 \
[self.requestIdList addObject:@(REQUEST_ID)];                                          \
}

#define AXUploadAPI(REQUEST_METHOD, REQUEST_ID)                                                       \
{                                                                                       \
REQUEST_ID = [[SJApiProxy sharedInstance] call##REQUEST_METHOD##WithParams:apiParams url:self.child.requestUrl headers:headers uploads:uploads methodName:self.getMethodName success:^(SJAPIResponse *response) { \
[self successedOnCallingAPI:response];                                          \
} fail:^(SJAPIResponse *response) {                                                \
[self failedOnCallingAPI:response withErrorType:SJAPIManagerErrorTypeDefault];  \
}];                                                                                 \
[self.requestIdList addObject:@(REQUEST_ID)];                                          \
}

@interface SJAPIBaseManager ()
//{
//    int page;//记录页码值
//    int pageSize;//每页条数
//    NSInteger total;//记录总条数
//    
//}
//未加工的Data
@property (nonatomic, strong, readwrite) id fetchedRawData;

@property (nonatomic, copy, readwrite) NSString *errorMessage;
@property (nonatomic, readwrite) SJAPIManagerErrorType errorType;
@property (nonatomic, strong) NSMutableArray *requestIdList;
@property (nonatomic, strong) SJCache *cache;


@end


@implementation SJAPIBaseManager

#pragma mark - getters and setters
- (SJCache *)cache
{
    if (_cache == nil) {
        _cache = [SJCache sharedInstance];
    }
    return _cache;
}

- (NSMutableArray *)requestIdList
{
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableArray alloc] init];
    }
    return _requestIdList;
}
- (BOOL)isReachable
{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

- (BOOL)isLoading
{
    return [self.requestIdList count] > 0;
}

#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegate = nil;
        _validator = nil;
        _paramSource = nil;
        
        _fetchedRawData = nil;
        
        _errorMessage = nil;
        _errorType = SJAPIManagerErrorTypeDefault;
        
        if ([self conformsToProtocol:@protocol(SJAPIManager)]) {
            self.child = (id <SJAPIManager>)self;
        }
    }
    return self;
}

- (void)dealloc
{
    [self cancelAllRequests];
    self.requestIdList = nil;
}

#pragma mark - public methods
- (void)cancelAllRequests
{
    [[SJApiProxy sharedInstance] cancelRequestWithRequestIDList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}


- (void)cancelRequestWithRequestId:(NSInteger)requestID
{
    [self removeRequestIdWithRequestID:requestID];
    [[SJApiProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
}

- (id)fetchDataWithAdaptor:(id<SJAPIManagerCallBackDataAdaptor>)reformer
{
    id resultData = nil;
    if ([reformer respondsToSelector:@selector(manager:adaptorData:)]) {
        resultData = [reformer manager:self adaptorData:self.fetchedRawData];
    } else {
        resultData = [self.fetchedRawData mutableCopy];
    }
    return resultData;
}

#pragma mark - calling api
- (NSInteger)loadData
{
    NSDictionary *params = [self.paramSource paramsForAPI:self];
    NSDictionary *headers = [self.headerSource headersForAPI:self];
    NSDictionary *uploads = [self.uploadsSource uploadsForAPI:self];
    NSInteger requestId = [self loadDataWithParams:params headers:headers uploads:uploads];
    return requestId;
}


-(void)invalidCache
{
    NSString *methodName = [self getMethodName];
    [self.cache deleteCacheWithMethodName:methodName];
}

- (NSInteger)loadDataWithParams:(NSDictionary *)params headers:(NSDictionary*)headers uploads:(NSDictionary*) uploads
{
    NSInteger requestId = 0;
    NSDictionary *apiParams = [self reformParams:params];
    
    
    if ([self shouldCallAPIWithParams:apiParams]) {       //没有使用过, 都返回YES了, 根据参数判断是否允许发出
        if ([self isCorrectWithParamsData:apiParams]) {    //没有使用过, 都返回YES了, 判断参数是否正确
            
            // 先检查一下是否有缓存
            if (self.child.requestType == SJAPIManagerRequestTypeGet && [self shouldCache] && [self hasCacheWithParams:apiParams]) {  //需要缓存并且有缓存
                
                
                NSLog(@"%@ : 这次请求用的是缓存", NSStringFromClass([self.child class]) );
                
                return 0;
            }
            
            // 实际的网络请求
            if ([self isReachable]) {              // 有网络
                switch (self.child.requestType)    // get/post/upload
                {
                    case SJAPIManagerRequestTypeGet:
                    {
                        NSLog(@"%@",self.child.requestUrl);
                        requestId = [[SJApiProxy sharedInstance] callGETWithParams:apiParams url:self.child.requestUrl headers:headers methodName:self.getMethodName success:^(SJAPIResponse *response) {
                            
                            [self successedOnCallingAPI:response];
                            
                        } fail:^(SJAPIResponse *response) {
                            
                            [self failedOnCallingAPI:response withErrorType:SJAPIManagerErrorTypeDefault];
                            
                        }];
                        
                        [self.requestIdList addObject:@(requestId)];
                    }
                        //                        AXCallAPI(GET, requestId);
                        break;
                        
                    case SJAPIManagerRequestTypePost:
                    {
                        requestId = [[SJApiProxy sharedInstance] callPOSTWithParams:apiParams url:self.child.requestUrl headers:headers methodName:self.getMethodName success:^(SJAPIResponse *response) {
                            
                            [self successedOnCallingAPI:response];
                            
                        } fail:^(SJAPIResponse *response) {
                            
                            [self failedOnCallingAPI:response withErrorType:SJAPIManagerErrorTypeDefault];
                            
                        }];
                        
                        [self.requestIdList addObject:@(requestId)];
                    }
                        //                        AXCallAPI(POST, requestId);
                        break;
                        
                    case SJAPIManagerRequestTypeUpload:
                        AXUploadAPI(UPLOAD, requestId);
                        break;
                    default:
                        break;
                }
                
                NSMutableDictionary *params = [apiParams mutableCopy];
                params[kSJAPIRequestId] = @(requestId);
                [self afterCallingAPIWithParams:params];
                return requestId;
                
            } else {
                [self failedOnCallingAPI:nil withErrorType:SJAPIManagerErrorTypeNoNetWork];//网络故障,没网
                return requestId;
            }
        } else {
            [self failedOnCallingAPI:nil withErrorType:SJAPIManagerErrorTypeParamsError];
            return requestId;
        }
    }
    return requestId;
}

#pragma mark - api callbacks

//- (void)apiCallBack:(SJAPIResponse *)response
//{
//    if (response.status == SJSURLResponseStatusSuccess) {
//        [self successedOnCallingAPI:response];
//    }else{
//        [self failedOnCallingAPI:response withErrorType:SJAPIManagerErrorTypeTimeout];
//    }
//}

- (void)successedOnCallingAPI:(SJAPIResponse *)response
{
    if (response.content) {
        self.fetchedRawData = [response.content copy];
    } else {
        self.fetchedRawData = [response.responseData copy];
    }
    [self removeRequestIdWithRequestID:response.requestId];
    if ([self isCorrectWithResponseData:response.content]) {
        
        if (self.child.requestType == SJAPIManagerRequestTypeGet && [self shouldCache] && !response.isCache) {
            [self.cache saveCacheWithData:response.responseData methodName:[self getMethodName] requestParams:response.requestParams];
        }

        [self beforePerformSuccessWithResponse:response];
        [self.delegate managerCallAPIDidSuccess:self];
        [self afterPerformSuccessWithResponse:response];
    } else {
        [self failedOnCallingAPI:response withErrorType:SJAPIManagerErrorTypeErrorContent];
    }
}

- (void)failedOnCallingAPI:(SJAPIResponse *)response withErrorType:(SJAPIManagerErrorType)errorType
{
    self.errorType = errorType;
    
    [self removeRequestIdWithRequestID:response.requestId];
    [self beforePerformFailWithResponse:response];
    [self.delegate managerCallAPIDidFailed:self];
    [self afterPerformFailWithResponse:response];
    
    if (errorType == SJAPIManagerErrorTypeDefault) {
        
        if (response.status == SJSURLResponseStatusTimeout) {
            self.errorType = SJAPIManagerErrorTypeTimeout;
            [MBProgressHUD showError:@"网络超时"];
            
        } else {
            self.errorType = SJAPIManagerErrorTypeNoNetWork;
            [MBProgressHUD showError:@"网络错误"];
        }
    }
    if (errorType == SJAPIManagerErrorTypeNoNetWork) {
        [MBProgressHUD showError:@"网络异常, 请检查网络设置"];
        self.errorType = SJAPIManagerErrorTypeNoNetWork;
    }
    
}

#pragma mark - method for interceptor

/*
 拦截器的功能可以由子类通过继承实现，也可以由其它对象实现,两种做法可以共存
 当两种情况共存的时候，子类重载的方法一定要调用一下super
 然后它们的调用顺序是BaseManager会先调用子类重载的实现，再调用外部interceptor的实现
 
 notes:
 正常情况下，拦截器是通过代理的方式实现的，因此可以不需要以下这些代码
 但是为了将来拓展方便，如果在调用拦截器之前manager又希望自己能够先做一些事情，所以这些方法还是需要能够被继承重载的
 所有重载的方法，都要调用一下super,这样才能保证外部interceptor能够被调到
 这就是decorate pattern
 */
- (void)beforePerformSuccessWithResponse:(SJAPIResponse *)response
{
    self.errorType = SJAPIManagerErrorTypeSuccess;
    self.errorMessage = response.content[@"message"];
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformSuccessWithResponse:)]) {
        [self.interceptor manager:self beforePerformSuccessWithResponse:response];
    }
}

- (void)afterPerformSuccessWithResponse:(SJAPIResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformSuccessWithResponse:)]) {
        [self.interceptor manager:self afterPerformSuccessWithResponse:response];
    }
//    if (self.isPageMode) {
//        if(self.isLoadNew){
//            page=1;
//            pageSize=[response.result[@"count"] intValue];
//            total=[response.result[@"total"] integerValue];
//        }
//        self.isLastPage=(total<=page*pageSize);
//    }
}

- (void)beforePerformFailWithResponse:(SJAPIResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:beforePerformFailWithResponse:)]) {
        [self.interceptor manager:self beforePerformFailWithResponse:response];
    }
}

- (void)afterPerformFailWithResponse:(SJAPIResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterPerformFailWithResponse:)]) {
        [self.interceptor manager:self afterPerformFailWithResponse:response];
    }
}

//只有返回YES才会继续调用API
- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:shouldCallAPIWithParams:)]) {
        return [self.interceptor manager:self shouldCallAPIWithParams:params];
    } else {
        return YES;
    }
}

-(BOOL)isCorrectWithParamsData:(NSDictionary*)params
{
    if (self != self.validator && [self.validator respondsToSelector:@selector(manager:isCorrectWithParamsData:)]) {
        return [self.validator manager:self isCorrectWithParamsData:params];
    }else{
        return YES;
    }
}

-(BOOL)isCorrectWithResponseData:(NSDictionary*)data
{
    if (self != self.validator && [self.validator respondsToSelector:@selector(manager:isCorrectWithResponseData:)]) {
        return [self.validator manager:self isCorrectWithResponseData:data];
    }else{
        return YES;
    }
}

-(NSString*)getMethodName
{
    if ([self.child respondsToSelector:@selector(methodName)]) {
        return [self.child methodName];
    }else{

//        NSString *methodName = [NSString stringWithFormat:@"%@_%@_%@",[self convertRequestType:self.child.requestType], SBAPPDelegate.token ? SBAPPDelegate.token : @"token", self.child.requestUrl];
        
        NSString *methodName = [NSString stringWithFormat:@"%@_%@",[self convertRequestType:self.child.requestType], self.child.requestUrl];
        return methodName;
    }
}

-(NSString*) convertRequestType:(SJAPIManagerRequestType)type
{
    NSString* str;
    switch (type) {
        case SJAPIManagerRequestTypePost:
            str = @"POST";
            break;
        case SJAPIManagerRequestTypeGet:
            str = @"GET";
            break;
        case SJAPIManagerRequestTypeUpload:
            str = @"UPLOAD";
            break;
        default:
            break;
    }
    return str;
}

- (void)afterCallingAPIWithParams:(NSDictionary *)params
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(manager:afterCallAPIWithParams:)]) {
        [self.interceptor manager:self afterCallAPIWithParams:params];
    }
}

#pragma mark - method for child
- (void)cleanData
{
    IMP childIMP = [self.child methodForSelector:@selector(cleanData)];
    IMP selfIMP = [self methodForSelector:@selector(cleanData)];
    
    if (childIMP == selfIMP) {
        self.fetchedRawData = nil;
        self.errorMessage = nil;
        self.errorType = SJAPIManagerErrorTypeDefault;
    } else {
        if ([self.child respondsToSelector:@selector(cleanData)]) {
            [self.child cleanData];
        }
    }
}

//如果需要在调用API之前额外添加一些参数，比如pageNumber和pageSize之类的就在这里添加
//子类中覆盖这个函数的时候就不需要调用[super reformParams:params]了
- (NSDictionary *)reformParams:(NSDictionary *)params
{
    //函数指针，IMP可以从 对象 & SEL的方法得到：
    IMP childIMP = [self.child methodForSelector:@selector(reformParams:)];
    IMP selfIMP = [self methodForSelector:@selector(reformParams:)];
    
    if (childIMP == selfIMP) {
        return params;
    } else {
        // 如果child是继承得来的，那么这里就不会跑到，会直接跑子类中的IMP。
        // 如果child是另一个对象，就会跑到这里
        NSDictionary *result = nil;
        result = [self.child reformParams:params];
        if (result) {
            return result;
        } else {
            return params;
        }
    }
}

- (BOOL)shouldCache
{
    return kSJSNeedCache;
}

#pragma mark - private methods
- (void)removeRequestIdWithRequestID:(NSInteger)requestId
{
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
    }
}

- (BOOL)hasCacheWithParams:(NSDictionary *)params
{
    NSString *methodName = [self getMethodName];
    NSData *result = [self.cache fetchCachedDataWithAPIResources:methodName  requestParams:params];
    
    if (result == nil) {
        return NO;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        SJAPIResponse *response = [[SJAPIResponse alloc] initWithData:result];
        response.requestParams = params;
        [self successedOnCallingAPI:response];
    });
    return YES;
}


@end
