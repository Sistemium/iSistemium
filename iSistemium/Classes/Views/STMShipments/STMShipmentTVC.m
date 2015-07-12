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

#define POSITION_SECTION_INDEX 2


@interface STMShipmentTVC () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSIndexPath *processedButtonCellIndexPath;
@property (nonatomic, strong) NSIndexPath *cancelButtonCellIndexPath;

@property (nonatomic, strong) STMShipmentPosition *selectedPosition;

@end


@implementation STMShipmentTVC

@synthesize resultsController = _resultsController;


- (NSString *)cellIdentifier {
    return @"shipmentPositionCell";
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isProcessed.boolValue == YES"];
    return ([self.shipment.shipmentPositions filteredSetUsingPredicate:predicate].count > 0);
    
}

- (BOOL)haveUnprocessedPositions {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isProcessed.boolValue != YES"];
    return ([self.shipment.shipmentPositions filteredSetUsingPredicate:predicate].count > 0);
    
}

- (BOOL)shippingProcessIsRunning {
    return [[STMShippingProcessController sharedInstance].shipments containsObject:self.shipment];
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
            return ([self shippingProcessIsRunning]) ? 2 : 1;
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
            return NSLocalizedString(@"SHIPMENT POSITIONS", nil);
            break;

        case 3:
            return NSLocalizedString(@"PROCESSED SHIPMENT POSITIONS", nil);
            break;

        default:
            return nil;
            break;
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
                        [self fillProcessedButtonCell:(STMCustom7TVCell *)cell atIndexPath:indexPath];
                        break;
                        
                    case 1:
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
    
    cell.titleLabel.text = point.name;
    cell.titleLabel.numberOfLines = 0;
    cell.detailLabel.text = @"";
    
}

- (void)fillCell:(STMCustom7TVCell *)cell withShipment:(STMShipment *)shipment {
    
    cell.titleLabel.text = shipment.ndoc;
    
    NSUInteger positionsCount = shipment.shipmentPositions.count;
    NSString *pluralType = [STMFunctions pluralTypeForCount:positionsCount];
    NSString *localizedString = [NSString stringWithFormat:@"%@POSITIONS", pluralType];
    
    NSString *detailText;
    
    if (positionsCount > 0) {
        
        detailText = [NSString stringWithFormat:@"%lu %@", (unsigned long)positionsCount, NSLocalizedString(localizedString, nil)];
        
    } else {
        
        detailText = NSLocalizedString(localizedString, nil);
        
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

- (void)fillProcessedButtonCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    cell.titleLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
    
    if ([self shippingProcessIsRunning]) {
        
        cell.titleLabel.text = NSLocalizedString(@"SHIPMENT PROCESSED BUTTON STOP TITLE", nil);
        
    } else {
        
        if ([self haveProcessedPositions]) {
            cell.titleLabel.text = NSLocalizedString(@"SHIPMENT PROCESSED BUTTON CONTINUE TITLE", nil);
        } else {
            cell.titleLabel.text = NSLocalizedString(@"SHIPMENT PROCESSED BUTTON START TITLE", nil);
        }
        
    }
    
    cell.titleLabel.textColor = ACTIVE_BLUE_COLOR;
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;

    cell.detailLabel.text = (self.point.isReached.boolValue) ? @"" : NSLocalizedString(@"SHOULD CONFIRM ARRIVAL FIRST", nil);
    
    cell.detailLabel.textColor = [UIColor lightGrayColor];
    cell.detailLabel.textAlignment = NSTextAlignmentCenter;
    
    self.processedButtonCellIndexPath = indexPath;
    
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
    
    cell.titleLabel.text = position.article.name;
    cell.detailLabel.text = @"";
    
    STMLabel *infoLabel = [[STMLabel alloc] initWithFrame:CGRectMake(0, 0, 40, 21)];
    infoLabel.text = [self infoTextForPosition:position];
    infoLabel.textAlignment = NSTextAlignmentRight;
    infoLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.accessoryView = infoLabel;
    
    UIColor *textColor = (position.isProcessed.boolValue) ? [UIColor lightGrayColor] : [UIColor blackColor];

    cell.titleLabel.textColor = textColor;
    cell.detailLabel.textColor = textColor;
    infoLabel.textColor = textColor;
    
}

- (NSString *)infoTextForPosition:(STMShipmentPosition *)position {
    
    NSString *volumeUnitString = nil;
    NSString *infoText = nil;
    
    int volume = [position.volume intValue];
    int packageRel = [position.article.packageRel intValue];
    
    if (packageRel != 0 && volume >= packageRel) {
        
        int package = floor(volume / packageRel);
        
        volumeUnitString = NSLocalizedString(@"VOLUME UNIT1", nil);
        NSString *packageString = [NSString stringWithFormat:@"%d %@", package, volumeUnitString];
        
        int bottle = volume % packageRel;
        
        if (bottle > 0) {
            
            volumeUnitString = NSLocalizedString(@"VOLUME UNIT2", nil);
            NSString *bottleString = [NSString stringWithFormat:@" %d %@", bottle, volumeUnitString];
            
            packageString = [packageString stringByAppendingString:bottleString];
            
        }
        
        infoText = packageString;
        
    } else {
        
        volumeUnitString = NSLocalizedString(@"VOLUME UNIT2", nil);
        infoText = [NSString stringWithFormat:@"%@ %@", position.volume, volumeUnitString];
        
    }
    
    return infoText;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([indexPath isEqual:self.processedButtonCellIndexPath]) {
        
        if (!self.point.isReached.boolValue) {
            
            [self.parentVC showArriveConfirmationAlert];
            
        } else {
            
            if ([[STMShippingProcessController sharedInstance].shipments containsObject:self.shipment]) {
                [self showStopShippingAlert];
            } else {
                [self showShippingStartAlert];
            }
            
        }
        
    } else if ([indexPath isEqual:self.cancelButtonCellIndexPath]) {
        
        [self showCancelShippingAlert];
        
    } else if (indexPath.section >= POSITION_SECTION_INDEX) {
        
        if ([self shippingProcessIsRunning]) {
            
            self.selectedPosition = [self.resultsController objectAtIndexPath:[self resultsControllerIndexPathFromTableIndexPath:indexPath]];
            [self showShippingActionSheet];
            
        }
        
    }
    
}


#pragma mark - action sheet

- (void)showShippingActionSheet {
    
    NSString *title = [NSString stringWithFormat:@"%@ — %@", self.selectedPosition.article.name, [self infoTextForPosition:self.selectedPosition]];
    
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
}

#pragma mark - cell's swipe

- (void)addSwipeGestureToCell:(UITableViewCell *)cell withPosition:(STMShipmentPosition *)position {
    
    UISwipeGestureRecognizer *swipe = nil;
    
    if (position.isProcessed.boolValue) {

        swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToLeft:)];
        swipe.direction = UISwipeGestureRecognizerDirectionLeft;

    } else {
    
        swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToRight:)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight;

    }
    
