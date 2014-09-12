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
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *largestId = [defaults objectForKey:@"largestId"];
        
        if (!largestId) {
            largestId = [NSNumber numberWithInt:1];
        } else {
            largestId = [NSNumber numberWithInt:(int)[largestId integerValue]+1];
        }

        [self setPrimitiveValue:largestId forKey:@"id"];

        [defaults setObject:largestId forKey:@"largestId"];
        [defaults synchronize];
        
    }
    
}

- (void)willSave {
    
//    NSLog(@"STGTDatum willSave");
    
//    NSLog(@"[self changedValues] %@", [self changedValues]);
    
    BOOL notLts = ![[[self changedValues] allKeys] containsObject:@"lts"];
    BOOL notSts = ![[[self changedValues] allKeys] containsObject:@"sts"];
    BOOL notDeviceTs = ![[[self changedValues] allKeys] containsObject:@"deviceTs"];
    
    if (notLts && notSts && notDeviceTs) {
        
        NSDate *ts = [NSDate date];
        
        [self willChangeValueForKey:@"deviceTs"];
        [self setPrimitiveValue:ts forKey:@"deviceTs"];
        [self didChangeValueForKey:@"deviceTs"];
        
        NSDate *lts = [self primitiveValueForKey:@"lts"];
        
        NSDate *deviceTs = [self primitiveValueForKey:@"deviceTs"];
        
        NSDate *deviceCts = [self primitiveValueForKey:@"deviceCts"];
        
        NSDate *sqts = lts ? deviceTs : deviceCts;
        
        [self setPrimitiveValue:sqts forKey:@"sqts"];
        
    }
    
    [super willSave];

}


@end
