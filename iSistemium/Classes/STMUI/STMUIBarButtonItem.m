//
//  STMUIBarButtonItem.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUIBarButtonItem.h"
#import "STMConstants.h"

@implementation STMUIBarButtonItemDone

@end


@implementation STMUIBarButtonItemCancel

@end


@implementation STMUIBarButtonItem

- (id)init {
    
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

    if ([self isKindOfClass:[STMUIBarButtonItemDone class]]) {
        
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

    } else if ([self isKindOfClass:[STMUIBarButtonItemCancel class]]) {
        

        
    }
    
}

@end
