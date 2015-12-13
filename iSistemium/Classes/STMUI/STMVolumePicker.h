//
//  STMVolumePicker.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STMVolumePicker : UIPickerView

@property (nonatomic) NSInteger packageRel;
@property (nonatomic) NSInteger volume;

@property (nonatomic) NSInteger selectedVolume;


@end
