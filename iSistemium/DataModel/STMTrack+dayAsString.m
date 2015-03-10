//
//  STMTrack+dayAsString.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 4/5/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STMTrack+dayAsString.h"
#import "STMFunctions.h"

@implementation STMTrack (dayAsString)

- (NSString *)dayAsString {

    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        formatter = [STMFunctions dateNumbersFormatter];
    });
    
    NSString *dateString;
    if (self.finishTime) {
        dateString = [formatter stringFromDate:self.finishTime];
    } else {
        dateString = [formatter stringFromDate:self.startTime];
    }
    return dateString;
}

@end
