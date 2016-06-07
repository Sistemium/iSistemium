//
//  STMKeychain.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/06/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMKeychain.h"

#define CHECK_OSSTATUS_ERROR(x) (x == noErr) ? YES : NO


@implementation STMKeychain

// method below was overwrited to set kSecAttrAccessible to kSecAttrAccessibleAlways

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)key forAccessGroup:(NSString *)group {
    
    NSMutableDictionary *keychainQuery = [self keychainQueryTemplateForKey:key];
    keychainQuery[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAlways;
    
    if (group != nil) {
        [keychainQuery setObject:[self getFullAppleIdentifier:group] forKey:(__bridge id)kSecAttrAccessGroup];
    }
    
    return keychainQuery;
    
}

+ (NSString *)getFullAppleIdentifier:(NSString *)bundleIdentifier {
    
    NSString *bundleSeedIdentifier = [self getBundleSeedIdentifier];
    if (bundleSeedIdentifier != nil && [bundleIdentifier rangeOfString:bundleSeedIdentifier].location == NSNotFound) {
        bundleIdentifier = [NSString stringWithFormat:@"%@.%@", bundleSeedIdentifier, bundleIdentifier];
    }
    return bundleIdentifier;
    
}

+ (BOOL)deleteValueForKey:(NSString *)key forAccessGroup:(NSString *)group {
    
    NSMutableDictionary *keychainQuery = [self getAccessibleAfterFirstUnlockKeychainQuery:key forAccessGroup:group];
    OSStatus result = SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    BOOL resultOne = CHECK_OSSTATUS_ERROR(result);

    keychainQuery = [self getAccessibleAlwaysKeychainQuery:key forAccessGroup:group];
    result = SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    BOOL resultTwo = CHECK_OSSTATUS_ERROR(result);

    return (resultOne || resultTwo);
    
}

+ (NSMutableDictionary *)getAccessibleAfterFirstUnlockKeychainQuery:(NSString *)key forAccessGroup:(NSString *)group {
    
    NSMutableDictionary *keychainQuery = [self keychainQueryTemplateForKey:key];
    keychainQuery[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
    
    if (group != nil) {
        [keychainQuery setObject:[self getFullAppleIdentifier:group] forKey:(__bridge id)kSecAttrAccessGroup];
    }
    
    return keychainQuery;
    
}

+ (NSMutableDictionary *)getAccessibleAlwaysKeychainQuery:(NSString *)key forAccessGroup:(NSString *)group {
    
    NSMutableDictionary *keychainQuery = [self keychainQueryTemplateForKey:key];
    keychainQuery[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAlways;
    
    if (group != nil) {
        [keychainQuery setObject:[self getFullAppleIdentifier:group] forKey:(__bridge id)kSecAttrAccessGroup];
    }
    
    return keychainQuery;
    
}

+ (NSMutableDictionary *)keychainQueryTemplateForKey:(NSString *)key {
    
    NSMutableDictionary *keychainQueryTemplate = @{(__bridge id)kSecClass            : (__bridge id)kSecClassGenericPassword,
                                                   (__bridge id)kSecAttrService      : key,
                                                   (__bridge id)kSecAttrAccount      : key
                                                   }.mutableCopy;
    return keychainQueryTemplate;

}

@end
