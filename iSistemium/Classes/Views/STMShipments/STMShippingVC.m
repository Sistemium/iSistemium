//
//  STMShippingVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShippingVC.h"
#import "STMUI.h"


@interface STMShippingVC ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end


@implementation STMShippingVC

- (UIView *)titleView {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    cell.textLabel.text = self.shipment.ndoc;
    
    NSString *positions = [self.shipment positionsCountString];
    
    NSString *detailText;
    
    if (self.shipment.shipmentPositions.count > 0) {
        
        NSString *boxes = [self.shipment approximateBoxCountString];
        NSString *bottles = [self.shipment bottleCountString];
        
        detailText = [NSString stringWithFormat:@"%@, %@, %@", positions, boxes, bottles];
        
    } else {
        detailText = NSLocalizedString(positions, nil);
    }
    
    cell.detailTextLabel.text = detailText;
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
//    self.navigationItem.titleView = [self titleView];
    self.navigationItem.title = self.shipment.ndoc;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

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
