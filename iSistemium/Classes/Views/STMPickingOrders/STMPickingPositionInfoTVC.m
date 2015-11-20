//
//  STMPickingPositionInfoTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 20/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingPositionInfoTVC.h"

@interface STMPickingPositionInfoTVC ()

@property (nonatomic, strong) NSArray *productionInfo;
@property (nonatomic, strong) NSString *articleNameCellIdentifier;
@property (nonatomic, strong) NSString *doneButtonCellIdentifier;

@property (nonatomic, strong) STMArticleProductionInfo *selectedProductionInfo;


@end


@implementation STMPickingPositionInfoTVC

- (NSArray *)productionInfo {
    
    if (!_productionInfo) {
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"info"
                                                                         ascending:YES
                                                                          selector:@selector(caseInsensitiveCompare:)];
        
        _productionInfo = [self.position.article.articleProductionInfo sortedArrayUsingDescriptors:@[sortDescriptor]];
        
    }
    return _productionInfo;
    
}

- (NSString *)articleNameCellIdentifier {
    
    if (!_articleNameCellIdentifier) {
        _articleNameCellIdentifier = [self.cellIdentifier stringByAppendingString:@"_articleNameCellIdentifier"];
    }
    return _articleNameCellIdentifier;
    
}

- (NSString *)doneButtonCellIdentifier {
    
    if (!_doneButtonCellIdentifier) {
        _doneButtonCellIdentifier = [self.cellIdentifier stringByAppendingString:@"_doneButtonCellIdentifier"];
    }
    return _doneButtonCellIdentifier;
    
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
        case 1:
            return [NSLocalizedString(@"SELECT INFO", nil) stringByAppendingString:@":"];
            break;
            
        default:
            return nil;
            break;
    }
    
}

- (UITableViewCell *)cellForHeightCalculationForIndexPath:(NSIndexPath *)indexPath {
    
    static STMCustom5TVCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    });
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            break;
            
        default:
            return self.standardCellHeight;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:self.articleNameCellIdentifier forIndexPath:indexPath];
            [self fillArticleNameCell:cell];
            break;

        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
            [self fillProductionInfoCell:cell atIndex:indexPath.row];
            break;

        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:self.doneButtonCellIdentifier forIndexPath:indexPath];
            [self fillDoneButtonCell:cell];
            break;

        default:
            break;
    }
    
    return cell;
    
}

- (void)fillArticleNameCell:(UITableViewCell *)cell {
    
    if ([cell isKindOfClass:[STMCustom5TVCell class]]) {
        
        STMCustom5TVCell *customCell = (STMCustom5TVCell *)cell;
        
        customCell.titleLabel.text = self.position.article.name;
        customCell.detailLabel.text = nil;
        customCell.infoLabel.text = [STMFunctions volumeStringWithVolume:self.selectedVolume
                                                           andPackageRel:self.position.article.packageRel.integerValue];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
}

- (void)fillProductionInfoCell:(UITableViewCell *)cell atIndex:(NSInteger)index {
    
    if (index == self.productionInfo.count) {
        
        cell.textLabel.text = NSLocalizedString(@"ADD INFO", nil);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = ACTIVE_BLUE_COLOR;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else {
        
        STMArticleProductionInfo *productionInfo = self.productionInfo[index];
        cell.textLabel.text = productionInfo.info;
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


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom5TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.articleNameCellIdentifier];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.cellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:self.doneButtonCellIdentifier];
    
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
