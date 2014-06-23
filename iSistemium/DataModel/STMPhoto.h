//
//  STMPhoto.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMPicture.h"

@class STMPhotoReport;

@interface STMPhoto : STMPicture

@property (nonatomic, retain) STMPhotoReport *photoReport;

@end
