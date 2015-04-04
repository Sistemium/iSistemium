//
//  STMRecordStatus.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 04/04/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "STMComment.h"


@interface STMRecordStatus : STMComment

@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSNumber * isRemoved;
@property (nonatomic, retain) NSData * objectXid;
@property (nonatomic, retain) NSNumber * isTemporary;

@end
