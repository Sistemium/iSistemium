//
//  STMShipmentVolumesVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 14/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMDataModel.h"


@interface STMShipmentVolumesVC : UIViewController

@property (nonatomic, strong) STMShipmentPosition *position;

- (void)volumeChangedInView:(UIView *)volumeView;

- (void)userSelectArticleFact:(STMArticle *)articleFact;

@end
