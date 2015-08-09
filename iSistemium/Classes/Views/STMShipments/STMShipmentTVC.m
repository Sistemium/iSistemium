//
//  STMShipmentPositionsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentTVC.h"
#import "STMNS.h"
#import "STMUI.h"
#import "STMFunctions.h"
#import "STMShippingProcessController.h"

#import "STMPositionVolumesVC.h"
#import "STMShippingVC.h"


#define POSITION_SECTION_INDEX 2


@interface STMShipmentTVC () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSIndexPath *shippingButtonCellIndexPath;
@property (nonatomic, strong) NSIndexPath *finishShippingButtonCellIndexPath;
@property (nonatomic, strong) NSIndexPath *cancelButtonCellIndexPath;

@property (nonatomic, strong) STMShipmentPosition *selectedPosition;

@property (nonatomic, strong) STMShippingProcessController *shippingProcessController;


@end


@implementation STMShipmentTVC

@synthesize resultsController = _resultsController;
@synthesize sortOrder = _sortOrder;


- (STMShippingProcessController *)shippingProcessController {
    return [STMShippingProcessController sharedInstance];
}

- (NSString *)cellIdentifier {
    return @"shipmentPositionCell";
}

- (STMShipmentPositionSort)sortOrder {
    
    if (!_sortOrder) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *sortOrder = [defaults valueForKey:@"STMShipmentPositionSort"];
        
        if (sortOrder) {
            
            _sortOrder = (STMShipmentPositionSort)sortOrder.integerValue;
            
        } else {
            
            _sortOrder = STMShipmentPositionSortNameAsc;
            [defaults setValue:@(_sortOrder) forKey:@"STMShipmentPositionSort"];
            [defaults synchronize];
            
        }
        
    }
    return _sortOrder;
    
}

- (void)setSortOrder:(STMShipmentPositionSort)sortOrder {
    
    _sortOrder = sortOrder;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@(_sortOrder) forKey:@"STMShipmentPositionSort"];
    [defaults synchronize];
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMShipmentPosition class])];
        
        NSSortDescriptor *processedDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"isProcessed.boolValue" ascending:YES selector:@selector(compare:)];
//        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[processedDescriptor, [self currentSortDescriptor]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shipment == %@", self.shipment];
        
        request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:predicate];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"wasProcessed" cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (NSSortDescriptor *)currentSortDescriptor {
    return [self sortDescriptorForSortOrder:self.sortOrder];
}

- (NSSortDescriptor *)sortDescriptorForSortOrder:(STMShipmentPositionSort)sortOrder {
    
    NSSortDescriptor *sortDescriptor;
    
    switch (sortOrder) {
        case STMShipmentPositionSortNameAsc:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            break;
            
        case STMShipmentPositionSortNameDesc:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:NO selector:@selector(caseInsensitiveCompare:)];
            break;
            
        case STMShipmentPositionSortTsAsc:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceTs" ascending:YES selector:@selector(compare:)];
            break;
            
        case STMShipmentPositionSortTsDesc:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceTs" ascending:NO selector:@selector(compare:)];
            break;
            
        default:
            break;
    }
    
    return sortDescriptor;

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

- (NSIndexPath *)resultsControllerIndexPathFromTableIndexPath:(NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section - POSITION_SECTION_INDEX];
}

- (NSIndexPath *)tableIndexPathFromResultsControllerIndexPath:(NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + POSITION_SECTION_INDEX];
}


