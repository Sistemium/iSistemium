//
//  STMSupplyOrder.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOrder.h"
#import "STMSupplyOrderArticleDoc.h"

#import "STMFunctions.h"


@implementation STMSupplyOrder

- (NSString *)dayAsString {
    
    if (self.date) {
        
        static NSDateFormatter *formatter;
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            formatter = [STMFunctions dateMediumNoTimeFormatter];
        });
        
        return [formatter stringFromDate:(NSDate * _Nonnull)self.date];

    } else {
        
        return nil;
        
    }
    
}


@end
