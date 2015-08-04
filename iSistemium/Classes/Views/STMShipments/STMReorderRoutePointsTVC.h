//
//  STMReorderRoutePointsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"
#import "STMAllRoutesMapVC.h"


@interface STMReorderRoutePointsTVC : STMVariableCellsHeightTVC

@property (nonatomic, strong) NSArray *points;
@property (nonatomic, weak) STMAllRoutesMapVC *parentVC;


@end
