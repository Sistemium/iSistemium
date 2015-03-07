//
//  STMOrdersMasterTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"
#import "STMOrdersSVC.h"

@interface STMOrdersMasterTVC : STMFetchedResultsControllerTVC

@property (nonatomic) NSUInteger index;

- (NSFetchRequest *)fetchRequest;
@property (nonatomic, weak) STMOrdersSVC *splitVC;


@end
