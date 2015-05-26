//
//  Tinynet.m
//  Tinynet
//
//  Created by wayne on 15/5/26.
//  Copyright (c) 2015年 wayne. All rights reserved.
//

#import "Tinynet.h"

NSString * const kGET   = @"GET";
NSString * const kPOST  = @"POST";

static NSTimeInterval kTimeInterval = 10;

@implementation Tinynet

+ (void)setTimeoutInterval:(NSTimeInterval)timeInterval {
    kTimeInterval = timeInterval;
}

+ (void)requestWithURL:(NSString *)inUrl method:(NSString *)inMethod params:(NSDictionary *)inParams completionHandler:(NetCallBack)inCompletionHandler {
    TinynetManager *manager = [[TinynetManager alloc] initWithURL:inUrl method:inMethod params:inParams completionHandler:inCompletionHandler];
    [manager fire];
}

+ (void)requestWithURL:(NSString *)inUrl method:(NSString *)inMethod completionHandler:(NetCallBack)inCompletionHandler {
    TinynetManager *manager = [[TinynetManager alloc] initWithURL:inUrl method:inMethod params:nil completionHandler:inCompletionHandler];
    [manager fire];
}

+ (void)get:(NSString *)inUrl params:(NSDictionary *)inParams completionHandler:(NetCallBack)inCompletionHandler {
    TinynetManager *manager = [[TinynetManager alloc] initWithURL:inUrl method:kGET params:inParams completionHandler:inCompletionHandler];
    [manager fire];
}

+ (void)get:(NSString *)inUrl completionHandler:(NetCallBack)inCompletionHandler {
    TinynetManager *manager = [[TinynetManager alloc] initWithURL:inUrl method:kGET params:nil completionHandler:inCompletionHandler];
    [manager fire];
}

+ (void)post:(NSString *)inUrl params:(NSDictionary *)inParams completionHandler:(NetCallBack)inCompletionHandler {
    TinynetManager *manager = [[TinynetManager alloc] initWithURL:inUrl method:kPOST params:inParams completionHandler:inCompletionHandler];
    [manager fire];
}

+ (void)post:(NSString *)inUrl completionHandler:(NetCallBack)inCompletionHandler {
    TinynetManager *manager = [[TinynetManager alloc] initWithURL:inUrl method:kPOST params:nil completionHandler:inCompletionHandler];
    [manager fire];
}


@end


@implementation TinynetManager
{
    NSString *_method;
    NSString *_url;
    NSDictionary *_params;
    NetCallBack _completionHandler;
    NSURLSession *_session;
    NSMutableURLRequest *_request;
    NSURLSessionTask *_task;
}

- (id)initWithURL:(NSString *)inUrl
           method:(NSString *)inMethod
           params:(NSDictionary *)inParams
completionHandler:(NetCallBack)inCompletionHandler {
    if (self = [super init]) {
        _url = inUrl;
        _method = inMethod;
        _params = inParams;
        _completionHandler = inCompletionHandler;
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kTimeInterval];
    }
    
    return self;
}

- (void)fire {
    [self _buildRequest];
    [self _buildBody];
    [self _commitTask];
}


- (void)_buildRequest {
    if ([_method isEqualToString:kGET] && _params.count > 0) {
        _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", _url, [self _buildParams:_params]]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kTimeInterval];
    }
    
    _request.HTTPMethod = _method;
    
    if (_params.count > 0) {
        [_request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    }
}

- (void)_buildBody {
    if (![_method isEqualToString:kGET] && _params.count > 0) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:_params
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
        if (!error && data) {
            _request.HTTPBody = data;
        }
    }
}

- (void)_commitTask {
    _task = [_session dataTaskWithRequest:_request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *er = nil;
        id datax = nil;
        if (!error) {
            datax = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&er];
        }
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            _completionHandler(er ? nil : datax, response, error);
        }];
        [[NSOperationQueue mainQueue] addOperation:op];
    }];
    [_task resume];
}

- (NSString *)_buildParams:(NSDictionary *)params {
    NSMutableString *components = [NSMutableString new];
    
    for (NSString *itemKey in [params allKeys]) {
        id itemValue = params[itemKey];
        NSString *tmp = [self _queryComponents:itemKey value:itemValue];
        [components appendString:tmp];
    }
    
    return [components substringFromIndex:1];
}

- (NSString *)_queryComponents:(NSString *)inKey value:(id)inValue {
    NSMutableString *components = [NSMutableString new];
    
    if ([inValue isKindOfClass:[NSArray class]]) {
        for (NSString *itemValue in inValue) {
            NSString *tmp = [self _queryComponents:inKey value:itemValue];
            [components appendString:tmp];
        }
    }
    else if ([inValue isKindOfClass:[NSDictionary class]]) {
        for (NSString *itemKey in [inValue allKeys]) {
            id itemValue = inValue[itemKey];
            NSString *tmp = [self _queryComponents:[NSString stringWithFormat:@"%@[%@]", inKey, itemKey] value:itemValue];
            [components appendString:tmp];
        }
    }
    else {
        [components appendFormat:@"&%@=%@", [inKey escape], [[NSString stringWithFormat:@"%@", inValue] escape]];
    }
    
    return components;
}


@end




@implementation NSString (escape)

- (NSString *)escape{
    CFStringRef legalURLCharactersToBeEscaped = CFSTR(":&=;+!@#$()',*");
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(nil, (CFStringRef)self, nil, legalURLCharactersToBeEscaped, kCFStringEncodingUTF8);
}

@end