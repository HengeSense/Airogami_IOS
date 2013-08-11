//
//  AGUploadHttpHandler.m
//  Airogami
//
//  Created by Tianhu Yang on 8/2/13.
//  Copyright (c) 2013 Airogami. All rights reserved.
//

#import "AGUploadHttpHandler.h"
#import "AGURLConnection.h"
#import "AGDefines.h"
#import "AGMessageUtils.h"

static int AGUploadHttpHandlerDefaultCapacity = 1024;

@interface AGUploadHttpHandler()

@property(nonatomic, strong) NSMutableURLRequest *request;

@end

@implementation AGUploadHttpHandler

@synthesize request;

+ (AGUploadHttpHandler*) handler
{
    static dispatch_once_t  onceToken;
    static AGUploadHttpHandler * sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[AGUploadHttpHandler alloc] init];
    });
    return sSharedInstance;
}

- (NSString *)generateBoundaryString
{
    CFUUIDRef       uuid;
    CFStringRef     uuidStr;
    NSString *      result;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSString stringWithFormat:@"Boundary-%@", uuidStr];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

-(id)init
{
    if (self = [super init]) {
        request = [[NSMutableURLRequest alloc] init];
        request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        [request setHTTPMethod:@"POST"];
        
    }
    return self;
}

- (AGURLConnection*) uploadImage:(UIImage*)image  params:(NSDictionary*)params context:(id)context block:(AGHttpUploadHandlerFinishBlock)block
{
    static NSNumber *number;
    NSURL *url = [NSURL URLWithString:AGDataServerUrl];
    NSString *BoundaryConstant = [self generateBoundaryString];
    NSData *body = [self prepare:params  boundary:BoundaryConstant fileParam:@"file" fileType:@"Content-Type: image/jpeg" data:UIImageJPEGRepresentation(image, 1.0)];
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    
    // set Content-Type in HTTP header
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
    AGURLConnection *conn;
    @synchronized(number){
        request.URL = url;
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        [request setHTTPBody:body];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        conn = [[AGURLConnection alloc] initWithRequest:request delegate:self];
    }
    if (block) {
        [conn setValue:block forKey:@"ResultBlock"];
    }
    if (context) {
         [conn setValue:context forKey:@"Context"];
    }
    
    return conn;
}

- (NSData*) prepare:(NSDictionary*)params boundary:(NSString*)BoundaryConstant fileParam:(NSString*)fileParam fileType:(NSString*)fileType data:(NSData*)data
{
    // post body
    NSMutableData *body = [NSMutableData dataWithCapacity:1024 * 256];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]]; 
    // add params (all params are strings)
    for (NSString *param in params) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
   //
    if (data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"filename\"\r\n", fileParam] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n\r\n", fileType] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return body;
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
                length = AGUploadHttpHandlerDefaultCapacity;
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
    AGHttpUploadHandlerFinishBlock block = [connection valueForKey:@"ResultBlock"];
    //NSLog(@"%@", desc);
    id context = [connection valueForKey:@"Context"];
    if(block){
        block(error, context);
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
#ifdef IS_DEBUG
    NSLog(@"Connection failed! Error - %@ %@",[error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
#endif
    [[error.userInfo mutableCopy] setObject:AGHttpFailErrorTitleKey forKey:AGErrorTitleKey];
    AGHttpUploadHandlerFinishBlock block = [connection valueForKey:@"ResultBlock"];
    id context = [connection valueForKey:@"Context"];
    if(block){
        block(error, context);
    }
}

- (void)connectionDidFinishLoading:(AGURLConnection *)connection
{
    // do something with the data
    // data is declared as a method instance elsewhere
    //NSLog(@"Succeeded! Received %d bytes of data: %@",[data length], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

    AGHttpUploadHandlerFinishBlock block = [connection valueForKey:@"ResultBlock"];
    id context = [connection valueForKey:@"Context"];
    if(block){
        block(nil, context);
    }
    
}

@end
