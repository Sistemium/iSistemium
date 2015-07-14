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


@interface STMShipmentRouteTVC ()

@property (nonatomic, strong) NSIndexSet *routePointsIndexSet;


@end


@implementation STMShipmentRouteTVC

@synthesize resultsController = _resultsController;


- (NSString *)cellIdentifier {
    return @"routePointCell";
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMShipmentRoutePoint class])];
        
        NSSortDescriptor *ordDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord" ascending:NO selector:@selector(compare:)];
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[ordDescriptor, nameDescriptor];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shipmentRoute == %@", self.route];
        
        request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:predicate];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
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


#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
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
            self.routePointsIndexSet = [NSIndexSet indexSetWithIndex:section];
            return NSLocalizedString(@"SHIPMENT ROUTE POINTS", nil);
            break;
            
        default:
            return nil;
            break;
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
                [self fillRouteCell:customCell atIndex:indexPath.row];
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

- (void)fillRouteCell:(STMCustom7TVCell *)cell atIndex:(NSUInteger)index {
    
    switch (index) {
        case 0:
            cell.titleLabel.text = [STMFunctions dayWithDayOfWeekFromDate:self.route.date];
            cell.detailLabel.text = @"";
            break;
            
        default:
            break;
    }
    
}

- (void)fillRoutePointCell:(STMCustom7TVCell *)cell atIndex:(NSUInteger)index {
    
    STMShipmentRoutePoint *point = [self.resultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];

    cell.titleLabel.text = point.name;

    UIColor *titleColor = [UIColor blackColor];
    
    if (point.isReached.boolValue) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isProcessed.boolValue != YES"];
        NSUInteger unprocessedShipmentsCount = [point.shipments filteredSetUsingPredicate:predicate].count;
        
        titleColor = (unprocessedShipmentsCount > 0) ? [UIColor redColor] : [UIColor lightGrayColor];

    }
    
    cell.titleLabel.textColor = titleColor;
    
    NSUInteger shipmentsCount = point.shipments.count;
    NSString *pluralType = [STMFunctions pluralTypeForCount:shipmentsCount];
    NSString *localizedString = [NSString stringWithFormat:@"%@SHIPMENTS", pluralType];
    
    NSString *detailText;
    
    if (shipmentsCount > 0) {
        
        detailText = [NSString stringWithFormat:@"%lu %@", (unsigned long)shipmentsCount, NSLocalizedString(localizedString, nil)];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else {
        
        detailText = NSLocalizedString(localizedString, nil);
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"needCashing == YES"];
    NSUInteger needCashingCount = [point.shipments filteredSetUsingPredicate:predicate].count;
    
    if (needCashingCount > 0) {
        
        pluralType = [STMFunctions pluralTypeForCount:needCashingCount];
        localizedString = [NSString stringWithFormat:@"%@NEED CASHING", pluralType];

        detailText = [detailText stringByAppendingString:[NSString stringWithFormat:@", %lu %@", (unsigned long)needCashingCount, NSLocalizedString(localizedString, nil)]];
        
    }
    
    cell.detailLabel.text = detailText;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
        
        STMShipmentRoutePoint *point = [self.resultsController objectAtIndexPath:indexPath];
        
        if (point.shipments.count > 0) {
            
            [self performSegueWithIdentifier:@"showShipments" sender:indexPath];
            
        }

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
    [self.tableView reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
}


#pragma mark - Navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showShipments"] &&
        [sender isKindOfClass:[NSIndexPath class]] &&
        [segue.destinationViewController isKindOfClass:[STMShipmentRoutePointTVC class]]) {
        
        STMShipmentRoutePoint *point = [self.resultsController objectAtIndexPath:(NSIndexPath *)sender];
        [(STMShipmentRoutePointTVC *)segue.destinationViewController setPoint:point];
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom7TVCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    [self performFetch];
    
    [super customInit];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (self.routePointsIndexSet) {
        [self.tableView reloadSections:self.routePointsIndexSet withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
