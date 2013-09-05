//
//  AGHttpHandler.m
//  Airogami
//
//  Created by Tianhu Yang on 8/1/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGJSONHttpHandler.h"
#import "AGDefines.h"
#import "AGURLConnection.h"
#import "AGMessageUtils.h"
#import "AGUtils.h"
#import "AGWaitUtils.h"
#import "AGManagerUtils.h"
#import "NSDictionary_JSONExtensions.h"

#define AGJSONHttpHandlerDefaultCapacity (16 * 1024)

#define TimeoutInterval 10

@interface AGJSONHttpHandler()<NSURLConnectionDelegate>
{
   
}

@property(nonatomic, strong) NSMutableURLRequest *request;

@end

@implementation AGJSONHttpHandler

@synthesize request;

+ (AGJSONHttpHandler*) handler
{
    static dispatch_once_t  onceToken;
    static AGJSONHttpHandler * sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[AGJSONHttpHandler alloc] init];
    });
    return sSharedInstance;
}

-(id)init
{
    if (self = [super init]) {
        request = [[NSMutableURLRequest alloc] init];
        request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        request.timeoutInterval = TimeoutInterval;
    }
    return self;
}

- (AGURLConnection*) start:(NSString*)path context:(id)context block:(AGHttpJSONHandlerFinishBlock)block
{
    return [self start:path params:nil device:NO context:context block:block];
}


- (AGURLConnection*) start:(NSString*)path params:(NSDictionary*)params device:(BOOL)device context:(id)context block:(AGHttpJSONHandlerFinishBlock)block
{
    static NSNumber *number;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", AGWebServerUrl, path]];
    NSData *body;
    if (params) {
        NSMutableString *content = [NSMutableString stringWithCapacity:2048];
        [AGUtils encodeParams:params path:content device:device];
        body = [content dataUsingEncoding:NSUTF8StringEncoding];
    }
    AGURLConnection *conn;
    @synchronized(number){
        request.URL = url;
        if (params) {
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:body];
        }
        else{
            [request setHTTPMethod:@"GET"];
            [request setHTTPBody:nil];
        }
        
        conn = [[AGURLConnection alloc] initWithRequest:request delegate:self];
    }
    if (context) {
        [conn setValue:context forKey:@"Context"];
    }
    if (block) {
        [conn setValue:block forKey:@"ResultBlock"];
    }
    
    //cookie
   /* NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        NSLog(@"%@", cookie);
    }*/
    return conn;
}

- (NSURLConnection*) start:(NSDictionary*)dict
{
    NSAssert(dict != nil, @"dict can't be nil");
    NSString *path = [dict objectForKey:@"path"];
    id context = [dict objectForKey:@"context"];
    AGHttpJSONHandlerFinishBlock block = [dict objectForKey:@"block"];
    NSDictionary* params = [dict objectForKey:@"params"];
    return [self start:path params:params device:NO context:context block:block];
}

- (void)connection:(AGURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    NSHTTPURLResponse * httpResponse;
    NSString *          contentTypeHeader;
    
    httpResponse = (NSHTTPURLResponse *) response;
    //NSLog(@"http response code=%d", httpResponse.statusCode);
    if ((httpResponse.statusCode / 100) != 2) {
        NSString *desc = [NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode];
        [self stopConnection:connection description:desc];
        
    } else {
        // -MIMEType strips any parameters, strips leading or trailer whitespace, and lower cases
        // the string, so we can just use -isEqual: on the result.
        contentTypeHeader = [httpResponse MIMEType];
        if (contentTypeHeader == nil) {
            [self stopConnection:connection description:@"No Content-Type!"];
        } else if ( ! [contentTypeHeader isEqual:@"application/json"]) {
            [self stopConnection:connection description:[NSString stringWithFormat:@"Unsupported Content-Type (%@)", contentTypeHeader]];
        }else{
            NSNumber *number = [httpResponse.allHeaderFields objectForKey:@"Content-Length"];
            int length = 0;
            if (number) {
                length = [number intValue];
            }
            else{
                length = AGJSONHttpHandlerDefaultCapacity;
            }
            NSMutableData *data = [[NSMutableData alloc] initWithCapacity:length];
            [connection setValue:data forKey:@"ReceivedData"];
        }
    }
}

