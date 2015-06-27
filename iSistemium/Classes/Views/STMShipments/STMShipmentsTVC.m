//
//  STMShipmentsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentsTVC.h"
#import "STMNS.h"
#import "STMUI.h"
#import "STMFunctions.h"
#import "STMSession.h"

#import "STMShipmentPositionsTVC.h"


@interface STMShipmentsTVC ()

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) NSString *shippingLocationCellIdentifier;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) STMDocument *document;
@property (nonatomic, strong) STMSession *session;

@property (nonatomic) BOOL isWaitingLocation;


@end


@implementation STMShipmentsTVC

- (STMSession *)session {
    
    if (!_session) {
        _session = [STMSessionManager sharedManager].currentSession;
    }
    return _session;
    
}

- (STMDocument *)document {
    
    if (!_document) {
        _document = self.session.document;
    }
    return _document;
    
}



- (NSString *)cellIdentifier {
    return @"shipmentCell";
}

- (NSString *)shippingLocationCellIdentifier {
    return @"shippingLocationCell";
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMShipment class])];
        
        NSSortDescriptor *ndocDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ndoc" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[ndocDescriptor];
        
        if (self.point) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ IN shipmentRoutePoints", self.point];
            request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:predicate];

        }
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
//        _resultsController.delegate = self;
        
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
            return 2;
            break;
            
        case 1:
            return 1;
            break;
            
        case 2:
            return self.resultsController.fetchedObjects.count;

        default:
            return 0;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return NSLocalizedString(@"SHIPMENT ROUTE POINT", nil);
            break;
            
        case 2:
            return NSLocalizedString(@"SHIPMENTS", nil);
            break;
            
        default:
            return nil;
            break;
    }
    
}

- (CGFloat)estimatedHeightForRow {
    
    static CGFloat standardCellHeight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        standardCellHeight = [[UITableViewCell alloc] init].frame.size.height;
    });
    
    return standardCellHeight + 1.0f;  // Add 1.0f for the cell separator height

}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self estimatedHeightForRow];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 1:
                    return [self heightForRoutePointCell];
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
    return [self tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    
}

- (CGFloat)heightForRoutePointCell {
    
    CGFloat diff = [self heightDiffForText:self.point.name];
    
    CGFloat height = [self estimatedHeightForRow] + diff;
    
    return height;

}

- (CGFloat)heightDiffForText:(NSString *)text {
    
    static UITableViewCell *standardCell;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        standardCell = [[UITableViewCell alloc] init];
    });
    
    UIFont *font = standardCell.textLabel.font;
    
    NSDictionary *attributes = @{NSFontAttributeName:font};
    
    CGSize lineSize = [text sizeWithAttributes:attributes];
    CGSize boundSize = CGSizeMake(CGRectGetWidth(self.tableView.bounds) - MAGIC_NUMBER_FOR_CELL_WIDTH, CGFLOAT_MAX);
    CGRect multilineRect = [text boundingRectWithSize:boundSize
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
    
    CGFloat diff = ceil(multilineRect.size.height) - ceil(lineSize.height);

    return diff;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
                    [self fillCell:cell withRoute:self.point.shipmentRoute];
                    break;
                    
                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
                    [self fillCell:cell withRoutePoint:self.point];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:self.shippingLocationCellIdentifier forIndexPath:indexPath];
            [self fillCell:cell withShippingLocation:self.point.shippingLocation];
            break;

        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
            [self fillCell:cell withShipment:self.resultsController.fetchedObjects[indexPath.row]];
            break;

        default:
            break;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell withRoute:(STMShipmentRoute *)route {
    
    cell.textLabel.text = [STMFunctions dayWithDayOfWeekFromDate:route.date];
    cell.detailTextLabel.text = @"";

}

- (void)fillCell:(UITableViewCell *)cell withRoutePoint:(STMShipmentRoutePoint *)point {

    cell.textLabel.text = point.name;
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = @"";

}

