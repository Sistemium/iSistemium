//
//  STMEntity+custom.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 10/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMEntity+custom.h"

@implementation STMEntity (custom)

- (void)willSave {
    
    NSArray *changedKeys = [[self changedValues] allKeys];
    
    if ([changedKeys containsObject:@"workflow"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"workflowDidChange" object:self];
    }
    
    [super willSave];
    
}

@end
