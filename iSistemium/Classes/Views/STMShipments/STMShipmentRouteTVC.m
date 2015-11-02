//
//  STMShipmentRoutePointsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRouteTVC.h"
#import "STMNS.h"
#import "STMUI.h"
#import "STMFunctions.h"

#import "STMShipmentRoutePointTVC.h"
#import "STMShipmentRouteSummaryTVC.h"
#import "STMAllRoutesMapVC.h"

#import "STMObjectsController.h"
#import "STMLocationController.h"
#import "STMShippingProcessController.h"
#import "STMWorkflowController.h"
#import "STMEntityController.h"
#import "STMShipmentRouteController.h"

#import "STMReorderRoutePointsTVC.h"
#import "STMWorkflowEditablesVC.h"


@interface STMShipmentRouteTVC () <UIActionSheetDelegate>

@property (nonatomic, strong) STMShipmentsSVC *splitVC;

@property (nonatomic, strong) NSIndexPath *doneSummaryIndexPath;
@property (nonatomic, strong) NSString *routeWorkflow;
@property (nonatomic, strong) NSString *nextProcessing;

@property (nonatomic, strong) NSString *routePointCellIdentifier;


@end


@implementation STMShipmentRouteTVC

@synthesize resultsController = _resultsController;

- (STMShipmentsSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMShipmentsSVC class]]) {
            _splitVC = (STMShipmentsSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (NSString *)routeWorkflow {

    if (!_routeWorkflow) {
        
        NSString *entityName = NSStringFromClass([STMShipmentRoute class]);
        entityName = [entityName stringByReplacingOccurrencesOfString:ISISTEMIUM_PREFIX withString:@""];
        
        STMEntity *shipmentRouteEntity = [STMEntityController entityWithName:entityName];
        
        _routeWorkflow = shipmentRouteEntity.workflow;

    }
    return _routeWorkflow;
    
}

- (NSString *)cellIdentifier {
    return @"routeCell";
}

- (NSString *)routePointCellIdentifier {
    return @"routePointCell";
}

- (void)setRoute:(STMShipmentRoute *)route {
    
    if (![_route isEqual:route]) {
        
        _route = route;
        [self performFetch];
        [self setupNavBar];
        
    }
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMShipmentRoutePoint class])];
        
        request.sortDescriptors = [self shipmentRoutePointsSortDescriptors];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shipmentRoute == %@", self.route];
        
        request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:predicate];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        _resultsController.delegate = self;

    }
    return _resultsController;
    
}

- (NSArray *)shipmentRoutePointsSortDescriptors {
    
    NSSortDescriptor *ordDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord" ascending:YES selector:@selector(compare:)];
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    return @[ordDescriptor, nameDescriptor];

}

- (void)performFetch {
    
    self.resultsController = nil;
    
    NSError *error;
    
    if (![self.resultsController performFetch:&error]) {
        
        NSLog(@"shipmentRoutePoints fetch error %@", error.localizedDescription);
        
    } else {
        
        for (STMShipmentRoutePoint *point in self.resultsController.fetchedObjects) {
            [self orderingPoint:point];
        }
        
        [self.tableView reloadData];
        [self checkPointsLocations];
        
    }
    
}

- (void)orderingPoint:(STMShipmentRoutePoint *)point {

    NSUInteger ord = [self.resultsController.fetchedObjects indexOfObject:point] + 1;
    
    if (!point.ord || point.ord.integerValue != ord) {
        point.ord = @(ord);
    }

}

- (void)checkPointsLocations {
    
    for (STMShipmentRoutePoint *point in self.resultsController.fetchedObjects) {
        
        if (!point.shippingLocation.location && point.address) {
            
            [[[CLGeocoder alloc] init] geocodeAddressString:point.address completionHandler:^(NSArray *placemarks, NSError *error) {
                
                if (!error) {
                    
                    CLPlacemark *placemark = placemarks.firstObject;
                    
                    [point updateShippingLocationWithGeocodedLocation:placemark.location];
                                        
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.resultsController.fetchedObjects indexOfObject:point] inSection:1];
                    if (indexPath) [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    
                    [self setupNavBar];
                    
                }
                
            }];
            
        }

    }
    
}

