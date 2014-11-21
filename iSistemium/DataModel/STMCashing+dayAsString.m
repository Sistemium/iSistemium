//
//  STMCashing+dayAsString.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCashing+dayAsString.h"
#import "STMDebt+Cashing.h"
#import "STMOutlet+photoReportsArePresent.h"

@implementation STMCashing (dayAsString)

- (NSString *)dayAsString {
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;

    });
    
    NSString *dateString = [formatter stringFromDate:self.date];
    
    return dateString;
    
}

- (void)willSave {
    
    BOOL isProcessedChanged = [[[self changedValues] allKeys] containsObject:@"isProcessed"];
    
    if (isProcessedChanged) {

        NSDecimalNumber *newCalculatedSum = [self.debt cashingCalculatedSum];
        NSDecimalNumber *oldCalculatedSum = self.debt.calculatedSum;
        
        if ([newCalculatedSum compare:oldCalculatedSum] != NSOrderedSame) {
            
            [self.debt willChangeValueForKey:@"calculatedSum"];
            [self.debt setPrimitiveValue:newCalculatedSum forKey:@"calculatedSum"];
            [self.debt didChangeValueForKey:@"calculatedSum"];

        }
        
/* causes crash?
        NSString *key = @"deviceTs";
        
        [self.outlet willAccessValueForKey:key];
        NSDate *outletDeviceTs = [self.outlet valueForKey:key];
        [self.outlet didAccessValueForKey:key];
        
        [self.outlet willChangeValueForKey:key];
        [self.outlet setValue:outletDeviceTs forKeyPath:key];
        [self.outlet didChangeValueForKey:key];
*/
        
    }
    
    [super willSave];
    
}


@end
