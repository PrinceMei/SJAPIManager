//
//  SJCachedObject.m
//  SJFramework
//
//  Created by Sharejoy on 15/6/12.
//  Copyright (c) 2015年 sharejoy. All rights reserved.
//

#import "SJCachedObject.h"
#import "SJNetworkConfiguration.h"

@interface SJCachedObject()

@property (nonatomic, copy, readwrite) NSData *content;
@property (nonatomic, copy, readwrite) NSDate *lastUpdateTime;

@end

@implementation SJCachedObject

#pragma mark - life cycle
- (instancetype)initWithContent:(NSData *)content{
    self = [super init];
    if (self) {
        self.content = content;
    }
    return self;
}

- (void)updateContent:(NSData *)content{
    self.content = content;
}

#pragma mark - getters and setters
- (BOOL)isEmpty{
    return nil == self.content;
}

- (BOOL)isOverdue{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
    return timeInterval > kSJSCacheOverdueSeconds;
}

- (void)setContent:(NSData *)content{
    _content = [content copy];
    self.lastUpdateTime = [NSDate dateWithTimeIntervalSinceNow:0];
}

@end
