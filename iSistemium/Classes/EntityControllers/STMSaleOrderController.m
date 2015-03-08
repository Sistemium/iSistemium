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

+ (NSString *)labelForProcessing:(NSString *)processing {

    NSDictionary *workflow = [self sharedInstance].workflow;
    
    NSDictionary *dictionaryForCode = workflow[processing];
    
    return dictionaryForCode[@"label"];
    
}

- (NSDictionary *)workflow {
    
    if (!_workflow) {

        NSString *entityName = NSStringFromClass([STMSaleOrder class]);
        entityName = [entityName stringByReplacingOccurrencesOfString:@"STM" withString:@""];
        
        STMEntity *saleOrderEntity = [STMEntityController entityWithName:entityName];
        
        NSString *workflow = saleOrderEntity.workflow;
        
        NSData *workflowData = [workflow dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error;
        NSDictionary *workflowJSON = [NSJSONSerialization JSONObjectWithData:workflowData options:NSJSONReadingMutableContainers error:&error];

        _workflow = workflowJSON[@"processing"];
        
    }
    return _workflow;
    
}


@end
