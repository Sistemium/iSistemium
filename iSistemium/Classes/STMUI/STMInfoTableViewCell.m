//
//  STMInfoTableViewCell.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMInfoTableViewCell.h"

@implementation STMInfoTableViewCell

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
//    UIFont *font = [UIFont systemFontOfSize:18];
    UIColor *backgroundColor = [UIColor clearColor];
    
//    self.infoLabel.font = font;
    self.infoLabel.textAlignment = NSTextAlignmentRight;
    self.infoLabel.backgroundColor = backgroundColor;
    
    CGFloat paddingX = 10;
    CGFloat paddingY = 0;
    CGFloat marginX = 10;
    
    NSDictionary *attributes = @{NSFontAttributeName:self.infoLabel.font};
    
    CGSize size = [self.infoLabel.text sizeWithAttributes:attributes];

    CGFloat x = self.contentView.frame.size.width - size.width - 2 * paddingX - marginX;
    CGFloat y = (self.contentView.frame.size.height - size.height - 2 * paddingY) / 2;
    CGRect frame = CGRectMake(x, y, size.width + 2 * paddingX, size.height + 2 * paddingY);
    self.infoLabel.frame = frame;

    [self setFrameToLabel:self.textLabel withInfoLabel:self.infoLabel];
    [self setFrameToLabel:self.detailTextLabel withInfoLabel:self.infoLabel];
    
}

- (void)setFrameToLabel:(UILabel *)label withInfoLabel:(UILabel *)infoLabel {

    CGFloat x = label.frame.origin.x;
    CGFloat y = label.frame.origin.y;
    CGFloat height = label.frame.size.height;
    CGFloat width = infoLabel.frame.origin.x - x;
    CGRect frame = CGRectMake(x, y, width, height);
    label.frame = frame;

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.infoLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.infoLabel];
        
    }
    return self;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end
