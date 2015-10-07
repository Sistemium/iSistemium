//
//  STMPositionVolumesVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMPositionVolumesVC.h"
#import "STMShippingProcessController.h"


@interface STMPositionVolumesVC () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) STMBarButtonItemCancel *cancelButton;
@property (nonatomic, strong) STMBarButtonItemDone *doneButton;

@property (nonatomic, strong) NSString *positionTitleCellIdentifier;
@property (nonatomic, strong) NSString *positionVolumeCellIdentifier;
@property (nonatomic, strong) NSString *volumeCellIdentifier;
@property (nonatomic, strong) NSString *controlsCellIdentifier;

@property (nonatomic, strong) NSMutableArray *selectedSections;

@property (nonatomic) CGFloat standardCellHeight;
@property (strong, nonatomic) NSMutableDictionary *cachedCellsHeights;

@property (nonatomic, strong) STMVolumeTVCell *doneVolumeCell;
@property (nonatomic, strong) STMVolumeTVCell *badVolumeCell;
@property (nonatomic, strong) STMVolumeTVCell *excessVolumeCell;
@property (nonatomic, strong) STMVolumeTVCell *shortageVolumeCell;
@property (nonatomic, strong) STMVolumeTVCell *regradeVolumeCell;
@property (nonatomic, strong) STMVolumeTVCell *brokenVolumeCell;
//@property (nonatomic, strong) STMVolumeTVCell *discrepancyVolumeCell;
@property (nonatomic, strong) NSArray *volumeCells;

@property (nonatomic, strong) NSMutableDictionary *volumeValues;


@end


@implementation STMPositionVolumesVC

- (NSString *)positionTitleCellIdentifier {
    return @"positionTitleCellIdentifier";
}

- (NSString *)positionVolumeCellIdentifier {
    return @"positionVolumeCellIdentifier";
}

- (NSString *)volumeCellIdentifier {
    return @"volumeCellIdentifier";
}

- (NSString *)controlsCellIdentifier {
    return @"controlsCellIdentifier";
}

- (NSMutableArray *)selectedSections {
    
    if (!_selectedSections) {
        _selectedSections = [NSMutableArray array];
    }
    return _selectedSections;
    
}

- (NSMutableDictionary *)cachedCellsHeights {
    
    if (!_cachedCellsHeights) {
        _cachedCellsHeights = [NSMutableDictionary dictionary];
    }
    return _cachedCellsHeights;
    
}

- (CGFloat)standardCellHeight {
    
    if (!_standardCellHeight) {
        
        static CGFloat standardCellHeight;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            standardCellHeight = [[UITableViewCell alloc] init].frame.size.height;
        });
        
        _standardCellHeight = standardCellHeight + 1.0f;  // Add 1.0f for the cell separator height
        
    }
    return _standardCellHeight;
    
}

- (NSArray *)volumeCells {
    
    return @[self.doneVolumeCell,
             self.badVolumeCell,
             self.excessVolumeCell,
             self.shortageVolumeCell,
             self.regradeVolumeCell,
             self.brokenVolumeCell];
    
}

- (STMVolumeTVCell *)doneVolumeCell {
    
    if (!_doneVolumeCell) {
        _doneVolumeCell = [[NSBundle mainBundle] loadNibNamed:@"STMVolumeTVCell" owner:nil options:nil].firstObject;
    }
    return _doneVolumeCell;
    
}

- (NSMutableDictionary *)volumeValues {
    
    if (!_volumeValues) {
        _volumeValues = [NSMutableDictionary dictionary];
    }
    return _volumeValues;
    
}

