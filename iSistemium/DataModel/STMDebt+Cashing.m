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
    
    NSDecimalNumber *result = self.summ;
    
    for (STMCashing *cashing in self.cashings) {
        
        result = [result decimalNumberBySubtracting:cashing.summ];
        
    }
    
    if ([result compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        
        result = [NSDecimalNumber zero];
        
    }
    
    return result;
    
}

- (void)willSave {
    
    NSDecimalNumber *cashingCalculatedSum = [self cashingCalculatedSum];
    
    if (cashingCalculatedSum != [self primitiveValueForKey:@"calculatedSum"]) {
                
        [self setPrimitiveValue:cashingCalculatedSum forKey:@"calculatedSum"];
                
    }
 
    [super willSave];
    
}


- (void)awakeFromFetch {
    
    [super awakeFromFetch];
    
    if (!self.calculatedSum) {
        
        [self setValue:[self cashingCalculatedSum] forKey:@"calculatedSum"];
        
    }
    
}


@end
