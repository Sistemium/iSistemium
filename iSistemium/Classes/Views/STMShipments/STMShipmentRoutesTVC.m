//
//  STMShipmentRoutesTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRoutesTVC.h"
#import "STMDataModel.h"
#import "STMNS.h"
#import "STMFunctions.h"

#import "STMShipmentRoutePointsTVC.h"


@interface STMShipmentRoutesTVC ()

@property (nonatomic, strong) NSString *cellIdentifier;


@end


@implementation STMShipmentRoutesTVC

@synthesize resultsController = _resultsController;

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMShipmentRoute class])];
        
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        NSSortDescriptor *idDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO selector:@selector(compare:)];
        
        request.sortDescriptors = @[dateDescriptor, idDescriptor];
        
        request.predicate = [STMPredicate predicateWithNoFantoms];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    STMShipmentRoute *route = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [STMFunctions dayWithDayOfWeekFromDate:route.date];
    
    NSUInteger pointsCount = route.shipmentRoutePoints.count;
    NSString *pluralType = [STMFunctions pluralTypeForCount:pointsCount];
    NSString *localizedString = [NSString stringWithFormat:@"%@SRPOINTS", pluralType];

    NSString *detailText;
    
    if (pointsCount > 0) {
        
        detailText = [NSString stringWithFormat:@"%lu %@", (unsigned long)pointsCount, NSLocalizedString(localizedString, nil)];
        
    } else {
        
        detailText = NSLocalizedString(localizedString, nil);
        
    }

    cell.detailTextLabel.text = detailText;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"showRoutePoints" sender:indexPath];
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showRoutePoints"] &&
        [sender isKindOfClass:[NSIndexPath class]] &&
        [segue.destinationViewController isKindOfClass:[STMShipmentRoutePointsTVC class]]) {
        
        STMShipmentRoute *route = [self.resultsController objectAtIndexPath:(NSIndexPath *)sender];
        [(STMShipmentRoutePointsTVC *)segue.destinationViewController setRoute:route];
        
    }

}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    [self performFetch];
    self.navigationItem.title = NSLocalizedString(@"SHIPMENT ROUTES", nil);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
