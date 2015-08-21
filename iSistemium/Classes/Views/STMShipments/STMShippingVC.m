//
//  STMShippingVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/08/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShippingVC.h"

#import "STMUI.h"

#import "STMShippingProcessController.h"

#import "STMPositionVolumesVC.h"
#import "STMShippingSettingsTVC.h"

typedef NS_ENUM(NSUInteger, STMPositionProcessingType) {
    STMPositionProcessingTypeDone = 0,
    STMPositionProcessingTypeBad = 1,
    STMPositionProcessingTypeExcess = 2,
    STMPositionProcessingTypeShortage = 3,
    STMPositionProcessingTypeRegrade = 4
};


@interface STMShippingVC ()    <UITableViewDataSource,
                                UITableViewDelegate,
                                NSFetchedResultsControllerDelegate,
                                UISearchBarDelegate,
                                UIActionSheetDelegate,
                                UIAlertViewDelegate>


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *checkButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *processingButton;

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) STMShippingProcessController *shippingProcessController;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) STMDocument *document;
@property (nonatomic) CGFloat standardCellHeight;
@property (nonatomic, strong) NSMutableDictionary *cachedCellsHeights;

@property (nonatomic, strong) STMShipmentPosition *selectedPosition;

@property (nonatomic, strong) NSMutableIndexSet *deletedSectionIndexes;
@property (nonatomic, strong) NSMutableIndexSet *insertedSectionIndexes;

@property (nonatomic, strong) NSMutableArray *checkedPositions;
@property (nonatomic) BOOL isBunchProcessing;
@property (nonatomic) STMPositionProcessingType currentProcessingType;


@end


@implementation STMShippingVC

- (NSString *)cellIdentifier {
    return @"shippmentPositionCell";
}

- (STMShippingProcessController *)shippingProcessController {
    return [STMShippingProcessController sharedInstance];
}

- (STMDocument *)document {
    
    if (!_document) {
        _document = (STMDocument *)[STMSessionManager sharedManager].currentSession.document;
    }
    return _document;
    
}

- (NSMutableArray *)checkedPositions {
    
    if (!_checkedPositions) {
        _checkedPositions = [NSMutableArray array];
    }
    return _checkedPositions;
    
}

- (void)setSortOrder:(STMShipmentPositionSort)sortOrder {
    
    _sortOrder = sortOrder;
    self.parentVC.sortOrder = sortOrder;
    
    [self setupSortSettingsButton];
    
}

- (NSMutableDictionary *)cachedCellsHeights {
    
    if (!_cachedCellsHeights) {
        
        NSMutableDictionary *cachedCellsHeights = [NSMutableDictionary dictionary];
        
        for (id key in self.cachedHeights.allKeys) {
            if ([key isKindOfClass:[NSManagedObjectID class]]) cachedCellsHeights[key] = self.cachedHeights[key];
        }
        
        _cachedCellsHeights = cachedCellsHeights;
        
    }
    return _cachedCellsHeights;
    
}

- (NSMutableIndexSet *)deletedSectionIndexes {
    
    if (!_deletedSectionIndexes) {
        _deletedSectionIndexes = [NSMutableIndexSet indexSet];
    }
    
    return _deletedSectionIndexes;
    
}

- (NSMutableIndexSet *)insertedSectionIndexes {
    
    if (!_insertedSectionIndexes) {
        _insertedSectionIndexes = [NSMutableIndexSet indexSet];
    }
    
    return _insertedSectionIndexes;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMShipmentPosition class])];
        
        NSSortDescriptor *processedDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"isProcessed.boolValue" ascending:YES selector:@selector(compare:)];

        NSSortDescriptor *sortOrderDescriptor = [self.parentVC currentSortDescriptor];
        
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name"
                                                                         ascending:sortOrderDescriptor.ascending
                                                                          selector:@selector(caseInsensitiveCompare:)];

        request.sortDescriptors = @[processedDescriptor, sortOrderDescriptor, nameDescriptor];
        
        NSMutableArray *subpredicates = [NSMutableArray array];
        
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"shipment == %@", self.shipment]];
        
        if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
            
            [subpredicates addObject:[NSPredicate predicateWithFormat:@"article.name CONTAINS[cd] %@", self.searchBar.text]];
            
        }

        NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
        
        request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:predicate];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"wasProcessed" cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (void)performFetch {
    
    self.resultsController.delegate = nil;
    self.resultsController = nil;
    
    NSError *error;
    
    if (![self.resultsController performFetch:&error]) {
        
        NSLog(@"shipmentRoutePoints fetch error %@", error.localizedDescription);
        
    } else {
        
        [self.tableView reloadData];
        [self updateToolbarButtons];
        
    }
    
}

