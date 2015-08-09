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


@interface STMShippingVC () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) STMShippingProcessController *shippingProcessController;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) STMDocument *document;
@property (nonatomic) CGFloat standardCellHeight;
@property (nonatomic, strong) NSMutableDictionary *cachedCellsHeights;

@property (nonatomic, strong) STMShipmentPosition *selectedPosition;

@property (nonatomic, strong) NSMutableIndexSet *deletedSectionIndexes;
@property (nonatomic, strong) NSMutableIndexSet *insertedSectionIndexes;

//@property (nonatomic) BOOL searchFieldIsScrolledAway;


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

- (void)setSortOrder:(STMShipmentPositionSort)sortOrder {
    
    _sortOrder = sortOrder;
    self.parentVC.sortOrder = sortOrder;
    
    [self setupSortSettingsButton];
    
}

- (NSMutableDictionary *)cachedCellsHeights {
    
    if (!_cachedCellsHeights) {
        _cachedCellsHeights = [NSMutableDictionary dictionary];
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
//        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[processedDescriptor, [self.parentVC sortDescriptorForSortOrder:self.sortOrder]];
        
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
    
    self.resultsController = nil;
    
    NSError *error;
    
    if (![self.resultsController performFetch:&error]) {
        NSLog(@"shipmentRoutePoints fetch error %@", error.localizedDescription);
    } else {
        [self.tableView reloadData];
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
    return ([self haveProcessedPositions] && [self haveUnprocessedPositions]) ? 2 : 1;
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
            return ([self haveUnprocessedPositions]) ? NSLocalizedString(@"SHIPMENT POSITIONS", nil) : NSLocalizedString(@"PROCESSED SHIPMENT POSITIONS", nil);
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
    
    STMCustom7TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self flushCellBeforeUse:(STMCustom7TVCell *)cell];
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)flushCellBeforeUse:(STMCustom7TVCell *)cell {
    
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
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        [self fillShipmentPositionCell:(STMCustom7TVCell *)cell atIndexPath:indexPath];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
}

- (void)fillShipmentPositionCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMShipmentPosition *position = [self.resultsController objectAtIndexPath:indexPath];
    [self fillCell:cell withShipmentPosition:position];
    
    if ([self shippingProcessIsRunning]) {
        [self addSwipeGestureToCell:cell withPosition:position];
    }
    
}

- (void)fillCell:(STMCustom7TVCell *)cell withShipmentPosition:(STMShipmentPosition *)position {
    
    UIColor *textColor = (position.isProcessed.boolValue) ? [UIColor lightGrayColor] : [UIColor blackColor];
    UIFont *font = [UIFont systemFontOfSize:17];

    NSMutableDictionary *attributes = @{NSForegroundColorAttributeName : textColor,
                                        NSFontAttributeName            : font}.mutableCopy;
    
    NSMutableAttributedString *attributedText = nil;
    
    if (position.articleFact) {
        
        attributedText = [[NSMutableAttributedString alloc] initWithString:[position.articleFact.name stringByAppendingString:@"\n"] attributes:attributes];
        
        font = [UIFont systemFontOfSize:font.pointSize - 4];
        
        NSDictionary *attributes = @{NSForegroundColorAttributeName     : [UIColor blackColor],
                                     NSStrikethroughStyleAttributeName  : @(NSUnderlinePatternSolid | NSUnderlineStyleSingle),
                                     NSFontAttributeName                : font};
        
        NSAttributedString *appendString = [[NSAttributedString alloc] initWithString:position.article.name attributes:attributes];
        
        [attributedText appendAttributedString:appendString];
        
    } else {
        
        if (position.article.name) {
            
            attributedText = [[NSMutableAttributedString alloc] initWithString:position.article.name attributes:attributes];
            
        } else {
            
            attributes[NSForegroundColorAttributeName] = [UIColor redColor];
            
            attributedText = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"UNKNOWN ARTICLE", nil) attributes:attributes];
            
        }
        
    }
    
    cell.titleLabel.attributedText = attributedText;
    
    attributes[NSFontAttributeName] = cell.detailLabel.font;
    
    if (position.isProcessed.boolValue) {
        
//        NSString *volumesString = [self.shippingProcessController volumesStringWithDoneVolume:position.doneVolume.integerValue
//                                                                                    badVolume:position.badVolume.integerValue
//                                                                                 excessVolume:position.excessVolume.integerValue
//                                                                               shortageVolume:position.shortageVolume.integerValue
//                                                                                regradeVolume:position.regradeVolume.integerValue
//                                                                                   packageRel:position.article.packageRel.integerValue];
//        
//        cell.detailLabel.text = [@"\n" stringByAppendingString:volumesString];
        
        NSAttributedString *volumes = [self.shippingProcessController volumesAttributedStringWithAttributes:attributes
                                                                                                 doneVolume:position.doneVolume.integerValue
                                                                                                  badVolume:position.badVolume.integerValue
                                                                                               excessVolume:position.excessVolume.integerValue
                                                                                             shortageVolume:position.shortageVolume.integerValue
                                                                                              regradeVolume:position.regradeVolume.integerValue
                                                                                                 packageRel:position.article.packageRel.integerValue];
        cell.detailLabel.attributedText = volumes;
        
    } else {
        
//        cell.detailLabel.text = @"";
        cell.detailLabel.attributedText = nil;
        
    }
    
    STMLabel *infoLabel = [[STMLabel alloc] initWithFrame:CGRectMake(0, 0, 40, 21)];
    infoLabel.text = [position volumeText];
    infoLabel.textAlignment = NSTextAlignmentRight;
    infoLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.accessoryView = infoLabel;
    
