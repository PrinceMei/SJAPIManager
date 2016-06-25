//
//  NSString+SJExtension.h
//  SJAPIManagerDemo
//
//  Created by sharejoy_lx on 16-06-24.
//  Copyright © 2016年 shangbin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SJExtension)

- (BOOL)matchWithRegex:(NSString*)regexString;
- (BOOL)sjContainString:(NSString*)other;

- (NSString *) md5;

@end