- (BOOL)haveProcessedShipments {
    return ([self.route shippedShipments].count > 0);
}


#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.route) ? 2 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return ([self.splitVC isMasterNCForViewController:self]) ? 0 : ([self haveProcessedShipments]) ? 3 : 2;
            break;
            
        case 1:
            return self.resultsController.fetchedObjects.count;
            
        default:
            return 0;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return ([self.splitVC isMasterNCForViewController:self]) ? nil : NSLocalizedString(@"SHIPMENT ROUTE", nil);
            break;
            
        case 1:
            return NSLocalizedString(@"SHIPMENT ROUTE POINTS", nil);
            break;
            
        default:
            return nil;
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return ([self.splitVC isMasterNCForViewController:self]) ? CGFLOAT_MIN : SINGLE_LINE_HEADER_HEIGHT;
            break;
            
        default:
            return SINGLE_LINE_HEADER_HEIGHT;
            break;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForCellAtIndexPath:indexPath];
}

- (UITableViewCell *)cellForHeightCalculationForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        static UITableViewCell *cell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
        });
        
        return cell;

    } else if (indexPath.section == 1) {

        static UITableViewCell *cell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            cell = [self.tableView dequeueReusableCellWithIdentifier:self.routePointCellIdentifier];
        });
        
        return cell;

    } else {
        
        return nil;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:self.routePointCellIdentifier forIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
                [self fillRouteCell:(STMCustom7TVCell *)cell atIndexPath:indexPath];
            }
            break;
            
        case 1:
            if ([cell isKindOfClass:[STMCustom9TVCell class]]) {
                [self fillRoutePointCell:(STMCustom9TVCell *)cell atIndex:indexPath.row];
            }
            break;
            
        default:
            break;
    }
    
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillRouteCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    UIColor *textColor = [UIColor blackColor];
    
    cell.titleLabel.textColor = textColor;
    cell.detailLabel.textColor = textColor;
    cell.accessoryType = UITableViewCellAccessoryNone;

    switch (indexPath.row) {
        case 0:

            cell.titleLabel.text = [STMFunctions dayWithDayOfWeekFromDate:self.route.date];
            cell.detailLabel.attributedText = [self detailTextForLabel:cell.detailLabel];
        break;
            
        case 1:
            cell.titleLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"PLAN SUMMARY CELL TITLE", nil)];
            cell.detailLabel.text = [self.route planSummary];
            break;

        case 2:
            cell.titleLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"DONE SUMMARY CELL TITLE", nil)];
            cell.detailLabel.text = [self.route doneSummary];
            self.doneSummaryIndexPath = indexPath;
            if ([self.route haveIssuesInProcessedShipments])
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;

        default:
            break;
    }

}

