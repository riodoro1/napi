//
//  NSData+MD5Sum.m
//  napi
//
//  Created by Rafał Białek on 08/09/14.
//  Copyright (c) 2014 Rafał Białek. All rights reserved.
//

#import "NSData+MD5Sum.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (MD5Sum)

-(NSString*) MD5Sum
{
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5((const void*)([self bytes]), (CC_LONG)[self length], md5Buffer);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", md5Buffer[i]];
    
    return output;
}

@end
