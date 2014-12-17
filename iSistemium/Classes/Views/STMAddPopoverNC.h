//
//  STMAddPopoverNC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMOutletsTVC.h"

@interface STMAddPopoverNC : UINavigationController

@property (nonatomic, strong) STMOutletsTVC *parentVC;

- (void)dissmissSelf;


@end
