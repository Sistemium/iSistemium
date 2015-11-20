//
//  STMPickingPositionInfoTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 20/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

@interface STMPickingPositionInfoTVC : STMVariableCellsHeightTVC

@property (nonatomic, weak) STMPickingOrderPosition *position;
@property (nonatomic) NSInteger selectedVolume;


@end
