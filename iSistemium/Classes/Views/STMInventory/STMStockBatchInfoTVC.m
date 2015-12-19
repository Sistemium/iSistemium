//
//  STMStockBatchInfoTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMStockBatchInfoTVC.h"

#import "STMInventoryArticleSelectTVC.h"
#import "STMInventoryInfoSelectTVC.h"

#import "STMObjectsController.h"


@interface STMStockBatchInfoTVC ()

@property (nonatomic, strong) NSArray *operations;
@property (nonatomic, strong) NSArray *barcodes;


@end


@implementation STMStockBatchInfoTVC

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


#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            if (self.stockBatch.productionInfo) {
                return 2;
            } else {
                return 1;
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
         
            STMArticle *article = self.stockBatch.article;
            
            NSString *labelText = article.name;
            
            if (article.extraLabel) labelText = [[labelText stringByAppendingString:@" "] stringByAppendingString:(NSString * _Nonnull)article.extraLabel];
            
            cell.textLabel.text = labelText;
            
            cell.detailTextLabel.text = [STMFunctions volumeStringWithVolume:[self.stockBatch localVolume] andPackageRel:article.packageRel.integerValue];

        }
            break;

        case 1:
            
            cell.textLabel.text = [self.stockBatch displayProductionInfo];
            
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
                articleSelectTVC.selectedArticle = self.stockBatch.article;
                
                [self.navigationController pushViewController:articleSelectTVC animated:YES];

            }
                break;

            case 1: {
                
                STMInventoryInfoSelectTVC *infoSelectTVC = [[STMInventoryInfoSelectTVC alloc] initWithStyle:UITableViewStyleGrouped];
                infoSelectTVC.article = self.stockBatch.article;
                infoSelectTVC.currentProductionInfo = self.stockBatch.productionInfo;
                
                [self.navigationController pushViewController:infoSelectTVC animated:YES];
                
            }
                
                break;

            default:
                break;
        }
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
