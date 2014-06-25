//
//  STMPhotoVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMPhoto.h"

@interface STMPhotoVC : UIViewController

@property (nonatomic, strong) STMPhoto *photo;
@property (nonatomic) NSUInteger index;

@end
