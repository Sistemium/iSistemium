//
//  STMCashing+dayAsString.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCashing+dayAsString.h"

@implementation STMCashing (dayAsString)

- (NSString *)dayAsString {
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;

    });
    
    NSString *dateString = [formatter stringFromDate:self.date];
    
    return dateString;
    
}


@end
