//
//  NSURLRequest+AIFNetworkingMethods.m
//  RTNetworking
//
//  Created by casa on 14-5-26.
//  Copyright (c) 2014年 anjuke. All rights reserved.
//

#import "NSURLRequest+SJNetworkingMethods.h"
#import <objc/runtime.h>

static void *SJNetworkingRequestParams;

@implementation NSURLRequest (SJNetworkingMethods)

- (void)setRequestParams:(NSDictionary *)requestParams
{
    objc_setAssociatedObject(self, &SJNetworkingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)requestParams
{
    return objc_getAssociatedObject(self, &SJNetworkingRequestParams);
}

@end
