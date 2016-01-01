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

//        [[NSNotificationCenter defaultCenter] addObserver:(id)[self class]
//                                                 selector:@selector(objectContextObjectsDidChange:)
//                                                     name:NSManagedObjectContextObjectsDidChangeNotification
//                                                   object:nil];
        
    }
    
}

+ (void)objectContextWillSave:(NSNotification*)notification {
    
    NSManagedObjectContext *context = [notification object];
    
    if (context.parentContext) {

        NSSet *modifiedObjects = [context.insertedObjects setByAddingObjectsFromSet:context.updatedObjects];
        [modifiedObjects makeObjectsPerformSelector:@selector(setLastModifiedTimestamp)];

    }
    
}

//+ (void)objectContextObjectsDidChange:(NSNotification *)notification {
//    
//    NSManagedObjectContext *context = [notification object];
//    
//    if (context.parentContext) {
//        
//        NSSet *modifiedObjects = [context.insertedObjects setByAddingObjectsFromSet:context.updatedObjects];
//        [modifiedObjects makeObjectsPerformSelector:@selector(setLastModifiedTimestamp)];
//                
//    }
//
//}

- (void)setLastModifiedTimestamp{

    if ([self isKindOfClass:[STMShipmentRoutePoint class]] || [self isKindOfClass:[STMShippingLocation class]]) {
        
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", self.xid);
        NSLog(@"changedValues %@", self.changedValues);
        NSLog(@"changedValuesForCurrentEvent %@", self.changedValuesForCurrentEvent);
        NSLog(@"------------------------");
        
    }
    
//    NSDictionary *changedValues = (self.changedValuesForCurrentEvent.count > 0) ? self.changedValuesForCurrentEvent : self.changedValues;
//    NSDictionary *changedValues = self.changedValuesForCurrentEvent;
    NSDictionary *changedValues = self.changedValues;


    if (![changedValues.allKeys containsObject:@"lts"]) { //?????
    
        NSArray *excludeProperties = @[@"lts",
                                       @"sts",
                                       @"sqts",
                                       @"deviceTs",
                                       @"imagePath",
                                       @"resizedImagePath",
                                       @"calculatedSum",
                                       @"imageThumbnail"];
        
        NSMutableArray *changedKeysArray = changedValues.allKeys.mutableCopy;
        [changedKeysArray removeObjectsInArray:excludeProperties];
        
        NSMutableArray *relationshipsToMany = [NSMutableArray array];
        
        for (NSRelationshipDescription *relationship in self.entity.relationshipsByName.allValues) {
            if (relationship.isToMany) [relationshipsToMany addObject:relationship.name];
        }
        
        [changedKeysArray removeObjectsInArray:relationshipsToMany];

        if (changedKeysArray.count > 0) {
            
            self.deviceTs = [NSDate date];
            self.sqts = (self.lts) ? self.deviceTs : self.deviceCts;
            
        }
        
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
