//
//  STMPickingOrdersTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

@interface STMPickingOrdersTVC : STMVariableCellsHeightTVC

- (NSArray <NSString *>*)actions;
- (void)selectAction:(NSString *)action;


@end
