//
//  STFunctions.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMFunctions.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/sysctl.h>

@implementation STMDateFormatter

- (NSDate *)dateFromString:(NSString *)string {

    if (string.length == 10) {
        
        self.dateFormat = @"yyyy-MM-dd";
        
    }
    
    return [super dateFromString:string];
    
}


@end


@implementation STMFunctions


+ (STMDateFormatter *)dateFormatter {
    
    STMDateFormatter *dateFormatter = [[STMDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    
    return dateFormatter;
    
}

+ (NSNumberFormatter *)decimalFormatter {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits = 2;

    return numberFormatter;
    
}

+ (NSNumber *)daysFromTodayToDate:(NSDate *)date {
    
    NSDate *today = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    today = [dateFormatter dateFromString:[dateFormatter stringFromDate:today]];
    date = [dateFormatter dateFromString:[dateFormatter stringFromDate:date]];
    
    NSTimeInterval interval = [date timeIntervalSinceDate:today];
    
    int numberOfDays = floor(interval / (60 * 60 * 24));
    
    return @(numberOfDays);
    
}

+ (BOOL)isCorrectPhoneNumber:(NSString *)phoneNumberString {
    
    if ([phoneNumberString hasPrefix:@"8"]) {
        
        if (phoneNumberString.length == 11) {
            
            NSScanner *scan = [NSScanner scannerWithString:phoneNumberString];
            int val;
            return [scan scanInt:&val] && [scan isAtEnd];
            
        }
        
    }
    
    return NO;
    
}

+ (BOOL)isCorrectSMSCode:(NSString *)SMSCode {
    
    if (SMSCode.length > 3 && SMSCode.length < 7) {

        NSScanner *scan = [NSScanner scannerWithString:SMSCode];
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
        NSString *hexString = [string substringWithRange:range];
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
        
    }
    
    return data;
    
}

+ (NSString *)xidStringFromXidData:(NSData *)xidData {
    
    CFUUIDBytes uuidBytes;
    [xidData getBytes:&uuidBytes length:xidData.length];
    
    CFUUIDRef CFXid = CFUUIDCreateFromUUIDBytes(kCFAllocatorDefault, uuidBytes);
    CFStringRef CFXidString = CFUUIDCreateString(kCFAllocatorDefault, CFXid);
    CFRelease(CFXid);
    
    NSString *xidString = (NSString *)CFBridgingRelease(CFXidString);
    
    return xidString;
    
}

+ (NSString *)hexStringFromData:(NSData *)data {
 
    NSUInteger dataLength = [data length];
    NSMutableString *string = [NSMutableString string];
    const unsigned char *dataBytes = [data bytes];
    
    for (NSInteger i = 0; i < dataLength; ++i) {
        [string appendFormat:@"%02X", dataBytes[i]];
    }
    
    return string;
    
}

+ (NSString *)pluralTypeForCount:(NSUInteger)count {
    
    NSString *result;
    
    if (count == 0) {
        
        result = @"0";
        
    } else {

        int testNumber = count % 100;
        
        if (testNumber >= 11 && testNumber <= 19) {
            
            result = @"5";
            
        } else {
            
            int switchNumber = testNumber % 10;
            
            switch (switchNumber) {
                    
                case 1:
                    result = @"1";
                    break;
                    
                case 2:
                case 3:
                case 4:
                    result = @"2";
                    break;
                    
                default:
                    result = @"5";
                    break;
                    
            }
            
        }

    }
    
    return result;
    
}

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    
    if (image.size.height > 0 && image.size.width > 0) {
        
        CGFloat width = size.width;
        CGFloat height = size.height;
        
        if (image.size.width >= image.size.height) {
            
            height = width * image.size.height / image.size.width;
            
        } else {
            
            width = height * image.size.width / image.size.height;
            
        }
        
        // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
        // Pass 1.0 to force exact pixel size.
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width ,height), NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, width, height)];
        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resultImage;

    } else {
        
        return nil;
        
    }
    
}

+ (NSString *)MD5FromString:(NSString *)string {

    if (string) {
        
        // Create pointer to the string as UTF8
        const char *ptr = [string UTF8String];
        
        // Create byte array of unsigned chars
        unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
        
        // Create 16 byte MD5 hash value, store in buffer
        // (CC_LONG) — is for removing warning
        CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
        
        // Convert MD5 value in the buffer to NSString of hex values
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        
        for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", md5Buffer[i]];
        }
        
        return output;

    } else {
        
        return nil;
        
    }
    
}

+ (NSString *)devicePlatform {
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = @(machine);
    free(machine);
    
    return platform;
    
}


@end
