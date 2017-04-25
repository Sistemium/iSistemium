//
//  STMShippingLocationPicturesPVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 28/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STMDataModel.h"
#import "STMShipmentRoutePointTVC.h"
#import "STMPicturesViewerDelegate.h"

@interface STMShippingLocationPicturesPVC : UIPageViewController

@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *photoArray;

@property (nonatomic, weak) id <STMPicturesViewerDelegate> parentVC;


@end