//    UIColor *textColor = (position.isProcessed.boolValue) ? [UIColor lightGrayColor] : attributes[NSForegroundColorAttributeName];
    
//    cell.titleLabel.textColor = textColor;
//    cell.detailLabel.textColor = textColor;
    infoLabel.textColor = textColor;
    
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
    
//    [self hideSearchButton];
//    
//}
//
//- (void)showSearchButton {
//    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonPressed)];
//}
//
//- (void)hideSearchButton {
//    self.navigationItem.rightBarButtonItem = nil;
//}
//
//- (void)setSearchFieldIsScrolledAway:(BOOL)searchFieldIsScrolledAway {
//    
//    if (_searchFieldIsScrolledAway != searchFieldIsScrolledAway) {
//        
//        _searchFieldIsScrolledAway = searchFieldIsScrolledAway;
//        
//        if (_searchFieldIsScrolledAway) {
//            [self showSearchButton];
//        } else {
//            [self hideSearchButton];
//        }
//        
//    }
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self performFetch];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = YES;
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = NO;
    searchBar.text = nil;
    
    [self hideKeyboard];
    [self performFetch];
    
//    if (self.searchFieldIsScrolledAway) {
//        [self showSearchButton];
//    }
    
}


- (void)hideKeyboard {
    
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
//    self.searchFieldIsScrolledAway = (scrollView.contentOffset.y > self.searchBar.frame.size.height);
//    
//}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self hideKeyboard];
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    if (![self shippingProcessIsRunning]) {
        
        self.cachedCellsHeights = nil;
        [self.tableView reloadData];
        
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
        
        self.cachedCellsHeights = nil;
        
        switch (type) {
                
            case NSFetchedResultsChangeMove: {
                //                NSLog(@"NSFetchedResultsChangeMove");
                [self moveObject:anObject atIndexPath:indexPath toIndexPath:newIndexPath];
                break;
            }
                
            default: {
                [self.tableView reloadData];
                break;
            }
                
        }
        
    }
    
}

- (void)moveObject:(id)anObject atIndexPath:indexPath toIndexPath:newIndexPath {
    
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
            [self.shippingProcessController shippingPosition:position withDoneVolume:position.volume.integerValue];
        }
        
    }
    
}


#pragma mark - sort settings button

- (void)setupSortSettingsButton {
    
    NSString *imageName;
    
    switch (self.sortOrder) {
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
    
    STMBarButtonItem *settingButton = [[STMBarButtonItem alloc] initWithImage:[UIImage imageNamed:imageName]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(settingsButtonPressed)];
    self.navigationItem.rightBarButtonItem = settingButton;

}

- (void)settingsButtonPressed {
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationItem.title = self.shipment.ndoc;
    
    [self setupSortSettingsButton];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom7TVCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.searchBar.delegate = self;
    
//    [self performFetch];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [self performFetch];
    [super viewWillAppear:animated];
    
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
