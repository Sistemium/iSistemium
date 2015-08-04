//
//  STFunctions.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMFunctions.h"

#import "STMLogger.h"

#import <CommonCrypto/CommonDigest.h>
#import <sys/sysctl.h>
#import "mach/mach.h"


@implementation STMDateFormatter

- (NSDate *)dateFromString:(NSString *)string {

    if (string.length == 10) {
        
        self.dateFormat = @"yyyy-MM-dd";
        
    }
    
    return [super dateFromString:string];
    
}


@end


@implementation STMFunctions

#pragma mark - date formatters

+ (STMDateFormatter *)dateFormatter {
    
    STMDateFormatter *dateFormatter = [[STMDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    
    return dateFormatter;
    
}

+ (NSDateFormatter *)dateNumbersFormatter {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy/MM/dd";

    return dateFormatter;
    
}

+ (NSDateFormatter *)dateNoTimeFormatter {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    return dateFormatter;

}

+ (NSDateFormatter *)dateShortNoTimeFormatter {
    
    NSDateFormatter *dateFormatter = [self dateNoTimeFormatter];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    return dateFormatter;
    
}

+ (NSDateFormatter *)dateShortTimeShortFormatter {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    return dateFormatter;
    
}

+ (NSDateFormatter *)dateMediumNoTimeFormatter {
    
    NSDateFormatter *dateFormatter = [self dateNoTimeFormatter];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;

    return dateFormatter;
    
}

+ (NSDateFormatter *)dateLongNoTimeFormatter {
    
    NSDateFormatter *dateFormatter = [self dateNoTimeFormatter];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    
    return dateFormatter;
    
}

+ (NSDateFormatter *)dateMediumTimeMediumFormatter {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;

    return dateFormatter;

}

+ (NSDateFormatter *)dateMediumTimeShortFormatter {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    return dateFormatter;
    
}

+ (NSDateFormatter *)noDateShortTimeFormatter {

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    return dateFormatter;

}

+ (void)NSLogCurrentDateWithMilliseconds {
    NSLog(@"%@", [[self dateFormatter] stringFromDate:[NSDate date]]);
}


#pragma mark - date as double

+ (NSDate *)dateFromDouble:(double)time {
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    double seconds = time * 3600;
    currentDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:currentDate]];
    return [NSDate dateWithTimeInterval:seconds sinceDate:currentDate];
    
}

+ (double)currentTimeInDouble {
    
    NSDate *localDate = [NSDate date];
    
    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
    hourFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    hourFormatter.dateFormat = @"HH";
    double hour = [[hourFormatter stringFromDate:localDate] doubleValue];
    
    NSDateFormatter *minuteFormatter = [[NSDateFormatter alloc] init];
    minuteFormatter.dateFormat = @"mm";
    double minute = [[minuteFormatter stringFromDate:localDate] doubleValue];

    NSDateFormatter *secondsFormatter = [[NSDateFormatter alloc] init];
    secondsFormatter.dateFormat = @"ss";
    double seconds = [[secondsFormatter stringFromDate:localDate] doubleValue];
    
    double currentTime = hour + minute/60 + seconds/3600;
    
    return currentTime;
    
}


#pragma mark - number formatters

+ (NSNumberFormatter *)trueMinusFormatter {

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.minusSign = @"\u2212"; // U+2212 TRUE MINUS SIGN
    
    return numberFormatter;

}

+ (NSNumberFormatter *)decimalFormatter {

    NSNumberFormatter *numberFormatter = [self trueMinusFormatter];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    return numberFormatter;

}

+ (NSNumberFormatter *)decimalMaxTwoDigitFormatter {
    
    NSNumberFormatter *numberFormatter = [self decimalFormatter];
    numberFormatter.maximumFractionDigits = 2;

    return numberFormatter;
    
}

+ (NSNumberFormatter *)decimalMinTwoDigitFormatter {

    NSNumberFormatter *numberFormatter = [self decimalFormatter];
    numberFormatter.minimumFractionDigits = 2;
    
    return numberFormatter;

}

+ (NSNumberFormatter *)decimalMaxTwoMinTwoDigitFormatter {
    
    NSNumberFormatter *numberFormatter = [self decimalMaxTwoDigitFormatter];
    numberFormatter.minimumFractionDigits = 2;

    return numberFormatter;
    
}

+ (NSNumberFormatter *)currencyFormatter {
    
    NSNumberFormatter *numberFormatter = [self trueMinusFormatter];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    return numberFormatter;
    
}

+ (NSNumberFormatter *)percentFormatter {
    
    NSNumberFormatter *numberFormatter = [self trueMinusFormatter];
    numberFormatter.numberStyle = NSNumberFormatterPercentStyle;
    numberFormatter.positivePrefix = @"+";

    return numberFormatter;
    
}


