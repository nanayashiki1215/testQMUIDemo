//
//  LZKeychain.m
// 
//
//  Created by ohundre on 2018/9/10.
//

#import "LZKeychain.h"

@implementation LZKeychain

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(NSString *)getDeviceIDInKeychain
    {
        NSString *getUDIDInKeychain = (NSString *)[LZKeychain load:KEY_UDID_INSTEAD];
        DefLog(@"从keychain中获取到的 UDID_INSTEAD %@",getUDIDInKeychain);
        if (!getUDIDInKeychain ||[getUDIDInKeychain isEqualToString:@""]||[getUDIDInKeychain isKindOfClass:[NSNull class]]) {
            CFUUIDRef puuid = CFUUIDCreate( nil );
            CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
            NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
            CFRelease(puuid);
            CFRelease(uuidString);
            DefLog(@"\n \n \n _____重新存储 UUID _____\n \n \n  %@",result);
            [LZKeychain save:KEY_UDID_INSTEAD data:result];
            getUDIDInKeychain = (NSString *)[LZKeychain load:KEY_UDID_INSTEAD];
        }
        DefLog(@"最终 ———— UDID_INSTEAD %@",getUDIDInKeychain);
        return getUDIDInKeychain;
    }
    
#pragma mark - private
    
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}
    
+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}
    
+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            NSData *my_nsdata = (__bridge_transfer NSData*)keyData;
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:my_nsdata];
        } @catch (NSException *e) {
            DefLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
    CFRelease(keyData);
    return ret;
}
    
+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

@end
