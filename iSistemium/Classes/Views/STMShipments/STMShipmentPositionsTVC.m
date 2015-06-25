//
//  STMShipmentPositionsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentPositionsTVC.h"
#import "STMNS.h"
#import "STMUI.h"


@interface STMShipmentPositionsTVC ()

@end


@implementation STMShipmentPositionsTVC

@synthesize resultsController = _resultsController;

- (NSString *)cellIdentifier {
    return @"shipmentPositionCell";
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMShipmentPosition class])];
        
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[nameDescriptor];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"shipment == %@", self.shipment];
        
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom5TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom5TVCell class]]) {
        
        STMCustom5TVCell *customCell = (STMCustom5TVCell *)cell;
        
        STMShipmentPosition *position = [self.resultsController objectAtIndexPath:indexPath];
        
        customCell.titleLabel.text = position.article.name;
        
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

        customCell.infoLabel.text = infoText;
        
//        volumeUnitString = NSLocalizedString(@"VOLUME UNIT", nil);
//        customCell.detailLabel.text = [NSString stringWithFormat:@"%@%@", position.article.pieceVolume, volumeUnitString];
     
        customCell.detailLabel.text = @"";
        
    }
    
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    STMShipmentRoutePoint *point = [self.resultsController objectAtIndexPath:indexPath];
//    
//    if (point.shipments.count > 0) {
//        
//        [self performSegueWithIdentifier:@"showShipments" sender:indexPath];
//        
//    }
    
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


#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"SHIPMENT", nil), self.shipment.ndoc];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom5TVCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
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
