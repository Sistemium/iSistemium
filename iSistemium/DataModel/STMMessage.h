//
//  STMMessage.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/04/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"

@class STMMessagePicture;

@interface STMMessage : STMComment

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSDate * cts;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * schedule;
@property (nonatomic, retain) NSSet *pictures;
@end

@interface STMMessage (CoreDataGeneratedAccessors)

- (void)addPicturesObject:(STMMessagePicture *)value;
- (void)removePicturesObject:(STMMessagePicture *)value;
- (void)addPictures:(NSSet *)values;
- (void)removePictures:(NSSet *)values;

@end
