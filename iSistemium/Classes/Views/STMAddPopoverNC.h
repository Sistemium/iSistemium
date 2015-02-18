//
//  STMAddPopoverNC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMOutletsTVC.h"
#import "STMPartner.h"

@interface STMAddPopoverNC : UINavigationController

@property (nonatomic, weak) STMOutletsTVC *parentVC;
@property (nonatomic, strong) STMPartner *partner;

- (void)dismissSelf;

@end
