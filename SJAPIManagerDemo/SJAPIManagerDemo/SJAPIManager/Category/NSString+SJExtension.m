//
//  NSString+SJExtension.m
//  SJAPIManagerDemo
//
//  Created by sharejoy_lx on 16-06-24.
//  Copyright © 2016年 shangbin. All rights reserved.
//

#import "NSString+SJExtension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (SJExtension)


- (BOOL)matchWithRegex:(NSString*)regexString
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regexString];
    return [predicate evaluateWithObject:self];
}


-(BOOL)sjContainString:(NSString *)other
{
    NSRange range = [self rangeOfString:other];
    return range.length != 0;
}

- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}



@end
