//
//  NSDictionary+SJNetworkingParams.h
//  SJFramework
//
//  Created by Sharejoy on 15/6/12.
//  Copyright (c) 2015年 sharejoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SJNetworkingParams)

//params 转换为NSString
- (NSString *)SJSUrlParamsToStringSignature:(BOOL)isForSignature;
//params 转换为JSON
- (NSString *)SJSUrlParamsToJsonString;
//params 转换为NSArray
- (NSArray *)SJSUrlParamsToArraySignature:(BOOL)isForSignature;





@end
