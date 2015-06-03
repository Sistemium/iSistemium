//
//  STMCustom6TVCell.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMTableViewCell.h"

@interface STMCustom6TVCell : STMTableViewCell

@property (weak, nonatomic) IBOutlet STMLabel *titleLabel;
@property (weak, nonatomic) IBOutlet STMLabel *detailLabel;
@property (weak, nonatomic) IBOutlet STMLabel *messageLabel;


@end
