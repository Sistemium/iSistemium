//
//  STMRecordStatusController.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMRecordStatusController.h"

@implementation STMRecordStatusController

+ (STMRecordStatus *)existingRecordStatusForXid:(NSData *)objectXid {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMRecordStatus class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"xid" ascending:YES selector:@selector(compare:)]];
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
        
        recordStatus = [STMEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMRecordStatus class]) inManagedObjectContext:[self document].managedObjectContext];
        recordStatus.objectXid = objectXid;
        
    }
    
    return recordStatus;
    
}


@end