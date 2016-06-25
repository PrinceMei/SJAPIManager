//
//  SJAPIResponse.m
//  SJFramework
//
//  Created by Sharejoy on 15/6/12.
//  Copyright (c) 2015年 sharejoy. All rights reserved.
//

#import "SJAPIResponse.h"
#import "NSURLRequest+SJNetworkingMethods.h"
#import "NSObject+AXNetworkingMethods.h"

@interface SJAPIResponse()

@property (nonatomic, assign, readwrite) SJSURLResponseStatus status; //响应状态
@property (nonatomic, copy, readwrite) NSString *contentString;    //
@property (nonatomic, copy, readwrite) id content;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, copy, readwrite) NSDictionary *result;
@property (nonatomic,assign, readwrite) int responseCode;
@property (nonatomic,copy, readwrite) NSString *responseMessage;
@property (nonatomic, assign, readwrite) BOOL isCache;
@property (nonatomic, strong, readwrite) NSError *error;

@end

@implementation SJAPIResponse

#pragma mark - life cycle
//成功走这里, 这里需要根据公司不同格式定制
- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData status:(SJSURLResponseStatus)status params:(NSDictionary *)params
{
    self = [super init];
    if (self) {
        self.contentString = responseString;
        self.content = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        self.status = status;
        self.requestId = [requestId integerValue];
        self.request = request;
        self.responseData = responseData;
        self.requestParams = params;
        self.isCache = NO;
        //以下需定制
        self.responseCode = [self.content[@"code"] intValue];
        NSLog(@"successCode : %d", self.responseCode);
        self.responseMessage = self.content[@"message"];
        self.result = self.content[@"data"];
    }
    return self;
}

//错误走这里, 这里需要根据公司不同格式定制
- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError *)error
{
    self = [super init];
    if (self) {
        self.contentString = [responseString SJ_defaultValue:@""];
        self.status = [self responseStatusWithError:error];
        self.requestId = [requestId integerValue];
        self.request = request;
        self.responseData = responseData;
        self.requestParams = request.requestParams;
        self.isCache = NO;
        self.error = error;
        
        if (responseData) {
            self.content = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
            self.responseCode = [self.content[@"code"] intValue];
            self.result = self.content[@"result"];
        } else {
            self.content = nil;
        }
    }
    return self;
}

// 使用initWithData的response，它的isCache是YES，上面两个函数生成的response的isCache是NO
- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        self.contentString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.status = [self responseStatusWithError:nil];
        self.requestId = 0;
        self.request = nil;
        self.responseData = [data copy];
        self.content = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
        self.isCache = YES;
        self.responseCode = [self.content[@"code"] intValue];
        self.result = self.content[@"result"];
        
    }
    return self;
}

#pragma mark - private methods
- (SJSURLResponseStatus)responseStatusWithError:(NSError *)error
{
    if (error) {
        SJSURLResponseStatus result = SJSURLResponseStatusNoNetwork;
        
        NSLog(@"errorCode: %zd  errorMessage: %@", error.code, error.userInfo[@"NSLocalizedDescription"]);
        // 除了超时以外，所有错误都当成是无网络
        if (error.code == NSURLErrorTimedOut) {
            result = SJSURLResponseStatusTimeout;
        }
        return result;
    } else {
        return SJSURLResponseStatusSuccess;
    }
}

@end