#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ([self haveProcessedPositions] && [self haveUnprocessedPositions]) ? 4 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 3;
            break;
            
        case 1:
            return ([self shippingProcessIsRunning]) ? 3 : 1;
            break;
            
        case 2:
        case 3:
            return [self numberOfRowsInResultsControllerSection:section - POSITION_SECTION_INDEX];
            break;
            
        default:
            return 0;
            break;
    }
    
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
            return NSLocalizedString(@"SHIPMENT", nil);
            break;
            
        case 2:
            return ([self haveUnprocessedPositions]) ? NSLocalizedString(@"SHIPMENT POSITIONS", nil) : NSLocalizedString(@"PROCESSED SHIPMENT POSITIONS", nil);
            break;

        case 3:
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
        
        switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 0:
                        [self fillCell:(STMCustom7TVCell *)cell withRoute:self.point.shipmentRoute];
                        break;

                    case 1:
                        [self fillCell:(STMCustom7TVCell *)cell withRoutePoint:self.point];
                        break;

                    case 2:
                        [self fillCell:(STMCustom7TVCell *)cell withShipment:self.shipment];
                        break;

                    default:
                        break;
                }
                break;
                
            case 1:
                switch (indexPath.row) {
                    case 0:
                        [self fillShippingButtonCell:(STMCustom7TVCell *)cell atIndexPath:indexPath];
                        break;
                        
                    case 1:
                        [self fillFinishShippingButtonCell:(STMCustom7TVCell *)cell atIndexPath:indexPath];
                        break;
                        
                    case 2:
                        [self fillCancelButtonCell:(STMCustom7TVCell *)cell atIndexPath:indexPath];
                        break;
                        
                    default:
                        break;
                }
                break;
                
            case 2:
            case 3:
                [self fillShipmentPositionCell:(STMCustom7TVCell *)cell atIndexPath:indexPath];
                break;
                
            default:
                break;
        }
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillCell:(STMCustom7TVCell *)cell withRoute:(STMShipmentRoute *)route {
    
    cell.titleLabel.text = [STMFunctions dayWithDayOfWeekFromDate:route.date];
    cell.detailLabel.text = @"";
    
}

- (void)fillCell:(STMCustom7TVCell *)cell withRoutePoint:(STMShipmentRoutePoint *)point {
    
    cell.titleLabel.text = [STMFunctions shortCompanyName:point.name];
    cell.titleLabel.numberOfLines = 0;
    cell.detailLabel.text = @"";
    
}

- (void)fillCell:(STMCustom7TVCell *)cell withShipment:(STMShipment *)shipment {
    
    cell.titleLabel.text = shipment.ndoc;
    
    NSString *positions = [shipment positionsCountString];
    
    NSString *detailText;
    
    if (shipment.shipmentPositions.count > 0) {
        
        NSString *boxes = [shipment approximateBoxCountString];
        NSString *bottles = [shipment bottleCountString];
        
        detailText = [NSString stringWithFormat:@"%@, %@, %@", positions, boxes, bottles];
        
    } else {        
        detailText = NSLocalizedString(positions, nil);
    }
    
    cell.detailLabel.text = detailText;

//    if ([shipment.needCashing boolValue]) {
//        
//        cell.imageView.image = [STMFunctions resizeImage:[UIImage imageNamed:@"banknotes-128"] toSize:CGSizeMake(30, 30)];
//        
//    } else {
//        cell.imageView.image = nil;
//    }

}

- (void)fillShippingButtonCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.titleLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
    
    if ([self shippingProcessIsRunning]) {
        
        cell.titleLabel.text = NSLocalizedString(@"SHIPPING", nil);
        cell.titleLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else {
        
        if (self.shipment.isShipped.boolValue) {
            
            cell.titleLabel.text = NSLocalizedString(@"SHIPMENT PROCESSED BUTTON EDIT TITLE", nil);
            
        } else {
            
            if ([self haveProcessedPositions]) {
                cell.titleLabel.text = NSLocalizedString(@"SHIPMENT PROCESSED BUTTON CONTINUE TITLE", nil);
            } else {
                cell.titleLabel.text = NSLocalizedString(@"SHIPMENT PROCESSED BUTTON START TITLE", nil);
            }
            
        }

        cell.titleLabel.textColor = ACTIVE_BLUE_COLOR;
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.detailLabel.text = (self.point.isReached.boolValue) ? @"" : NSLocalizedString(@"SHOULD CONFIRM ARRIVAL FIRST", nil);
    
    cell.detailLabel.textColor = [UIColor lightGrayColor];
    cell.detailLabel.textAlignment = NSTextAlignmentCenter;

    self.shippingButtonCellIndexPath = indexPath;
    
}

- (void)fillFinishShippingButtonCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.titleLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
    
    if ([self shippingProcessIsRunning]) {
        
        cell.titleLabel.text = NSLocalizedString(@"SHIPMENT PROCESSED BUTTON STOP TITLE", nil);
        
    } else {
        
        cell.titleLabel.text = @"";
        
    }
    
    cell.titleLabel.textColor = ACTIVE_BLUE_COLOR;
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.detailLabel.textColor = [UIColor lightGrayColor];
    cell.detailLabel.textAlignment = NSTextAlignmentCenter;
    
    self.finishShippingButtonCellIndexPath = indexPath;
    
}

