//
//  STMShipmentPositionsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentTVC.h"
#import "STMNS.h"
#import "STMFunctions.h"
#import "STMShippingProcessController.h"

#import "STMPositionVolumesVC.h"
#import "STMShippingVC.h"
#import "STMShippingSettingsTVC.h"


#define POSITION_SECTION_INDEX 2


@interface STMShipmentTVC () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) STMShipmentsSVC *splitVC;
@property (nonatomic, strong) UIPopoverController *settingsPopover;

@property (nonatomic, strong) NSIndexPath *shippingButtonCellIndexPath;
@property (nonatomic, strong) NSIndexPath *finishShippingButtonCellIndexPath;
@property (nonatomic, strong) NSIndexPath *rejectShippingButtonCellIndexPath;
@property (nonatomic, strong) NSIndexPath *cancelButtonCellIndexPath;
@property (nonatomic, strong) NSIndexPath *lastClickedButtonIndexPath;

@property (nonatomic, strong) STMShipmentPosition *selectedPosition;

@property (nonatomic, strong) STMShippingProcessController *shippingProcessController;

@property (nonatomic, strong) NSString *positionCellIdentifier;




@end


@implementation STMShipmentTVC

@synthesize resultsController = _resultsController;
@synthesize sortOrder = _sortOrder;

- (STMShipmentsSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMShipmentsSVC class]]) {
            _splitVC = (STMShipmentsSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (void)setShipment:(STMShipment *)shipment {
    
    if (![_shipment isEqual:shipment]) {
        
        _shipment = shipment;
        [self performFetch];
        
    }
    
}

- (STMShippingProcessController *)shippingProcessController {
    return [STMShippingProcessController sharedInstance];
}

- (NSString *)cellIdentifier {
    return @"shipmentTVCell";
}

- (NSString *)positionCellIdentifier {
    return @"positionCell";
}

- (STMShipmentPositionSort)sortOrder {
    
    if (!_sortOrder) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *sortOrder = [defaults valueForKey:@"STMShipmentPositionSort"];
        
        if (sortOrder) {
            
            _sortOrder = (STMShipmentPositionSort)sortOrder.integerValue;
            
        } else {
            
            _sortOrder = STMShipmentPositionSortOrdAsc;
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
    
    [self setupSortSettingsButton];
    [self performFetch];
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMShipmentPosition class])];
        
        NSSortDescriptor *processedDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"isProcessed.boolValue"
                                                                              ascending:YES
                                                                               selector:@selector(compare:)];
        
        NSSortDescriptor *sortOrderDescriptor = [self currentSortDescriptor];
        
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name"
                                                                         ascending:sortOrderDescriptor.ascending
                                                                          selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[processedDescriptor, sortOrderDescriptor, nameDescriptor];
        
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
        case STMShipmentPositionSortOrdAsc:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord" ascending:YES selector:@selector(compare:)];
            break;
            
        case STMShipmentPositionSortOrdDesc:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord" ascending:NO selector:@selector(compare:)];
            break;

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
    
    self.resultsController.delegate = nil;
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
        return ([self shippingProcessIsRunning]) ? 3 : self.shipment.isShipped.boolValue || self.shipment.isRejected.boolValue ? 1 : 2;
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

- (UITableViewCell *)cellForHeightCalculationForIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section < 2) {
        
        static UITableViewCell *shipmentTVCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shipmentTVCell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
        });
        
        cell = shipmentTVCell;
        
    } else {
        
        static UITableViewCell *positionCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            positionCell = [self.tableView dequeueReusableCellWithIdentifier:self.positionCellIdentifier];
        });
        
        cell = positionCell;
        
    }

    return cell;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;

    if (indexPath.section < 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:self.positionCellIdentifier forIndexPath:indexPath];
    }
    
    if ([cell conformsToProtocol:@protocol(STMTDCell)]) {
        
        [self flushCellBeforeUse:(UITableViewCell <STMTDCell> *)cell];
        [self fillCell:(UITableViewCell <STMTDCell> *)cell atIndexPath:indexPath];

    }
    
    return cell;
    
}

