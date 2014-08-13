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

- (NSDecimalNumber *)calculatedSum {
    
    NSDecimalNumber *result = self.summ;
    
    for (STMCashing *cashing in self.cashings) {
        
        result = [result decimalNumberBySubtracting:cashing.summ];
        
    }
    
    if ([result compare:[NSDecimalNumber zero]] == NSOrderedAscending) {
        
        result = [NSDecimalNumber zero];
        
    }
    
    return result;
    
}

@end
