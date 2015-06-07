//
//  STMVariableCellsHeightTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMFetchedResultsControllerTVC.h"

@interface STMVariableCellsHeightTVC : STMFetchedResultsControllerTVC

@property (nonatomic, strong) NSString *cellIdentifier;

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;


@end