- (void)setupToolbar {
    
    self.cancelButton = [[STMBarButtonItemCancel alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self
                                                                             action:@selector(cancelButtonPressed:)];
    
    self.doneButton = [[STMBarButtonItemDone alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                         target:self
                                                                         action:@selector(doneButtonPressed:)];
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
    
    self.toolbar.items = @[self.cancelButton, flexibleSpace, self.doneButton];
    
}

- (void)cancelButtonPressed:(id)sender {
    [self dismissSelf];
}

- (void)doneButtonPressed:(id)sender {
    
    NSNumber *volumesSum = [self.volumeValues.allValues valueForKeyPath:@"@sum.self"];

    if (volumesSum > 0) {
        
        NSInteger discrepancyVolume = self.position.volume.integerValue - volumesSum.integerValue;

        
        if (discrepancyVolume != 0) {
            
            NSString *checkingInfo = [[STMShippingProcessController sharedInstance] checkingInfoForPosition:self.position
                                                                                             withDoneVolume:[self.volumeValues[@(STMVolumeTypeDone)] integerValue]
                                                                                                  badVolume:[self.volumeValues[@(STMVolumeTypeBad)] integerValue]
                                                                                               excessVolume:[self.volumeValues[@(STMVolumeTypeExcess)] integerValue]
                                                                                             shortageVolume:[self.volumeValues[@(STMVolumeTypeShortage)] integerValue]
                                                                                              regradeVolume:[self.volumeValues[@(STMVolumeTypeRegrade)] integerValue]
                                                                                               brokenVolume:[self.volumeValues[@(STMVolumeTypeBroken)] integerValue]];
            
            if (!checkingInfo) {
                
                [self shippingPositionAndDismiss];
                
            } else {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:checkingInfo
                                                                   delegate:self
                                                          cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                          otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
                    alert.tag = 111;
                    [alert show];
                    
                }];
                
            }
            
        } else {
            [self shippingPositionAndDismiss];
        }
        
    } else {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"EMPTY POSITION VOLUMES TITLE", nil)
                                                            message:NSLocalizedString(@"EMPTY POSITION VOLUMES MESSAGE", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
            [alert show];
            
        }];
        
    }

}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case 111:
            
            switch (buttonIndex) {
                case 1:
                    [self shippingPositionAndDismiss];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
    
}


- (void)shippingPositionAndDismiss {
    
    [[STMShippingProcessController sharedInstance] shippingPosition:self.position
                                                     withDoneVolume:[self.volumeValues[@(STMVolumeTypeDone)] integerValue]
                                                          badVolume:[self.volumeValues[@(STMVolumeTypeBad)] integerValue]
                                                       excessVolume:[self.volumeValues[@(STMVolumeTypeExcess)] integerValue]
                                                     shortageVolume:[self.volumeValues[@(STMVolumeTypeShortage)] integerValue]
                                                      regradeVolume:[self.volumeValues[@(STMVolumeTypeRegrade)] integerValue]
                                                       brokenVolume:[self.volumeValues[@(STMVolumeTypeBroken)] integerValue]];
    [self dismissSelf];
    
}

- (void)dismissSelf {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - tableView dataSource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
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
        case 0:
            return @"   ";
            break;
            
        case 1:
            return @"   ";
            break;

        default:
            return nil;
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    switch (section) {
        case 0:
            return 20;
            break;
            
        case 1:
            return 20;
            break;
            
        default:
            return 5;
            break;
    }

}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.standardCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *cachedHeight = [self getCachedHeightForIndexPath:indexPath];
    CGFloat height = (cachedHeight) ? cachedHeight.floatValue : [self heightForCellAtIndexPath:indexPath];
    
    return height;
    
}

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            static UITableViewCell *cell = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                cell = [self.tableView dequeueReusableCellWithIdentifier:self.positionTitleCellIdentifier];
            });
            
            [self fillCell:cell atIndexPath:indexPath];
            
            cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds) - MAGIC_NUMBER_FOR_CELL_WIDTH, CGRectGetHeight(cell.bounds));
            
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
            
            CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            CGFloat height = size.height + 1.0f; // Add 1.0f for the cell separator height
            
            if (height < [self tableView:self.tableView estimatedHeightForRowAtIndexPath:indexPath]) {
                height = [self tableView:self.tableView estimatedHeightForRowAtIndexPath:indexPath];
            }
            
            [self putCachedHeight:height forIndexPath:indexPath];
            
            return height;

        } else {
            return self.standardCellHeight;
        }
        
    } else {
        return self.standardCellHeight;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:self.positionTitleCellIdentifier forIndexPath:indexPath];
                    break;
                    
                default:
                    cell = [tableView dequeueReusableCellWithIdentifier:self.positionVolumeCellIdentifier forIndexPath:indexPath];
                    break;
            }
            break;
            
        default:
            switch (indexPath.row) {
                case 0:
//                    cell = [tableView dequeueReusableCellWithIdentifier:self.volumeCellIdentifier forIndexPath:indexPath];
                    cell = [self volumeCellForIndexPath:indexPath];
                    break;
                    
                default:
                    cell = [tableView dequeueReusableCellWithIdentifier:self.controlsCellIdentifier forIndexPath:indexPath];
                    break;
            }
            break;
    }
    
    [self fillCell:cell atIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (STMVolumeTVCell *)volumeCellForIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 1:
            return self.doneVolumeCell;
            break;
            
        default:
            return [self.tableView dequeueReusableCellWithIdentifier:self.volumeCellIdentifier forIndexPath:indexPath];
            break;
    }
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    if ([cell isKindOfClass:[STMCustom2TVCell class]]) {
                        [self fillPositionNameCell:(STMCustom2TVCell *)cell atIndexPath:indexPath];
                    }
                    break;
                    
                default:
                    if ([cell isKindOfClass:[STMVolumeTVCell class]]) {
                        [self fillPositionVolumeCell:(STMVolumeTVCell *)cell atIndexPath:indexPath];
                    }
                    break;
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
                    if ([cell isKindOfClass:[STMVolumeControlsTVCell class]]) {
                        [self fillControlCell:(STMVolumeControlsTVCell *)cell atIndexPath:indexPath];
                    }
                    break;
                    
                default:
                    break;
            }
            break;
    }
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
}

