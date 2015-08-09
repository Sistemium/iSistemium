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


@interface STMShippingVC () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

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
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[processedDescriptor, nameDescriptor];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shipment == %@", self.shipment];
        
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
    
    UIFont *font = [UIFont systemFontOfSize:17];
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                 NSFontAttributeName            : font};
    
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
            
            attributes = @{NSForegroundColorAttributeName : [UIColor redColor],
                           NSFontAttributeName            : font};
            
            attributedText = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"UNKNOWN ARTICLE", nil) attributes:attributes];
            
        }
        
    }
    
    cell.titleLabel.attributedText = attributedText;
    
    if (position.isProcessed.boolValue) {
        
        NSString *volumesString = [self.shippingProcessController volumesStringWithDoneVolume:position.doneVolume.integerValue
                                                                                    badVolume:position.badVolume.integerValue
                                                                                 excessVolume:position.excessVolume.integerValue
                                                                               shortageVolume:position.shortageVolume.integerValue
                                                                                regradeVolume:position.regradeVolume.integerValue
                                                                                   packageRel:position.article.packageRel.integerValue];
        
        cell.detailLabel.text = [@"\n" stringByAppendingString:volumesString];
        
    } else {
        
        cell.detailLabel.text = @"";
        
    }
    
    STMLabel *infoLabel = [[STMLabel alloc] initWithFrame:CGRectMake(0, 0, 40, 21)];
    infoLabel.text = [position volumeText];
    infoLabel.textAlignment = NSTextAlignmentRight;
    infoLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.accessoryView = infoLabel;
    
    UIColor *textColor = (position.isProcessed.boolValue) ? [UIColor lightGrayColor] : attributes[NSForegroundColorAttributeName];
    
    cell.titleLabel.textColor = textColor;
    cell.detailLabel.textColor = textColor;
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
        
        }
    
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
    
    if (indexPath.section == 0) {
        
        NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] objectID];
        self.cachedCellsHeights[objectID] = @(height);
        
    } else {
        
        self.cachedCellsHeights[indexPath] = @(height);
        
    }
    
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] objectID];;
        return self.cachedCellsHeights[objectID];
        
    } else {
        
        return self.cachedCellsHeights[indexPath];
        
    }
    
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



/*
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
*/


#pragma mark - view lifecycle

- (void)customInit {
    
//    self.navigationItem.titleView = [self titleView];
    self.navigationItem.title = self.shipment.ndoc;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom7TVCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self performFetch];
    
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
