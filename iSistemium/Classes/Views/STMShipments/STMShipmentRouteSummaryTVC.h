//
//  STMShipmentRouteSummaryTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"
#import "STMDataModel.h"


typedef NS_ENUM(NSInteger, STMSummaryType) {
    STMSummaryTypeBad,
    STMSummaryTypeExcess,
    STMSummaryTypeShortage,
    STMSummaryTypeRegrade,
    STMSummaryTypeBroken
};


@interface STMShipmentRouteSummaryTVC : STMVariableCellsHeightTVC

@property (nonatomic, strong) STMShipmentRoute *route;

+ (NSString *)stringVolumePropertyForType:(STMSummaryType)type;


@end
