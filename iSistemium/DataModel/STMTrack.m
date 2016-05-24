//
//  STMTrack.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMTrack.h"
#import "STMLocation.h"

#import "STMFunctions.h"


@implementation STMTrack

- (NSString *)dayAsString {
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        formatter = [STMFunctions dateNumbersFormatter];
    });
    
    NSString *dateString;
    if (self.finishTime) {
        dateString = [formatter stringFromDate:(NSDate * _Nonnull)self.finishTime];
    } else if (self.startTime) {
        dateString = [formatter stringFromDate:(NSDate * _Nonnull)self.startTime];
    }
    return dateString;
}


@end
