//
//  STMSaleOrderController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMSaleOrderController.h"
#import "STMEntityController.h"

@interface STMSaleOrderController()

@property (nonatomic, strong) NSDictionary *workflow;

@end

@implementation STMSaleOrderController

+ (STMSaleOrderController *)sharedInstance {
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
    
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) [self addObservers];
    return self;
    
}

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(authStateChanged)
               name:@"authControllerStateChanged"
             object:[STMAuthController authController]];
    
}

- (void)authStateChanged {
    
    if ([STMAuthController authController].controllerState != STMAuthSuccess) {
        self.workflow = nil;
    }

}

- (NSDictionary *)workflow {
    
    if (!_workflow) {
        
        NSString *entityName = NSStringFromClass([STMSaleOrder class]);
        entityName = [entityName stringByReplacingOccurrencesOfString:@"STM" withString:@""];
        
        STMEntity *saleOrderEntity = [STMEntityController entityWithName:entityName];
        
        NSString *workflow = saleOrderEntity.workflow;
        
        NSData *workflowData = [workflow dataUsingEncoding:NSUTF8StringEncoding];
        
        if (workflowData) {
            
            NSError *error;
            NSDictionary *workflowJSON = [NSJSONSerialization JSONObjectWithData:workflowData options:NSJSONReadingMutableContainers error:&error];
            
            _workflow = workflowJSON[@"processing"];
            
        }
        
    }
    return _workflow;
    
}


+ (NSString *)labelForProcessing:(NSString *)processing {

    NSDictionary *workflow = [self sharedInstance].workflow;
    
    NSDictionary *dictionaryForProcessing = workflow[processing];
    
    return dictionaryForProcessing[@"label"];
    
}

+ (UIColor *)colorForProcessing:(NSString *)processing {
    
    NSDictionary *workflow = [self sharedInstance].workflow;
    
    NSDictionary *dictionaryForProcessing = workflow[processing];

    NSString *colorString = dictionaryForProcessing[@"cls"];
    
    if (colorString) {

        return [STMFunctions colorForColorString:colorString];

    } else {
    
        return nil;

    }
    
}


@end
