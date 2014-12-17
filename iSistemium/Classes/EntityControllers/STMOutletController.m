//
//  STMOutletController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMOutletController.h"
#import "STMSessionManager.h"
#import "STMDocument.h"
#import "STMObjectsController.h"
#import "STMSyncer.h"

@implementation STMOutletController

+ (STMDocument *)document {
    
    return (STMDocument *)[STMSessionManager sharedManager].currentSession.document;
    
}

+ (STMSyncer *)syncer {
    
    return [[STMSessionManager sharedManager].currentSession syncer];
    
}

+ (STMOutlet *)addOutletWithShortName:(NSString *)shortName forPartner:(STMPartner *)partner {
    
    STMOutlet *outlet = (STMOutlet *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMOutlet class])];

    outlet.shortName = shortName;
    outlet.partner = partner;
    
    [[self document] saveDocument:^(BOOL success) {
    
        [[self syncer] setSyncerState:STMSyncerSendDataOnce];

    }];
    
    return outlet;
    
}

@end
