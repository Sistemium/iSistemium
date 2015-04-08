//
//  STMRecordStatusController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMRecordStatusController.h"
#import "STMObjectsController.h"


@implementation STMRecordStatusController

+ (STMRecordStatus *)existingRecordStatusForXid:(NSData *)objectXid {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMRecordStatus class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES selector:@selector(compare:)]];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.objectXid == %@", objectXid];
    
    NSError *error;
    NSArray *fetchResult = [[self document].managedObjectContext executeFetchRequest:request error:&error];
    
    STMRecordStatus *recordStatus = [fetchResult lastObject];
    
    return recordStatus;
    
}

+ (STMRecordStatus *)recordStatusForObject:(NSManagedObject *)object {
    
    NSData *objectXid = [object valueForKey:@"xid"];
    
    STMRecordStatus *recordStatus = [self existingRecordStatusForXid:objectXid];
    
    if (!recordStatus) {
        
        recordStatus = (STMRecordStatus *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMRecordStatus class])];
        recordStatus.isFantom = @NO;
        recordStatus.objectXid = objectXid;
        
    }
    
    return recordStatus;
    
}


@end
