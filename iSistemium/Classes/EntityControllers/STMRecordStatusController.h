//
//  STMRecordStatusController.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMController.h"
#import "STMRecordStatus.h"

@interface STMRecordStatusController : STMController

+ (STMRecordStatus *)existingRecordStatusForXid:(NSData *)objectXid;
+ (STMRecordStatus *)recordStatusForObject:(NSManagedObject *)object;


@end
