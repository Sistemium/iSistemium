//
//  STFunctions.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STMDateFormatter : NSDateFormatter

@end


@interface STMFunctions : NSObject

+ (BOOL)isCorrectPhoneNumber:(NSString *)phoneNumberString;
+ (BOOL)isCorrectSMSCode:(NSString *)SMSCode;

+ (NSData *)dataFromString:(NSString *)string;
+ (NSString *)xidStringFromXidData:(NSData *)xidData;

+ (NSString *)pluralTypeForCount:(NSUInteger)count;
+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size;

+ (STMDateFormatter *)dateFormatter;

@end