- (void)fillPositionNameCell:(STMCustom2TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = @"Товар";
            cell.titleLabel.textColor = [UIColor blackColor];
            cell.detailLabel.text = self.position.article.name;
            cell.detailLabel.textAlignment = NSTextAlignmentRight;
            break;
            
        default:
            break;
    }
    
}

- (void)fillPositionVolumeCell:(STMVolumeTVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 1:
            cell.titleLabel.text = @"По накладной";
            cell.titleLabel.textColor = [UIColor blackColor];
            cell.packageRel = self.position.article.packageRel.integerValue;
            cell.volume = self.position.volume.integerValue;
            break;
            
        default:
            break;
    }

}

- (void)fillVolumeCell:(STMVolumeTVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.parentVC = self;
    
    NSString *title = [NSString stringWithFormat:@"%ld_VOLUME_TYPE", (long)(indexPath.section - 1)];
    cell.titleLabel.text = NSLocalizedString(title, nil);
    
    cell.titleLabel.textColor = [UIColor blackColor];

    cell.packageRel = self.position.article.packageRel.integerValue;
    
    cell.volumeType = (int)(indexPath.section - 1);
    NSNumber *volume = self.volumeValues[@(indexPath.section - 1)];
    
    switch (indexPath.section) {
        case 1:
//            self.doneVolumeCell = cell;
            cell.volume = (volume) ? volume.integerValue : (self.position.isProcessed.boolValue) ? self.position.doneVolume.integerValue : self.position.volume.integerValue;
            break;
            
        case 2:
            self.badVolumeCell = cell;
            cell.volume = (volume) ? volume.integerValue : self.position.badVolume.integerValue;
            break;

        case 3:
            self.excessVolumeCell = cell;
            cell.volume = (volume) ? volume.integerValue : self.position.excessVolume.integerValue;
            break;

        case 4:
            self.shortageVolumeCell = cell;
            cell.volume = (volume) ? volume.integerValue : self.position.shortageVolume.integerValue;
            break;

        case 5:
            self.regradeVolumeCell = cell;
            cell.volume = (volume) ? volume.integerValue : self.position.regradeVolume.integerValue;
            break;

        case 6:
            self.brokenVolumeCell = cell;
            cell.volume = (volume) ? volume.integerValue : self.position.brokenVolume   .integerValue;
            break;

        default:
            break;
    }
    
    [self removeSwipeGesturesFromCell:cell];
    [self addSwipeGestureToCell:cell];
    
}

- (void)fillControlCell:(STMVolumeControlsTVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.packageRel = self.position.article.packageRel.integerValue;
    cell.volumeLimit = self.position.volume.integerValue;
    
    NSNumber *volume = self.volumeValues[@(indexPath.section - 1)];

    switch (indexPath.section) {
        case 1:
            cell.volumeCell = self.doneVolumeCell;
            cell.volume = (volume) ? volume.integerValue : (self.position.isProcessed.boolValue) ? self.position.doneVolume.integerValue : self.position.volume.integerValue;
            break;
            
        case 2:
            cell.volumeCell = self.badVolumeCell;
            cell.volume = (volume) ? volume.integerValue : self.position.badVolume.integerValue;
            break;
            
        case 3:
            cell.volumeCell = self.excessVolumeCell;
            cell.volume = (volume) ? volume.integerValue : self.position.excessVolume.integerValue;
            break;
            
        case 4:
            cell.volumeCell = self.shortageVolumeCell;
            cell.volume = (volume) ? volume.integerValue : self.position.shortageVolume.integerValue;
            break;
            
        case 5:
            cell.volumeCell = self.regradeVolumeCell;
            cell.volume = (volume) ? volume.integerValue : self.position.regradeVolume.integerValue;
            break;

        case 6:
            cell.volumeCell = self.brokenVolumeCell;
            cell.volume = (volume) ? volume.integerValue : self.position.brokenVolume.integerValue;
            break;

        default:
            break;
    }
    
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
    
//    if (![tableView.visibleCells containsObject:[tableView cellForRowAtIndexPath:controlsIndexPath]]) {
        [tableView scrollToRowAtIndexPath:controlsIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
    
}

- (void)hideControlsAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
    //    [tableView beginUpdates];
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
    
    //    [tableView endUpdates];
    
}


