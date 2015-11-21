//
//  STMPickingPositionVolumeTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

#import "STMDataModel.h"
#import "STMPickingOrderPositionsTVC.h"


@interface STMPickingPositionVolumeTVC : STMVariableCellsHeightTVC

@property (nonatomic, weak) STMPickingOrderPosition *position;
@property (nonatomic, weak) STMPickingOrderPositionsTVC *mainVC;


@end
