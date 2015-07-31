//
//  STMRouteSummaryArticleInfoTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMRouteSummaryArticleInfoTVC.h"
#import "STMUI.h"
#import "STMFunctions.h"


@interface STMRouteSummaryArticleInfoTVC ()

@property (nonatomic, strong) NSString *articleNameCellIdentifier;


@end


@implementation STMRouteSummaryArticleInfoTVC

- (NSString *)cellIdentifier {
    return @"articleInfoCell";
}

- (NSString *)articleNameCellIdentifier {
    return @"articleNameCellIdentifier";
}

#pragma mark - table data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.positions.count + 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return self.volumeTypeTitle;
            break;
            
        default:
            return [(STMShipmentPosition *)self.positions[section - 1] valueForKeyPath:@"shipment.outlet.name"];
            break;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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
            cell = [tableView dequeueReusableCellWithIdentifier:self.articleNameCellIdentifier];
            break;
            
        default:
            cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
            break;
    }
    
    [self fillCell:cell atIndexPath:indexPath];

    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
        case 0:
            if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
                [self fillArticleCell:(STMCustom7TVCell *)cell];
            }
            break;
            
        default:
            [self fillPositionCell:cell atIndexPath:indexPath];
            break;
    }
    
    [super fillCell:cell atIndexPath:indexPath];

}

- (void)fillArticleCell:(STMCustom7TVCell *)cell {
    
    cell.titleLabel.text = self.article.name;
    cell.detailLabel.text = nil;
    
}

- (void)fillPositionCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    STMShipmentPosition *position = self.positions[indexPath.section - 1];

    [self fillShipmentCell:cell forPosition:position];
    
}

- (void)fillShipmentCell:(UITableViewCell *)cell forPosition:(STMShipmentPosition *)position {
    
    cell.accessoryView = nil;
    
    cell.textLabel.text = position.shipment.ndoc;
    
    NSNumber *volume = [position valueForKey:self.volumeType];
    
    if (volume) {
        
        STMLabel *infoLabel = [[STMLabel alloc] initWithFrame:CGRectMake(0, 0, 40, 21)];
        infoLabel.text = [STMFunctions volumeStringWithVolume:volume.integerValue andPackageRel:position.article.packageRel.integerValue];
        infoLabel.textAlignment = NSTextAlignmentRight;
        infoLabel.adjustsFontSizeToFitWidth = YES;
        
        cell.accessoryView = infoLabel;
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom7TVCell" bundle:nil] forCellReuseIdentifier:self.articleNameCellIdentifier];
    
    [super customInit];
    
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
