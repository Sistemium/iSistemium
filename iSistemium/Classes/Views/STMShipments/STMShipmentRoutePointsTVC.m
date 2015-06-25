//
//  STMShipmentRoutePointsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRoutePointsTVC.h"
#import "STMNS.h"
#import "STMUI.h"
#import "STMFunctions.h"

#import "STMShipmentsTVC.h"


@interface STMShipmentRoutePointsTVC ()

@end


@implementation STMShipmentRoutePointsTVC

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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"SHIPMENT ROUTE POINTS", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom7TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        
        STMCustom7TVCell *customCell = (STMCustom7TVCell *)cell;
        
        STMShipmentRoutePoint *point = [self.resultsController objectAtIndexPath:indexPath];
        
        customCell.titleLabel.text = point.name;

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
        
        customCell.detailLabel.text = detailText;
        
    }
    
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMShipmentRoutePoint *point = [self.resultsController objectAtIndexPath:indexPath];

    if (point.shipments.count > 0) {
        
        [self performSegueWithIdentifier:@"showShipments" sender:indexPath];
        
    }
    
}


#pragma mark - Navigation
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showShipments"] &&
        [sender isKindOfClass:[NSIndexPath class]] &&
        [segue.destinationViewController isKindOfClass:[STMShipmentsTVC class]]) {
        
        STMShipmentRoutePoint *point = [self.resultsController objectAtIndexPath:(NSIndexPath *)sender];
        [(STMShipmentsTVC *)segue.destinationViewController setPoint:point];
        
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
