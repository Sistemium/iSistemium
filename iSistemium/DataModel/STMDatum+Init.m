//
//  STMDatum+Init.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 4/1/13.
//  Copyright (c) 2013 Maxim Grigoriev. All rights reserved.
//

#import "STMDatum+Init.h"

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
        
//        [self willChangeValueForKey:@"xid"];
        [self setPrimitiveValue:[self newXid] forKey:@"xid"];
//        [self didChangeValueForKey:@"xid"];
        
        NSDate *ts = [NSDate date];
//        [self willChangeValueForKey:@"deviceCts"];
        [self setPrimitiveValue:ts forKey:@"deviceCts"];
//        [self didChangeValueForKey:@"deviceCts"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *largestId = [defaults objectForKey:@"largestId"];
        
        if (!largestId) {
            largestId = [NSNumber numberWithInt:1];
        } else {
            largestId = [NSNumber numberWithInt:(int)[largestId integerValue]+1];
        }

//        [self willChangeValueForKey:@"id"];
        [self setPrimitiveValue:largestId forKey:@"id"];
//        [self didChangeValueForKey:@"id"];

        [defaults setObject:largestId forKey:@"largestId"];
        [defaults synchronize];
        
    }
    
}

- (void)willSave {
    
//    NSLog(@"STGTDatum willSave");
//    NSLog(@"[self changedValues] %@", [self changedValues]);
    
    if (![[[self changedValues] allKeys] containsObject:@"lts"] && ![[[self changedValues] allKeys] containsObject:@"sts"]) {
        
        NSDate *ts = [NSDate date];
        
//        [self willChangeValueForKey:@"deviceTs"];
        [self setPrimitiveValue:ts forKey:@"deviceTs"];
//        [self didChangeValueForKey:@"deviceTs"];
        
//        [self willAccessValueForKey:@"lts"];
        NSDate *lts = [self primitiveValueForKey:@"lts"];
//        [self didAccessValueForKey:@"lts"];
        
//        [self willAccessValueForKey:@"deviceTs"];
        NSDate *deviceTs = [self primitiveValueForKey:@"deviceTs"];
//        [self didAccessValueForKey:@"deviceTs"];
        
//        [self willAccessValueForKey:@"deviceCts"];
        NSDate *deviceCts = [self primitiveValueForKey:@"deviceCts"];
//        [self didAccessValueForKey:@"deviceCts"];
        
        NSDate *sqts = lts ? deviceTs : deviceCts;
        
//        [self willChangeValueForKey:@"sqts"];
        [self setPrimitiveValue:sqts forKey:@"sqts"];
//        [self didChangeValueForKey:@"sqts"];
        
    }
    
    [super willSave];

}


@end