- (NSAttributedString *)detailTextForLabel:(STMLabel *)detailLabel {
    
    NSDictionary *attributes = @{NSFontAttributeName: detailLabel.font,
                                 NSForegroundColorAttributeName: detailLabel.textColor};
    
    NSMutableAttributedString *detailText = [[NSMutableAttributedString alloc] initWithString:@"" attributes:attributes];
    
    if (self.route.processing) {
        
        NSString *processingDescription = [STMWorkflowController descriptionForProcessing:self.route.processing inWorkflow:self.routeWorkflow];
        
        if (processingDescription) {

            [detailText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            
            UIColor *processingColor = [STMWorkflowController colorForProcessing:self.route.processing inWorkflow:self.routeWorkflow];
            UIColor *textColor = (processingColor) ? processingColor : [UIColor blackColor];
            
            UIFont *font = detailLabel.font;
            
            attributes = @{NSFontAttributeName: font,
                           NSForegroundColorAttributeName: textColor};

            [detailText appendAttributedString:[[NSAttributedString alloc] initWithString:processingDescription attributes:attributes]];
            
        }
        
    }
    
    if (self.route.commentText) {
        
        [detailText appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        
        UIFont *font = [UIFont systemFontOfSize:detailLabel.font.pointSize - 2];
        
        attributes = @{NSFontAttributeName: font,
                       NSForegroundColorAttributeName: detailLabel.textColor};
        
        [detailText appendAttributedString:[[NSAttributedString alloc] initWithString:self.route.commentText attributes:attributes]];
        
    }
    
    return detailText;
    
}

- (void)fillRoutePointCell:(STMCustom9TVCell *)cell atIndex:(NSUInteger)index {
    
    STMShipmentRoutePoint *point = [self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];

    cell.infoLabel.text = point.ord.stringValue;
    
    cell.titleLabel.text = [STMFunctions shortCompanyName:point.name];

    UIColor *textColor = [UIColor blackColor];
    
    if (point.isReached.boolValue) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isShipped.boolValue != YES"];
        NSUInteger unprocessedShipmentsCount = [point.shipments filteredSetUsingPredicate:predicate].count;
        
        textColor = (unprocessedShipmentsCount > 0) ? [UIColor redColor] : [UIColor lightGrayColor];

    }
    
    cell.titleLabel.textColor = textColor;
    
    NSMutableAttributedString *detailString;
    
    NSDictionary *attributes = @{NSFontAttributeName:cell.detailLabel.font,
                                 NSForegroundColorAttributeName:textColor};

    detailString = [[NSMutableAttributedString alloc] initWithString:[point shortInfo] attributes:attributes];
    
    if (!point.shippingLocation.location) {

        [detailString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attributes]];
        
        textColor = [UIColor redColor];
        
        attributes = @{NSFontAttributeName:cell.detailLabel.font,
                       NSForegroundColorAttributeName:textColor};

        NSAttributedString *appendString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NO LOCATION", nil) attributes:attributes];
        [detailString appendAttributedString:appendString];
        
    } else if (!point.shippingLocation.isLocationConfirmed.boolValue) {
        
        [detailString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attributes]];

        textColor = [UIColor lightGrayColor];
        
        attributes = @{NSFontAttributeName:cell.detailLabel.font,
                       NSForegroundColorAttributeName:textColor};
        
        NSAttributedString *appendString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"LOCATION NOT CONFIRMED", nil) attributes:attributes];
        [detailString appendAttributedString:appendString];

    }
    
    cell.detailLabel.attributedText = detailString;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];

        if ([self.splitVC isMasterNCForViewController:self]) {
            
            STMShipmentRoutePoint *point = [self.resultsController objectAtIndexPath:indexPath];
            [self.splitVC didSelectPoint:point inVC:self];
            
        } else {
            
            [self performSegueWithIdentifier:@"showShipments" sender:indexPath];

        }
        
    } else if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            if (self.routeWorkflow) {
                
                STMWorkflowAS *workflowActionSheet = [STMWorkflowController workflowActionSheetForProcessing:self.route.processing
                                                                                                  inWorkflow:self.routeWorkflow
                                                                                                withDelegate:self];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [workflowActionSheet showInView:self.view];
                }];
                
//                NSLog(@"processing %@", self.route.processing);
//                NSLog(@"workflow %@", self.routeWorkflow);
                
            }
            
        }
        
    }
    
    if ([indexPath compare:self.doneSummaryIndexPath] == NSOrderedSame) {
        [self performSegueWithIdentifier:@"showSummary" sender:self];
    }
    
}

- (void)showShipments {
    [self performSegueWithIdentifier:@"showShipments" sender:self.splitVC];
}

