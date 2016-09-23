//
//  STMDebt.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/02/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMDebt.h"
#import "STMCashing.h"
#import "STMOutlet.h"

@implementation STMDebt

- (NSDecimalNumber *)cashingCalculatedSum {
    
    [self willAccessValueForKey:@"summ"];
    NSDecimalNumber *result = self.summ;
    [self didAccessValueForKey:@"summ"];
    
    [self willAccessValueForKey:@"cashings"];
    [self willAccessValueForKey:@"isProcessed"];
    
    NSPredicate *cashingPredicate = [NSPredicate predicateWithFormat:@"isProcessed != %@", @YES];
    NSSet *cashings = [self.cashings filteredSetUsingPredicate:cashingPredicate];
    
    [self didAccessValueForKey:@"isProcessed"];
    [self didAccessValueForKey:@"cashings"];
    
    for (STMCashing *cashing in cashings) {
        
        result = (cashing.summ) ? [result decimalNumberBySubtracting:(NSDecimalNumber * _Nonnull)cashing.summ] : result;
        
    }
    
    if ([result compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        
        result = [NSDecimalNumber zero];
        
    }
    
    return result;
    
}

- (void)willSave {
    
    NSDecimalNumber *cashingCalculatedSum = [self cashingCalculatedSum];
    
    [self willAccessValueForKey:@"calculatedSum"];
    NSDecimalNumber *primitiveCalculatedSum = [self primitiveValueForKey:@"calculatedSum"];
    [self didAccessValueForKey:@"calculatedSum"];
    
    if ([cashingCalculatedSum compare:primitiveCalculatedSum] != NSOrderedSame) {
        
        [self willChangeValueForKey:@"calculatedSum"];
        [self setPrimitiveValue:cashingCalculatedSum forKey:@"calculatedSum"];
        [self didChangeValueForKey:@"calculatedSum"];
        
    }
    
    if (self.outlet) {
        
        BOOL sumChanged = [[[self changedValues] allKeys] containsObject:@"summ"];
        
        if (sumChanged) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"debtSummChanged"
                                                                object:nil
                                                              userInfo:@{@"outletXid": self.outlet.xid}];
            
        }
        
    }
    
    [super willSave];
    
}

- (void)awakeFromFetch {
    
    [super awakeFromFetch];
    
    [self willAccessValueForKey:@"calculatedSum"];
    NSDecimalNumber *calculatedSum = self.calculatedSum;
    [self didAccessValueForKey:@"calculatedSum"];
    
    if (!calculatedSum) {
        
        [self willChangeValueForKey:@"calculatedSum"];
        [self setValue:[self cashingCalculatedSum] forKey:@"calculatedSum"];
        [self didChangeValueForKey:@"calculatedSum"];
        
    }
    
}


@end
