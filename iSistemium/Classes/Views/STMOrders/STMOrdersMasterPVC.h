//
//  STMOrdersMasterPVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STMOrdersMasterPVC : UIPageViewController

- (void)updateResetFilterButtonState;
- (void)refreshTables;

@end
