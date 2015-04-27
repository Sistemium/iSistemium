//
//  STFunctions.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMConstants.h"

@interface STMDateFormatter : NSDateFormatter

@end


@interface STMFunctions : NSObject

+ (BOOL)isCorrectPhoneNumber:(NSString *)phoneNumberString;
+ (BOOL)isCorrectSMSCode:(NSString *)SMSCode;

+ (NSData *)dataFromString:(NSString *)string;
+ (NSData *)xidDataFromXidString:(NSString *)xidString;
+ (NSString *)UUIDStringFromUUIDData:(NSData *)UUIDData;
+ (NSString *)hexStringFromData:(NSData *)data;

+ (NSString *)pluralTypeForCount:(NSUInteger)count;

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size;

+ (NSNumber *)daysFromTodayToDate:(NSDate *)date;

+ (STMDateFormatter *)dateFormatter;
+ (NSDateFormatter *)dateNumbersFormatter;
+ (NSDateFormatter *)dateShortNoTimeFormatter;
+ (NSDateFormatter *)dateMediumNoTimeFormatter;
+ (NSDateFormatter *)dateMediumTimeMediumFormatter;
+ (NSDateFormatter *)dateLongNoTimeFormatter;
+ (void)NSLogCurrentDateWithMilliseconds;

+ (NSNumberFormatter *)decimalFormatter;
+ (NSNumberFormatter *)decimalMaxTwoDigitFormatter;
+ (NSNumberFormatter *)decimalMinTwoDigitFormatter;
+ (NSNumberFormatter *)decimalMaxTwoMinTwoDigitFormatter;
+ (NSNumberFormatter *)currencyFormatter;
+ (NSNumberFormatter *)percentFormatter;

+ (NSString *)dayWithDayOfWeekFromDate:(NSDate *)date;

+ (NSString *)MD5FromString:(NSString *)string;

+ (NSString *)devicePlatform;
+ (NSString *)currentAppVersion;

+ (NSString *)documentsDirectory;
+ (NSString *)absolutePathForPath:(NSString *)path;

+ (UIColor *)colorForColorString:(NSString *)colorSting;

+ (CGRect)frameOfHighlightedTabBarButtonForTBC:(UITabBarController *)tabBarController;

+ (NSString *)jsonStringFromDictionary:(NSDictionary *)objectDic;


@end