- (BOOL)haveProcessedPositions {
    return [self.shippingProcessController haveProcessedPositionsAtShipment:self.shipment];
}

- (BOOL)haveUnprocessedPositions {
    return [self.shippingProcessController haveUnprocessedPositionsAtShipment:self.shipment];
}

- (BOOL)shippingProcessIsRunning {
    return [self.shippingProcessController shippingProcessIsRunningWithShipment:self.shipment];
}

- (NSUInteger)unprocessedPositionsCount {
    return [self.shippingProcessController unprocessedPositionsCountForShipment:self.shipment];
}

- (NSSet *)unprocessedPositions {
    return [self.shippingProcessController unprocessedPositionsForShipment:self.shipment];
}

- (NSArray *)currentUnprocessedPositions {

    if ([self haveUnprocessedPositions]) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isProcessed == NO OR isProcessed == %@", nil];
        NSArray *currentUnprocessedPositions = [self.resultsController.fetchedObjects filteredArrayUsingPredicate:predicate];
        
        return currentUnprocessedPositions;

    } else {
        return nil;
    }
    
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


#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
//    return ([self haveProcessedPositions] && [self haveUnprocessedPositions]) ? 2 : 1;
    return self.resultsController.sections.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self numberOfRowsInResultsControllerSection:section];
}

- (NSInteger)numberOfRowsInResultsControllerSection:(NSInteger)section {
    
    if (section < self.resultsController.sections.count) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[section];
        return [sectionInfo numberOfObjects];
        
    } else {
        return 0;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return ([self currentUnprocessedPositions].count > 0) ? NSLocalizedString(@"SHIPMENT POSITIONS", nil) : NSLocalizedString(@"PROCESSED SHIPMENT POSITIONS", nil);
            break;
            
        case 1:
            return NSLocalizedString(@"PROCESSED SHIPMENT POSITIONS", nil);
            break;
            
        default:
            return nil;
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self heightForCellAtIndexPath:indexPath];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *cachedHeight = [self getCachedHeightForIndexPath:indexPath];
    CGFloat height = (cachedHeight) ? cachedHeight.floatValue : [self heightForCellAtIndexPath:indexPath];
    
    return height;
    
}

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *cachedHeight = [self getCachedHeightForIndexPath:indexPath];
    
    if (cachedHeight) {
        
        return cachedHeight.floatValue;
        
    } else {
        
        static UITableViewCell *cell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
        });
        
        [self fillCell:cell atIndexPath:indexPath];
        
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds) - MAGIC_NUMBER_FOR_CELL_WIDTH, CGRectGetHeight(cell.bounds));
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        CGFloat height = size.height + 1.0f; // Add 1.0f for the cell separator height
        
        height = (height < self.standardCellHeight) ? self.standardCellHeight : height;
        
        [self putCachedHeight:height forIndexPath:indexPath];
        
        return height;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom8TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self flushCellBeforeUse:(STMCustom8TVCell *)cell];
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)flushCellBeforeUse:(STMCustom8TVCell *)cell {
    
    cell.accessoryView = nil;
    
    cell.titleLabel.font = [UIFont systemFontOfSize:cell.textLabel.font.pointSize];
    cell.titleLabel.text = @"";
    cell.titleLabel.textColor = [UIColor blackColor];
    cell.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    cell.detailLabel.text = @"";
    cell.detailLabel.textColor = [UIColor blackColor];
    cell.detailLabel.textAlignment = NSTextAlignmentLeft;
    
    [self removeSwipeGesturesFromCell:cell];
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell conformsToProtocol:@protocol(STMTDICell)]) {
        [self fillShipmentPositionCell:(UITableViewCell <STMTDICell> *)cell atIndexPath:indexPath];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
}

