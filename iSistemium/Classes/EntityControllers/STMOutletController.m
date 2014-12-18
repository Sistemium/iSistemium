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
#import "STMDebtsController.h"
#import "STMPartnerController.h"
#import "STMCashing.h"

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
    outlet.isFantom = [NSNumber numberWithBool:NO];
    
    [[self document] saveDocument:^(BOOL success) {
    
        [[self syncer] setSyncerState:STMSyncerSendDataOnce];

    }];
    
    NSLog(@"outlet %@", outlet);
    
    return outlet;
    
}

+ (void)removeOutlet:(STMOutlet *)outlet {
    
    STMPartner *partner = outlet.partner;
    
    for (STMDebt *debt in outlet.debts) {
        [STMDebtsController removeDebt:debt];
    }
    
    for (STMCashing *cashing in outlet.cashings) {
        [STMObjectsController removeObject:cashing];
    }
    
    [STMObjectsController removeObject:outlet];
    
    if (partner.outlets.count == 0) {
        [STMPartnerController removePartner:partner];
    }

    
}

@end
