//
//  STMSalesmanController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 15/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMSalesmanController.h"

@implementation STMSalesmanController

+ (BOOL)isItOnlyMeAmongSalesman {
    
    NSArray *salesmans = [self salesmansArray];
    
    if (salesmans.count != 1) {
        
        return NO;
        
    } else {
        
        STMSalesman *salesman = salesmans.firstObject;
        
        NSString *loginName = [STMAuthController authController].userName;
        
        // for testing
        loginName = @"Сейлюс Александр";
        //
        
        if (loginName && [salesman.name caseInsensitiveCompare:loginName] == NSOrderedSame) {
            
            return YES;
            
        } else {
            
            return NO;
            
        }
        
    }
    
}

+ (NSArray *)salesmansArray {
    
    STMFetchRequest *request = [[STMFetchRequest alloc] initWithEntityName:NSStringFromClass([STMSalesman class])];
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    request.sortDescriptors = @[nameDescriptor];
    
    NSArray *salesmans = [[self document].managedObjectContext executeFetchRequest:request error:nil];
    
    return salesmans;
    
}


@end
