//
//  STMOutlet.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMOutlet.h"
#import "STMBasketPosition.h"
#import "STMCampaign.h"
#import "STMCashing.h"
#import "STMDebt.h"
#import "STMPartner.h"
#import "STMPhotoReport.h"
#import "STMSaleOrder.h"
#import "STMSalesman.h"
#import "STMShipment.h"

@implementation STMOutlet

- (BOOL)photoReportsArePresent {
    
    if (self.photoReports.count == 0) {
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}


@end
