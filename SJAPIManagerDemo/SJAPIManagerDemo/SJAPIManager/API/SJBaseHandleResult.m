//
//  SJBaseHandleError.m
//  Shangbin
//
//  Created by Sharejoy on 15/10/30.
//  Copyright © 2015年 com.sharejoy. All rights reserved.
//

#import "SJBaseHandleResult.h"
#import "MBProgressHUD+MJ.h"
#import "RequestResult.h"

@implementation SJBaseHandleResult

- (void) handleResult:(NSInteger)code
{
    [MBProgressHUD showError:[[RequestResult sharedInstance] errorCode:code]];
}

-(void)handleErrmsg:(NSString *)errMsg
{
    
    if (errMsg != nil && ![errMsg isEqualToString:@""]) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", errMsg]];
    }
    
}

-(void)handleError:(NSInteger)code errMsg:(NSString *)errMsg
{
    if (code == DATA_NOT_FOUND) {
        return;
    }
    if (errMsg) {
        [self handleErrmsg:errMsg];
    }else{
        [self handleResult:code];
    }
}

-(void)handleResult:(NSInteger)code name:(NSString*)name args:(id)args
{
    SEL sel;
    if (name) {
        sel = NSSelectorFromString([NSString stringWithFormat:@"handle%@_%ld:",name,(long)code]);
    }else{
        sel = NSSelectorFromString([NSString stringWithFormat:@"handle_%ld:",(long)code]);
    }
    if ([self.delegate respondsToSelector:sel]) {
        [self.delegate performSelector:sel withObject:args];
        
    }else{
        [self handleResult:(int)code];
    }
}
@end
