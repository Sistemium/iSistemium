//
//  STMDebt+Cashing.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMDebt+Cashing.h"
#import "STMCashing.h"

@implementation STMDebt (Cashing)

- (NSDecimalNumber *)cashingCalculatedSum {
    
    [self willAccessValueForKey:@"summ"];
    NSDecimalNumber *result = self.summ;
    [self didAccessValueForKey:@"summ"];
    
    [self willAccessValueForKey:@"cashings"];
    NSSet *cashings = self.cashings;
    [self didAccessValueForKey:@"cashings"];
    
    for (STMCashing *cashing in cashings) {
        
        result = [result decimalNumberBySubtracting:cashing.summ];
        
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