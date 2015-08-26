//
//  STMPositionVolumesVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMDataModel.h"
#import "STMUI.h"


@interface STMPositionVolumesVC : UIViewController

@property (nonatomic, strong) STMShipmentPosition *position;

- (void)volumeChangedInCell:(STMVolumeTVCell *)cell;


@end
