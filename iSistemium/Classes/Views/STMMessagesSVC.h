//
//  STMMessagesSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 30/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STMMessagesMasterTVC.h"
#import "STMMessagesDetailTVC.h"

@interface STMMessagesSVC : UISplitViewController

@property (nonatomic, strong) STMMessagesMasterTVC *masterVC;
@property (nonatomic, strong) STMMessagesDetailTVC *detailVC;


@end
