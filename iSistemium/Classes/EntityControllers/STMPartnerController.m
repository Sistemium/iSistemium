//
//  STMPartnerController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMPartnerController.h"
#import "STMOutletController.h"
#import "STMObjectsController.h"

@implementation STMPartnerController

+ (STMPartner *)addPartnerWithName:(NSString *)name {
    
    STMPartner *partner = (STMPartner *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMPartner class]) isFantom:NO];
    
    partner.name = name;
    
    [[self document] saveDocument:^(BOOL success) {
//        if (success) [[self syncer] setSyncerState:STMSyncerSendDataOnce];
    }];
    
    return partner;
    
}

+ (void)removePartner:(STMPartner *)partner {
    
    for (STMOutlet *outlet in partner.outlets) {
        [STMOutletController removeOutlet:outlet];
    }
    
    [STMObjectsController createRecordStatusAndRemoveObject:partner];
    
}

@end
