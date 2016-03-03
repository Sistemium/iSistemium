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
+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size allowRetina:(BOOL)retina;
+ (UIImage *)colorImage:(UIImage *)origImage withColor:(UIColor *)color;
+ (UIImage *)drawText:(NSString *)text withFont:(UIFont *)font color:(UIColor *)color inImage:(UIImage *)image atCenter:(BOOL)atCenter;

+ (NSNumber *)daysFromTodayToDate:(NSDate *)date;

+ (NSString *)displayDateInfo:(NSString *)dateInfo;

+ (STMDateFormatter *)dateFormatter;
+ (NSDateFormatter *)dateNumbersFormatter;
+ (NSDateFormatter *)dateNumbersFormatterTwo;
+ (NSDateFormatter *)dateShortNoTimeFormatter;
+ (NSDateFormatter *)dateShortTimeShortFormatter;
+ (NSDateFormatter *)dateMediumNoTimeFormatter;
+ (NSDateFormatter *)dateLongNoTimeFormatter;
+ (NSDateFormatter *)dateMediumTimeMediumFormatter;
+ (NSDateFormatter *)dateMediumTimeShortFormatter;
+ (NSDateFormatter *)noDateShortTimeFormatter;
+ (NSDateFormatter *)noDateMediumTimeFormatter;
+ (NSDateFormatter *)noDateShortTimeFormatterAllowZero:(BOOL)allowZero;

+ (void)NSLogCurrentDateWithMilliseconds;

+ (NSDate *)dateFromDouble:(double)time;
+ (double)currentTimeInDouble;

+ (NSString *)trueMinus;

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

// - JSON representation

+ (NSString *)jsonStringFromArray:(NSArray *)objectArray;
+ (NSString *)jsonStringFromDictionary:(NSDictionary *)objectDic;
+ (NSDictionary *)validJSONDictionaryFromDictionary:(NSDictionary *)dictionary;

+ (NSString *)volumeStringWithVolume:(NSInteger)volume andPackageRel:(NSInteger)packageRel;

+ (BOOL)shouldHandleMemoryWarningFromVC:(UIViewController *)vc;
+ (void)nilifyViewForVC:(UIViewController *)vc;
+ (void)logMemoryStat;

+ (NSString *)shortCompanyName:(NSString *)companyName;

+ (NSString *)appStateString;

+ (uint64_t)freeDiskspace;


@end
