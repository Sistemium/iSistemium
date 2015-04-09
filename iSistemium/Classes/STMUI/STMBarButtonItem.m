//
//  STMUIBarButtonItem.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMBarButtonItem.h"
#import "STMConstants.h"

@implementation STMBarButtonItemDone

@end


@implementation STMBarButtonItemCancel

@end


@implementation STMBarButtonItem

+ (STMBarButtonItem *)flexibleSpace {
    
    STMBarButtonItem *flexibleSpace = [[STMBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    return flexibleSpace;
    
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self customInit];
        
    }
    
    return self;
    
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self customInit];
    
}

- (void)customInit {

    if ([self isKindOfClass:[STMBarButtonItemDone class]]) {
        
        UIFont *font = [UIFont boldSystemFontOfSize:17];
        UIColor *color = ACTIVE_BLUE_COLOR;
        
        NSDictionary *textAttributes = @{
                                         NSFontAttributeName:font,
                                         NSForegroundColorAttributeName:color
                                         };

        [self setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        
        color = GREY_LINE_COLOR;
        textAttributes = @{
                           NSForegroundColorAttributeName:color
                           };

        [self setTitleTextAttributes:textAttributes forState:UIControlStateDisabled];

    } else if ([self isKindOfClass:[STMBarButtonItemCancel class]]) {
        
//        UIColor *color = [UIColor redColor];
        UIColor *color = ACTIVE_BLUE_COLOR;
        
        NSDictionary *textAttributes = @{
                                         NSForegroundColorAttributeName:color
                                         };
        
        [self setTitleTextAttributes:textAttributes forState:UIControlStateNormal];

        
    }
    
}

@end