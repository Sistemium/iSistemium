//
//  STMDatum+Init.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 4/1/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STMDatum+Init.h"
#import "STMMessage.h"

@implementation STMDatum (Init)


- (NSData *)newXid {
    
    CFUUIDRef xid = CFUUIDCreate(nil);
    CFUUIDBytes xidBytes = CFUUIDGetUUIDBytes(xid);
    CFRelease(xid);
    return [NSData dataWithBytes:&xidBytes length:sizeof(xidBytes)];

}

- (void)awakeFromInsert {
    
//    NSLog(@"awakeFromInsert");
    
//    [super awakeFromInsert];
    
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
    
//    NSLog(@"STGTDatum willSave");
    
//    NSLog(@"[self changedValues] %@", [self changedValues]);
    
    NSArray *changedKeys = [[self changedValues] allKeys];
    
    BOOL notLts = ![changedKeys containsObject:@"lts"];
    BOOL notSts = ![changedKeys containsObject:@"sts"];
    BOOL notSqts = ![changedKeys containsObject:@"sqts"];
    BOOL notDeviceTs = ![changedKeys containsObject:@"deviceTs"];
    BOOL notImagePath = ![changedKeys containsObject:@"imagePath"];
    BOOL notResizedImagePath = ![changedKeys containsObject:@"resizedImagePath"];
    BOOL notCalculatedSum = ![changedKeys containsObject:@"calculatedSum"];
    
    BOOL notEmpty = (changedKeys.count != 0);
    
    BOOL notToMany = YES;
    
    NSMutableArray *relationshipsToMany = [NSMutableArray array];

    for (NSRelationshipDescription *relationship in [self.entity.relationshipsByName allValues]) {
        
        if ([relationship isToMany]) {
            
            [relationshipsToMany addObject:relationship.name];
            
        }
        
    }

    BOOL allChangesIsToMany = YES;
    for (NSString *key in changedKeys) allChangesIsToMany &= [relationshipsToMany containsObject:key];

    notToMany = !allChangesIsToMany;
    
//    if (changedKeys.count == 1) {
//        
//        NSString *key = [changedKeys lastObject];
//        if ([relationshipsToMany containsObject:key]) {
//            notToMany = NO;
//            
//            //            NSLog(@"%@ is toMany", key);
//            
//        }
//        
//    }

    
//    if ([self.entity.name isEqualToString:@"STMOutlet"] || [self.entity.name isEqualToString:@"STMSalesman"]) {
//        
//        NSLog(@"self1 %@", self)
//        
//        NSArray *keys = self.changedValues.allKeys;
//        NSLog(@"self.changedValues.allKeys %@", self.changedValues.allKeys);
//        
//        for (NSString *key in keys) {
//            
//            NSLog(@"%@: %@", key, self.changedValues[key]);
//            
//        }
//        
//    }
    
    
    if (notLts && notSts && notSqts && notDeviceTs && notEmpty && notToMany && notImagePath && notResizedImagePath && notCalculatedSum) {
        
        NSDate *ts = [NSDate date];
        
        [self willChangeValueForKey:@"deviceTs"];
        [self setPrimitiveValue:ts forKey:@"deviceTs"];
        [self didChangeValueForKey:@"deviceTs"];
        
        NSDate *lts = [self primitiveValueForKey:@"lts"];
        
        NSDate *deviceTs = [self primitiveValueForKey:@"deviceTs"];
        
        NSDate *deviceCts = [self primitiveValueForKey:@"deviceCts"];
        
        NSDate *sqts = lts ? deviceTs : deviceCts;
        
        [self setPrimitiveValue:sqts forKey:@"sqts"];

        
        if ([self.entity.name isEqualToString:@"STMOutlet"] || [self.entity.name isEqualToString:@"STMSalesman"]) {
            
            NSArray *keys = self.changedValues.allKeys;
            NSLog(@"self.changedValues.allKeys %@", keys);

            NSLog(@"self2 %@", self)
            
        }
    
        
    }
    
    [super willSave];

}


@end
