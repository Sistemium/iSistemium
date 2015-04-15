//
//  STMSaleOrderController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMSaleOrderController.h"
#import "STMEntityController.h"
#import "STMObjectsController.h"


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

    [nc addObserver:self
           selector:@selector(workflowDidChange:)
               name:@"workflowDidChange"
             object:[STMSaleOrderController saleOrderEntity]];
    
}

- (void)authStateChanged {
    
    if ([STMAuthController authController].controllerState != STMAuthSuccess) {
        self.workflow = nil;
    }

}

- (void)workflowDidChange:(NSNotification *)notification {
    self.workflow = nil;
}

- (NSDictionary *)workflow {
    
    if (!_workflow) {
        
        NSString *workflow = [STMSaleOrderController saleOrderEntity].workflow;
        
        NSData *workflowData = [workflow dataUsingEncoding:NSUTF8StringEncoding];
        
        if (workflowData) {
            
            NSError *error;
            NSDictionary *workflowJSON = [NSJSONSerialization JSONObjectWithData:workflowData options:NSJSONReadingMutableContainers error:&error];
            
            _workflow = workflowJSON;
            
        }
        
    }
    return _workflow;
    
}

+ (STMEntity *)saleOrderEntity {
    
    NSString *entityName = NSStringFromClass([STMSaleOrder class]);
    entityName = [entityName stringByReplacingOccurrencesOfString:@"STM" withString:@""];
    
    STMEntity *saleOrderEntity = [STMEntityController entityWithName:entityName];
    
    return saleOrderEntity;
    
}

+ (NSString *)labelForProcessing:(NSString *)processing {

    NSDictionary *workflow = [self sharedInstance].workflow;
    
    NSDictionary *dictionaryForProcessing = workflow[processing];
    
    return dictionaryForProcessing[@"label"];
    
}

+ (NSString *)processingForLabel:(NSString *)label {
    
    NSDictionary *workflow = [self sharedInstance].workflow;
    
    for (NSString *key in workflow.allKeys) {
        
        if ([label isEqualToString:workflow[key][@"label"]]) {
            return key;
        }
        
    }
    return nil;
    
}

+ (UIColor *)colorForProcessing:(NSString *)processing {
    
    return [self colorForType:@"cls" andProcessing:processing];

}

+ (UIColor *)messageColorForProcessing:(NSString *)processing {

    return [self colorForType:@"messageCls" andProcessing:processing];

}

+ (NSString *)descriptionForProcessing:(NSString *)processing {
    
    NSDictionary *workflow = [self sharedInstance].workflow;
    
    NSDictionary *dictionaryForProcessing = workflow[processing];
    
    return dictionaryForProcessing[@"desc"];
    
}

+ (UIColor *)colorForType:(NSString *)type andProcessing:(NSString *)processing {
    
    NSDictionary *workflow = [self sharedInstance].workflow;
    
    NSDictionary *dictionaryForProcessing = workflow[processing];
    
    NSString *colorString = dictionaryForProcessing[type];
    
    if (colorString) {
        
        return [STMFunctions colorForColorString:colorString];
        
    } else {
        
        return nil;
        
    }

}

+ (NSArray *)availableRoutesForProcessing:(NSString *)processing {
    
    NSDictionary *workflow = [self sharedInstance].workflow;
    
    NSMutableArray *routes = [NSMutableArray array];
    
    for (NSString *key in workflow.allKeys) {
        
        NSArray *fromArray = workflow[key][@"from"];
        
        if ([fromArray containsObject:processing]) {
            [routes addObject:key];
        }
        
    }
    
    return routes;
    
}

+ (NSArray *)editablesPropertiesForProcessing:(NSString *)processing {
    
    NSDictionary *workflow = [self sharedInstance].workflow;
    
    NSDictionary *dictionaryForProcessing = workflow[processing];
    
    NSArray *editableProperties = dictionaryForProcessing[@"editables"];
    
    return editableProperties;
    
}

+ (NSString *)labelForEditableProperty:(NSString *)editableProperty {
    return ([editableProperty isEqualToString:@"processingMessage"]) ? NSLocalizedString(@"PROCESSING MESSAGE", nil) : editableProperty;
}


+ (void)setProcessing:(NSString *)processing forSaleOrder:(STMSaleOrder *)saleOrder {
    [self setProcessing:processing forSaleOrder:saleOrder withFields:nil];
}

+ (void)setProcessing:(NSString *)processing forSaleOrder:(STMSaleOrder *)saleOrder withFields:(NSDictionary *)fields {
    
    if (![saleOrder.processing isEqualToString:processing]) {
        
        for (NSString *field in fields) {
            
            if ([saleOrder.entity.propertiesByName.allKeys containsObject:field]) {
                [saleOrder setValue:fields[field] forKey:field];
            }
            
        }
        
        NSDictionary *objectDic = @{@"saleOrderBefore":[STMObjectsController dictionaryForObject:saleOrder]};
        NSString *JSONString = [STMFunctions jsonStringFromDictionary:objectDic];
        [[STMLogger sharedLogger] saveLogMessageWithText:JSONString type:@"important"];

        [STMSaleOrderController sharedInstance].processingDidChanged = YES;

        saleOrder.processing = processing;

        [[self document] saveDocument:^(BOOL success) {
            
            NSDictionary *objectDic = @{@"saleOrderAfter":[STMObjectsController dictionaryForObject:saleOrder]};
            NSString *JSONString = [STMFunctions jsonStringFromDictionary:objectDic];
            [[STMLogger sharedLogger] saveLogMessageWithText:JSONString type:@"important"];

            [STMSaleOrderController sharedInstance].processingDidChanged = NO;
            
            if (success) [[self syncer] setSyncerState:STMSyncerSendDataOnce];
            
        }];

    }
    
}


@end
