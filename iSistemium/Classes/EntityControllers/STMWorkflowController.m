//
//  STMWorkflowController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 23/09/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMWorkflowController.h"

@implementation STMWorkflowController

#pragma mark - workflow action sheet

+ (STMWorkflowAS *)workflowActionSheetForProcessing:(NSString *)processing inWorkflow:(NSString *)workflow withDelegate:(id <UIActionSheetDelegate>)delegate {
    
    NSString *title = [self descriptionForProcessing:processing inWorkflow:workflow];
        
    STMWorkflowAS *actionSheet = [[STMWorkflowAS alloc] init];
    actionSheet.title = title;
    
    NSArray *processingRoutes = [self availableRoutesForProcessing:processing inWorkflow:workflow];
    
    if (processingRoutes.count > 0) {
        
        for (NSString *processing in processingRoutes) {
            [actionSheet addButtonWithTitle:[self labelForProcessing:processing inWorkflow:workflow]];
        }
        
    } else {
        
        [actionSheet addButtonWithTitle:@""];
        
    }

    actionSheet.delegate = delegate;
    actionSheet.workflow = workflow;
    actionSheet.processing = processing;
    
    return actionSheet;
    
}

+ (NSString *)workflowActionSheetForProcessing:(NSString *)processing didSelectButtonWithIndex:(NSInteger)buttonIndex inWorkflow:(NSString *)workflow {
    
    NSArray *processingRoutes = [self availableRoutesForProcessing:processing inWorkflow:workflow];

    if (buttonIndex >= 0 && buttonIndex < processingRoutes.count) {
        
        NSString *nextProcessing = processingRoutes[buttonIndex];
    
        return nextProcessing;
        
//        self.editableProperties = [STMSaleOrderController editablesPropertiesForProcessing:nextProcessing];
//        
//        if (self.editableProperties) {
//            
//            [self hideRoutesActionSheet];
//            
//            [self performSelector:@selector(showEditablesPopover) withObject:nil afterDelay:0];
//            
//        } else {
//            
//            [STMSaleOrderController setProcessing:nextProcessing forSaleOrder:self.processingOrder];
//            
//        }
        
    } else {
        return nil;
    }

}


#pragma mark - handling workflow

+ (NSDictionary *)workflowDicFromWorkflow:(NSString *)workflow {
    
    NSData *workflowData = [workflow dataUsingEncoding:NSUTF8StringEncoding];
    
    if (workflowData) {
        
        NSError *error;
        NSDictionary *workflowJSON = [NSJSONSerialization JSONObjectWithData:workflowData options:NSJSONReadingMutableContainers error:&error];
        
        return workflowJSON;
        
    } else {
        
        return nil;
        
    }
    
}

+ (NSDictionary *)dictionaryForProcessing:(NSString *)processing inWorkflow:(NSString *)workflow {
    
    NSDictionary *workflowDic = [self workflowDicFromWorkflow:workflow];
    NSDictionary *dictionaryForProcessing = workflowDic[processing];

    return dictionaryForProcessing;
    
}

+ (NSString *)descriptionForProcessing:(NSString *)processing inWorkflow:(NSString *)workflow {
    
    NSDictionary *dictionaryForProcessing = [self dictionaryForProcessing:processing inWorkflow:workflow];
    return dictionaryForProcessing[@"desc"];
    
}

+ (NSString *)labelForProcessing:(NSString *)processing inWorkflow:(NSString *)workflow {
    
    NSDictionary *dictionaryForProcessing = [self dictionaryForProcessing:processing inWorkflow:workflow];
    return dictionaryForProcessing[@"label"];
    
}

+ (NSArray *)availableRoutesForProcessing:(NSString *)processing inWorkflow:(NSString *)workflow {
    
    NSDictionary *workflowDic = [self workflowDicFromWorkflow:workflow];
    
    NSMutableArray *routes = [NSMutableArray array];
    
    for (NSString *key in workflowDic.allKeys) {
        
        NSArray *fromArray = workflowDic[key][@"from"];
        
        if ([fromArray containsObject:processing]) {
            [routes addObject:key];
        }
        
    }
    
    return routes;
    
}

//+ (NSString *)processingForLabel:(NSString *)label inWorkflow:(NSString *)workflow {
//    
//    NSDictionary *workflowDic = [self workflowDicFromWorkflow:workflow];
//    
//    for (NSString *key in workflowDic.allKeys) {
//        
//        if ([label isEqualToString:workflowDic[key][@"label"]]) {
//            return key;
//        }
//        
//    }
//    
//    return nil;
//    
//}

+ (UIColor *)colorForProcessing:(NSString *)processing inWorkflow:(NSString *)workflow {
    return [self colorForType:@"cls" andProcessing:processing inWorkflow:workflow];
}

+ (UIColor *)colorForType:(NSString *)type andProcessing:(NSString *)processing inWorkflow:(NSString *)workflow {
    
    NSDictionary *dictionaryForProcessing = [self dictionaryForProcessing:processing inWorkflow:workflow];
    NSString *colorString = dictionaryForProcessing[type];
    
    return (colorString) ? [STMFunctions colorForColorString:colorString] : nil;
    
}


@end