- (void)fillShipmentPositionCell:(UITableViewCell <STMTDICell> *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMShipmentPosition *position = [self.resultsController objectAtIndexPath:indexPath];
    [self fillCell:cell withShipmentPosition:position];
    
    if ([self shippingProcessIsRunning]) {
        [self addSwipeGestureToCell:cell withPosition:position];
    }
    
}

- (void)fillCell:(UITableViewCell <STMTDICell> *)cell withShipmentPosition:(STMShipmentPosition *)position {
    
    [self.parentVC fillCell:cell withShipmentPosition:position];
    
    if ([cell isKindOfClass:[STMCustom9TVCell class]]) {
        
        STMCustom9TVCell *customCell = (STMCustom9TVCell *)cell;

        [[customCell.checkboxView viewWithTag:444] removeFromSuperview];

        if ([self.checkedPositions containsObject:position]) {
        
            STMLabel *checkLabel = [[STMLabel alloc] initWithFrame:customCell.checkboxView.bounds];
            checkLabel.text = @"✓";
            checkLabel.textColor = ACTIVE_BLUE_COLOR;
            checkLabel.textAlignment = NSTextAlignmentLeft;
            checkLabel.tag = 444;
            
            [customCell.checkboxView addSubview:checkLabel];

            cell.titleLabel.textColor = [UIColor lightGrayColor];

            if ([cell.accessoryView isKindOfClass:[STMLabel class]]) {
                
                STMLabel *infoLabel = (STMLabel *)cell.accessoryView;
                infoLabel.textColor = [UIColor lightGrayColor];
            }
            
        } else {
            
        }

    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMShipmentPosition *position = [self.resultsController objectAtIndexPath:indexPath];

    if (!position.isProcessed.boolValue) {
        
        ([self.checkedPositions containsObject:position]) ? [self.checkedPositions removeObject:position] : [self.checkedPositions addObject:position];
        
//        [self.cachedCellsHeights removeObjectForKey:position.objectID];
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self hideKeyboard];
        [self updateToolbarButtons];
        
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self shippingProcessIsRunning];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"SHIPPING", nil);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.selectedPosition = [self.resultsController objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"showPositionVolumes" sender:self];
        
    }
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showPositionVolumes"] &&
        [segue.destinationViewController isKindOfClass:[STMPositionVolumesVC class]]) {
        
            [(STMPositionVolumesVC *)segue.destinationViewController setPosition:self.selectedPosition];
        
    } else if ([segue.identifier isEqualToString:@"showSettings"] &&
               [segue.destinationViewController isKindOfClass:[STMShippingSettingsTVC class]]) {
        
        STMShippingSettingsTVC *settingTVC = (STMShippingSettingsTVC *)segue.destinationViewController;
        
        settingTVC.parentVC = self;
    
    }
    
}


#pragma mark - search & UISearchBarDelegate

- (void)searchButtonPressed {
    
    [self.searchBar becomeFirstResponder];
    [self.tableView setContentOffset:CGPointZero animated:YES];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self performSelector:@selector(performFetch) withObject:nil afterDelay:0];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = YES;
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = NO;
    searchBar.text = nil;
    
    [self hideKeyboard];
    [self performSelector:@selector(performFetch) withObject:nil afterDelay:0];
    
}

