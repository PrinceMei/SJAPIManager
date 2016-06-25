//
//  NSDictionary+SJNetworkingParams.m
//  SJFramework
//
//  Created by Sharejoy on 15/6/12.
//  Copyright (c) 2015年 sharejoy. All rights reserved.
//

#import "NSDictionary+SJNetworkingParams.h"
#import "NSArray+SJNetworkingParams.h"

@implementation NSDictionary (SJNetworkingParams)


- (NSString *)SJSUrlParamsToStringSignature:(BOOL)isForSignature{
    NSArray *sortedArray = [self SJSUrlParamsToArraySignature:isForSignature];
    return [sortedArray SJSUrlParamString];
}

- (NSString *)SJSUrlParamsToJsonString{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:NULL];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSArray *)SJSUrlParamsToArraySignature:(BOOL)isForSignature{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            obj = [NSString stringWithFormat:@"%@", obj];
        }
        if (!isForSignature) {
            obj = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)obj,  NULL,  (CFStringRef)@"!*'();:@&;=+$,/?%#[]",  kCFStringEncodingUTF8));
            
        }
        [result addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    NSArray *sortedResult = [result sortedArrayUsingSelector:@selector(compare:)];
    return sortedResult;
}


@end