- (void)fillCancelButtonCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.titleLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
    
    cell.titleLabel.text = NSLocalizedString(@"SHIPMENT PROCESSED BUTTON CANCEL TITLE", nil);
    
    cell.titleLabel.textColor = [UIColor redColor];
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.detailLabel.text = @"";
    
    self.cancelButtonCellIndexPath = indexPath;

}

- (void)fillShipmentPositionCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMShipmentPosition *position = [self shipmentPositionForTableIndexPath:indexPath];
    [self fillCell:cell withShipmentPosition:position];
    
    if ([self shippingProcessIsRunning]) {
        [self addSwipeGestureToCell:cell withPosition:position];
    }
    
}

- (STMShipmentPosition *)shipmentPositionForTableIndexPath:(NSIndexPath *)indexPath {

    indexPath = [self resultsControllerIndexPathFromTableIndexPath:indexPath];
    
    STMShipmentPosition *position = [self.resultsController objectAtIndexPath:indexPath];

    return position;
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([indexPath isEqual:self.shippingButtonCellIndexPath]) {
        
        if (!self.point.isReached.boolValue) {
            
            [self.parentVC showArriveConfirmationAlert];
            
        } else {
            
            if ([self.shippingProcessController.shipments containsObject:self.shipment]) {
                [self performSegueWithIdentifier:@"showShipping" sender:self];
            } else {
                [self showStartShippingAlert];
            }
            
        }
        
    } else if ([indexPath isEqual:self.finishShippingButtonCellIndexPath]) {
        
        [self showDoneShippingAlert];
        
    } else if ([indexPath isEqual:self.cancelButtonCellIndexPath]) {
        
        [self showCancelShippingAlert];
        
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return ((indexPath.section >= POSITION_SECTION_INDEX) && [self shippingProcessIsRunning]);
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"SHIPPING", nil);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.selectedPosition = [self.resultsController objectAtIndexPath:[self resultsControllerIndexPathFromTableIndexPath:indexPath]];
        [self performSegueWithIdentifier:@"showPositionVolumes" sender:self];

    }
    
}


#pragma mark - action sheet

- (void)showShippingActionSheet {
    
    NSString *title = [NSString stringWithFormat:@"%@ — %@", self.selectedPosition.article.name, [self.selectedPosition volumeText]];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    actionSheet.tag = 666;
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"DONE VOLUME BUTTON", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"SHORTAGE VOLUME BUTTON", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"EXCESS VOLUME BUTTON", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"BAD VOLUME BUTTON", nil)];
    
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    NSLog(@"buttonIndex %d", buttonIndex);
    
    [self performSegueWithIdentifier:@"showVolumes" sender:self];
    
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

        STMShipmentPosition *position = [self shipmentPositionForTableIndexPath:indexPath];
        
        if (position.isProcessed.boolValue) {
            [self.shippingProcessController resetPosition:position];
        } else {
            [self.shippingProcessController shippingPosition:position withDoneVolume:position.volume.integerValue];
        }
        
    }
    
}


#pragma mark - processed button

- (void)routePointIsReached {
    
    [self reloadStopShippingButtonCell];
    [self showStartShippingAlert];
    
}

- (void)showStartShippingAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    
        NSString *title = (self.shipment.isShipped.boolValue) ? NSLocalizedString(@"EDIT SHIPPING?", nil) : ([self haveProcessedPositions]) ? NSLocalizedString(@"CONTINUE SHIPPING?", nil) : NSLocalizedString(@"START SHIPPING?", nil);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                              otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        
        alert.tag = 222;
        [alert show];
    
    }];
    
}

- (void)startShipping {

    [self.shippingProcessController startShippingWithShipment:self.shipment];
    [self.tableView reloadData];
    
}

