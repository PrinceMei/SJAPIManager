//
//  RequestResult.m
//  Shangbin
//
//  Created by Sharejoy on 15/7/28.
//  Copyright (c) 2015年 com.sharejoy. All rights reserved.
//

#import "RequestResult.h"

@interface RequestResult ()
@property (nonatomic, strong) NSMutableDictionary* dict;
@end

@implementation RequestResult

+ (instancetype)sharedInstance{
    static RequestResult * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RequestResult alloc] init];
    });
    return instance;
}

-(NSMutableDictionary *)dict
{
    if (!_dict) {
        _dict = [NSMutableDictionary new];
    }
    return _dict;
}


-(NSString *)errorCode:(RequestResultCode)requestCode
{
    NSString* str ;
//    str = [self.dict objectForKey:@(requestCode)];
//    if (!str) {
        str = [NSString stringWithFormat:@"返回码：%ld，请稍后重试", (long)requestCode];
//    }else{
//        str = [NSString stringWithFormat:@"返回码：%ld，%@",(long)requestCode, str];
//    }
    return str;
    
}


@end
