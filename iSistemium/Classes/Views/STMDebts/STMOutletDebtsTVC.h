//
//  STMOutletDebtsTVC.h
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMOutlet.h"
#import "STMFetchedResultsControllerTVC.h"
#import "STMDebtsDetailsPVC.h"

@interface STMOutletDebtsTVC : STMFetchedResultsControllerTVC <UIActionSheetDelegate>

@property (nonatomic, strong) STMOutlet *outlet;
@property (nonatomic, weak) STMDebtsDetailsPVC *parentVC;
@property (nonatomic, strong) STMDebt *selectedDebt;

- (void)updateRowWithDebt:(STMDebt *)debt;
- (void)showLongPressActionSheetFromView:(UIView *)view;
- (NSMutableAttributedString *)textLabelForDebt:(STMDebt *)debt withFont:(UIFont *)font;
- (NSMutableAttributedString *)detailTextLabelForDebt:(STMDebt *)debt withFont:(UIFont *)font;
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)addLongPressToCell:(UITableViewCell *)cell;

@end
