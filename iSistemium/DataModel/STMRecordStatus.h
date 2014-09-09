//
//  STMRecordStatus.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 09/09/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMRecordStatus : STMComment

@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSNumber * isRemoved;
@property (nonatomic, retain) NSDate * removedObjectXid;

@end
