//
//  STMPhotoVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMCorePhoto.h"

@interface STMPhotoVC : UIViewController

@property (nonatomic, strong) STMCorePhoto *photo;
@property (nonatomic) NSUInteger index;

@property (nonatomic, strong) UIImage *image;

@end
