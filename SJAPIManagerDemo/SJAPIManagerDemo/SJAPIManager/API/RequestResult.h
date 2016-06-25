//
//  RequestResult.h
//  Shangbin
//
//  Created by Sharejoy on 15/7/28.
//  Copyright (c) 2015年 com.sharejoy. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  访问服务器返回的结果代码
 */
typedef NS_ENUM(NSInteger, RequestResultCode) {
    SUCCESS                         = 200,//操作成功
    USER_NOT_LOGIN                  = 403000,//登录后才可使用此功能
    DATA_NOT_FOUND                  = 404000,//没有找到满足条件的数据
    
};

@interface RequestResult : NSObject

+ (instancetype)sharedInstance;
-(NSString*) errorCode:(RequestResultCode) requestCode;

@end
