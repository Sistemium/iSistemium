//
//  STMShipmentsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRoutePointTVC.h"
#import "STMNS.h"
#import "STMUI.h"
#import "STMFunctions.h"
#import "STMSession.h"

#import "STMShipmentTVC.h"
#import "STMLocationMapVC.h"

#define CELL_IMAGES_SIZE 30
#define THUMB_SIZE CGSizeMake(CELL_IMAGES_SIZE, CELL_IMAGES_SIZE)


@interface STMShipmentRoutePointTVC ()

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) NSString *shippingLocationCellIdentifier;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic, strong) STMDocument *document;
@property (nonatomic, strong) STMSession *session;

@property (nonatomic) BOOL isWaitingLocation;


@end


@implementation STMShipmentRoutePointTVC

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


#pragma mark - resultsController

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


#pragma mark - photos

- (UIView *)blankPicture {
    
    UIImage *image = [[STMFunctions resizeImage:[UIImage imageNamed:@"Picture-32"] toSize:THUMB_SIZE] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tintColor = [UIColor lightGrayColor];
    
    return imageView;
    
}

- (UIView *)addPhotoButton {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[STMFunctions resizeImage:[UIImage imageNamed:@"plus"] toSize:THUMB_SIZE]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPhotoButtonPressed)];
    imageView.gestureRecognizers = @[tap];
    imageView.userInteractionEnabled = YES;
    
    return imageView;
    
}

- (void)addPhotoButtonPressed {
    
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
            return (self.point.shippingLocation) ? 2 : 1;
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
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:self.shippingLocationCellIdentifier forIndexPath:indexPath];
                    [self fillCell:cell withShippingLocation:self.point.shippingLocation];
                    break;
                    
                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
                    [self fillCell:cell withPhotos:self.point.shippingLocation.shippingLocationPictures];
                    break;
                    
                default:
                    break;
            }
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
        customCell.titleLabel.text = @"";
        customCell.titleLabel.textColor = [UIColor blackColor];
        customCell.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        customCell.detailLabel.text = @"";
        customCell.detailLabel.textAlignment = NSTextAlignmentCenter;
        
        [[customCell viewWithTag:666] removeFromSuperview];
        
        if (self.isWaitingLocation) {
            
            STMSpinnerView *spinner = [STMSpinnerView spinnerViewWithFrame:customCell.contentView.bounds];
            spinner.tag = 666;
            
            [customCell.contentView addSubview:spinner];
            
        } else {
        
            if (!location) {
                
                customCell.titleLabel.text = NSLocalizedString(@"SET LOCATION", nil);
                
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
    
}

- (void)fillCell:(UITableViewCell *)cell withPhotos:(NSSet *)photos {
    
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    [[cell.contentView viewWithTag:555] removeFromSuperview];
    [[cell.contentView viewWithTag:666] removeFromSuperview];

    UIView *blankPicture = [self blankPicture];
    UIView *addPhotoButton = [self addPhotoButton];
    
    CGFloat x = ceil((cell.contentView.frame.size.width - CELL_IMAGES_SIZE) / 2);
    CGFloat y = ceil((cell.contentView.frame.size.height - CELL_IMAGES_SIZE) / 2);
    CGFloat padding = 6;

    blankPicture.frame = CGRectMake(x - padding - CELL_IMAGES_SIZE, y, CELL_IMAGES_SIZE, CELL_IMAGES_SIZE);
    blankPicture.tag = 666;
    
    addPhotoButton.frame = CGRectMake(x, y, CELL_IMAGES_SIZE, CELL_IMAGES_SIZE);
    addPhotoButton.tag = 555;
    
    [cell.contentView addSubview:blankPicture];
    [cell.contentView addSubview:addPhotoButton];
    
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
        
        switch (indexPath.row) {
            case 0:
                if (self.point.shippingLocation) {
                    
                    [self performSegueWithIdentifier:@"showShippingLocationMap" sender:self.point.shippingLocation];
                    
                } else if (!self.isWaitingLocation) {
                    
                    self.isWaitingLocation = YES;
                    [self.session.locationTracker getLocation];
                    
                }

                break;
                
            default:
                break;
        }
        
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
        [segue.destinationViewController isKindOfClass:[STMShipmentTVC class]]) {
        
        STMShipment *shipment = self.resultsController.fetchedObjects[[(NSIndexPath *)sender row]];
        [(STMShipmentTVC *)segue.destinationViewController setShipment:shipment];
        [(STMShipmentTVC *)segue.destinationViewController setPoint:self.point];
        
    } else if ([segue.identifier isEqualToString:@"showShippingLocationMap"] &&
               [segue.destinationViewController isKindOfClass:[STMLocationMapVC class]]) {
        
        [(STMLocationMapVC *)segue.destinationViewController setLocation:self.point.shippingLocation];
        
    }
    
}


#pragma mark - notifications

- (void)currentAccuracyUpdated:(NSNotification *)notification {
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    
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