- (void) stopConnection:(AGURLConnection *)connection description:(NSString*)desc
{
    [connection cancel];
    NSError *error = [AGMessageUtils errorServer];
    AGHttpJSONHandlerFinishBlock block = [connection valueForKey:@"ResultBlock"];
    id context = [connection valueForKey:@"Context"];
    if(block){
        block(error,context, nil);
    }
}

- (void)connection:(AGURLConnection *)connection didReceiveData:(NSData *)d
{
    // Append the new data to data.
    // data is an instance variable declared elsewhere.
    NSMutableData *data = [connection valueForKey:@"ReceivedData"];
    [data appendData:d];
}

- (void)connection:(AGURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // inform the user
#ifdef IS_DEBUG
    NSLog(@"Connection failed! Error - %@ %@",[error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
#endif
    [[error.userInfo mutableCopy] setObject:AGHttpFailErrorTitleKey forKey:AGErrorTitleKey];
    AGHttpJSONHandlerFinishBlock block = [connection valueForKey:@"ResultBlock"];
    id context = [connection valueForKey:@"Context"];
    if (block) {
        block(error,context, nil);
    }
    
}

- (void)connectionDidFinishLoading:(AGURLConnection *)connection
{
    // do something with the data
    // data is declared as a method instance elsewhere
    NSMutableData *data = [connection valueForKey:@"ReceivedData"];
    //NSLog(@"Succeeded! Received %d bytes of data",[data length]);
    NSMutableDictionary *dict = nil;
    //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    //dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    dict = [[NSDictionary dictionaryWithJSONData:data error:nil] mutableCopy];;
    
    NSError *error = nil;
    if (dict == nil) {
         error = [AGMessageUtils errorServer];
    }
    AGHttpJSONHandlerFinishBlock block = [connection valueForKey:@"ResultBlock"];
    id context = [connection valueForKey:@"Context"];
    if (block) {
         block(error,context, dict);
    }

}


+ (void) request:(BOOL)get params:(NSDictionary*)params path:(NSString*)path prompt:(NSString*)prompt context:(id)context  block:(AGHttpJSONHandlerRequestFinishBlock)block
{
    NSMutableString *url = [NSMutableString stringWithCapacity:128];
    [url appendString:path];
    if (get) {
        [AGUtils encodeParams:params path:url device:NO];
        params = nil;
    }
    
    if (prompt) {
        [AGWaitUtils startWait:NSLocalizedString(prompt, prompt)];
    }
    NSMutableString * NotSignin = [NSMutableString stringWithString:@"NO"];
    [[AGJSONHttpHandler handler] start:url  params:params device:NO context:context block:^(NSError *error,id context, NSMutableDictionary *dict) {
        if (prompt) {
            [AGWaitUtils startWait:nil];
        }
        NSMutableDictionary *result = nil;
        if (error) {
            
        }
        else{
            NSNumber *status = [dict objectForKey:AGLogicJSONStatusKey];
            
            if (status.intValue == 0) {
                result = [dict objectForKey:AGLogicJSONResultKey];
                if (result == nil) {
                    error = [AGMessageUtils errorServer];
#ifdef IS_DEBUG
                    NSAssert(false, @"Server Error");
#endif
                }
            
            }
            else if(status.intValue == AGLogicJSONStatusNotSignin)
            {//not signin
                error = [AGMessageUtils errorNotSignin];
                NotSignin.string = @"YES";
                //
                NSMutableDictionary * oldDict = [NSMutableDictionary dictionaryWithCapacity:3];
                [oldDict setObject:url forKey:@"path"];
                if (params) {
                    [oldDict setObject:params forKey:@"params"];
                }
                if (context) {
                    [oldDict setObject:context forKey:@"context"];
                }
                if (block) {
                    [oldDict setObject:block forKey:@"block"];
                }
                
                
                [[AGManagerUtils managerUtils].accountManager autoSignin:oldDict];
            }
            else{
                error = [AGMessageUtils errorServer];
               
            }
        }
        
        if ([NotSignin isEqual:@"NO"]) {
            if (error && prompt) {
                [AGMessageUtils alertMessageWithError:error];
            }
            if (block) {
                block(error, context, result);
            }
        }
        
#ifdef IS_DEBUG
        if (error) {
            NSLog(@"AGJSONHttpHandler.request: %@", error.userInfo);
        }
#endif
        
    }];
}
@end
