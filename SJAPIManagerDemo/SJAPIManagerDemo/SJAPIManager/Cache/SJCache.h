//
//  SJCache.h
//  SJFramework
//
//  Created by Sharejoy on 15/6/12.
//  Copyright (c) 2015年 sharejoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJCache : NSObject

+ (instancetype)sharedInstance;

- (NSData *)fetchCachedDataWithAPIResources:(NSString *)methodName
                              requestParams:(NSDictionary *)requestParams;

- (void)saveCacheWithData:(NSData *)cachedData
               methodName:(NSString *)methodName
            requestParams:(NSDictionary *)requestParams;

- (void)deleteCacheWithAPIResources:(NSString *)methodName
                      requestParams:(NSDictionary *)requestParams;

//根据方法名删除缓存
-(void)deleteCacheWithMethodName:(NSString*)methodName;
//根据class名删除缓存，这里的Class主要是服务名对应的Class
-(void)deleteCacheWithClass:(Class)cls;

- (void)clean;

@end
