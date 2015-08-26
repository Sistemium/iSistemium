//
//  STMOrdersMasterTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMSearchableTVC.h"
#import "STMOrdersSVC.h"

@interface STMOrdersMasterTVC : STMSearchableTVC

@property (nonatomic, weak) STMOrdersSVC *splitVC;
@property (nonatomic) NSUInteger index;
@property (nonatomic, strong) NSString *sectionNameKeyPath;

- (NSFetchRequest *)fetchRequest;
- (void)resetFilter;
- (void)refreshTable;

@end
