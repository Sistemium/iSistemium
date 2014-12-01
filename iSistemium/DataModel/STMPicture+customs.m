//
//  STMPicture+customs.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMPicture+customs.h"
#import "STMPicturesController.h"

@implementation STMPicture (customs)

- (void)willSave {
    
    if (self.isDeleted) {
        [STMPicturesController removeImageFilesForPicture:self];
    }
    
    [super willSave];
    
}


@end
