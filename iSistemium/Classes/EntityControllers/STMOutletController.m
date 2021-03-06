//
//  STMOutletController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMOutletController.h"
#import "STMDebtsController.h"
#import "STMPartnerController.h"
#import "STMCashing.h"
#import "STMObjectsController.h"

@implementation STMOutletController

+ (STMOutlet *)addOutletWithShortName:(NSString *)shortName forPartner:(STMPartner *)partner {
    
    STMOutlet *outlet = (STMOutlet *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMOutlet class]) isFantom:NO];

    outlet.shortName = shortName;
    outlet.name = [NSString stringWithFormat:@"%@ (%@)", partner.name, shortName];
    outlet.partner = partner;
    
    [[self document] saveDocument:^(BOOL success) {
//        if (success) [[self syncer] setSyncerState:STMSyncerSendDataOnce];
    }];
    
//    NSLog(@"outlet %@", outlet);
    
    return outlet;
    
}

+ (void)removeOutlet:(STMOutlet *)outlet {
    
    STMPartner *partner = outlet.partner;
    
    NSArray *debts = [outlet.debts copy];
    for (STMDebt *debt in debts) {
        [STMDebtsController removeDebt:debt];
    }

    NSArray *cashings = [outlet.cashings copy];
    for (STMCashing *cashing in cashings) {
        [STMObjectsController createRecordStatusAndRemoveObject:cashing];
    }

    [STMObjectsController createRecordStatusAndRemoveObject:outlet];
    
    if (partner.outlets.count == 0) {
        [STMPartnerController removePartner:partner];
    }

    
}

@end