- (void)showCancelShippingAlert {

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CANCEL SHIPPING?", nil)
                                                        message:NSLocalizedString(@"CANCEL SHIPPING MESSAGE", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                              otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        
        alert.tag = 333;
        [alert show];

    }];

}

- (void)cancelShipping {

    [self.shippingProcessController cancelShippingWithShipment:self.shipment];

    [self.tableView reloadData];
    
}

- (void)showDoneShippingAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        UIAlertView *alert = nil;
        
        if ([self haveUnprocessedPositions]) {
            
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HAVE UNPROCESSED POSITIONS TITLE", nil)
                                               message:NSLocalizedString(@"HAVE UNPROCESSED POSITIONS MESSAGE", nil)
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                     otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
            alert.tag = 555;
            
        } else {
            
            alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STOP SHIPPING?", nil)
                                               message:@""
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                     otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
            alert.tag = 444;
            
        }
        
        if (alert) [alert show];

    }];

}

- (void)doneShipping {
    
    [self.shippingProcessController doneShippingWithShipment:self.shipment withCompletionHandler:^(BOOL success) {
        
        if (!success) {
            [self showDoneShippingErrorAlert];
        }
        
        [self.tableView reloadData];
        
    }];

}

- (void)showDoneShippingErrorAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HAVE UNPROCESSED POSITIONS", nil)
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];

        [alert show];
        
    }];

}

- (void)reloadStopShippingButtonCell {
    
    if (self.shippingButtonCellIndexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[self.shippingButtonCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

}

- (void)reloadButtonsSections {
    
    if (self.shippingButtonCellIndexPath) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.shippingButtonCellIndexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case 222:
            switch (buttonIndex) {
                case 1:
                    [self startShipping];
                    [self performSegueWithIdentifier:@"showShipping" sender:self];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 333:
            switch (buttonIndex) {
                case 1:
                    [self cancelShipping];
                    break;
                    
                default:
                    break;
            }
            break;

        case 444:
            switch (buttonIndex) {
                case 1:
                    [self doneShipping];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 555:
            switch (buttonIndex) {
                case 1:
                    [self.shippingProcessController markUnprocessedPositionsAsDoneForShipment:self.shipment];
                    [self doneShipping];
                    break;
                    
                default:
                    break;
            }
            break;

        default:
            break;
    }
    
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    
}


#pragma mark - height's cache

- (void)putCachedHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        
        NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-2]] objectID];
        self.cachedCellsHeights[objectID] = @(height);
        
    } else {
        
        self.cachedCellsHeights[indexPath] = @(height);
        
    }
    
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        
        NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-2]] objectID];;
        return self.cachedCellsHeights[objectID];
        
    } else {

        return self.cachedCellsHeights[indexPath];
        
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
    
    sectionIndex = sectionIndex + POSITION_SECTION_INDEX;
    [super controller:controller didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:type];
    
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
    
        indexPath = [self tableIndexPathFromResultsControllerIndexPath:indexPath];
        newIndexPath = [self tableIndexPathFromResultsControllerIndexPath:newIndexPath];
        
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


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showPositionVolumes"]) {
        
        if ([segue.destinationViewController isKindOfClass:[STMPositionVolumesVC class]]) {
            
            [(STMPositionVolumesVC *)segue.destinationViewController setPosition:self.selectedPosition];
            
        }
        
    } else if ([segue.identifier isEqualToString:@"showShipping"] &&
               [segue.destinationViewController isKindOfClass:[STMShippingVC class]]) {
        
        STMShippingVC *shippingVC = (STMShippingVC *)segue.destinationViewController;
        shippingVC.shipment = self.shipment;
        shippingVC.parentVC = self;
        shippingVC.sortOrder = self.sortOrder;
        
    }

}


#pragma mark - observers

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(routePointIsReached) name:@"routePointIsReached" object:self.parentVC];
    
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom7TVCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    
    [self addObservers];
//    [self performFetch];
    
    [super customInit];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self performFetch];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }

    if (![self.navigationController.viewControllers containsObject:self]) {
        
        if (self.point.isReached.boolValue && !self.shipment.isShipped.boolValue) {
            [self.parentVC shippingProcessWasInterrupted];
        }
        [self removeObservers];
        
    }
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
