//
//  SJCachedObject.h
//  SJFramework
//
//  Created by Sharejoy on 15/6/12.
//  Copyright (c) 2015年 sharejoy. All rights reserved.
//

#import <Foundation/Foundation.h>


// 缓存池中的对象
@interface SJCachedObject : NSObject

//只读属性
@property (nonatomic, copy, readonly) NSData *content;
@property (nonatomic, copy, readonly) NSDate *lastUpdateTime;


@property (nonatomic, assign, readonly) BOOL isOverdue;
@property (nonatomic, assign, readonly) BOOL isEmpty;   


- (instancetype)initWithContent:(NSData *)content;

- (void)updateContent:(NSData *)content;

@end
