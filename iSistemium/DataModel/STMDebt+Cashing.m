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
    
//    NSLog(@"willSave");
    
    if (cashingCalculatedSum != [self primitiveValueForKey:@"calculatedSum"]) {
        
//        NSLog(@"setValue %@", cashingCalculatedSum);
        
        [self setPrimitiveValue:cashingCalculatedSum forKey:@"calculatedSum"];
        
    }
    
    [super willSave];
    
}


/*
- (void)willAccessValueForKey:(NSString *)key {
    
    if ([key isEqualToString:@"calculatedSum"]) {
        
//        NSLog(@"willAccessValueForKey %@", key);
    
        id value = [self primitiveValueForKey:key];
        
        NSLog(@"value %@", value);
        
        if (!value) {
            
            NSLog(@"!value");

            NSDecimalNumber *cashingCalculatedSum = [self cashingCalculatedSum];

            NSLog(@"cashingCalculatedSum %@", cashingCalculatedSum);
            
            [self setPrimitiveValue:cashingCalculatedSum forKey:key];
            
        }
        
    }
    
    [super willAccessValueForKey:key];
    
}
*/
 

- (void)awakeFromFetch {
    
    [super awakeFromFetch];
    
//    NSLog(@"awakeFromFetch %@", self.calculatedSum);

    if (!self.calculatedSum) {

//        NSLog(@"set calc value");
        
        [self setValue:[self cashingCalculatedSum] forKey:@"calculatedSum"];
        
//        NSLog(@"self %@", self);
        
    }
    
}


/*
- (void)awakeFromInsert {
    
    [super awakeFromInsert];
    
    NSLog(@"awakeFromInsert");
    
}
*/


@end
