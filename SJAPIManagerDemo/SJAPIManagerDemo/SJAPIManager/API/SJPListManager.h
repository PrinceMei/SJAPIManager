//
//  LPListManager.h
//
//  Created by casa on 10/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJPListManager : NSObject

@property (nonatomic, strong, readonly) NSString *fileName;
@property (nonatomic, strong) NSMutableDictionary* listData; //plist中读出的数据
@property (nonatomic, readonly) BOOL isBundle; //是否从bunlde读取

/**
 * 读取FileName文件中的内容到ListData(字典)中。如果没有文件则ListData为nil
 * isBundle 打开方式，表示从沙盒中还是应用本身打开。注意：只能修改在沙盒中的数据
 */
- (id)initWithFileName:(NSString *)fileName isBundle:(BOOL)isBundle;
/*
 * 如果文件不存在，则默认会在沙盒中新建fileName文件
 */
- (id)initWithFileNameAutoCreate:(NSString *)fileName;
/*
 * 如果修改了ListData中的数据(update, remove, clean)，必须通过save方法保存到沙盒文件中
 */
- (BOOL)save;
/*
 * 删除ListData中key对应的数据
 */
- (BOOL)removeKey:(NSString*)key;
/*
 * 更新ListData中key对应的数据
 */
- (BOOL)updateWithKey:(NSString*)key value:(id)value;
/*
 * 清空ListData
 */
- (BOOL)clean;

/*
    以下涉及的filename都不需要带.plist的后缀, 如果文件名是@"abc.plist",那么传入的参数就是 @"abc"
    所有的plist文件都是在NSDocumentDirectory目录下。
 */

- (BOOL)isExistWithFileNameInLibrary:(NSString *)plistFileName;
- (BOOL)isExistWithFileNameInBundle:(NSString *)plistFileName;

/** 
    如果文件不存在的话就新建一个，如果文件已经存在的话，就会删掉已经有的文件重新创建一个
    data只能传NSArray或者NSDictionary
 */
- (BOOL)saveData:(id)data withFileName:(NSString *)fileName;
- (BOOL)saveString:(NSString *)string withFileName:(NSString *)fileName;

/** 如果文件不存在的话返回YES */
- (BOOL)deletePlistFile:(NSString *)fileName;

- (id)loadDataWithFileName:(NSString *)fileName;
- (NSString *)loadStringWithFileName:(NSString *)fileName;


@end