//    swipe.delegate = self;
    
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
        position.doneVolume = position.volume;
        position.isProcessed = @YES;
        
    }
    
}

- (void)swipeToLeft:(id)sender {
    
//    NSLogMethodName;
    
    if ([sender isKindOfClass:[UISwipeGestureRecognizer class]]) {
        
        UITableViewCell *cell = (UITableViewCell *)[(UISwipeGestureRecognizer *)sender view];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        STMShipmentPosition *position = [self shipmentPositionForTableIndexPath:indexPath];
        [self resetPosition:position];
        
    }
    
}

- (void)resetPosition:(STMShipmentPosition *)position {

    position.doneVolume = nil;
    position.badVolume = nil;
    position.excessVolume = nil;
    position.shortageVolume = nil;
    position.isProcessed = nil;

}


#pragma mark - processed button

- (void)routePointIsReached {
    
    [self reloadProcessedButtonCell];
    [self showShippingStartAlert];
    
}

- (void)showShippingStartAlert {
    
    NSString *title = ([self haveProcessedPositions]) ? NSLocalizedString(@"CONTINUE SHIPPING?", nil) : NSLocalizedString(@"START SHIPPING?", nil);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                          otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    
    alert.tag = 222;
    [alert show];
    
}

- (void)startShipping {

    [[STMShippingProcessController sharedInstance].shipments addObject:self.shipment];
    [self reloadButtonsSections];
    
}

- (void)showCancelShippingAlert {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CANCEL SHIPPING?", nil)
                                                    message:NSLocalizedString(@"CANCEL SHIPPING MESSAGE", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                          otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    
    alert.tag = 333;
    [alert show];

}

- (void)cancelShipping {
    
    for (STMShipmentPosition *position in self.shipment.shipmentPositions) {
        [self resetPosition:position];
    }
    
    [self stopShipping];
    
}

- (void)showStopShippingAlert {
    
    UIAlertView *alert = nil;
    
    if ([self haveUnprocessedPositions]) {
        
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HAVE UNPROCESSED POSITIONS", nil)
                                           message:@""
                                          delegate:self
                                 cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                 otherButtonTitles:nil];

    } else {
    
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STOP SHIPPING?", nil)
                                           message:@""
                                          delegate:self
                                 cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                 otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        
        alert.tag = 444;

    }

    if (alert) [alert show];

}

- (void)stopShipping {

    [[STMShippingProcessController sharedInstance].shipments removeObject:self.shipment];
    [self reloadButtonsSections];

}

- (void)reloadProcessedButtonCell {
    
    if (self.processedButtonCellIndexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[self.processedButtonCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

}

- (void)reloadButtonsSections {
    
    if (self.processedButtonCellIndexPath) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.processedButtonCellIndexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
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
                    [self stopShipping];
                    break;
                    
                default:
                    break;
            }
            break;

        default:
            break;
    }
    
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
        
        STMShipmentPosition *position = (STMShipmentPosition *)anObject;
        
        UITableViewRowAnimation rowAnimation = (position.isProcessed.boolValue) ? UITableViewRowAnimationRight : UITableViewRowAnimationLeft;
    
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

//#pragma mark - Navigation
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    
//    if ([segue.identifier isEqualToString:@"showShipments"] &&
//        [sender isKindOfClass:[NSIndexPath class]] &&
//        [segue.destinationViewController isKindOfClass:[STMShipmentsTVC class]]) {
//        
//        STMShipmentRoutePoint *point = [self.resultsController objectAtIndexPath:(NSIndexPath *)sender];
//        [(STMShipmentsTVC *)segue.destinationViewController setPoint:point];
//        
//    }
//    
//    
//}


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
    [self performFetch];
    
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

}

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }

    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        
        if (self.point.isReached.boolValue && !self.shipment.isProcessed.boolValue) {
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
