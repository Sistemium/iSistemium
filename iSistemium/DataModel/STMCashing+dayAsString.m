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
#import "STMFunctions.h"

@implementation STMCashing (dayAsString)

- (NSString *)dayAsString {
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        formatter = [STMFunctions dateMediumNoTimeFormatter];

    });
    
    NSString *dateString = [formatter stringFromDate:self.date];
    
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
                                                              userInfo:@{@"outlet": self.outlet}];
            
        }

    }
    
    [super willSave];
    
}


@end
