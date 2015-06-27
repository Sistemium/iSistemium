//
//  STMShipmentsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentsTVC.h"
#import "STMNS.h"
#import "STMFunctions.h"
#import "STMSession.h"

#import "STMShipmentPositionsTVC.h"


@interface STMShipmentsTVC ()

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) STMDocument *document;
@property (nonatomic, strong) STMSession *session;

@end


@interface STMShippingLocationTVCell : UITableViewCell

@end

@implementation STMShippingLocationTVCell

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
// center alignment
    self.textLabel.frame = CGRectMake(0, self.textLabel.frame.origin.y, self.frame.size.width, self.textLabel.frame.size.height);
    self.detailTextLabel.frame = CGRectMake(0, self.detailTextLabel.frame.origin.y, self.frame.size.width, self.detailTextLabel.frame.size.height);
    
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    
}


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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 3;
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
            return NSLocalizedString(@"SHIPMENT ROUTE POINT", nil);
            break;
            
        case 1:
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];

    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [self fillCell:cell withRoute:self.point.shipmentRoute];
                    break;
                    
                case 1:
                    [self fillCell:cell withRoutePoint:self.point];
                    break;
                    
                case 2:
                    [self fillCell:cell withShippingLocation:self.point.shippingLocation];
                    break;
                    
                default:
                    break;
            }
            break;

        case 1:
            [self fillCell:cell withShipment:self.resultsController.fetchedObjects[indexPath.row]];
            break;

        default:
            break;
    }

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

    cell = [[STMShippingLocationTVCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"shippingLocationCell"];
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
    cell.textLabel.textColor = [UIColor blackColor];

    cell.detailTextLabel.text = @"";

    if (!location) {
        
        cell.textLabel.text = NSLocalizedString(@"GET LOCATION", nil);
        
        if (self.session.locationTracker.isAccuracySufficient) {
            
            cell.textLabel.textColor = ACTIVE_BLUE_COLOR;
            
        } else {

            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.detailTextLabel.text = NSLocalizedString(@"ACCURACY IS NOT SUFFICIENT", nil);

        }
        
    } else {
        
        cell.textLabel.text = NSLocalizedString(@"SHOW MAP", nil);
        
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
    
    if (indexPath.section == 1) {
        
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

#pragma mark - view lifecycle

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(currentAccuracyUpdated:) name:@"currentAccuracyUpdated" object:self.session.locationTracker];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {

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
