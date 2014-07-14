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
    
    if (self.managedObjectContext.parentContext) {
        [self setPrimitiveValue:[self newXid] forKey:@"xid"];
        
        NSDate *ts = [NSDate date];
        [self setPrimitiveValue:ts forKey:@"cts"];
        
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
    
    if (![[[self changedValues] allKeys] containsObject:@"lts"] && ![[[self changedValues] allKeys] containsObject:@"sts"]) {
        
        NSDate *ts = [NSDate date];
        [self setPrimitiveValue:ts forKey:@"ts"];
        NSDate *sqts = [self primitiveValueForKey:@"lts"] ? [self primitiveValueForKey:@"ts"] : [self primitiveValueForKey:@"cts"];
        [self setPrimitiveValue:sqts forKey:@"sqts"];
        
    }
    [super willSave];

}


@end
