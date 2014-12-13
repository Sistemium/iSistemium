//
//  STMLogMessagesSVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUISplitViewController.h"
#import "STMLogMessagesMasterTVC.h"
#import "STMLogMessagesDetailTVC.h"

@interface STMLogMessagesSVC : STMUISplitViewController

@property (nonatomic, strong) STMLogMessagesMasterTVC *masterTVC;
@property (nonatomic, strong) STMLogMessagesDetailTVC *detailTVC;

@end
