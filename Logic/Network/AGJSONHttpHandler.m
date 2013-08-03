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

#define AGJSONHttpHandlerDefaultCapacity (16 * 1024)

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
    }
    return self;
}


- (AGURLConnection*) start:(NSString*)path  context:(id)context block:(AGHttpJSONHandlerFinishBlock)block
{
    static NSNumber *number;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", AGWebServerUrl, path]];
    AGURLConnection *conn;
    @synchronized(number){
        request.URL = url;
        conn = [[AGURLConnection alloc] initWithRequest:request delegate:self];
    }
    if (context) {
        [conn setValue:context forKey:@"Context"];
    }
    [conn setValue:block forKey:@"ResultBlock"];
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
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:desc forKey:NSLocalizedDescriptionKey];
    //NSError *error = [[NSError alloc] initWithDomain:@"Network" code:-1 userInfo:details];
    AGHttpJSONHandlerFinishBlock block = [connection valueForKey:@"ResultBlock"];
    id context = [connection valueForKey:@"Context"];
    block(nil,context, nil);
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
    NSLog(@"Connection failed! Error - %@ %@",[error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    AGHttpJSONHandlerFinishBlock block = [connection valueForKey:@"ResultBlock"];
    id context = [connection valueForKey:@"Context"];
    block(error,context, nil);
}

- (void)connectionDidFinishLoading:(AGURLConnection *)connection
{
    // do something with the data
    // data is declared as a method instance elsewhere
    NSMutableData *data = [connection valueForKey:@"ReceivedData"];
    NSLog(@"Succeeded! Received %d bytes of data",[data length]);
    NSMutableDictionary *dict = nil;
    dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    AGHttpJSONHandlerFinishBlock block = [connection valueForKey:@"ResultBlock"];
    id context = [connection valueForKey:@"Context"];
    block(nil,context, dict);
    
}

@end
