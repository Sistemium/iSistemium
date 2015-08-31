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


@interface STMShipmentRouteTVC ()

@property (nonatomic, strong) STMShipmentsSVC *splitVC;

@property (nonatomic, strong) NSIndexPath *summaryIndexPath;


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

- (NSString *)cellIdentifier {
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
        
        [self.tableView reloadData];
        [self checkPointsLocations];
        
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


- (NSArray *)shippedShipments {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isShipped.boolValue == YES"];
    
    NSArray *shipments = [self.resultsController.fetchedObjects valueForKeyPath:@"@distinctUnionOfSets.shipments"];
    shipments = [shipments filteredArrayUsingPredicate:predicate];

    return shipments;
    
}

- (BOOL)haveProcessedShipments {
    return ([self shippedShipments].count > 0);
}

- (NSNumber *)badVolumeSummary {
    
    NSArray *positions = [[self shippedShipments] valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
    NSNumber *volume = [positions valueForKeyPath:@"@sum.badVolume"];
    
    return volume;
    
}

- (NSNumber *)shortageVolumeSummary {

    NSArray *positions = [[self shippedShipments] valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
    NSNumber *volume = [positions valueForKeyPath:@"@sum.shortageVolume"];
    
    return volume;

}

- (NSNumber *)excessVolumeSummary {
    
    NSArray *positions = [[self shippedShipments] valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
    NSNumber *volume = [positions valueForKeyPath:@"@sum.excessVolume"];
    
    return volume;

}

- (NSNumber *)regradeVolumeSummary {

    NSArray *positions = [[self shippedShipments] valueForKeyPath:@"@distinctUnionOfSets.shipmentPositions"];
    NSNumber *volume = [positions valueForKeyPath:@"@sum.regradeVolume"];
    
    return volume;

}

#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.route) ? 2 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return ([self haveProcessedShipments]) ? 2 : 1;
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
            return NSLocalizedString(@"SHIPMENT ROUTE", nil);
            break;
            
        case 1:
//            self.routePointsIndexSet = [NSIndexSet indexSetWithIndex:section];
            return NSLocalizedString(@"SHIPMENT ROUTE POINTS", nil);
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
    return [self heightForCellAtIndexPath:indexPath];
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
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        
        STMCustom7TVCell *customCell = (STMCustom7TVCell *)cell;
        
        switch (indexPath.section) {
            case 0:
                [self fillRouteCell:customCell atIndexPath:indexPath];
                break;
                
            case 1:
                [self fillRoutePointCell:customCell atIndex:indexPath.row];
                break;
                
            default:
                break;
        }
        
    }
    
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillRouteCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:

            cell.titleLabel.text = [STMFunctions dayWithDayOfWeekFromDate:self.route.date];
            cell.detailLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
        break;
            
        case 1:
            cell.titleLabel.text = [self summaryCellTitle];
            cell.detailLabel.text = [self summaryCellDetails];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.summaryIndexPath = indexPath;
            break;
            
        default:
            break;
    }
    
    UIColor *textColor = [UIColor blackColor];

    cell.titleLabel.textColor = textColor;
    cell.detailLabel.textColor = textColor;
    
}

- (NSString *)summaryCellTitle {
    
    NSString *pluralString = [STMFunctions pluralTypeForCount:[self shippedShipments].count];
    NSString *pointsString = NSLocalizedString([pluralString stringByAppendingString:@"SHIPMENTS"], nil);
    
    return [NSString stringWithFormat:@"%@ (%lu %@)", NSLocalizedString(@"SUMMARY CELL TITLE", nil), (unsigned long)[self shippedShipments].count, pointsString];
    
}

- (NSString *)summaryCellDetails {
    
    NSNumber *badVolume = [self badVolumeSummary];
    NSNumber *shortageVolume = [self shortageVolumeSummary];
    NSNumber *excessVolume = [self excessVolumeSummary];
    NSNumber *regradeVolume = [self regradeVolumeSummary];
    
    NSString *volumesString = [[STMShippingProcessController sharedInstance] volumesStringWithDoneVolume:0
                                                                                               badVolume:badVolume.integerValue
                                                                                            excessVolume:excessVolume.integerValue
                                                                                          shortageVolume:shortageVolume.integerValue
                                                                                           regradeVolume:regradeVolume.integerValue
                                                                                              packageRel:0];
    
    return (volumesString) ? [@"\n" stringByAppendingString:volumesString] : @"";
    
}

- (void)fillRoutePointCell:(STMCustom7TVCell *)cell atIndex:(NSUInteger)index {
    
    STMShipmentRoutePoint *point = [self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];

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
        
        if (indexPath.row == 1) {
            
            [self performSegueWithIdentifier:@"showSummary" sender:self];
            
        }
        
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
            
            if (!point.ord || point.ord.integerValue != [self.resultsController.fetchedObjects indexOfObject:point]) {
                point.ord = @([self.resultsController.fetchedObjects indexOfObject:point]);
            }
            
        }
        
//        allRoutesMapVC.points = [self pointsWithLocation];
        allRoutesMapVC.points = self.resultsController.fetchedObjects;
//        allRoutesMapVC.geocodedLocations = self.geocodedLocations.copy;
        allRoutesMapVC.parentVC = self;
        
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
    
    if (self.summaryIndexPath) [self.cachedCellsHeights removeObjectForKey:self.summaryIndexPath];

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
    
    for (STMShipmentRoutePoint *point in result) {
        
        if (point.ord.integerValue != [result indexOfObject:point]) {
            point.ord = @([result indexOfObject:point]);
        }
        
    }

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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ROUTING ERROR", nil)
                                                    message:NSLocalizedString(@"NOT ENOUGH LOCATIONS", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}


#pragma mark - view lifecycle

- (void)customInit {
    
    if ([self.splitVC isDetailNCForViewController:self]) {
        self.title = NSLocalizedString(@"SHIPMENT ROUTE POINTS", nil);
    }
    
    [self setupNavBar];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom7TVCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    [self performFetch];
    
//    [self shipmentsInfo];
    
    [super customInit];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self setupNavBar];
    [self reloadData];
    
    [super viewWillAppear:animated];
    
    if ([self.splitVC isMasterNCForViewController:self]) {
        [self highlightSelectedPoint];
    }

}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (![self.navigationController.viewControllers containsObject:self]) {
        [self.splitVC backButtonPressed];
    }
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