- (void)hideKeyboard {
    
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hideKeyboard];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self hideKeyboard];
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if (![self shippingProcessIsRunning]) {
        
        self.cachedCellsHeights = nil;
        [self.tableView reloadData];
        
    } else {
        [self updateToolbarButtons];
    }
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {
            
        case NSFetchedResultsChangeInsert:
            [self.insertedSectionIndexes addIndex:sectionIndex];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.deletedSectionIndexes addIndex:sectionIndex];
            break;
            
        default:
            ; // Shouldn't have a default
            break;
            
    }
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if ([self shippingProcessIsRunning]) {

        if ([anObject isKindOfClass:[STMShipmentPosition class]]) {
            [self.cachedCellsHeights removeObjectForKey:[(STMShipmentPosition *)anObject objectID]];
        }
        
        switch (type) {
                
            case NSFetchedResultsChangeMove: {

                [self moveObject:anObject atIndexPath:indexPath toIndexPath:newIndexPath];
                [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
                
            default: {
                [self.tableView reloadData];
                break;
            }
                
        }
        
    }
    
}

- (void)moveObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    
    if ([anObject isKindOfClass:[STMShipmentPosition class]]) {
        
        UITableViewRowAnimation rowAnimation = UITableViewRowAnimationRight;
                
        [self.tableView beginUpdates];
        
        [self.tableView deleteSections:self.deletedSectionIndexes withRowAnimation:rowAnimation];
        [self.tableView insertSections:self.insertedSectionIndexes withRowAnimation:rowAnimation];
        
        self.insertedSectionIndexes = nil;
        self.deletedSectionIndexes = nil;
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
        [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:rowAnimation];
        
        [self.tableView endUpdates];

        [self.checkedPositions removeObject:anObject];
        
        if (self.isBunchProcessing) {
            [self bunchShippingProcessing];
        }
        
    } else {
        [self.tableView reloadData];
    }
    
}


#pragma mark - height's cache

- (void)putCachedHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:indexPath] objectID];
    self.cachedCellsHeights[objectID] = @(height);
    
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:indexPath] objectID];;
    return self.cachedCellsHeights[objectID];
    
}


#pragma mark - cell's swipe

- (void)addSwipeGestureToCell:(UITableViewCell *)cell withPosition:(STMShipmentPosition *)position {
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToRight:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    if (swipe) [cell addGestureRecognizer:swipe];
    
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
        
        UITableViewCell *cell = (UITableViewCell *)[(UISwipeGestureRecognizer *)sender view];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        STMShipmentPosition *position = [self.resultsController objectAtIndexPath:indexPath];
        
        if (position.isProcessed.boolValue) {
            
            [self.shippingProcessController resetPosition:position];
            
        } else {
            
            if ([self.checkedPositions containsObject:position]) {
                
                self.isBunchProcessing = YES;
                self.currentProcessingType = STMPositionProcessingTypeDone;
                [self bunchShippingProcessing];
                
            } else {
            
                [self.shippingProcessController shippingPosition:position withDoneVolume:position.volume.integerValue];

            }
            
        }
        
    }
    
}

- (void)bunchShippingProcessing {
    
    STMShipmentPosition *position = self.checkedPositions.firstObject;
    
    if (position) {
        
        [self.checkedPositions removeObject:position];
        
        switch (self.currentProcessingType) {
            case STMPositionProcessingTypeDone: {
                [self.shippingProcessController shippingPosition:position withDoneVolume:position.volume.integerValue];
                break;
            }
            case STMPositionProcessingTypeBad: {
                [self.shippingProcessController shippingPosition:position withBadVolume:position.volume.integerValue];
                break;
            }
            case STMPositionProcessingTypeExcess: {
                [self.shippingProcessController shippingPosition:position withExcessVolume:position.volume.integerValue];
                break;
            }
            case STMPositionProcessingTypeShortage: {
                [self.shippingProcessController shippingPosition:position withShortageVolume:position.volume.integerValue];
                break;
            }
            case STMPositionProcessingTypeRegrade: {
                [self.shippingProcessController shippingPosition:position withRegradeVolume:position.volume.integerValue];
                break;
            }
            default: {
                break;
            }
        }
        
        if (![self.resultsController.fetchedObjects containsObject:position]) {
            [self bunchShippingProcessing];
        }
        
    } else {
        
        self.isBunchProcessing = NO;
        [self updateToolbarButtons];
        
    }
    
}

#pragma mark - navigation bar

- (void)setupNavBar {
    
//    self.navigationItem.title = self.shipment.ndoc;
    [self setupTitleView];
    [self setupSortSettingsButton];

}

