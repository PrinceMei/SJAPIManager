//
//  SJNetworkConfiguration.h
//  SJFramework
//
//  Created by Sharejoy on 15/6/12.
//  Copyright (c) 2015年 sharejoy. All rights reserved.
//

#ifndef SJFramework_SJNetworkConfiguration_h
#define SJFramework_SJNetworkConfiguration_h


typedef NS_ENUM(NSUInteger, SJSURLResponseStatus)
{
    SJSURLResponseStatusSuccess,  //服务器请求成功即设置为此状态,内容是否错误由各子类验证
    SJSURLResponseStatusTimeout,
    SJSURLResponseStatusNoNetwork  // 默认除了超时以外的错误都是无网络错误。
};

//网络请求超时时间,默认设置为20秒
static NSTimeInterval kSJSNetworkingTimeoutSeconds = 20.0f;
// 是否需要缓存的标志,默认为YES
static BOOL kSJSNeedCache = YES;
// cache过期时间 设置为30秒
static NSTimeInterval kSJSCacheOverdueSeconds = 30;
// cache容量限制,最多100条
static NSUInteger kSJSCacheCountLimit = 100;

#endif