#pragma mark - days calc

+ (NSNumber *)daysFromTodayToDate:(NSDate *)date {
    
    NSDate *today = [NSDate date];
    
    NSDateFormatter *dateFormatter = [self dateShortNoTimeFormatter];
    
    today = [dateFormatter dateFromString:[dateFormatter stringFromDate:today]];
    date = [dateFormatter dateFromString:[dateFormatter stringFromDate:date]];
    
    NSTimeInterval interval = [date timeIntervalSinceDate:today];
    
    int numberOfDays = floor(interval / (60 * 60 * 24));
    
    return @(numberOfDays);
    
}

+ (NSString *)dayWithDayOfWeekFromDate:(NSDate *)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd MMMM yyyy, EEE";
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSNumber *numberOfDays = [STMFunctions daysFromTodayToDate:date];

    NSString *dayString = nil;
    
    if ([numberOfDays intValue] == 0) {
        
        dayString = NSLocalizedString(@"TODAY", nil);
        
    } else if ([numberOfDays intValue] == -1) {
        
        dayString = NSLocalizedString(@"YESTERDAY", nil);
        
    } else if ([numberOfDays intValue] == 1) {
        
        dayString = NSLocalizedString(@"TOMORROW", nil);
        
    }
    
    if (dayString) dateString = [NSString stringWithFormat:@"%@, %@", dateString, [dayString lowercaseString]];
    
    return dateString;
    
}


#pragma mark - phone number & sms-code checking

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


#pragma mark - NSString <-> NSData manipulation

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

+ (NSData *)xidDataFromXidString:(NSString *)xidString {
    
    NSData *xidData = (xidString) ? [self dataFromString:[xidString stringByReplacingOccurrencesOfString:@"-" withString:@""]] : nil;
    
    return xidData;
    
}

+ (NSString *)UUIDStringFromUUIDData:(NSData *)UUIDData {
    
    CFUUIDBytes UUIDBytes;
    [UUIDData getBytes:&UUIDBytes length:UUIDData.length];
    
    CFUUIDRef CFUUID = CFUUIDCreateFromUUIDBytes(kCFAllocatorDefault, UUIDBytes);
    CFStringRef CFUUIDString = CFUUIDCreateString(kCFAllocatorDefault, CFUUID);
    CFRelease(CFUUID);
    
    NSString *UUIDString = (NSString *)CFBridgingRelease(CFUUIDString);
    
    return UUIDString;
    
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


#pragma mark - some other usefull methods

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
    return [self resizeImage:image toSize:size allowRetina:YES];
}

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size allowRetina:(BOOL)retina {
    
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
        
        CGFloat scale = (retina) ? 0.0 : 1.0;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width ,height), NO, scale);
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

+ (NSString *)currentAppVersion {
    
    NSDictionary *infoDictionary = [NSBundle mainBundle].infoDictionary;
    NSString *displayName = infoDictionary[@"CFBundleDisplayName"];
    NSString *appVersionString = APP_VERSION;
    NSString *buildVersion = BUILD_VERSION;
    
    NSString *result = [NSString stringWithFormat:@"%@ %@ (%@)", displayName, appVersionString, buildVersion];
    
//    NSLog(@"infoDictionary %@", infoDictionary);
    
    return result;
    
}

+ (NSString *)documentsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = ([paths count] > 0) ? paths[0] : nil;

    return documentsDirectory;
    
}

+ (NSString *)absolutePathForPath:(NSString *)path {
    return [[self documentsDirectory] stringByAppendingPathComponent:path];
}

+ (UIColor *)colorForColorString:(NSString *)colorSting {
    
    NSString *selectorString = [colorSting stringByAppendingString:@"Color"];
    
    SEL selector = NSSelectorFromString(selectorString);
    
    if ([UIColor respondsToSelector:selector]) {
        
// next 3 lines — implementation of id value = [self performSelector:selector] w/o warning
        IMP imp = [UIColor methodForSelector:selector];
        id (*func)(id, SEL) = (void *)imp;
        id value = func([UIColor class], selector);
        
        return value;
        
    } else {
        
        return nil;
        
    }
    
}

+ (CGRect)frameOfHighlightedTabBarButtonForTBC:(UITabBarController *)tabBarController {
    
    CGFloat tabBarYPosition = tabBarController.tabBar.frame.origin.y;
    CGRect rect;
    
    NSMutableArray *tabBarSubviews = [tabBarController.tabBar.subviews mutableCopy];
    
    for (UIView *view in tabBarSubviews) {
        
        if ([view isKindOfClass:[UIControl class]]) {
            
            UIControl *controlView = (UIControl *)view;
            if (controlView.highlighted) rect = controlView.frame;
            
        }
        
    }
    
    rect = CGRectMake(rect.origin.x, rect.origin.y + tabBarYPosition, rect.size.width, rect.size.height);

    return rect;
    
}


