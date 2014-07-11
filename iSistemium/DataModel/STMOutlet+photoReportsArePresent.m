//
//  STMOutlet+photoReportsArePresent.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/07/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMOutlet+photoReportsArePresent.h"

@implementation STMOutlet (photoReportsArePresent)

- (BOOL)photoReportsArePresent {
    
    if (self.photoReports.count == 0) {
        
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}

@end
