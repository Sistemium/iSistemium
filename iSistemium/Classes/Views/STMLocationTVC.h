//
//  STMLocationTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/05/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "STMSessionManagement.h"

@interface STMLocationTVC : NSObject //<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) id <STMSession> session;

@end
