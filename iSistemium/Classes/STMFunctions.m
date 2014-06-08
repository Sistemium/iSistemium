//
//  STFunctions.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMFunctions.h"

@implementation STMFunctions

+ (BOOL)isCorrectPhoneNumber:(NSString *)phoneNumberString {
    
    if ([phoneNumberString hasPrefix:@"8"]) {
        
        if (phoneNumberString.length == 11) {
            
            NSScanner* scan = [NSScanner scannerWithString:phoneNumberString];
            int val;
            return [scan scanInt:&val] && [scan isAtEnd];
            
        }
        
    }
    
    return NO;
    
}

+ (BOOL)isCorrectSMSCode:(NSString *)SMSCode {
    
    if (SMSCode.length == 4) {

        NSScanner* scan = [NSScanner scannerWithString:SMSCode];
        int val;
        return [scan scanInt:&val] && [scan isAtEnd];

    }
    
    return NO;
    
}

+ (NSData *)dataFromString:(NSString *)string {
    
    NSMutableData *data = [NSMutableData data];
    int i;
    
    for (i = 0; i+2 <= string.length; i+=2) {
        
        NSRange range = NSMakeRange(i, 2);
        NSString* hexString = [string substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexString];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
        
    }
    
    return data;
    
}


@end