- (void)flushCellBeforeUse:(UITableViewCell <STMTDCell> *)cell {
    
    cell.accessoryView = nil;

    cell.titleLabel.font = [UIFont systemFontOfSize:cell.textLabel.font.pointSize];
    cell.titleLabel.text = @"";
    cell.titleLabel.textColor = [UIColor blackColor];
    cell.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    cell.detailLabel.text = @"";
    cell.detailLabel.textColor = [UIColor blackColor];
    cell.detailLabel.textAlignment = NSTextAlignmentLeft;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
}

- (void)fillCell:(UITableViewCell <STMTDCell> *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [self fillCell:cell withRoute:self.point.shipmentRoute];
                    break;

                case 1:
                    [self fillCell:cell withRoutePoint:self.point];
                    break;

                case 2:
                    [self fillCell:cell withShipment:self.shipment];
                    break;

                default:
                    break;
            }
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                    if (self.shipment.isRejected.boolValue){
                        [self fillRejectShippingButtonCell:cell atIndexPath:indexPath];
                    }else{
                        [self fillShippingButtonCell:cell atIndexPath:indexPath];
                    }
                    break;
                    
                case 1:
                    if ([self shippingProcessIsRunning]) {
                        [self fillFinishShippingButtonCell:cell atIndexPath:indexPath];
                    }else{
                        [self fillRejectShippingButtonCell:cell atIndexPath:indexPath];
                    }
                    break;
                    
                case 2:
                    [self fillCancelButtonCell:cell atIndexPath:indexPath];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 2:
        case 3:
            if ([cell conformsToProtocol:@protocol(STMTDICell)]) {
                [self fillShipmentPositionCell:(UITableViewCell <STMTDICell> *)cell atIndexPath:indexPath];
            }
            break;
            
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillCell:(UITableViewCell <STMTDCell> *)cell withRoute:(STMShipmentRoute *)route {
    
    if (route.date) {
        
        cell.titleLabel.text = [STMFunctions dayWithDayOfWeekFromDate:(NSDate *)route.date];
        cell.detailLabel.text = @"";

    }
    
}

- (void)fillCell:(UITableViewCell <STMTDCell> *)cell withRoutePoint:(STMShipmentRoutePoint *)point {
    
    cell.titleLabel.text = [STMFunctions shortCompanyName:point.name];
    cell.titleLabel.numberOfLines = 0;
    cell.detailLabel.text = @"";
    
}

- (void)fillCell:(UITableViewCell <STMTDCell> *)cell withShipment:(STMShipment *)shipment {
    [self.parentVC fillCell:cell withShipment:shipment];
}