#pragma mark - cell's swipe

- (void)addSwipeGestureToCell:(UITableViewCell *)cell {
    
    UISwipeGestureRecognizer *swipeToRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToRight:)];
    swipeToRight.direction = UISwipeGestureRecognizerDirectionRight;

    UISwipeGestureRecognizer *swipeToLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToLeft:)];
    swipeToLeft.direction = UISwipeGestureRecognizerDirectionLeft;

    if (swipeToRight) [cell addGestureRecognizer:swipeToRight];
    if (swipeToLeft) [cell addGestureRecognizer:swipeToLeft];
    
}

- (void)removeSwipeGesturesFromCell:(UITableViewCell *)cell {
    
    for (UIGestureRecognizer *gesture in cell.gestureRecognizers) {
        if ([gesture isKindOfClass:[UISwipeGestureRecognizer class]]) {
            [cell removeGestureRecognizer:gesture];
        }
    }
    
}

- (void)swipeToRight:(id)sender {
    
//    NSLogMethodName;
    
    if ([sender isKindOfClass:[UISwipeGestureRecognizer class]]) {
        
        STMVolumeTVCell *cell = (STMVolumeTVCell *)[(UISwipeGestureRecognizer *)sender view];
        
        if ([self.volumeCells containsObject:cell]) {
            
            cell.volume = self.position.volume.integerValue;
            [self syncControlsVolumeWithCell:cell];
            
        }

    }
    
}

- (void)swipeToLeft:(id)sender {
    
//    NSLogMethodName;

    if ([sender isKindOfClass:[UISwipeGestureRecognizer class]]) {

        STMVolumeTVCell *cell = (STMVolumeTVCell *)[(UISwipeGestureRecognizer *)sender view];
        
        if ([self.volumeCells containsObject:cell]) {

            cell.volume = 0;
            [self syncControlsVolumeWithCell:cell];

        }

    }

}

- (void)syncControlsVolumeWithCell:(STMVolumeTVCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSIndexPath *controlsIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
    
    STMVolumeControlsTVCell *controlCell = (STMVolumeControlsTVCell *)[self.tableView cellForRowAtIndexPath:controlsIndexPath];
    
    if (controlCell) {
        controlCell.volume = cell.volume;
    }

}

- (void)volumeChangedInCell:(STMVolumeTVCell *)cell {
    
    if ([self.volumeValues[@(cell.volumeType)] integerValue] != cell.volume) {
        
        self.volumeValues[@(cell.volumeType)] = @(cell.volume);
        
        if (![cell isEqual:self.doneVolumeCell]) {
            
            NSInteger notDoneVolume = self.badVolumeCell.volume + self.excessVolumeCell.volume + self.shortageVolumeCell.volume + self.regradeVolumeCell.volume + self.brokenVolumeCell.volume;
            NSInteger doneVolume = self.position.volume.integerValue - notDoneVolume;
            
            self.doneVolumeCell.volume = (doneVolume > 0) ? doneVolume : 0;
            
        }

    }
    
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
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom2TVCell" bundle:nil] forCellReuseIdentifier:self.positionTitleCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"STMVolumeTVCell" bundle:nil] forCellReuseIdentifier:self.positionVolumeCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"STMVolumeTVCell" bundle:nil] forCellReuseIdentifier:self.volumeCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"STMVolumeControlsTVCell" bundle:nil] forCellReuseIdentifier:self.controlsCellIdentifier];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.navigationController.navigationBarHidden = YES;

    [self setupToolbar];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = NO;
    
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
