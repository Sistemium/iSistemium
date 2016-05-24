//
//  STMOutlet.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STMDatum.h"

@class STMBasketPosition, STMCampaign, STMCashing, STMDebt, STMPartner, STMPhotoReport, STMPickingOrder, STMSaleOrder, STMSalesman, STMShipment;

NS_ASSUME_NONNULL_BEGIN

@interface STMOutlet : STMDatum

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "STMOutlet+CoreDataProperties.h"