- (void)fillShippingButtonCell:(UITableViewCell <STMTDCell> *)cell atIndexPath:(NSIndexPath *)indexPath {
    
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

- (void)fillFinishShippingButtonCell:(UITableViewCell <STMTDCell> *)cell atIndexPath:(NSIndexPath *)indexPath {
    
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

- (void)fillRejectShippingButtonCell:(UITableViewCell <STMTDCell> *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.titleLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
    
    if (self.shipment.isRejected.boolValue){
        cell.titleLabel.text = NSLocalizedString(@"SHIPMENT PROCESSED BUTTON CANCEL REJECT TITLE", nil);
    }else{
        cell.titleLabel.text = NSLocalizedString(@"SHIPMENT PROCESSED BUTTON REJECT TITLE", nil);
    }
    
    cell.titleLabel.textColor = ACTIVE_BLUE_COLOR;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.detailLabel.text = (self.point.isReached.boolValue) ? @"" : NSLocalizedString(@"SHOULD CONFIRM ARRIVAL FIRST", nil);
    
    cell.detailLabel.textColor = [UIColor lightGrayColor];
    cell.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.finishShippingButtonCellIndexPath = nil;
    self.rejectShippingButtonCellIndexPath = indexPath;
    if (self.shippingButtonCellIndexPath == self.rejectShippingButtonCellIndexPath) {
        self.shippingButtonCellIndexPath = nil;
    }
    
}

- (void)fillCancelButtonCell:(UITableViewCell <STMTDCell> *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.titleLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
    
    cell.titleLabel.text = NSLocalizedString(@"SHIPMENT PROCESSED BUTTON CANCEL TITLE", nil);
    
    cell.titleLabel.textColor = [UIColor redColor];
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.detailLabel.text = @"";
    
    self.cancelButtonCellIndexPath = indexPath;

}

- (void)fillShipmentPositionCell:(UITableViewCell <STMTDICell> *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMShipmentPosition *position = [self shipmentPositionForTableIndexPath:indexPath];
    [self fillCell:cell withShipmentPosition:position];
    
//    cell.infoLabel.text = @(indexPath.row).stringValue;
    
}

- (STMShipmentPosition *)shipmentPositionForTableIndexPath:(NSIndexPath *)indexPath {

    indexPath = [self resultsControllerIndexPathFromTableIndexPath:indexPath];
    
    STMShipmentPosition *position = [self.resultsController objectAtIndexPath:indexPath];

    return position;
    
}

- (void)fillCell:(UITableViewCell <STMTDICell> *)cell withShipmentPosition:(STMShipmentPosition *)position {
    
    UIColor *textColor = (position.isProcessed.boolValue) ? [UIColor lightGrayColor] : [UIColor blackColor];
    
    UIFont *font = [UIFont systemFontOfSize:17];
    
    NSMutableDictionary *attributes = @{NSForegroundColorAttributeName : textColor,
                                        NSFontAttributeName            : font}.mutableCopy;
    
    NSMutableAttributedString *attributedText = nil;
    
    if (position.articleFact.name) {
        
        attributedText = [[NSMutableAttributedString alloc] initWithString:[(NSString * _Nonnull)position.articleFact.name stringByAppendingString:@"\n"]
                                                                attributes:attributes];
        
        if (position.article.name) {
        
            font = [UIFont systemFontOfSize:font.pointSize - 4];
            
            NSDictionary *attributes = @{NSForegroundColorAttributeName     : [UIColor blackColor],
                                         NSStrikethroughStyleAttributeName  : @(NSUnderlinePatternSolid | NSUnderlineStyleSingle),
                                         NSFontAttributeName                : font};

            NSAttributedString *appendString = [[NSAttributedString alloc] initWithString:(NSString * _Nonnull)position.article.name
                                                                               attributes:attributes];
            
            [attributedText appendAttributedString:appendString];

        }
        
    } else {
        
        if (position.article.name) {
            
            attributedText = [[NSMutableAttributedString alloc] initWithString:(NSString * _Nonnull)position.article.name
                                                                    attributes:attributes];
            
        } else {
            
            attributes[NSForegroundColorAttributeName] = [UIColor redColor];
            
            attributedText = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"UNKNOWN ARTICLE", nil)
                                                                    attributes:attributes];
            
        }
        
    }
    
    cell.titleLabel.attributedText = attributedText;
    
    attributes[NSFontAttributeName] = cell.detailLabel.font;
    
    if (position.isProcessed.boolValue) {
        
        NSAttributedString *volumes = [self.shippingProcessController volumesAttributedStringWithAttributes:attributes
                                                                                                 doneVolume:position.doneVolume.integerValue
                                                                                                  badVolume:position.badVolume.integerValue
                                                                                               excessVolume:position.excessVolume.integerValue
                                                                                             shortageVolume:position.shortageVolume.integerValue
                                                                                              regradeVolume:position.regradeVolume.integerValue
                                                                                               brokenVolume:position.brokenVolume.integerValue
                                                                                                 packageRel:position.article.packageRel.integerValue];
        cell.detailLabel.attributedText = volumes;
        
    } else {
        
        cell.detailLabel.attributedText = nil;
        
    }
    
    STMLabel *volumeLabel = [[STMLabel alloc] initWithFrame:CGRectMake(0, 0, 40, 21)];
    volumeLabel.text = [position volumeText];
    volumeLabel.textAlignment = NSTextAlignmentRight;
    volumeLabel.textColor = textColor;
    volumeLabel.adjustsFontSizeToFitWidth = YES;

    cell.accessoryView = volumeLabel;
    
    cell.infoLabel.text = position.ord.stringValue;
    cell.infoLabel.textColor = [UIColor lightGrayColor];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    self.lastClickedButtonIndexPath = indexPath;
    
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
    
    else if ([indexPath isEqual:self.rejectShippingButtonCellIndexPath]) {
        
        if (!self.point.isReached.boolValue) {
            [self.parentVC showArriveConfirmationAlert];
        }else{
            if (self.shipment.isRejected.boolValue){
                [self showCancelRjectShippingAlert];
            }else{
                [self showRjectShippingAlert];
            }
        }
        
    }
    
}


