//
//  STMInventoryInfoSelectTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMInventoryInfoSelectTVC.h"

#import "STMPickingPositionAddInfoVC.h"


@interface STMInventoryInfoSelectTVC ()

@property (nonatomic, strong) NSArray *productionInfo;


@end


@implementation STMInventoryInfoSelectTVC

- (NSArray *)productionInfo {
    
    if (!_productionInfo) {
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"info"
                                                                         ascending:YES
                                                                          selector:@selector(caseInsensitiveCompare:)];
        
        _productionInfo = [self.article.articleProductionInfo sortedArrayUsingDescriptors:@[sortDescriptor]];
        
    }
    return _productionInfo;
    
}

- (void)setSelectedProductionInfo:(STMArticleProductionInfo *)selectedProductionInfo {
    
    _selectedProductionInfo = selectedProductionInfo;
    
    if (![self.navigationController.topViewController isEqual:self]) {
        self.productionInfo = nil;
    }
    
    NSRange indexRange;
    indexRange.location = 1;
    indexRange.length = 2;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:indexRange] withRowAnimation:UITableViewRowAnimationNone];
    
}


#pragma mark - table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
            
        case 1:
            return self.productionInfo.count + 1;
            break;
            
        case 2:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 1: {
            
            NSString *infoTypeName = self.article.productionInfoType.name;
            return [(infoTypeName) ? infoTypeName : NSLocalizedString(@"SELECT INFO", nil) stringByAppendingString:@":"];
            
        }
            break;
            
        default:
            return nil;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:
            [self fillArticleNameCell:cell];
            break;
            
        case 1:
            [self fillProductionInfoCell:cell atIndex:indexPath.row];
            break;
            
        case 2:
            [self fillDoneButtonCell:cell];
            break;
            
        default:
            break;
    }
    
    return cell;
    
}

- (void)fillArticleNameCell:(UITableViewCell *)cell {
    
    cell.textLabel.text = self.article.name;
    cell.textLabel.numberOfLines = 0;
    
    cell.detailTextLabel.text = self.article.extraLabel;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)fillProductionInfoCell:(UITableViewCell *)cell atIndex:(NSInteger)index {
    
    if (index == self.productionInfo.count) {
        
        cell.textLabel.text = NSLocalizedString(@"ADD", nil);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = ACTIVE_BLUE_COLOR;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else {
        
        STMArticleProductionInfo *productionInfo = self.productionInfo[index];
        cell.textLabel.text = [productionInfo displayInfo];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryType = ([self.selectedProductionInfo isEqual:productionInfo]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
    }
    
}

- (void)fillDoneButtonCell:(UITableViewCell *)cell {
    
    cell.textLabel.text = NSLocalizedString(@"DONE", nil);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = (self.selectedProductionInfo) ? ACTIVE_BLUE_COLOR : [UIColor lightGrayColor];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 1:
            if (indexPath.row == self.productionInfo.count) {
                
                STMProductionInfoType *type = self.article.productionInfoType;
                
                NSString *vcIdentifier = ([type.datatype isEqualToString:@"date"]) ? @"addDateVC" : @"addInfoVC";

                STMPickingPositionAddInfoVC *vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:vcIdentifier];
                vc.article = self.article;
                vc.inventoryInfoVC = self;
                
                [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                
                self.selectedProductionInfo = self.productionInfo[indexPath.row];
                
            }
            break;
            
        case 2:
            if (self.selectedProductionInfo) {
                [self infoSelected];
            }
            break;
            
        default:
            break;
    }
    
}

- (void)infoSelected {
    
    if (![self.navigationController.topViewController isEqual:self]) {
        [self.navigationController popToViewController:self animated:YES];
    }
    
    [self.ownerVC selectInfo:self.selectedProductionInfo];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    
    if (self.currentProductionInfo) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"info == %@", self.currentProductionInfo];
        NSArray *currentInfo = [self.productionInfo filteredArrayUsingPredicate:predicate];
        
        if (currentInfo.count == 1) {
            self.selectedProductionInfo = currentInfo.firstObject;
        }
        
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
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
