//
//  AXApiProxy.h
//  RTNetworking
//
//  Created by casa on 14-5-12.
//  Copyright (c) 2014年 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "SJAPIResponse.h"

typedef void(^suceesBlock)(AFHTTPRequestOperation *operation, id reponseObject);
typedef void(^failureBlock)(AFHTTPRequestOperation *operation, NSError *err);
typedef void(^AXCallback)(SJAPIResponse * response);
typedef void(^multipart)(id<AFMultipartFormData>);
typedef NS_ENUM(NSInteger, RequestType) {
    REQUEST_GET = 0,
    REQUEST_POST,
    REQUEST_UPLOAD
};

@interface SJApiProxy : NSObject

+ (instancetype)sharedInstance;

- (NSInteger)callGETWithParams:(NSDictionary *)params url:(NSString *)url  headers:(NSDictionary*)headers methodName:(NSString *)methodName success:(AXCallback)success fail:(AXCallback)fail;
- (NSInteger)callPOSTWithParams:(NSDictionary *)params url:(NSString *)url  headers:(NSDictionary*)headers methodName:(NSString *)methodName success:(AXCallback)success fail:(AXCallback)fail;
- (NSInteger)callUPLOADWithParams:(NSDictionary *)params url:(NSString *)url headers:(NSDictionary*)headers uploads:(NSDictionary*)uploads methodName:(NSString *)methodName success:(AXCallback)success fail:(AXCallback)fail;

- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;

@end
