//
//  STMStockBatchInfoTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMStockBatchInfoTVC.h"

#import "STMInventoryNC.h"

#import "STMInventoryArticleSelectTVC.h"
#import "STMInventoryInfoSelectTVC.h"

#import "STMObjectsController.h"


@interface STMStockBatchInfoTVC ()

@property (nonatomic, weak) STMInventoryNC *parentNC;

@property (nonatomic, strong) NSArray *operations;
@property (nonatomic, strong) NSArray *barcodes;

@property (nonatomic, strong) STMArticle *replacingArticle;
@property (nonatomic, strong) STMArticleProductionInfo *replacingInfo;


@end


@implementation STMStockBatchInfoTVC

- (STMInventoryNC *)parentNC {

    if (!_parentNC) {
    
        if ([self.navigationController isKindOfClass:[STMInventoryNC class]]) {
            _parentNC = (STMInventoryNC *)self.navigationController;
        }
        
    }
    return _parentNC;

}

- (NSArray *)operations {
    
    if (!_operations) {
        
        NSMutableSet *operations = self.stockBatch.sourceOperations.mutableCopy;
        if (self.stockBatch.destinationOperations) [operations unionSet:(NSSet * _Nonnull)self.stockBatch.destinationOperations];
        
        NSArray *operationsArray = operations.allObjects;
        
        NSSortDescriptor *deviceCtsDesriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:NO selector:@selector(compare:)];

        operationsArray = [operationsArray sortedArrayUsingDescriptors:@[deviceCtsDesriptor]];
        
        _operations = operationsArray;
        
    }
    return _operations;
    
}

- (NSArray *)barcodes {
    
    if (!_barcodes) {
        
        NSArray *barcodes = [[self.stockBatch.barCodes valueForKeyPath:@"code"] allObjects];
        barcodes = [barcodes sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        _barcodes = barcodes;
        
    }
    return _barcodes;
    
}


#pragma mark - STMArticleSelecting protocol

- (void)selectArticle:(STMArticle *)article withSearchedBarcode:(NSString *)barcode {
    
    [self.parentNC popToViewController:self animated:YES];
    
    self.replacingArticle = article;
    self.replacingInfo = nil;

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];

    if (article.productionInfoType) {
        
        [self showInfoSelectTVC];
        
    }
    
    [self updateToolbar];
    
}


#pragma mark - STMProductionInfoSelecting protocol

- (void)selectInfo:(STMArticleProductionInfo *)info {
    
    self.replacingInfo = info;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self updateToolbar];

}


#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            
            if (self.replacingArticle) {
                return (self.replacingArticle.productionInfoType) ? 2 : 1;
            } else {
                if (self.stockBatch.productionInfo || self.replacingInfo) {
                    return 2;
                } else {
                    return 1;
                }
            }
            break;

        case 1:
            return 1;
            break;

        case 2:
            return self.operations.count;
            break;

        default:
            return 0;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return NSLocalizedString(@"ARTICLE", nil);
            break;

        case 1:
            return NSLocalizedString(@"BARCODES", nil);
            break;

        case 2:
            return NSLocalizedString(@"OPERATIONS", nil);
            break;

        default:
            return nil;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewSubtitleStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = @"";
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textColor = [UIColor blackColor];
    
    cell.detailTextLabel.text = @"";
    
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (indexPath.section) {
        case 0:
            [self fillInfoCell:cell atIndexPath:indexPath];
            break;

        case 1:
            [self fillCodeCell:cell atIndexPath:indexPath];
            break;

        case 2:
            [self fillOperationCell:cell atIndexPath:indexPath];
            break;

        default:
            break;
    }
    
    return cell;
    
}

- (void)fillInfoCell:(STMTableViewSubtitleStyleCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    switch (indexPath.row) {
        case 0: {
         
            STMArticle *article = (self.replacingArticle) ? self.replacingArticle : self.stockBatch.article;
            
            NSString *labelText = article.name;
            
            if (article.extraLabel) labelText = [[labelText stringByAppendingString:@" "] stringByAppendingString:(NSString * _Nonnull)article.extraLabel];
            
            cell.textLabel.text = labelText;
            
            cell.detailTextLabel.text = [STMFunctions volumeStringWithVolume:[self.stockBatch localVolume] andPackageRel:article.packageRel.integerValue];

        }
            break;

        case 1:
            
            if (self.replacingArticle) {
                
                if (self.replacingInfo) {
                    
                    cell.textLabel.text = [self.replacingInfo displayInfo];
                    
                } else {
                    
                    cell.textLabel.text = NSLocalizedString(@"ENTER PRODUCTION INFO", nil);
                    cell.textLabel.textColor = [UIColor redColor];
                    
                }
                
            } else {
                
                if (self.replacingInfo) {
                    
                    cell.textLabel.text = [self.replacingInfo displayInfo];
                    
                } else {
                    
                    cell.textLabel.text = [self.stockBatch displayProductionInfo];
                    
                }
                
            }
            
            break;
            
        default:
            break;
    }
    
}

