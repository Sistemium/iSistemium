//
//  STMPicturesController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/05/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMPicturesController.h"

#import "STMDataModel.h"


@implementation STMPicturesController

- (NSArray *)photoEntitiesNames {
    
    return @[NSStringFromClass([STMPhotoReport class]),
             NSStringFromClass([STMUncashingPicture class])];
    
}


@end
