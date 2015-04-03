//
//  STMCampaignPictureVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 23/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMCampaignPicture.h"
#import "STMObjectsController.h"

@interface STMCampaignPictureVC : UIViewController

@property (nonatomic, strong) STMCampaignPicture *picture;
@property (nonatomic) NSUInteger index;

@end
