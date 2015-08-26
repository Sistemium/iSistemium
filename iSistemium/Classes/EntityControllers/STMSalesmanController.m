//
//  STMSalesmanController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 15/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMSalesmanController.h"

@interface STMSalesmanController()

@property (nonatomic) BOOL isItOnlyMeAmongSalesman;
@property (nonatomic, strong) NSArray *salesmansArray;


@end


@implementation STMSalesmanController

+ (STMSalesmanController *)sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self checkSalesmans];
    }
    return self;

}

+ (BOOL)isItOnlyMeAmongSalesman {
    return [self sharedInstance].isItOnlyMeAmongSalesman;
}

+ (NSArray *)salesmansArray {
    return [self sharedInstance].salesmansArray;
}

- (NSArray *)salesmansArray {
    
    if (!_salesmansArray) {
        
        STMFetchRequest *request = [[STMFetchRequest alloc] initWithEntityName:NSStringFromClass([STMSalesman class])];
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        request.sortDescriptors = @[nameDescriptor];
        
        NSArray *salesmans = [[STMSalesmanController document].managedObjectContext executeFetchRequest:request error:nil];
        
        _salesmansArray = salesmans;

    }
    return _salesmansArray;
    
}

- (void)checkSalesmans {
    
    NSArray *salesmans = self.salesmansArray;
    
    if (salesmans.count != 1) {
        
        self.isItOnlyMeAmongSalesman = NO;
        
    } else {
        
        STMSalesman *salesman = salesmans.firstObject;
        
        NSString *loginName = [STMAuthController authController].userName;

        if (loginName && [salesman.name caseInsensitiveCompare:loginName] == NSOrderedSame) {
            
            self.isItOnlyMeAmongSalesman = YES;
            
        } else {
            
            self.isItOnlyMeAmongSalesman = NO;
            
        }
        
    }
    
}


@end
