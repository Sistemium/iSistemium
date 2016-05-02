//
//  STMOutletCashingVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMDebtsDetailsVC.h"

@interface STMOutletCashingTV : UITableView

@end

@interface STMOutletCashingVC : STMDebtsDetailsVC <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet STMOutletCashingTV *tableView;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
