//
//  STMSelectPartnerTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/12/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"
#import "STMPartner.h"

@interface STMSelectPartnerTVC : STMFetchedResultsControllerTVC

@property (nonatomic, strong) STMPartner *partner;

@end
