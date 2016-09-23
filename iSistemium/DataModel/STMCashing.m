//
//  STMCashing.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMCashing.h"
#import "STMDebt.h"
#import "STMOutlet.h"
#import "STMUncashing.h"

#import "STMFunctions.h"


@implementation STMCashing

- (NSString *)dayAsString {
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        formatter = [STMFunctions dateMediumNoTimeFormatter];
        
    });
    
    NSString *dateString = (self.date) ? [formatter stringFromDate:(NSDate * _Nonnull)self.date] : nil;
    
    return dateString;
    
}

- (NSString *)outletSectionName {
    
    if (self.outlet.name) {
        
        return self.outlet.name;
        
    } else {
        
        if ([self.summ compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
            
            return NSLocalizedString(@"DEDUCTIONS", nil);
            
        } else {
            
            return NSLocalizedString(@"ETC", nil);
            
        }
        
    }
    
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
        
        if (self.outlet) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cashingIsProcessedChanged"
                                                                object:nil
                                                              userInfo:@{@"outletXid": self.outlet.xid}];
            
        }
        
    }
    
    [super willSave];
    
}


@end
