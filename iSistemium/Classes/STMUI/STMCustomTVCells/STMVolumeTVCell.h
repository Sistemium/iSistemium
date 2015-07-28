//
//  STMVolumeTVCell.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 28/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMTableViewCell.h"

@interface STMVolumeTVCell : STMTableViewCell

@property (weak, nonatomic) IBOutlet STMLabel *titleLabel;

@property (weak, nonatomic) IBOutlet STMLabel *boxCountLabel;
@property (weak, nonatomic) IBOutlet STMLabel *bottleCountLabel;


@end
