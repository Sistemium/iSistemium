//
//  STMPhotoReport.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/07/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMPhoto.h"

@class STMCampaign, STMOutlet, STMSalesman;

@interface STMPhotoReport : STMPhoto

@property (nonatomic, retain) STMCampaign *campaign;
@property (nonatomic, retain) STMOutlet *outlet;
@property (nonatomic, retain) STMSalesman *salesman;

@end
