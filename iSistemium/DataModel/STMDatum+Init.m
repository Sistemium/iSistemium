//
//  STMDatum+Init.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 4/1/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STMDatum+Init.h"
#import "STMMessage.h"

#import "STMSaleOrderController.h"

@implementation STMDatum (Init)

+ (void)load {
    
    @autoreleasepool {
        [[NSNotificationCenter defaultCenter] addObserver:(id)[self class]
                                                 selector:@selector(objectContextWillSave:)
                                                     name:NSManagedObjectContextWillSaveNotification
                                                   object:nil];
    }
    
}

+ (void)objectContextWillSave:(NSNotification*)notification {
    
    NSManagedObjectContext *context = [notification object];
    
    if (context.parentContext) {
    
        NSSet *modifiedObjects = [context.insertedObjects setByAddingObjectsFromSet:context.updatedObjects];
        [modifiedObjects makeObjectsPerformSelector:@selector(setLastModifiedTimestamp)];

    }
    
}

- (void)setLastModifiedTimestamp{
    
//    if (/*[STMSaleOrderController sharedInstance].processingDidChanged && */[self isKindOfClass:[STMShipmentRoutePoint class]]) {
//        
//        NSString *xidString = [STMFunctions UUIDStringFromUUIDData:self.xid];
//        NSDictionary *objectDic = @{@"saleOrderXid":xidString, @"saleOrderChangedValues":self.changedValues};
//        NSString *JSONString = [STMFunctions jsonStringFromDictionary:objectDic];
//        [[STMLogger sharedLogger] saveLogMessageWithText:JSONString type:@"important"];
//
//        NSLog(@"changedValues %@", self.changedValues);
//        
//    }
    
    NSArray *excludeProperties = @[@"lts",
                                   @"sts",
                                   @"sqts",
                                   @"deviceTs",
                                   @"imagePath",
                                   @"resizedImagePath",
                                   @"calculatedSum",
                                   @"imageThumbnail"];
    
    NSMutableArray *changedKeysArray = self.changedValues.allKeys.mutableCopy;
    [changedKeysArray removeObjectsInArray:excludeProperties];
    
    NSMutableArray *relationshipsToMany = [NSMutableArray array];
    
    for (NSRelationshipDescription *relationship in self.entity.relationshipsByName.allValues) {
        if (relationship.isToMany) [relationshipsToMany addObject:relationship.name];
    }
    
    [changedKeysArray removeObjectsInArray:relationshipsToMany];
    
    if (changedKeysArray.count > 0) {
        
        NSDate *newDeviceTs = [NSDate date];

        self.deviceTs = newDeviceTs;
        
        self.sqts = (self.lts) ? self.deviceTs : self.deviceCts;
        
    }
    
}

- (NSData *)newXid {
    
    CFUUIDRef xid = CFUUIDCreate(nil);
    CFUUIDBytes xidBytes = CFUUIDGetUUIDBytes(xid);
    CFRelease(xid);
    return [NSData dataWithBytes:&xidBytes length:sizeof(xidBytes)];

}

- (void)awakeFromInsert {
    
//    NSLog(@"awakeFromInsert");
    
    [super awakeFromInsert];
    
    if (self.managedObjectContext.parentContext) {
    
        [self setPrimitiveValue:[self newXid] forKey:@"xid"];
        
        NSDate *ts = [NSDate date];
        [self setPrimitiveValue:ts forKey:@"deviceCts"];
        [self setPrimitiveValue:ts forKey:@"deviceTs"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *largestId = [defaults objectForKey:@"largestId"];
        
        if (!largestId) {
            largestId = @1;
        } else {
            largestId = @((long long)[largestId longLongValue]+1);
        }

//        NSLog(@"largestId %@", largestId);
        
        [self setPrimitiveValue:largestId forKey:@"id"];

        [defaults setObject:largestId forKey:@"largestId"];
        [defaults synchronize];
        
    }
    
}

- (void)willSave {
    
    [super willSave];

}

- (NSString *)ctsDayAsString {
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        formatter = [STMFunctions dateMediumNoTimeFormatter];
        
    });
    
    NSString *dateString = [formatter stringFromDate:self.deviceCts];
    
    return dateString;
    
}


@end
