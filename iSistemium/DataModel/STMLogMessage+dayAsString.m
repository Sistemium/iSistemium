//
//  STMLogMessage+dayAsString.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 5/8/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STMLogMessage+dayAsString.h"
#import "STMFunctions.h"

@implementation STMLogMessage (dayAsString)

- (NSString *)dayAsString {
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{        
        formatter = [STMFunctions dateNumbersFormatter];
    });
    
    return [formatter stringFromDate:self.deviceCts];
    
}


@end
