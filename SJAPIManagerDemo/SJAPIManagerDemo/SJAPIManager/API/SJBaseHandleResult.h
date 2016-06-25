//
//  SJBaseHandleError.h
//  Shangbin
//
//  Created by Sharejoy on 15/10/30.
//  Copyright © 2015年 com.sharejoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HandleResultDelegate <NSObject>

@end

@interface SJBaseHandleResult : NSObject
@property (nonatomic, strong) id<HandleResultDelegate> delegate;
- (void) handleResult:(NSInteger)code;
- (void) handleErrmsg:(NSString*)errMsg;
//目前使用这种
- (void) handleError:(NSInteger)code errMsg:(NSString*)errMsg;

-(void)handleResult:(NSInteger)code name:(NSString*)name args:(id)args;

@end
