//
//  AXApiProxy.m
//  RTNetworking
//
//  Created by casa on 14-5-12.
//  Copyright (c) 2014年 anjuke. All rights reserved.
//

#import "AFNetworking.h"
#import "SJApiProxy.h"
#import "NSURLRequest+SJNetworkingMethods.h"

static NSString * const kAXApiProxyDispatchItemKeyCallbackSuccess = @"kAXApiProxyDispatchItemCallbackSuccess";
static NSString * const kAXApiProxyDispatchItemKeyCallbackFail = @"kAXApiProxyDispatchItemCallbackFail";


@interface SJApiProxy ()

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recordedRequestId;

//AFNetworking stuff
@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;

@end

@implementation SJApiProxy
#pragma mark - getters and setters
- (NSMutableDictionary *)dispatchTable
{
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

- (AFHTTPRequestOperationManager *)operationManager
{
    if (_operationManager == nil) {
        _operationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:nil];
        //        _operationManager.responseSerializer = [AFJSONResponseSerializer serializer];  //都在具体请求里设置
        [_operationManager.securityPolicy setAllowInvalidCertificates:YES]; //设置这句话可以支持发布测试url
        
    }
    return _operationManager;
}

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static SJApiProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SJApiProxy alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public methods
- (NSInteger)callGETWithParams:(NSDictionary *)params url:(NSString *)url  headers:(NSDictionary*)headers methodName:(NSString *)methodName success:(AXCallback)success fail:(AXCallback)fail
{
    self.operationManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.operationManager.requestSerializer.timeoutInterval = kSJSNetworkingTimeoutSeconds;
    
    [self fillHeader:headers];
    
    NSNumber *requestId = [self callApiWithParams:params url:url methodName:methodName requestType:REQUEST_GET success:success fail:fail upload:nil];
    return [requestId integerValue];
}

- (NSInteger)callPOSTWithParams:(NSDictionary *)params url:(NSString *)url  headers:(NSDictionary*)headers methodName:(NSString *)methodName success:(AXCallback)success fail:(AXCallback)fail
{
    
    self.operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.operationManager.requestSerializer.timeoutInterval = kSJSNetworkingTimeoutSeconds;
    
    [self fillHeader:headers];
    
    NSNumber *requestId = [self callApiWithParams:params url:url methodName:methodName requestType:REQUEST_POST success:success fail:fail upload:nil];
    
    return [requestId integerValue];
}

- (NSInteger)callUPLOADWithParams:(NSDictionary *)params url:(NSString *)url headers:(NSDictionary *)headers uploads:(NSDictionary *)uploads methodName:(NSString *)methodName success:(AXCallback)success fail:(AXCallback)fail
{
    
    [self.operationManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    self.operationManager.requestSerializer.timeoutInterval = 60.0f;
    [self fillHeader:headers];
    
    multipart upload = ^(id<AFMultipartFormData> formData){
        NSMutableArray *filepart = [uploads objectForKey:@"fileparts"];
        NSString *filename = [uploads objectForKey:@"filename"];
        for (int i = 0; i< filepart.count; i++) {
            NSData *imageData = filepart[i];
            [formData appendPartWithFileData:imageData
                                        name:[NSString stringWithFormat:@"%@",filename]
                                    fileName:[NSString stringWithFormat:@"image%d.jpg",i]mimeType:@"image/jpeg"];
        }
    };
    NSNumber *requestId = [self callApiWithParams:params url:url methodName:methodName requestType:REQUEST_UPLOAD success:success fail:fail upload:upload];
    return [requestId integerValue];
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID
{
    NSOperation *requestOperation = self.dispatchTable[requestID];
    [requestOperation cancel];
    [self.dispatchTable removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList
{
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}

#pragma mark - private methods
/** 这个函数存在的意义在于，如果将来要把AFNetworking换掉，只要修改这个函数的实现即可。 */
- (NSNumber *)callApiWithParams:(NSDictionary *)params url:(NSString *)url methodName:(NSString *)methodName requestType:(RequestType)type success:(AXCallback)success fail:(AXCallback)fail upload:(multipart)upload
{
    
    // 之所以不用getter，是因为如果放到getter里面的话，每次调用self.recordedRequestId的时候值就都变了，违背了getter的初衷
    NSNumber *requestId = [self generateRequestId];
    
    suceesBlock sblk = ^(AFHTTPRequestOperation *operation, id reponseObject) {
//        NSLog(@"operation  : %@",operation);
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            [self.dispatchTable removeObjectForKey:requestId];  //成功返回数据, 删除掉requestId
        }
        
        SJAPIResponse *response = [[SJAPIResponse alloc] initWithResponseString:operation.responseString  requestId:requestId request:operation.request responseData:operation.responseData status:SJSURLResponseStatusSuccess params:params];
        
        success ? success(response) : nil;
        
    };
    
    
    failureBlock fblk =  ^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"operation  : %@",operation);
        AFHTTPRequestOperation *storedOperation = self.dispatchTable[requestId];
        if (storedOperation == nil) {
            // 如果这个operation是被cancel的，那就不用处理回调了。
            return;
        } else {
            [self.dispatchTable removeObjectForKey:requestId];
        }
        
        SJAPIResponse *response = [[SJAPIResponse alloc] initWithResponseString:operation.responseString requestId:requestId request:operation.request responseData:operation.responseData error:error];
        
        fail?fail(response):nil;
        
    };
    
    
    // 跑到这里的block的时候，就已经是主线程了。
    AFHTTPRequestOperation *httpRequestOperation;  //返回的类型就是AFHTTPRequestOperation, 含请求头, 响应头等信息
    switch (type) {
        case REQUEST_GET:
            httpRequestOperation = [self.operationManager GET:url parameters:params success:sblk    failure:fblk];
            break;
        case REQUEST_POST:
            httpRequestOperation = [self.operationManager POST:url parameters:params success:sblk failure:fblk];
            break;
        case REQUEST_UPLOAD:
            httpRequestOperation = [self.operationManager POST:url parameters:params constructingBodyWithBlock:upload  success:sblk failure:fblk];
            break;
            
        default:
            break;
    }
    
    self.dispatchTable[requestId] = httpRequestOperation;   //发出请求之后立即将httpRequestOperation加进dispatchTable
    return requestId;
}

- (NSNumber *)generateRequestId
{
    if (_recordedRequestId == nil) {
        _recordedRequestId = @(1);
    } else {
        if ([_recordedRequestId integerValue] == NSIntegerMax) {
            _recordedRequestId = @(1);
        } else {
            _recordedRequestId = @([_recordedRequestId integerValue] + 1);
        }
    }
    return _recordedRequestId;
}

-(void) fillHeader:(NSDictionary* )headers
{
    if (nil != headers) {
        for (id key in headers) {
            [self.operationManager.requestSerializer setValue:[headers objectForKey:key] forHTTPHeaderField:key];
        }
    }
}

@end