- (void)setupTitleView {
    
    UIButton *titleLabelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    titleLabelButton.titleLabel.font = [UIFont boldSystemFontOfSize:titleLabelButton.titleLabel.font.pointSize];
    [titleLabelButton setTitle:self.shipment.ndoc forState:UIControlStateNormal];
    [titleLabelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [titleLabelButton addTarget:self action:@selector(titleViewTapped:) forControlEvents:UIControlEventTouchUpInside];

    self.navigationItem.titleView = titleLabelButton;

}

- (void)titleViewTapped:(id)sender {
    
    NSIndexPath *indexPath = nil;
    
    if (self.resultsController.sections.count > 1) {
        
        indexPath = [NSIndexPath indexPathForRow:NSNotFound inSection:1];
        
    } else if ([self currentUnprocessedPositions].count == 0) {
        
        indexPath = [NSIndexPath indexPathForRow:NSNotFound inSection:0];
        
    }
    
    if (indexPath) {
        
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];

    }
    
}


#pragma mark - sort settings button

- (void)setupSortSettingsButton {
    
    NSString *imageName;
    
    switch (self.sortOrder) {
        case STMShipmentPositionSortOrdAsc:
            imageName = @"numerical_sorting_12.png";
            break;
            
        case STMShipmentPositionSortOrdDesc:
            imageName = @"numerical_sorting_21.png";
            break;

        case STMShipmentPositionSortNameAsc:
            imageName = @"alphabetical_sorting.png";
            break;
            
        case STMShipmentPositionSortNameDesc:
            imageName = @"alphabetical_sorting_2.png";
            break;

        case STMShipmentPositionSortTsAsc:
            imageName = @"future.png";
            break;

        case STMShipmentPositionSortTsDesc:
            imageName = @"past.png";
            break;

        default:
            break;
    }
    
    UIImage *image = [UIImage imageNamed:imageName];
    image = [STMFunctions resizeImage:image toSize:CGSizeMake(25, 25)];
    
    STMBarButtonItem *settingButton = [[STMBarButtonItem alloc] initWithImage:image
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(settingsButtonPressed)];
    self.navigationItem.rightBarButtonItem = settingButton;

}

- (void)settingsButtonPressed {
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}


#pragma mark - toolbar setup

- (void)setupToolbarButtons {
    
    [self updateToolbarButtons];
    
}

- (void)updateToolbarButtons {

    NSString *processingButtonTitle = nil;
    
    if (self.checkedPositions.count > 0) {
        
        processingButtonTitle = NSLocalizedString(@"PROCESSING BUTTON TITLE", nil);
        
        processingButtonTitle = [processingButtonTitle stringByAppendingString:[NSString stringWithFormat:@" %lu%@", (unsigned long)self.checkedPositions.count, NSLocalizedString(@"_POSITIONS", nil)]];

        NSNumber *bottlesCount = [self.checkedPositions valueForKeyPath:@"@sum.volume"];

        processingButtonTitle = [processingButtonTitle stringByAppendingString:[NSString stringWithFormat:@"/%@%@", bottlesCount, NSLocalizedString(@"_BOTTLES", nil)]];

        self.processingButton.enabled = YES;

    } else {
        
        self.processingButton.enabled = NO;
        
    }
    
    self.processingButton.title = processingButtonTitle;
    
    NSString *checkmarkImageName = ([self hasVisibileCheckedPositions]) ? @"uncheckmark" : @"checkmark_filled";
    self.checkButton.image = [STMFunctions resizeImage:[UIImage imageNamed:checkmarkImageName] toSize:CGSizeMake(25, 25)];
    
}

- (IBAction)checkmarkPressed:(id)sender {

    if ([self hasVisibileCheckedPositions]) {
        
        if ([self isAllCurrentUnprocessedPositionsChecked]) {
            [self uncheckAllCurrentUnprocessedPositions];
        } else {
            [self showUncheckAlert];
        }

    } else {
        [self checkAllCurrentUnprocessedPositions];
    }
    
}