- (void)highlightSelectedPoint {
    
    NSIndexPath *indexPath = [self.resultsController indexPathForObject:self.splitVC.selectedPoint];
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+1];
    
    if (indexPath) {
        
        UITableViewScrollPosition scrollPosition = ([[self.tableView indexPathsForVisibleRows] containsObject:indexPath]) ? UITableViewScrollPositionNone : UITableViewScrollPositionTop;

        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:scrollPosition];
        
    }
    
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet isKindOfClass:[STMWorkflowAS class]] && buttonIndex != actionSheet.cancelButtonIndex) {
        
        [self workflowAS:(STMWorkflowAS *)actionSheet didDismissWithButtonIndex:buttonIndex];
        
    }
    
}

- (void)workflowAS:(STMWorkflowAS *)workflowAS didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    NSDictionary *result = [STMWorkflowController workflowActionSheetForProcessing:workflowAS.processing
                                                          didSelectButtonWithIndex:buttonIndex
                                                                        inWorkflow:workflowAS.workflow];
    
    self.nextProcessing = result[@"nextProcessing"];
    
    if (self.nextProcessing) {
        
        NSString *startedProcessing = @"started";
        
        if ([self.nextProcessing isEqualToString:startedProcessing]) {
            
            NSArray *startedRoutes = [STMShipmentRouteController routesWithProcessing:startedProcessing];
            
            if (startedRoutes.count > 0) {

                [self showUnfinishedRoutesAlert];
                return;
                
            }
            
        }
        
        NSArray *editableProperties = result[@"editableProperties"];
        
        if (editableProperties) {
            
            STMWorkflowEditablesVC *editablesVC = [[STMWorkflowEditablesVC alloc] init];
            
            editablesVC.workflow = workflowAS.workflow;
            editablesVC.toProcessing = self.nextProcessing;
            editablesVC.editableFields = editableProperties;
            editablesVC.parent = self;
            
            [self presentViewController:editablesVC animated:YES completion:^{
                
            }];
            
        } else {
            
            [self updateAndSyncAndReloadRootCell];
            
        }
        
    }

}


- (void)takeEditableValues:(NSDictionary *)editableValues {
    
    NSLog(@"editableValues %@", editableValues);
    
    for (NSString *field in editableValues.allKeys) {
        
        if ([self.route.entity.propertiesByName.allKeys containsObject:field]) {
            [self.route setValue:editableValues[field] forKey:field];
        }
        
    }
    
    [self updateAndSyncAndReloadRootCell];
    
}

- (void)updateAndSyncAndReloadRootCell {
    
    NSString *from = self.route.processing;
    NSString *to = self.nextProcessing;
    
    if (to) self.route.processing = to;
    
    [self.document saveDocument:^(BOOL success) {
//        if (success) [[[STMSessionManager sharedManager].currentSession syncer] setSyncerState:STMSyncerSendDataOnce];
    }];
    
    NSIndexPath *routeIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if (routeIndexPath) [self.tableView reloadRowsAtIndexPaths:@[routeIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    NSString *geotrackerControl = [STMSettingsController stringValueForSettings:@"geotrackerControl" forGroup:@"location"];
    
    if ([geotrackerControl isEqualToString:GEOTRACKER_CONTROL_SHIPMENT_ROUTE]) {
        
        if ([@[from, to] containsObject:@"started"]) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shipmentRouteProcessingChanged" object:self];
            
        }
        
    }

}

- (void)showUnfinishedRoutesAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"UNFINISHED ROUTES ALERT MESSAGE", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:nil];

        [alert show];
        
    }];
    
}


#pragma mark - height's cache

- (void)putCachedHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        self.cachedCellsHeights[indexPath] = @(height);
        
    } else {
        
        NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1]] objectID];
        self.cachedCellsHeights[objectID] = @(height);
        
    }
    
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return self.cachedCellsHeights[indexPath];
        
    } else {
        
        NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1]] objectID];;
        return self.cachedCellsHeights[objectID];
        
    }
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    for (STMShipmentRoutePoint *point in self.resultsController.fetchedObjects) {
        [self orderingPoint:point];
    }
    [self checkPointsLocations];
    [self reloadData];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

}


