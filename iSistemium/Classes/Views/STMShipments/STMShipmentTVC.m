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


@interface STMShipmentTVC () <UIAlertViewDelegate>

@property (nonatomic, strong) NSIndexPath *processedButtonCellIndexPath;


@end


@implementation STMShipmentTVC

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 3;
            break;
            
        case 1:
            return 1;
            break;
            
        case 2:
            return self.resultsController.fetchedObjects.count;
            break;
            
        default:
            return 0;
            break;
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
                [self fillProcessedButtonCell:(STMCustom7TVCell *)cell atIndexPath:indexPath];
                break;
                
            case 2:
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
    
    if ([STMShippingProcessController sharedInstance].state == STMShippingProcessRunning) {
        cell.titleLabel.text = NSLocalizedString(@"SHIPMENT PROCESSED BUTTON STOP TITLE", nil);
    } else {
        cell.titleLabel.text = NSLocalizedString(@"SHIPMENT PROCESSED BUTTON START TITLE", nil);
    }
    
    cell.titleLabel.textColor = ACTIVE_BLUE_COLOR;
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;

    cell.detailLabel.text = (self.point.isReached.boolValue) ? @"" : NSLocalizedString(@"SHOULD CONFIRM ARRIVAL FIRST", nil);
    
    cell.detailLabel.textColor = [UIColor lightGrayColor];
    cell.detailLabel.textAlignment = NSTextAlignmentCenter;
    
    self.processedButtonCellIndexPath = indexPath;
    
}

- (void)fillShipmentPositionCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMShipmentPosition *position = self.resultsController.fetchedObjects[indexPath.row];
    [self fillCell:cell withShipmentPosition:position];
    
}

- (void)fillCell:(STMCustom7TVCell *)cell withShipmentPosition:(STMShipmentPosition *)position {
    
    cell.titleLabel.text = position.article.name;
    
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
    
    //        customCell.infoLabel.text = infoText;
    
    //        volumeUnitString = NSLocalizedString(@"VOLUME UNIT", nil);
    //        customCell.detailLabel.text = [NSString stringWithFormat:@"%@%@", position.article.pieceVolume, volumeUnitString];
    
    cell.detailLabel.text = @"";
    
    STMLabel *infoLabel = [[STMLabel alloc] initWithFrame:CGRectMake(0, 0, 40, 21)];
    infoLabel.text = infoText;
    infoLabel.textAlignment = NSTextAlignmentRight;
    infoLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.accessoryView = infoLabel;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([indexPath isEqual:self.processedButtonCellIndexPath]) {
        
        if (!self.point.isReached.boolValue) {
            
            [self.parentVC showArriveConfirmationAlert];
            
        } else {
            
            if ([STMShippingProcessController sharedInstance].state == STMShippingProcessRunning) {
                [self showShippingStopAlert];
            } else {
                [self showShippingStartAlert];
            }
            
        }
        
    }
    
}


#pragma mark - processed button

- (void)routePointIsReached {
    
    [self reloadProcessedButtonCell];
    [self showShippingStartAlert];
    
}

- (void)showShippingStartAlert {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"START SHIPPING?", nil)
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                          otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
    
    alert.tag = 222;
    [alert show];
    
}

- (void)startShipping {

    [STMShippingProcessController sharedInstance].state = STMShippingProcessRunning;
    [self reloadProcessedButtonCell];
    
}

- (void)showShippingStopAlert {
    
    NSLogMethodName;
    [self stopShipping];
    
}

- (void)stopShipping {

    [STMShippingProcessController sharedInstance].state = STMShippingProcessIdle;
    [self reloadProcessedButtonCell];

}

- (void)reloadProcessedButtonCell {
    
    if (self.processedButtonCellIndexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[self.processedButtonCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    [self.tableView reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
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

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self removeObservers];
    }
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
