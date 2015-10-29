//
//  STMShipmentRoutesTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMDriverTVC.h"
#import "STMNS.h"
#import "STMFunctions.h"

#import "STMShipmentRouteTVC.h"

#import "STMShipmentRouteController.h"
#import "STMWorkflowController.h"


@interface STMDriverTVC ()

@property (nonatomic, strong) STMShipmentsSVC *splitVC;
@property (nonatomic, strong) NSString *shipmentRoutesWorkflow;

@end


@implementation STMDriverTVC

@synthesize resultsController = _resultsController;

- (STMShipmentsSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMShipmentsSVC class]]) {
            _splitVC = (STMShipmentsSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (NSString *)shipmentRoutesWorkflow {
    
    if (!_shipmentRoutesWorkflow) {
        _shipmentRoutesWorkflow = [STMWorkflowController workflowForEntityName:NSStringFromClass([STMShipmentRoute class])];
    }
    return _shipmentRoutesWorkflow;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {

        _resultsController = [STMShipmentRouteController sharedInstance].resultsController;
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (void)performFetch {
    
    self.resultsController = nil;
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
    }
    
}

- (NSString *)cellIdentifier {
    return @"shipmentRouteCell";
}


#pragma mark - table view data

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"SHIPMENT ROUTES", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    STMShipmentRoute *route = [self.resultsController objectAtIndexPath:indexPath];
    
    [self fillCell:cell withRoute:route];
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell withRoute:(STMShipmentRoute *)route {
    
    cell.textLabel.text = [STMFunctions dayWithDayOfWeekFromDate:route.date];
    
    NSUInteger pointsCount = route.shipmentRoutePoints.count;
    NSString *pluralType = [STMFunctions pluralTypeForCount:pointsCount];
    NSString *localizedString = [NSString stringWithFormat:@"%@SRPOINTS", pluralType];
    
    NSString *detailText;
    
    if (pointsCount > 0) {
        
        detailText = [NSString stringWithFormat:@"%lu %@", (unsigned long)pointsCount, NSLocalizedString(localizedString, nil)];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else {
        
        detailText = NSLocalizedString(localizedString, nil);
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    detailText = [route planSummary];
    
    if (!self.driver && route.driver.name) {
        detailText = [detailText stringByAppendingString:[NSString stringWithFormat:@", %@", route.driver.name]];
    }
    
    cell.detailTextLabel.text = detailText;
    
    UIColor *processingColor = [STMWorkflowController colorForProcessing:route.processing inWorkflow:self.shipmentRoutesWorkflow];
    
    cell.textLabel.textColor = processingColor;
    cell.detailTextLabel.textColor = processingColor;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMShipmentRoute *route = [self.resultsController objectAtIndexPath:indexPath];

    if (route.shipmentRoutePoints.count > 0) {
        
        if (IPHONE) {
            
            [self performSegueWithIdentifier:@"showRoutePoints" sender:indexPath];
            
        } else if (IPAD) {
            
            self.splitVC.selectedRoute = route;
            
        }
        
    }
    
}

- (void)showRoutePoints {
    [self performSegueWithIdentifier:@"showRoutePoints" sender:self.splitVC];
}

- (void)highlightSelectedRoute {
    
    NSIndexPath *indexPath = [self.resultsController indexPathForObject:self.splitVC.selectedRoute];
    
    if (indexPath) {
        
        UITableViewScrollPosition scrollPosition = ([[self.tableView indexPathsForVisibleRows] containsObject:indexPath]) ? UITableViewScrollPositionNone : UITableViewScrollPositionTop;
        
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:scrollPosition];
        
    }
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showRoutePoints"] &&
        [segue.destinationViewController isKindOfClass:[STMShipmentRouteTVC class]]) {

        STMShipmentRouteTVC *routeTVC = (STMShipmentRouteTVC *)segue.destinationViewController;
        
        if ([sender isKindOfClass:[NSIndexPath class]]) {
            
            STMShipmentRoute *route = [self.resultsController objectAtIndexPath:(NSIndexPath *)sender];
            routeTVC.route = route;

        } else if ([sender isEqual:self.splitVC]) {

            routeTVC.route = self.splitVC.selectedRoute;
            
        }
        
    }

}


#pragma mark - observers

- (void)syncerGetBunchOfObjects:(NSNotification *)notification {
    
    if ([notification.userInfo[@"entityName"] isEqualToString:NSStringFromClass([STMEntity class])]) {
        self.shipmentRoutesWorkflow = nil;
    }

}

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(syncerGetBunchOfObjects:)
               name:NOTIFICATION_SYNCER_GET_BUNCH_OF_OBJECTS
             object:[(STMSession *)[STMSessionManager sharedManager].currentSession syncer]];
    
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    [self addObservers];
    [self performFetch];
    self.navigationItem.title = NSLocalizedString(@"SHIPMENT ROUTES", nil);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([self.splitVC isMasterNCForViewController:self]) [self highlightSelectedRoute];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
