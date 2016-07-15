//
//  Tinynet.h
//  Tinynet
//
//  Created by wayne on 15/5/26.
//  Copyright (c) 2015年 wayne. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const kGET;
FOUNDATION_EXTERN NSString * const kPOST;


typedef void(^NetCallBack)(NSData *data, NSURLResponse *response, NSError *error);


@interface Tinynet : NSObject


+ (void)setTimeoutInterval:(NSTimeInterval)timeInterval;

+ (void)requestWithURL:(NSString *)inUrl method:(NSString *)inMethod params:(NSDictionary *)inParams completionHandler:(NetCallBack)inCompletionHandler;

+ (void)requestWithURL:(NSString *)inUrl method:(NSString *)inMethod completionHandler:(NetCallBack)inCompletionHandler;

+ (void)get:(NSString *)inUrl params:(NSDictionary *)inParams completionHandler:(NetCallBack)inCompletionHandler;

+ (void)get:(NSString *)inUrl completionHandler:(NetCallBack)inCompletionHandler;

+ (void)post:(NSString *)inUrl params:(NSDictionary *)inParams completionHandler:(NetCallBack)inCompletionHandler;

+ (void)post:(NSString *)inUrl completionHandler:(NetCallBack)inCompletionHandler;



@end



@interface TinynetManager : NSObject

- (id)initWithURL:(NSString *)inUrl
           method:(NSString *)inMethod
           params:(NSDictionary *)inParams
completionHandler:(NetCallBack)inCompletionHandler;

- (void)fire;

@end

