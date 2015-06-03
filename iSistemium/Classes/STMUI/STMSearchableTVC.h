//
//  STMSearchableTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMVariableCellsHeightTVC.h"

@interface STMSearchableTVC : STMVariableCellsHeightTVC

@property (nonatomic, strong) UISearchBar *searchBar;

- (void)performFetch;


@end
