//
//  STMInventoryInfoTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMInventoryInfoTVC.h"

@interface STMInventoryInfoTVC ()

@end

@implementation STMInventoryInfoTVC

- (void)refreshInfo {
    [self.tableView reloadData];
}


#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryNone;

    switch (indexPath.row) {
        case 0: {
            
            STMArticle *article = [self.inventoryBatch operatingArticle];
            
            NSString *labelText = article.name;
            
            if (article.extraLabel) labelText = [[labelText stringByAppendingString:@" "] stringByAppendingString:(NSString * _Nonnull)article.extraLabel];

            cell.textLabel.text = labelText;

        }
            break;

        case 1: {
            
            NSString *labelText = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"STOCK BATCH", nil), self.inventoryBatch.stockBatchCode];

            if (self.productionInfo) labelText = [labelText stringByAppendingString:[NSString stringWithFormat:@" (%@)", self.productionInfo]];

            cell.textLabel.text = labelText;
            
            if (!self.inventoryBatch.isDone.boolValue) {
                
                cell.textLabel.textColor = ACTIVE_BLUE_COLOR;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            }
            
        }
            break;

        default:
            break;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.inventoryBatch.isDone.boolValue && indexPath.row == 1) {
        [self.parentVC showStockBatchInfo];
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    self.tableView.scrollEnabled = NO;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.cellIdentifier];

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
