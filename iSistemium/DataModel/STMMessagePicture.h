//
//  STMMessagePicture.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 04/04/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMPicture.h"

@class STMMessage;

@interface STMMessagePicture : STMPicture

@property (nonatomic, retain) NSNumber * ord;
@property (nonatomic, retain) STMMessage *message;

@end