- (void)fillCodeCell:(STMTableViewSubtitleStyleCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSString *codesString = [self.barcodes componentsJoinedByString:@", "];
    
    cell.textLabel.text = codesString;
    
}

- (void)fillOperationCell:(STMTableViewSubtitleStyleCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMStockBatchOperation *operation = self.operations[indexPath.row];
    
    UIColor *color = (operation.isProcessed.boolValue) ? [UIColor grayColor] : [UIColor blackColor];
    
    cell.textLabel.text = [[STMFunctions noDateMediumTimeFormatter] stringFromDate:operation.deviceCts];
    cell.textLabel.textColor = color;
    
    NSString *volumeString = [STMFunctions volumeStringWithVolume:operation.volume.integerValue
                                                    andPackageRel:self.stockBatch.article.packageRel.integerValue];
    
    NSString *signString = ([operation.destinationAgent isEqual:self.stockBatch]) ? @"+" : [STMFunctions trueMinus];
    
    volumeString = [NSString stringWithFormat:@"%@%@", signString, volumeString];
    
    STMLabel *volumeLabel = [[STMLabel alloc] initWithFrame:CGRectMake(0, 0, 46, 21)];
    volumeLabel.text = volumeString;
    volumeLabel.textColor = color;
    volumeLabel.textAlignment = NSTextAlignmentRight;
    volumeLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.accessoryView = volumeLabel;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {

            case 0: {
                
                NSArray *articles = [STMObjectsController objectsForEntityName:NSStringFromClass([STMArticle class])
                                                                       orderBy:@"name"
                                                                     ascending:YES
                                                                    fetchLimit:0
                                                                   withFantoms:NO
                                                        inManagedObjectContext:nil
                                                                         error:nil];

            
                STMInventoryArticleSelectTVC *articleSelectTVC = [[STMInventoryArticleSelectTVC alloc] initWithStyle:UITableViewStyleGrouped];
                articleSelectTVC.articles = articles;
                articleSelectTVC.selectedArticle = (self.replacingArticle) ? self.replacingArticle : self.stockBatch.article;
                articleSelectTVC.ownerVC = self;
                
                [self.navigationController pushViewController:articleSelectTVC animated:YES];

            }
                break;

            case 1:
                [self showInfoSelectTVC];
                break;

            default:
                break;
        }
        
    }
    
}

- (void)showInfoSelectTVC {
    
    STMInventoryInfoSelectTVC *infoSelectTVC = [[STMInventoryInfoSelectTVC alloc] initWithStyle:UITableViewStyleGrouped];
    infoSelectTVC.article = (self.replacingArticle) ? self.replacingArticle : self.stockBatch.article;
    infoSelectTVC.currentProductionInfo = (self.replacingInfo) ? self.replacingInfo.info : self.stockBatch.productionInfo;
    infoSelectTVC.ownerVC = self;
    
    [self.navigationController pushViewController:infoSelectTVC animated:YES];

}


#pragma mark - toolbar setup

- (void)updateToolbar {
    
    self.navigationController.toolbarHidden = NO;
    
    STMBarButtonItemCancel *cancelButton = [[STMBarButtonItemCancel alloc] initWithTitle:NSLocalizedString(@"CANCEL", nil)
                                                                                   style:UIBarButtonItemStylePlain
                                                                                  target:self
                                                                                  action:@selector(cancelButtonPressed)];

    STMBarButtonItemDone *doneButton = [[STMBarButtonItemDone alloc] initWithTitle:NSLocalizedString(@"DONE", nil)
                                                                             style:UIBarButtonItemStyleDone
                                                                            target:self
                                                                            action:@selector(doneButtonPressed)];

    if (!self.replacingArticle && !self.replacingInfo) {
        doneButton.enabled = NO;
    }

    if (self.replacingArticle && self.replacingArticle.productionInfoType && !self.replacingInfo) {
        doneButton.enabled = NO;
    }
    
    [self setToolbarItems:@[cancelButton, [STMBarButtonItem flexibleSpace], doneButton]];

}

- (void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed {
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];

    [self updateToolbar];
    
    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.navigationController.toolbarHidden = NO;

    if ([self isMovingToParentViewController]) {
        self.parentNC.scanEnabled = NO;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        self.parentNC.scanEnabled = YES;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