- (void)fillCell:(UITableViewCell *)cell withShippingLocation:(STMShippingLocation *)location {

    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        
        STMCustom7TVCell *customCell = (STMCustom7TVCell *)cell;
    
        customCell.titleLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
        customCell.titleLabel.textColor = [UIColor blackColor];
        customCell.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        customCell.detailLabel.text = @"";
        customCell.detailLabel.textAlignment = NSTextAlignmentCenter;
        
        if (!location) {
            
            customCell.titleLabel.text = NSLocalizedString(@"GET LOCATION", nil);
            
            if (self.session.locationTracker.isAccuracySufficient) {
                
                customCell.titleLabel.textColor = ACTIVE_BLUE_COLOR;
                
            } else {
                
                customCell.titleLabel.textColor = [UIColor lightGrayColor];
                customCell.detailLabel.text = NSLocalizedString(@"ACCURACY IS NOT SUFFICIENT", nil);
                
            }
            
        } else {
            
            customCell.titleLabel.text = NSLocalizedString(@"SHOW MAP", nil);
            
        }

    }
    
}

- (void)fillCell:(UITableViewCell *)cell withShipment:(STMShipment *)shipment {
    
    cell.textLabel.text = shipment.ndoc;
    
    NSUInteger positionsCount = shipment.shipmentPositions.count;
    NSString *pluralType = [STMFunctions pluralTypeForCount:positionsCount];
    NSString *localizedString = [NSString stringWithFormat:@"%@POSITIONS", pluralType];
    
    NSString *detailText;
    
    if (positionsCount > 0) {
        
        detailText = [NSString stringWithFormat:@"%lu %@", (unsigned long)positionsCount, NSLocalizedString(localizedString, nil)];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else {
        
        detailText = NSLocalizedString(localizedString, nil);
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    cell.detailTextLabel.text = detailText;

    if ([shipment.needCashing boolValue]) {
        
        cell.imageView.image = [STMFunctions resizeImage:[UIImage imageNamed:@"banknotes-128"] toSize:CGSizeMake(30, 30)];
        
    } else {
        cell.imageView.image = nil;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1 && !self.isWaitingLocation) {
        
        self.isWaitingLocation = YES;
        [self.session.locationTracker getLocation];
        
    }
    
    if (indexPath.section == 2) {
        
        STMShipment *shipment = self.resultsController.fetchedObjects[indexPath.row];
        
        if (shipment.shipmentPositions.count > 0) {
            [self performSegueWithIdentifier:@"showShipmentPositions" sender:indexPath];
        }

    }
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showShipmentPositions"] &&
        [sender isKindOfClass:[NSIndexPath class]] &&
        [segue.destinationViewController isKindOfClass:[STMShipmentPositionsTVC class]]) {
        
        STMShipment *shipment = self.resultsController.fetchedObjects[[(NSIndexPath *)sender row]];
        [(STMShipmentPositionsTVC *)segue.destinationViewController setShipment:shipment];
        
    }
    
}


#pragma mark - notifications

- (void)currentAccuracyUpdated:(NSNotification *)notification {
    
}

- (void)currentLocationWasUpdated:(NSNotification *)notification {
    
    if (self.isWaitingLocation) {
        
        CLLocation *currentLocation = notification.userInfo[@"currentLocation"];
        
        STMShippingLocation *location = [STMEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMShippingLocation class]) inManagedObjectContext:self.document.managedObjectContext];
        
        location.latitude = @(currentLocation.coordinate.latitude);
        location.longitude = @(currentLocation.coordinate.longitude);
        
        self.point.shippingLocation = location;
        
        [self.document saveDocument:^(BOOL success) {
            [self.tableView reloadData];
        }];
        
        self.isWaitingLocation = NO;
        
    }
    
}

#pragma mark - view lifecycle

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(currentAccuracyUpdated:) name:@"currentAccuracyUpdated" object:self.session.locationTracker];
    [nc addObserver:self selector:@selector(currentLocationWasUpdated:) name:@"currentLocationWasUpdated" object:self.session.locationTracker];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"currentLocationWasUpdated" object:self userInfo:@{@"currentLocation":self.lastLocation}];

}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom7TVCell" bundle:nil] forCellReuseIdentifier:self.shippingLocationCellIdentifier];
//    [self.tableView registerClass:[STMCustom7TVCell class] forCellReuseIdentifier:self.shippingLocationCellIdentifier];
    
    [self addObservers];
    [self performFetch];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