- (BOOL)hasVisibileCheckedPositions {

    if (self.checkedPositions > 0) {
    
        NSMutableSet *unprocessedPositions = [NSMutableSet setWithArray:[self currentUnprocessedPositions]];
        NSSet *checkedPositions = [NSSet setWithArray:self.checkedPositions];
        return [unprocessedPositions intersectsSet:checkedPositions];
        
    } else {
        return NO;
    }
    
}

- (BOOL)isAllCurrentUnprocessedPositionsChecked {
    
    NSMutableArray *positions = [self currentUnprocessedPositions].mutableCopy;
    [positions removeObjectsInArray:self.checkedPositions];
    
    return (positions.count == 0);
    
}

- (void)uncheckAllCurrentUnprocessedPositions {

    for (STMShipmentPosition *position in [self currentUnprocessedPositions]) {
        
        [self.checkedPositions removeObject:position];
        [self.cachedCellsHeights removeObjectForKey:position.objectID];
        
    }
    [self reloadUnprocessedSection];

}

- (void)checkAllCurrentUnprocessedPositions {

    for (STMShipmentPosition *position in [self currentUnprocessedPositions]) {
        
        if (![self.checkedPositions containsObject:position]) [self.checkedPositions addObject:position];
        [self.cachedCellsHeights removeObjectForKey:position.objectID];
        
    }
    [self reloadUnprocessedSection];

}

- (IBAction)processingButtonPressed:(id)sender {
    [self showProcessingActionSheet];
}

- (void)reloadUnprocessedSection {
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self updateToolbarButtons];

}


#pragma mark - UIAlertView

- (void)showUncheckAlert {

    NSString *message = [NSString stringWithFormat:@"%@?", NSLocalizedString(@"UNCHECK ALL POSITION", nil)];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                          otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    alert.tag = 111;
    [alert show];
    
}

- (void)showCheckAllAlert {

    NSString *message = [NSString stringWithFormat:@"%@?", NSLocalizedString(@"CHECK ALL POSITION", nil)];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                          otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    alert.tag = 222;
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case 111: {
            if (buttonIndex == 1) [self uncheckAllCurrentUnprocessedPositions];
            break;
        }
        case 222: {
            if (buttonIndex == 1) [self checkAllCurrentUnprocessedPositions];
            break;
        }
        default: {
            break;
        }
    }
    
}


#pragma mark - UIActionSheet

- (void)showProcessingActionSheet {
    
    NSNumber *count = @(self.checkedPositions.count);
    NSString *pluralType = [STMFunctions pluralTypeForCount:count.integerValue];
    NSString *countString = [NSString stringWithFormat:@"%@POSITIONS", pluralType];
    
    NSString *title = [NSString stringWithFormat:@"%@ %@,", count, NSLocalizedString(countString, nil)];
    
    count = [self.checkedPositions valueForKeyPath:@"@sum.volume"];
    pluralType = [STMFunctions pluralTypeForCount:count.integerValue];
    countString = [NSString stringWithFormat:@"%@BOTTLES", pluralType];
    
    title = [title stringByAppendingString:@"\n"];
    title = [title stringByAppendingString:[NSString stringWithFormat:@"%@ %@", count, NSLocalizedString(countString, nil)]];
    title = [title stringByAppendingString:@"\n"];
    title = [title stringByAppendingString:NSLocalizedString(@"PROCESSING ACTION SHEET TITLE", nil)];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:nil];

    [actionSheet addButtonWithTitle:NSLocalizedString(@"DONE VOLUME LABEL", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"BAD VOLUME LABEL", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EXCESS VOLUME LABEL", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SHORTAGE VOLUME LABEL", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"REGRADE VOLUME LABEL", nil)];
    
    [actionSheet showFromBarButtonItem:self.processingButton animated:YES];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex > 0) {
        
        self.isBunchProcessing = YES;
        self.currentProcessingType = (STMPositionProcessingType)(buttonIndex - 1);
        [self bunchShippingProcessing];

    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self setupNavBar];
    [self setupToolbarButtons];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom9TVCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.searchBar.delegate = self;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillAppear:(BOOL)animated {
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }

    [self performSelector:@selector(performFetch) withObject:nil afterDelay:0];
    
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }

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
