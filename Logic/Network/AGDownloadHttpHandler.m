//
//  AGDownloadHttpHandler.m
//  Airogami
//
//  Created by Tianhu Yang on 8/4/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGDownloadHttpHandler.h"
#import "AGMessageUtils.h"
#import "AGManagerUtils.h"

static const int AGDownloadDefaultCapacity = 1024 * 256;

@interface AGDownloadHttpHandler()<NSURLConnectionDelegate>
{
    NSNumber *mutex;
}

@property(nonatomic, strong) NSMutableURLRequest *request;

@end

@implementation AGDownloadHttpHandler

@synthesize request;

+ (AGDownloadHttpHandler*) handler
{
    static dispatch_once_t  onceToken;
    static AGDownloadHttpHandler * sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[AGDownloadHttpHandler alloc] init];
    });
    return sSharedInstance;
}

-(id)init
{
    if (self = [super init]) {
        request = [[NSMutableURLRequest alloc] init];
        request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        mutex = [NSNumber numberWithBool:YES];
    }
    return self;
}

- (NSURLConnection*) start:(NSString*)path context:(id)context block:(AGDownloadHttpHandlerFinishBlock)block
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", AGDataServerUrl, path]];
    AGURLConnection *conn;
    @synchronized(mutex){
        request.URL = url;
        conn = [[AGURLConnection alloc] initWithRequest:request delegate:self];
        [[AGManagerUtils managerUtils].networkManager addURLConnection:conn];
    }
    if (context) {
        [conn setValue:context forKey:@"Context"];
    }
    if (block) {
        [conn setValue:block forKey:@"ResultBlock"];
    }
    
    return conn;
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
    if ((httpResponse.statusCode / 100) != 2) {
        NSString *desc = [NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode];
        [self stopConnection:connection description:desc];
        
    } else {
        // -MIMEType strips any parameters, strips leading or trailer whitespace, and lower cases
        // the string, so we can just use -isEqual: on the result.
        contentTypeHeader = [httpResponse MIMEType];
        if (contentTypeHeader == nil) {
            [self stopConnection:connection description:@"No Content-Type!"];
        } else{
            NSNumber *number = [httpResponse.allHeaderFields objectForKey:@"Content-Length"];
            int length = 0;
            if (number) {
                length = [number intValue];
            }
            else{
                length = AGDownloadDefaultCapacity;
            }
            NSMutableData *data = [[NSMutableData alloc] initWithCapacity:length];
            [connection setValue:data forKey:@"ReceivedData"];
        }
    }
}

- (void) stopConnection:(AGURLConnection *)connection description:(NSString*)desc
{
    //
    [[AGManagerUtils managerUtils].networkManager removeURLConnection:connection];
    [connection cancel];
    /* called in cancel
    NSError *error = [AGMessageUtils errorServer];
    AGDownloadHttpHandlerFinishBlock block = [connection valueForKey:@"ResultBlock"];
    id context = [connection valueForKey:@"Context"];
    if (block) {
        block(error, nil, context);
    }*/
    
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
    //
    [[AGManagerUtils managerUtils].networkManager removeURLConnection:connection];
#ifdef IS_DEBUG
    NSLog(@"Connection failed! Error - %@ %@",[error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
#endif
    [[error.userInfo mutableCopy] setObject:AGHttpFailErrorTitleKey forKey:AGErrorTitleKey];
    AGDownloadHttpHandlerFinishBlock block = [connection valueForKey:@"ResultBlock"];
    id context = [connection valueForKey:@"Context"];
    if (block) {
        block(error,nil, context);
    }
    
}

- (void)connectionDidFinishLoading:(AGURLConnection *)connection
{
    //
    [[AGManagerUtils managerUtils].networkManager removeURLConnection:connection];
    // do something with the data
    NSMutableData *data = [connection valueForKey:@"ReceivedData"];
    //NSLog(@"Succeeded! Received %d bytes of data",[data length]);
    AGDownloadHttpHandlerFinishBlock block = [connection valueForKey:@"ResultBlock"];
    id context = [connection valueForKey:@"Context"];
    if (block) {
        block(nil, data, context);
    }
    
}

@end
