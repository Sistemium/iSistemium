//
//  STMUncashingPhotoVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMUncashingPicture.h"
#import "STMUncashingHandOverVC.h"

@interface STMUncashingPhotoVC : UIViewController

@property (nonatomic, strong) STMUncashingPicture *picture;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, weak) STMUncashingHandOverVC *handOverController;

@end
