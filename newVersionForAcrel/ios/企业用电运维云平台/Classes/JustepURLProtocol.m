//
//  JustepURLProtocol.m
//  CachedWebView
//
//  Created by 007slm on 6/25/14.
//
//
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSData+AES128.h"

#import "JustepURLProtocol.h"

@implementation JustepURLProtocol

+(BOOL)canInitWithRequest:(NSURLRequest *)request{
    NSString *localURI = [JustepURLProtocol getLocalURIByURL:request];
    NSLog(@"localURI:%@",localURI);
    if(!localURI.length){
        return NO;
    }
    localURI = [JustepURLProtocol pathForResource:localURI];
    
    if (localURI == NULL) {
        return NO;
    }
    return YES;
}
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}
+(NSString *)getLocalURIByURL:(NSURLRequest *)request{
    NSString *baseURL = @"";
    if ([[request URL] port] == nil) {
        baseURL = [NSString stringWithFormat:@"%@://%@/",[[request URL] scheme],[[request URL] host]];
    }else{
        NSURL *url = [request URL];
        NSString *urlStr =[url absoluteString];
        if ([urlStr hasPrefix:@"http://["]) {
            baseURL = [NSString stringWithFormat:@"%@://[%@]:%@/",[[request URL] scheme],[[request URL] host],[[request URL] port]];
        }else{
            baseURL = [NSString stringWithFormat:@"%@://%@:%@/",[[request URL] scheme],[[request URL] host],[[request URL] port]];
        }
    }
    if (!([[[request URL] scheme] isEqualToString:@"http"] || [[[request URL] scheme] isEqualToString:@"https"])) {
        return [[request URL] absoluteString];
    }
    NSString *localURI = [[[request URL] absoluteString] stringByReplacingOccurrencesOfString:baseURL withString:@""];
    
    NSRange range = [localURI rangeOfString:@"?"];
    if (range.length > 0 ) {
        localURI = [localURI substringToIndex:range.location];
    }
    
    NSRange rangeMao = [localURI rangeOfString:@"#"];
    if (rangeMao.length > 0 ) {
        localURI = [localURI substringToIndex:rangeMao.location];
    }
    return localURI;
}

+ (NSString *)pathForResource:(NSString*)resourcepath{
    //获取程序Documents目录路径
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    
    NSString* libPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    NSString* libPathNoSync = [libPath stringByAppendingPathComponent:@"NoCloud"];
    NSString* localURI = [[libPathNoSync stringByAppendingPathComponent:@"www"] stringByAppendingPathComponent:resourcepath];
    if([fileManager fileExistsAtPath:localURI]){
        NSLog(@"本地存在文件:%@",localURI);
        return localURI;
    }
   
    
    NSBundle* mainBundle = [NSBundle mainBundle];
    
    NSMutableArray* directoryParts = [NSMutableArray arrayWithArray:[resourcepath componentsSeparatedByString:@"/"]];
    NSString* filename = [directoryParts lastObject];
    [directoryParts removeLastObject];
    NSString* directoryPartsJoined = [directoryParts componentsJoinedByString:@"/"];
    NSString* directoryStr = @"www";
    
    if ([directoryPartsJoined length] > 0) {
        directoryStr = [NSString stringWithFormat:@"%@/%@/", @"www", [directoryParts componentsJoinedByString:@"/"]];
    }
    localURI = [mainBundle pathForResource:filename ofType:@"" inDirectory:directoryStr];
    if([fileManager fileExistsAtPath:localURI]){
        NSLog(@"本地存在文件:%@",localURI);
        return localURI;
    }
    
    NSLog(@"本地不存在文件:%@",localURI);
    return NULL;
}

-(NSString *)getMimeType:(NSString *)localURI{
    NSString *extension = [localURI pathExtension];
    
    CFStringRef typeId = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString* mimeType = @"*/*";
    if (typeId) {
        mimeType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass(typeId, kUTTagClassMIMEType);
        if (!mimeType) {
            // special case for m4a
            if ([(__bridge NSString*)typeId rangeOfString : @"m4a-audio"].location != NSNotFound) {
                mimeType = @"audio/mp4";
            } else if ([[localURI pathExtension] rangeOfString:@"wav"].location != NSNotFound) {
                mimeType = @"audio/wav";
            } else if ([[localURI pathExtension] rangeOfString:@"css"].location != NSNotFound) {
                mimeType = @"text/css";
            }
        }
        CFRelease(typeId);
    }
    if ([[extension lowercaseString] isEqualToString:@"w"]){
        mimeType = @"text/html";
    }
    NSLog(@"extension:%@",extension);
    return mimeType;
}

Boolean needDecrypted = false;

-(void)startLoading{
    NSLog(@"%@", [[self.request URL] absoluteString]);
    NSString *localURI = [JustepURLProtocol getLocalURIByURL:[self request]];
    localURI = [JustepURLProtocol pathForResource:localURI];
    NSString* mimeType = [self getMimeType:localURI];
    
    NSData *data = [NSData dataWithContentsOfFile:localURI];
    
    
    
    if(needDecrypted && ([localURI rangeOfString:@"/www/plugins/"].length <= 0) && ([localURI rangeOfString:@"/www/cordova"].length <= 0)){
        NSData *decryptedData =[data AES128Decrypt];
        [self sendResponseWithResponseCode:200 data:decryptedData mimeType:mimeType];
    }else{
        [self sendResponseWithResponseCode:200 data:data mimeType:mimeType];
    }
}


- (void)sendResponseWithResponseCode:(NSInteger)statusCode data:(NSData*)data mimeType:(NSString*)mimeType
{
    if (mimeType == nil) {
        mimeType = @"text/plain";
    }
    
    
    NSMutableDictionary* mutableHeaderFields = [[NSMutableDictionary alloc] init];
    mutableHeaderFields[@"Content-Type"] = mimeType;
    mutableHeaderFields[@"Content-Length"] = [NSString stringWithFormat:@"%lu",(unsigned long)data.length];
    //mutableHeaderFields[@"Content-Encoding"] = encodingName;
    //mutableHeaderFields[@"Access-Control-Allow-Origin"] = @"*";
    //mutableHeaderFields[@"Access-Control-Allow-Headers"] = @"Content-Type";
    
    NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:[[self request] URL] statusCode:statusCode HTTPVersion:@"1.1" headerFields:mutableHeaderFields];
    
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self client] URLProtocol:self didLoadData:data];
    [[self client] URLProtocolDidFinishLoading:self];
}


- (void)stopLoading{
    NSLog(@"stoploading!");
}

@end
