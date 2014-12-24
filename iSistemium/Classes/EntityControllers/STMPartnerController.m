//
//  STMPartnerController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMPartnerController.h"
#import "STMSessionManager.h"
#import "STMDocument.h"
#import "STMObjectsController.h"
#import "STMSyncer.h"
#import "STMOutletController.h"

@implementation STMPartnerController

+ (STMDocument *)document {
    
    return (STMDocument *)[STMSessionManager sharedManager].currentSession.document;
    
}

+ (STMSyncer *)syncer {
    
    return [[STMSessionManager sharedManager].currentSession syncer];
    
}

+ (STMPartner *)addPartnerWithName:(NSString *)name {
    
    STMPartner *partner = (STMPartner *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMPartner class])];
    
    partner.name = name;
    partner.isFantom = [NSNumber numberWithBool:NO];
    
    [[self document] saveDocument:^(BOOL success) {
        
        [[self syncer] setSyncerState:STMSyncerSendDataOnce];
        
    }];
    
    return partner;
    
}

+ (void)removePartner:(STMPartner *)partner {
    
    for (STMOutlet *outlet in partner.outlets) {
        [STMOutletController removeOutlet:outlet];
    }
    
    [STMObjectsController removeObject:partner];
    
}

@end
