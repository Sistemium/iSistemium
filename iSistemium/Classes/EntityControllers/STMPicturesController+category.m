//
//  STMPicturesController+category.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/04/16.
//  Copyright © 2016 Sistemium UAB. All rights reserved.
//

#import "STMPicturesController+category.h"

#import "STMDataModel.h"


@implementation STMPicturesController (category)

- (NSArray *)photoEntitiesNames {
    
    return @[NSStringFromClass([STMPhotoReport class]),
             NSStringFromClass([STMUncashingPicture class])];
    
}

- (NSArray *)instantLoadPicturesEntityNames {
    return @[NSStringFromClass([STMMessagePicture class])];
}


@end