#pragma mark - JSON representation

+ (NSString *)jsonStringFromDictionary:(NSDictionary *)objectDic {

    if (![NSJSONSerialization isValidJSONObject:objectDic]) {
        
        objectDic = [self validJSONDictionaryFromDictionary:objectDic];
        
    }
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:objectDic options:0 error:nil];
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    
    return JSONString;

}

+ (NSDictionary *)validJSONDictionaryFromDictionary:(NSDictionary *)dictionary {
    
    NSMutableDictionary *validDictionary = [NSMutableDictionary dictionary];
    
    for (id key in dictionary.allKeys) {
        
        NSString *keyString = ([key isKindOfClass:[NSString class]]) ? key : [key description];
        
        if ([dictionary[key] isKindOfClass:[NSDictionary class]]) {
            
            validDictionary[keyString] = [self validJSONDictionaryFromDictionary:dictionary[key]];
            
        } else if ([dictionary[key] isKindOfClass:[NSArray class]]) {
            
            validDictionary[keyString] = [self validJSONArrayFromArray:dictionary[key]];
            
        } else if (![dictionary[key] isKindOfClass:[NSString class]]) {
            
            validDictionary[keyString] = [dictionary[key] description];
            
        } else {
            
            validDictionary[keyString] = dictionary[key];
            
        }
        
    }
    
    return validDictionary;
    
}

+ (NSArray *)validJSONArrayFromArray:(NSArray *)array {
    
    NSMutableArray *validArray = [NSMutableArray array];
    
    for (id arrayItem in array) {
        
        if ([arrayItem isKindOfClass:[NSDictionary class]]) {
            
            [validArray addObject:[self validJSONDictionaryFromDictionary:arrayItem]];
            
        } else if ([arrayItem isKindOfClass:[NSArray class]]) {
            
            [validArray addObject:[self validJSONArrayFromArray:arrayItem]];
            
        } else if (![arrayItem isKindOfClass:[NSString class]]) {
            
            [validArray addObject:[arrayItem description]];
            
        } else {
            
            [validArray addObject:arrayItem];
            
        }
        
    }
    
    return validArray;
    
}


+ (NSString *)volumeStringWithVolume:(NSInteger)volume andPackageRel:(NSInteger)packageRel {
    
    NSString *volumeUnitString = nil;
    NSString *infoText = nil;
    
    if (packageRel != 0 && volume >= packageRel) {
        
        NSInteger package = floor(volume / packageRel);
        
        volumeUnitString = NSLocalizedString(@"VOLUME UNIT1", nil);
        NSString *packageString = [NSString stringWithFormat:@"%ld %@", (long)package, volumeUnitString];
        
        NSInteger bottle = volume % packageRel;
        
        if (bottle > 0) {
            
            volumeUnitString = NSLocalizedString(@"VOLUME UNIT2", nil);
            NSString *bottleString = [NSString stringWithFormat:@" %ld %@", (long)bottle, volumeUnitString];
            
            packageString = [packageString stringByAppendingString:bottleString];
            
        }
        
        infoText = packageString;
        
    } else {
        
        volumeUnitString = NSLocalizedString(@"VOLUME UNIT2", nil);
        infoText = [NSString stringWithFormat:@"%ld %@", (long)volume, volumeUnitString];
        
    }

    return infoText;
    
}


#pragma mark - memory warning handle

+ (BOOL)shouldHandleMemoryWarningFromVC:(UIViewController *)vc {
    
    if ([vc isViewLoaded] && [vc.view window] == nil) {
        
        NSString *logMessage = [NSString stringWithFormat:@"%@ receive memory warning. %@", NSStringFromClass(vc.class), [self memoryStatistic]];
        [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"important"];
        
        return YES;
        
    } else {
        
        return NO;
        
    }
    
}

+ (void)logMemoryUsageFromVC:(UIViewController *)vc {

    NSString *logMessage = [NSString stringWithFormat:@"%@ set it's view to nil. %@", NSStringFromClass(vc.class), [self memoryStatistic]];
    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"important"];

}

+ (NSString *)memoryStatistic {
    
    NSString *usedMemoryString = [NSString stringWithFormat:@"Used memory: %f Kb", usedMemory()/1024.0f];
    NSString *freeMemoryString = [NSString stringWithFormat:@"Free memory: %f Kb", freeMemory()/1024.0f];
    
    return [NSString stringWithFormat:@"%@ / %@", usedMemoryString, freeMemoryString];
    
}

vm_size_t usedMemory(void) {
    
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
    
}

vm_size_t freeMemory(void) {
    
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    
    return vm_stat.free_count * pagesize;
    
}



@end
