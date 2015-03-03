//
//  STMAddOutletVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMAddPopoverVC.h"
#import "STMPartner.h"

@interface STMAddOutletVC : STMAddPopoverVC

@property (nonatomic, strong) STMPartner *partner;
@property (nonatomic, strong) NSString *partnerName;

@end
