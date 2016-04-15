//
//  STMShippingLocationPictureVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 28/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMUI.h"
#import "STMDataModel.h"


@interface STMShippingLocationPictureVC : UIViewController

@property (nonatomic, strong) STMShippingLocationPicture *photo;
@property (nonatomic) NSUInteger index;
@property (nonatomic, strong) STMSpinnerView *spinnerView;

@end