#pragma mark - Navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showShipments"] &&
        [segue.destinationViewController isKindOfClass:[STMShipmentRoutePointTVC class]]) {
        
        STMShipmentRoutePointTVC *pointTVC = (STMShipmentRoutePointTVC *)segue.destinationViewController;

        if ([sender isKindOfClass:[NSIndexPath class]]) {
        
            STMShipmentRoutePoint *point = [self.resultsController objectAtIndexPath:(NSIndexPath *)sender];
            [self orderingPoint:point];
            
            pointTVC.point = point;
            
            [self.splitVC didSelectPoint:point inVC:self];

        } else if ([sender isEqual:self.splitVC]) {
            
            pointTVC.point = self.splitVC.selectedPoint;
            
        }
        
    } else if ([segue.identifier isEqualToString:@"showSummary"] &&
               [segue.destinationViewController isKindOfClass:[STMShipmentRouteSummaryTVC class]]) {
        
        [(STMShipmentRouteSummaryTVC *)segue.destinationViewController setRoute:self.route];
        
    } else if ([segue.identifier isEqualToString:@"showAllRoutes"] &&
               [segue.destinationViewController isKindOfClass:[STMAllRoutesMapVC class]]) {
        
        STMAllRoutesMapVC *allRoutesMapVC = (STMAllRoutesMapVC *)segue.destinationViewController;

        for (STMShipmentRoutePoint *point in self.resultsController.fetchedObjects) {
            [self orderingPoint:point];
        }
        
        allRoutesMapVC.points = self.resultsController.fetchedObjects;
        allRoutesMapVC.parentVC = self;
        
        if ([self.splitVC isDetailNCForViewController:self]) {
            
            STMReorderRoutePointsTVC *reorderTVC = [[STMReorderRoutePointsTVC alloc] initWithStyle:UITableViewStyleGrouped];
            reorderTVC.points = self.resultsController.fetchedObjects;
            reorderTVC.parentVC = allRoutesMapVC;
            
            [self.splitVC.masterNC pushViewController:reorderTVC animated:YES];

        }
        
    }
    
}

- (void)shipmentsInfo {
    
    NSLog(@"shipmentRoutePoints.count %d", self.route.shipmentRoutePoints.count);
    
    NSSet *shipments = [self.route valueForKeyPath:@"shipmentRoutePoints.@distinctUnionOfSets.shipments"];
    
    NSLog(@"shipments.count %d", shipments.count);
    
    NSSet *positions = [shipments valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
    
    NSLog(@"positions.count %d", positions.count);
    
    NSArray *articles = [positions valueForKeyPath:@"@distinctUnionOfObjects.article"];
    
    NSLog(@"articles.count %d", articles.count);
    
    for (STMArticle *article in articles) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shipment IN %@", shipments];
        
        NSSet *filteredPositions = [article.shipmentPositions filteredSetUsingPredicate:predicate];
        
        if (filteredPositions.count > 1) {
            
            NSLog(@"article.name %@", article.name);
            
            for (STMShipmentPosition *position in filteredPositions) {
                
                NSLog(@"shipment.ndoc %@", position.shipment.ndoc);

                for (STMShipmentRoutePoint *point in position.shipment.shipmentRoutePoints) {
                    
                    NSLog(@"point.name %@", point.name);
                    
                }
                
            }
            
        }
        
    }
    
}

- (void)reloadData {
    
    if (self.doneSummaryIndexPath) [self.cachedCellsHeights removeObjectForKey:self.doneSummaryIndexPath];

    [self.tableView reloadData];

}


#pragma mark - navbar

