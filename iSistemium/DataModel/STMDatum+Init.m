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
    
//    if ([STMSaleOrderController sharedInstance].processingDidChanged && [self isKindOfClass:[STMSaleOrder class]]) {
//        
//        NSString *xidString = [STMFunctions UUIDStringFromUUIDData:self.xid];
//        NSDictionary *objectDic = @{@"saleOrderXid":xidString, @"saleOrderChangedValues":self.changedValues};
//        NSString *JSONString = [STMFunctions jsonStringFromDictionary:objectDic];
//        [[STMLogger sharedLogger] saveLogMessageWithText:JSONString type:@"important"];
//        
//    }
    
    if (![self.changedValues.allKeys containsObject:@"lts"]) {
        
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
            
            [self willChangeValueForKey:@"deviceTs"];
            [self setPrimitiveValue:newDeviceTs forKey:@"deviceTs"];
            [self didChangeValueForKey:@"deviceTs"];
            
//            if ([STMSaleOrderController sharedInstance].processingDidChanged && [self isKindOfClass:[STMSaleOrder class]]) {
//                
//                NSString *xidString = [STMFunctions UUIDStringFromUUIDData:self.xid];
//                
//                if ([self.deviceTs compare:newDeviceTs] != NSOrderedSame) {
//                    
//                    NSString *logMessage = [NSString stringWithFormat:@"deviceTs might not updated to %@", [[STMFunctions dateFormatter] stringFromDate:newDeviceTs]];
//                    [[STMLogger sharedLogger] saveLogMessageWithText:logMessage type:@"important"];
//                    
//                }
//                                
//                NSDictionary *objectDic = @{
//                                            @"saleOrderXid":xidString,
//                                            @"tsValues":@{
//                                                          @"ts":[[STMFunctions dateFormatter] stringFromDate:newDeviceTs],
//                                                          @"dotDeviceTs":[[STMFunctions dateFormatter] stringFromDate:self.deviceTs],
//                                                          @"deviceTs":[[STMFunctions dateFormatter] stringFromDate:[self valueForKey:@"deviceTs"]]
//                                                          }
//                                            };
//                
//                NSString *JSONString = [STMFunctions jsonStringFromDictionary:objectDic];
//                [[STMLogger sharedLogger] saveLogMessageWithText:JSONString type:@"important"];
//
//            }
            
//            if ([self isKindOfClass:[STMLocation class]]) {
//                
//                NSLog(@"self.changedValues %@", self.changedValues);
//                
//            }
            
            [self setPrimitiveValue:newDeviceTs forKey:@"deviceTs"];

            NSDate *lts = [self primitiveValueForKey:@"lts"];
            NSDate *deviceTs = [self primitiveValueForKey:@"deviceTs"];
            NSDate *deviceCts = [self primitiveValueForKey:@"deviceCts"];
            NSDate *sqts = lts ? deviceTs : deviceCts;
            
//            [self willChangeValueForKey:@"sqts"];
            [self setPrimitiveValue:sqts forKey:@"sqts"];
//            [self didChangeValueForKey:@"sqts"];
            
//            [self setPrimitiveValue:sqts forKey:@"sqts"];

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


@end
