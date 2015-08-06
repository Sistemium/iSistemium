//
//  STMReorderRoutePointsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMReorderRoutePointsTVC.h"
#import "STMUI.h"
#import "STMDataModel.h"


@interface STMReorderRoutePointsTVC ()

@property (nonatomic) BOOL orderWasChanged;


@end


@implementation STMReorderRoutePointsTVC

- (NSString *)cellIdentifier {
    return @"reorderPointCell";
}


#pragma mark - tableView data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.points.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom8TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom8TVCell class]]) {
        
        STMCustom8TVCell *customCell = (STMCustom8TVCell *)cell;
        
        STMShipmentRoutePoint *point = self.points[indexPath.row];
        
        customCell.titleLabel.text = point.name;
        
        UIColor *textColor = [UIColor blackColor];
        NSString *detailString;
        
        detailString = [point shortInfo];
        
        if (!point.shippingLocation.location) {
            
            detailString = [detailString stringByAppendingString:@"\n"];
            
            if (self.parentVC.geocodedLocations[point.xid]) {
                
                detailString = [detailString stringByAppendingString:NSLocalizedString(@"LOCATION NOT CONFIRMED", nil)];
                textColor = [UIColor lightGrayColor];
                
            } else {
                
                detailString = [detailString stringByAppendingString:NSLocalizedString(@"NO LOCATION", nil)];
                textColor = [UIColor redColor];
                
            }
            
        }

        customCell.detailLabel.text = detailString;
        
        customCell.infoLabel.text = @(point.ord.integerValue + 1).stringValue;
        customCell.infoLabel.textColor = textColor;
        
        customCell.accessoryType = UITableViewCellAccessoryNone;
        customCell.showsReorderControl = YES;
        
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    cell.backgroundView.backgroundColor = [UIColor whiteColor];
    
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    
    NSInteger fromIndex = fromIndexPath.row;
    NSInteger toIndex = toIndexPath.row;
    
    NSUInteger minIndex = MIN(fromIndex, toIndex);
    NSUInteger loc = (minIndex == fromIndex) ? minIndex + 1 : minIndex;
    
    NSRange affectedPointsRange = NSMakeRange(loc, labs(fromIndex - toIndex));
    
    NSArray *affectedPoints = [self.points subarrayWithRange:affectedPointsRange];

    for (STMShipmentRoutePoint *point in affectedPoints) {
        point.ord = (minIndex == fromIndex) ? @(point.ord.integerValue - 1) : @(point.ord.integerValue + 1);
    }
    
    STMShipmentRoutePoint *movedPoint = self.points[fromIndex];
    movedPoint.ord = @(toIndex);
    
    self.points = [self.points sortedArrayUsingDescriptors:[self.parentVC.parentVC shipmentRoutePointsSortDescriptors]];
    
    self.cachedCellsHeights = nil;
    [self.tableView reloadData];
    
    self.orderWasChanged = YES;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}


#pragma mark - cell's heights cache

- (void)putCachedHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    if (indexPath) self.cachedCellsHeights[indexPath] = @(height);
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    return self.cachedCellsHeights[indexPath];
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom8TVCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    self.editing = YES;
    
    [super customInit];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (self.orderWasChanged) [self.parentVC recalcRoutes];
    
    [super viewWillDisappear:animated];
    
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