- (void)setupNavBar {
    
    if (![self.splitVC isMasterNCForViewController:self] && [self pointsWithLocation].count > 0) {
        
        STMBarButtonItem *waypointButton = [[STMBarButtonItem alloc] initWithCustomView:[self waypointView]];
        self.navigationItem.rightBarButtonItem = waypointButton;
        
    } else {
        
        self.navigationItem.rightBarButtonItem = nil;
        
    }
    
}

- (NSArray *)pointsWithLocation {

    NSPredicate *locationPredicate = [NSPredicate predicateWithFormat:@"shippingLocation.location != %@", nil];
    NSSet *pointsWithLocation = [self.route.shipmentRoutePoints filteredSetUsingPredicate:locationPredicate];

    NSArray *result = [pointsWithLocation sortedArrayUsingDescriptors:[self shipmentRoutePointsSortDescriptors]];
    
//    for (STMShipmentRoutePoint *point in result) {
//        
//        if (point.ord.integerValue != [result indexOfObject:point] + 1) {
//            point.ord = @([result indexOfObject:point] + 1);
//        }
//        
//    }

    return result;
    
}

- (BOOL)isAllPointsHaveLocation {
    return (self.route.shipmentRoutePoints.count == [self pointsWithLocation].count);
}

- (UIView *)waypointView {
    
    CGFloat imageSize = 22;
    CGFloat imagePadding = 0;
    
    UIImage *image = [[UIImage imageNamed:@"waypoint_map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(imagePadding, imagePadding, imageSize, imageSize);
    imageView.tintColor = ([self isAllPointsHaveLocation]) ? ACTIVE_BLUE_COLOR : [UIColor lightGrayColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, imageSize + imagePadding * 2, imageSize + imagePadding * 2)];
    [button addTarget:self action:@selector(waypointButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:imageView];
    
    return button;
    
}

- (void)waypointButtonPressed {
    
//    if ([self isAllPointsHaveLocation]) {
        [self performSegueWithIdentifier:@"showAllRoutes" sender:self];
//    } else {
//        [self showNotEnoughLocationsAlert];
//    }

}

- (void)showNotEnoughLocationsAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ROUTING ERROR", nil)
                                                        message:NSLocalizedString(@"NOT ENOUGH LOCATIONS", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        
    }];
    
}


#pragma mark - observers

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routePointAllShipmentsIsDone:)
                                                 name:@"routePointAllShipmentsIsDone"
                                               object:nil];

}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)routePointAllShipmentsIsDone:(NSNotification *)notification {
    
    if ([notification.object isKindOfClass:[STMShipmentRoutePoint class]]) {

        [self.tableView reloadData];
        
//        STMShipmentRoutePoint *point = (STMShipmentRoutePoint *)notification.object;
//        
//        NSIndexPath *pointIndexPath = [self.resultsController indexPathForObject:point];
//        
//        if (pointIndexPath) {
//            
//            pointIndexPath = [NSIndexPath indexPathForRow:pointIndexPath.row inSection:pointIndexPath.section + 1];
//
//            [self.tableView reloadRowsAtIndexPaths:@[pointIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//            
//        }
        
    }
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    if ([self.splitVC isDetailNCForViewController:self]) {
        self.title = NSLocalizedString(@"SHIPMENT ROUTE POINTS", nil);
    }

    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom7TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
    
    cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom9TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.routePointCellIdentifier];
    
    [self performFetch];
    [self addObservers];
    
    [super customInit];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self setupNavBar];
    
    if ([self isMovingToParentViewController]) {
        self.cachedCellsHeights = nil;
    }

    [self reloadData];
    
    [super viewWillAppear:animated];
    
    if ([self.splitVC isMasterNCForViewController:self]) {
        [self highlightSelectedPoint];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([self isMovingFromParentViewController]) {
        
        [self.splitVC backButtonPressed];
        [self removeObservers];
        
    }
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