#pragma mark - action sheet

- (void)showShippingActionSheet {
    
    NSString *title = [NSString stringWithFormat:@"%@ — %@", self.selectedPosition.article.name, [self.selectedPosition volumeText]];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

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
        
    }];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    NSLog(@"buttonIndex %d", buttonIndex);
    
    [self performSegueWithIdentifier:@"showVolumes" sender:self];
    
}


#pragma mark - processed button

- (void)routePointIsReached {
    
    [self reloadStopShippingButtonCell];
    [self reloadRejectShippingButtonCell];
    [self tableView:self.tableView didSelectRowAtIndexPath:self.lastClickedButtonIndexPath];
    
}

- (void)showStartShippingAlert {
    
    if (!self.shipment.isShipped.boolValue && ![self haveProcessedPositions]) {
        [self startShipping];
    } else {
    
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
    
}

- (void)startShipping {

    [self.shippingProcessController startShippingWithShipment:self.shipment];
    [self performSegueWithIdentifier:@"showShipping" sender:self];
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

- (void)showRjectShippingAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REJECT SHIPPING?", nil)
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                              otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        
        alert.tag = 777;
        [alert show];
        
    }];
    
}

- (void)showCancelRjectShippingAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CANCEL REJECT SHIPPING?", nil)
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                              otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        
        alert.tag = 888;
        [alert show];
        
    }];
    
}

- (void)cancelShipping {

    self.resultsController.delegate = nil;
    [self.shippingProcessController cancelShippingWithShipment:self.shipment];
    [self performSelector:@selector(performFetch) withObject:nil afterDelay:0];
    
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
    
    [self popToSelf];
    
    [self.shippingProcessController doneShippingWithShipment:self.shipment withCompletionHandler:^(BOOL success) {
        
        if (!success) {
            [self showDoneShippingErrorAlert];
        }
        
        NSLog(@"isMainThread %d", [NSThread isMainThread]);
        
        [self performSelector:@selector(performFetch) withObject:nil afterDelay:0];
        
    }];

}

- (void)rejectShipping {
    
    //[self popToSelf];
    self.resultsController.delegate = nil;
    [self.shippingProcessController rejectShippingWithShipment:self.shipment];
    [self.tableView reloadData];
    
}

- (void)cancelRejectShipping {
    
    //[self popToSelf];
    [self performSelector:@selector(performFetch) withObject:nil afterDelay:0];
    [self.tableView reloadData];
    
}

