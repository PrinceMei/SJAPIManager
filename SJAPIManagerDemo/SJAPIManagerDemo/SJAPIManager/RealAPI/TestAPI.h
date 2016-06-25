//
//  TestAPI.h
//  SJAPIManagerDemo
//
//  Created by sharejoy_lx on 16-06-24.
//  Copyright © 2016年 shangbin. All rights reserved.
//

#import "SJAPIBaseManager.h"

@interface TestAPI : SJAPIBaseManager<SJAPIManager, SJAPIManagerParamSourceDelegate, SJAPIManagerHeaderSourceDelegate>

@property(nonatomic,assign)int code;
@property (nonatomic, copy) NSString *message;
/** 是否为读取新数据(对应下拉刷新) */
@property(nonatomic,assign)BOOL isLoadNew;
/** 是否为最后一页 */
@property(nonatomic,assign)BOOL isLastPage;
@end
