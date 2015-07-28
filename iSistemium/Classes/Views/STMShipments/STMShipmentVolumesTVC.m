//
//  STMShipmentVolumesTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 28/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentVolumesTVC.h"

#import "STMUI.h"


@interface STMShipmentVolumesTVC ()

@property (nonatomic, strong) NSString *positionCellIdentifier;
@property (nonatomic, strong) NSString *volumeCellIdentifier;

@property (nonatomic, strong) NSMutableArray *selectedSections;


@end


@implementation STMShipmentVolumesTVC

- (NSString *)cellIdentifier {
    return self.positionCellIdentifier;
}

- (NSString *)positionCellIdentifier {
    return @"positionCellIdentifier";
}

- (NSString *)volumeCellIdentifier {
    return @"volumeCellIdentifier";
}

- (NSMutableArray *)selectedSections {
    
    if (!_selectedSections) {
        _selectedSections = [NSMutableArray array];
    }
    return _selectedSections;
    
}


#pragma mark - tableView dataSource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 2;
            break;
            
        default:
            return ([self.selectedSections containsObject:@(section)]) ? 2 : 1;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 1:
            return @"   ";
            break;
            
        default:
            return nil;
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
        case 0:
            return [super tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                    return self.standardCellHeight;
                    break;
                    
                case 1:
                    return self.standardCellHeight;
                    break;
                    
                default:
                    break;
            }
            
        default:
            break;
    }

    return self.standardCellHeight;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:self.positionCellIdentifier forIndexPath:indexPath];
            break;

        default:
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:self.volumeCellIdentifier forIndexPath:indexPath];
                    break;
                    
                default:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"volumeCell" forIndexPath:indexPath];
                    break;
            }
            break;
    }
    
    [self fillCell:cell atIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            if ([cell isKindOfClass:[STMCustom2TVCell class]]) {
                [self fillPositionInfoCell:(STMCustom2TVCell *)cell atIndexPath:indexPath];
            }
            break;

        default:
            switch (indexPath.row) {
                case 0:
                    if ([cell isKindOfClass:[STMVolumeTVCell class]]) {
                        [self fillVolumeCell:(STMVolumeTVCell *)cell atIndexPath:indexPath];
                    }
                    break;
                    
                case 1:
                    [self fillControlCell:cell atIndexPath:indexPath];
                    break;

                default:
                    break;
            }
            break;
    }
    
    [super fillCell:cell atIndexPath:indexPath];

}

- (void)fillPositionInfoCell:(STMCustom2TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = @"Товар";
            cell.detailLabel.text = self.position.article.name;
            cell.detailLabel.textAlignment = NSTextAlignmentLeft;
            break;

        case 1:
            cell.titleLabel.text = @"По накладной";
            cell.detailLabel.text = [self.position volumeText];
            cell.detailLabel.textAlignment = NSTextAlignmentRight;
            break;

        default:
            break;
    }
    
}

- (void)fillVolumeCell:(STMVolumeTVCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    NSString *title = [NSString stringWithFormat:@"%ld_VOLUME_TYPE", (NSInteger)(indexPath.section - 1)];
    
    cell.titleLabel.text = NSLocalizedString(title, nil);
    
}

- (void)fillControlCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = @"CONTROLS";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 && indexPath.section > 0) {

        BOOL isSelected = [self.selectedSections containsObject:@(indexPath.section)];
        
        (isSelected) ? [self.selectedSections removeObject:@(indexPath.section)] : [self.selectedSections addObject:@(indexPath.section)];
        
        (isSelected) ? [self hideControlsAtIndexPath:indexPath tableView:tableView] : [self showControlsAtIndexPath:indexPath tableView:tableView];
        
    }
    
}

- (void)showControlsAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {

    [tableView beginUpdates];

    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    NSIndexPath *controlsIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    [tableView reloadRowsAtIndexPaths:@[controlsIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    
    [tableView endUpdates];

    if (![tableView.visibleCells containsObject:[tableView cellForRowAtIndexPath:controlsIndexPath]]) {
        [tableView scrollToRowAtIndexPath:controlsIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

}

- (void)hideControlsAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
//    [tableView beginUpdates];
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    
//    [tableView endUpdates];

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
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom2TVCell" bundle:nil] forCellReuseIdentifier:self.positionCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"STMVolumeTVCell" bundle:nil] forCellReuseIdentifier:self.volumeCellIdentifier];
    
    [super customInit];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

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
