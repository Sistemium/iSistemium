//
//  STMCustom1TVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCustom1TVCell.h"

@implementation STMCustom1TVCell


#pragma mark - view lifecycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