- (void)shippingDidDone {
    
    [self performSelector:@selector(performFetch) withObject:nil afterDelay:0];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)popToSelf {
    
    if (![self.navigationController.topViewController isEqual:self]) {
        
        [self.navigationController popToViewController:self animated:YES];
        
    } else if (![self.navigationController.visibleViewController isEqual:self]) {
        
        [self.navigationController.visibleViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
        
    }
    
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

- (void)reloadRejectShippingButtonCell {
    
    if (self.rejectShippingButtonCellIndexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[self.rejectShippingButtonCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}

- (void)reloadButtonsSections {
    
    if (self.shippingButtonCellIndexPath) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.shippingButtonCellIndexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case 222:
            switch (buttonIndex) {
                case 1:
                    [self startShipping];
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
                    self.resultsController.delegate = nil;
                    [self.shippingProcessController markUnprocessedPositionsAsDoneForShipment:self.shipment];
                    [self doneShipping];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 777:
            switch (buttonIndex) {
                case 1:
                    [self rejectShipping];
                    break;
                    
                default:
                    break;
            }
            break;
        case 888:
            switch (buttonIndex) {
                case 1:
                    [self cancelRejectShipping];
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
    
    if (indexPath.section >= 2) {
        
        NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-2]] objectID];
        self.cachedCellsHeights[objectID] = @(height);
        
    } else {
        
        self.cachedCellsHeights[indexPath] = @(height);
        
    }
    
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section >= 2) {
        
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
    
//    if (![self shippingProcessIsRunning]) {
//        
//        self.cachedCellsHeights = nil;
//        [self.tableView reloadData];
//        
//    }

    [self.tableView reloadData];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    sectionIndex = sectionIndex + POSITION_SECTION_INDEX;
    [super controller:controller didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:type];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if ([self shippingProcessIsRunning]) {
        
        if ([anObject isKindOfClass:[STMShipmentPosition class]]) {
            [self.cachedCellsHeights removeObjectForKey:[(STMShipmentPosition *)anObject objectID]];
        }

//        switch (type) {
//                
//            case NSFetchedResultsChangeMove: {
////                NSLog(@"NSFetchedResultsChangeMove");
//                [self moveObject:anObject atIndexPath:indexPath toIndexPath:newIndexPath];
//                break;
//            }
//                
//            default: {
//                [self.tableView reloadData];
//                break;
//            }
//                
//        }
        
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
    
    if ([segue.identifier isEqualToString:@"showShipping"]) {
        
        STMShippingVC *shippingVC = nil;
        
        if ([segue.destinationViewController isKindOfClass:[STMShippingVC class]]) {
        
            shippingVC = (STMShippingVC *)segue.destinationViewController;
            shippingVC.cachedHeights = self.cachedCellsHeights;
            
        } else if ([segue.destinationViewController isKindOfClass:[UINavigationController class]] &&
                   [[(UINavigationController *)segue.destinationViewController topViewController] isKindOfClass:[STMShippingVC class]]) {

            shippingVC = (STMShippingVC *)[(UINavigationController *)segue.destinationViewController topViewController];
            shippingVC.splitVC = self.splitVC;

        }
        
//        shippingVC.shipment = self.shipment;
        shippingVC.shipments = @[self.shipment];
        shippingVC.parentVC = self;
        shippingVC.sortOrder = self.sortOrder;
        
    } else if ([segue.identifier isEqualToString:@"showSettings"] &&
               [segue.destinationViewController isKindOfClass:[STMShippingSettingsTVC class]]) {
        
        STMShippingSettingsTVC *settingTVC = (STMShippingSettingsTVC *)segue.destinationViewController;
        
        settingTVC.parentVC = self;
        
    }

}


#pragma mark - observers

- (void)addObservers {
    
    if (self.shipment) {
    
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        
        [nc addObserver:self selector:@selector(routePointIsReached) name:@"routePointIsReached" object:self.parentVC];

    }
    
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    if ([self.splitVC isDetailNCForViewController:self]) {
        
        [self showSettingsPopover];
        
    } else {
    
        [self performSegueWithIdentifier:@"showSettings" sender:self];

    }
    
}

- (void)showSettingsPopover {
    
    self.settingsPopover = nil;
    
    STMShippingSettingsTVC *settingsVC = (STMShippingSettingsTVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"shippingSettings"];
    settingsVC.parentVC = self;
    
    self.settingsPopover = [[UIPopoverController alloc] initWithContentViewController:settingsVC];
    
    UIView *buttonView = [[self.navigationItem rightBarButtonItem] valueForKey:@"view"];
    
    [self.settingsPopover presentPopoverFromRect:buttonView.frame
                                          inView:self.view
                        permittedArrowDirections:UIPopoverArrowDirectionUp
                                        animated:YES];
    
}

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification {
    
    [super deviceOrientationDidChangeNotification:notification];
    
    [self.settingsPopover dismissPopoverAnimated:NO];
    self.settingsPopover = nil;
    
}


#pragma mark - view lifecycle

- (void)customInit {

    [self setupSortSettingsButton];

    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom7TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
    
    cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom9TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.positionCellIdentifier];
    
    [self addObservers];

    [self performSelector:@selector(performFetch) withObject:nil afterDelay:0];

    [super customInit];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    if ([self isMovingToParentViewController]) {
        self.cachedCellsHeights = nil;
    }
    
    [super viewWillAppear:animated];

    if ([self.splitVC isDetailNCForViewController:self]) [self.navigationItem setHidesBackButton:YES animated:NO];

}

- (void)viewWillDisappear:(BOOL)animated {

    if ([self isMovingFromParentViewController]) {
        
        if (self.point.isReached.boolValue && !self.shipment.isShipped.boolValue) {
            
            if ([self haveUnprocessedPositions]) {
                
                [self.parentVC shippingProcessWasInterrupted];
                
            } else {
                
                [[STMShippingProcessController sharedInstance] doneShippingWithShipment:self.shipment withCompletionHandler:^(BOOL success) {
                    
                }];
                
            }
            
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
