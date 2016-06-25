//
//  TestAPI.m
//  SJAPIManagerDemo
//
//  Created by sharejoy_lx on 16-06-24.
//  Copyright © 2016年 shangbin. All rights reserved.
//

#import "TestAPI.h"

#define BaseUrl @"http://api.zsreader.com/v2/"

@implementation TestAPI
{
    int page;//记录页码值
    int pageSize;//每页条数
    NSInteger total;//记录总条数
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.paramSource = self;
        self.headerSource =self;
    }
    return self;
}

- (SJAPIManagerRequestType)requestType {
    return SJAPIManagerRequestTypeGet;
}

- (NSString *)cacheRegexKey {
    return [NSString stringWithFormat:@"%@%@", BaseUrl, @"pub/home/2"];
}
//@"?&page=%ld&tp=1&size=20"
- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"%@%@", BaseUrl, @"pub/home/2"];
}

- (NSDictionary *)headersForAPI:(SJAPIBaseManager *)manager {
    return nil;
}

- (NSDictionary *)paramsForAPI:(SJAPIBaseManager *)manager {
    //假如是上拉刷新，取下一页
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (!self.isLoadNew) {
        params[@"page"]=@(page);
    }

    return [params copy];
}

-(void)beforePerformSuccessWithResponse:(SJAPIResponse *)response
{
    [super beforePerformSuccessWithResponse:response];
    if(self.isLoadNew){
        page=1;
        pageSize=[response.result[@"count"] intValue];
        total=[response.result[@"total"] integerValue];
    }
    self.isLastPage=(total<=page*pageSize);
    self.code=response.responseCode;
    self.message = response.responseMessage;
    
    //可以在这转好模型, 控制器里直接用
    
    page++;
    NSLog(@"jsonLength = %lu",(unsigned long)response.responseData.length);
//    NSLog(@"json = %@", response.contentString);
}

@end
