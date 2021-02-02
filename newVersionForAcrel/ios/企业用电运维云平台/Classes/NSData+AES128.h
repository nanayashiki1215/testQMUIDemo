//

//  X5
//
//  Created by 007slm on 12/24/14.
//
//

#import <Foundation/Foundation.h>

@interface NSData (AES128)

//@class NSString;

- (NSData *)AES128Decrypt;

- (NSData *)AES128EncryptWithKey:(NSString *) key ivKey:(NSString *)ivkey;//加密
- (NSData *)AES128DecryptWithKey:(NSString *) key ivkey:(NSString * )ivkey;//解密
@end
