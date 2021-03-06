//
//  STMShipmentsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMShipmentRoutePointTVC.h"
#import "STMNS.h"
#import "STMFunctions.h"
#import "STMSession.h"
#import "STMPicturesController.h"
#import "STMLocationController.h"
#import "STMObjectsController.h"

#import "STMShipmentTVC.h"
#import "STMShippingLocationMapVC.h"
#import "STMShippingLocationPicturesPVC.h"
#import "STMRouteMapVC.h"
#import "STMShippingVC.h"

#import "STMShippingProcessController.h"


#define CELL_IMAGES_SIZE 54
#define ORD_PICKER_CELL_HEIGHT 88
#define THUMB_SIZE CGSizeMake(CELL_IMAGES_SIZE, CELL_IMAGES_SIZE)
#define IMAGE_PADDING 6
#define LIMIT_COUNT 4

@interface STMShipmentRoutePointTVC () <UINavigationControllerDelegate,
                                        UIImagePickerControllerDelegate,
                                        UIAlertViewDelegate,
                                        UIActionSheetDelegate,
                                        NSFetchedResultsControllerDelegate,
                                        UIPickerViewDataSource,
                                        UIPickerViewDelegate>

@property (nonatomic, strong) STMShipmentsSVC *splitVC;

@property (nonatomic, strong) NSString *shippingLocationCellIdentifier;
@property (nonatomic, strong) NSString *arrivalButtonCellIdentifier;

@property (nonatomic, strong) NSIndexPath *arrivalButtonCellIndexPath;

@property (nonatomic, strong) STMSession *session;

@property (nonatomic) BOOL isWaitingLocation;

@property (nonatomic, strong) UIView *cameraOverlayView;
@property (nonatomic, strong) STMImagePickerController *imagePickerController;
@property (nonatomic) UIImagePickerControllerSourceType selectedSourceType;

@property (nonatomic, strong) NSString *currentPhotoType;

@property (nonatomic ,strong) STMSpinnerView *spinner;

@property (nonatomic, strong) UIView *picturesView;

@property (nonatomic, strong) STMShipmentTVC *shipmentTVC;

@property (nonatomic, strong) NSIndexPath *pointNumberCellIndexPath;
@property (nonatomic, strong) NSIndexPath *ordPickerCellIndexPath;
@property (nonatomic, strong) UIPickerView *ordPicker;
@property (nonatomic, strong) UIToolbar *pickerToolbar;
@property (nonatomic) UIEdgeInsets originSeparatorInset;

@property (nonatomic) BOOL showOrdPicker;

@end


@implementation STMShipmentRoutePointTVC

@synthesize resultsController = _resultsController;

- (STMShipmentsSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMShipmentsSVC class]]) {
            _splitVC = (STMShipmentsSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (STMSession *)session {
    
    if (!_session) {
        _session = [STMSessionManager sharedManager].currentSession;
    }
    return _session;
    
}

- (UIPickerView *)ordPicker {
    
    if (!_ordPicker) {
        
        CGRect pickerFrame = CGRectMake(0, 0, self.view.frame.size.width, 162); // UIPicker height may be 162, 180 and 216 only
        
        _ordPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
        
        _ordPicker.dataSource = self;
        _ordPicker.delegate = self;
            
    }
    return _ordPicker;
    
}

- (UIToolbar *)pickerToolbar {
    
    if (!_pickerToolbar) {

        CGRect toolbarFrame = CGRectMake(0, 0, self.view.frame.size.width, TOOLBAR_HEIGHT);

        _pickerToolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];

        STMBarButtonItemCancel *cancelButton = [[STMBarButtonItemCancel alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                    target:self
                                                                                                    action:@selector(pickerCancel)];
        STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];

        STMBarButtonItemDone *doneButton = [[STMBarButtonItemDone alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                              target:self
                                                                                              action:@selector(pickerDone)];
        [_pickerToolbar setItems:@[cancelButton, flexibleSpace, doneButton]];

        _pickerToolbar.backgroundColor = [UIColor whiteColor];
        _pickerToolbar.tintColor = [UIColor whiteColor];
        _pickerToolbar.barTintColor = [UIColor whiteColor];
        
    }
    return _pickerToolbar;

}

- (void)setPoint:(STMShipmentRoutePoint *)point {
    
    if (![_point isEqual:point]) {
        
        _point = point;
        [self performFetch];
        [self setupNavBar];

    }
    
}


- (NSString *)cellIdentifier {
    return @"shipmentCell";
}

- (NSString *)shippingLocationCellIdentifier {
    return @"shippingLocationCell";
}

- (NSString *)arrivalButtonCellIdentifier {
    return @"arrivalButtonCell";
}

- (NSString *)picturesViewCellIdentifier {
    return @"picturesViewCell";
}

- (NSSet *)unprocessedShipments {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isShipped.boolValue != YES"];
    NSSet *unprocessedShipments = [self.point.shipments filteredSetUsingPredicate:predicate];
    
    return unprocessedShipments;
    
}

- (NSUInteger)unprocessedShipmentsCount {
    
    NSUInteger unprocessedShipmentsCount = [self unprocessedShipments].count;
    return unprocessedShipmentsCount;
    
}

- (BOOL)enableAggregateShipment {
    
    NSDictionary *appSettings = [self.session.settingsController currentSettingsForGroup:@"appSettings"];
    
    return [appSettings[@"enableAggregateShipment"] boolValue];
    
}

- (UIView *)downloadPlaceholder {
    
    UIImage *image = [[STMFunctions resizeImage:[UIImage imageNamed:@"Download-100.png"] toSize:THUMB_SIZE] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tintColor = [UIColor grayColor];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoButtonPressed:)];
    imageView.gestureRecognizers = @[tap];
    imageView.userInteractionEnabled = YES;

    return imageView;
    
}

- (NSSet *)currentPhotos {
    
    NSSet *pointPhotos = self.point.photos ? self.point.photos : [NSSet set];
    NSSet *photos = [self.point.shippingLocation.shippingLocationPictures setByAddingObjectsFromSet:pointPhotos];

    return photos;
    
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
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
        
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
        [self.tableView reloadData];
    }
    
}


#pragma mark - photos

- (UIView *)blankPicture {
    
    UIImage *image = [[STMFunctions resizeImage:[UIImage imageNamed:@"Picture-100"] toSize:THUMB_SIZE] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
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

- (UIView *)pictureButtonWithPicture:(STMPicture *)picture {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:(NSData * _Nonnull)picture.imageThumbnail]];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoButtonPressed:)];
    imageView.gestureRecognizers = @[tap];
    imageView.userInteractionEnabled = YES;

    return imageView;
    
}

- (void)addPhotoButtonPressed {
    [self showSelectPhotoTypeActionSheet];
}

- (void)photoButtonPressed:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        
        UIView *tappedView = [(UITapGestureRecognizer *)sender view];
        [self performSegueWithIdentifier:@"showPhotos" sender:tappedView];

    }
    
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)imageSourceType {
    
    if ([UIImagePickerController isSourceTypeAvailable:imageSourceType]) {
        
        self.selectedSourceType = imageSourceType;
        
        [self presentViewController:self.imagePickerController animated:YES completion:^{
            
//            [self.splitViewController.view addSubview:self.spinnerView];
//                        NSLog(@"presentViewController:UIImagePickerController");
            
        }];
        
    }
    
}

- (STMImagePickerController *)imagePickerController {
    
    if (!_imagePickerController) {
        
//        _imagePickerController = [STMImagePickerController pickerControllerWithCameraOverlayView:self.cameraOverlayView
//                                                                                        delegate:self
//                                                                                      sourceType:self.selectedSourceType];

        STMImagePickerController *imagePickerController = [[STMImagePickerController alloc] init];
        imagePickerController.delegate = self;
        
        imagePickerController.sourceType = self.selectedSourceType;
        
        if (imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            imagePickerController.showsCameraControls = NO;
            
            [[NSBundle mainBundle] loadNibNamed:@"STMCameraOverlayView" owner:self options:nil];

            [imagePickerController setFrameForCameraOverlayView:self.cameraOverlayView];
            
            imagePickerController.cameraOverlayView = self.cameraOverlayView;
            
        }
        
        _imagePickerController = imagePickerController;
        
    }
    return _imagePickerController;
    
}

- (void)saveImage:(UIImage *)image {
    
    if (!self.currentPhotoType) return;
    
    STMPhoto *photo = (STMPhoto *)[STMObjectsController newObjectForEntityName:self.currentPhotoType
                                                                      isFantom:NO];

    CGFloat jpgQuality = [STMPicturesController jpgQuality];
    
    [STMPicturesController setImagesFromData:UIImageJPEGRepresentation(image, jpgQuality)
                                  forPicture:photo
                                   andUpload:YES];

    if ([self.currentPhotoType isEqualToString:NSStringFromClass([STMShippingLocationPicture class])] &&
        [photo respondsToSelector:@selector(shippingLocation)]) {
        
        [photo setValue:self.point.shippingLocation forKey:@"shippingLocation"];
        
    }

    if ([self.currentPhotoType isEqualToString:NSStringFromClass([STMShipmentRoutePointPhoto class])] &&
        [photo respondsToSelector:@selector(shipmentRoutePoint)]) {
        
        [photo setValue:self.point forKey:@"shipmentRoutePoint"];
        
    }
    
    [[self document] saveDocument:^(BOOL success) {
        
        if (success) {
        
            [self.spinner removeFromSuperview];
            [self.tableView reloadData];
            
        }
        
    }];
    
}

- (void)photoWasDeleted:(STMShippingLocationPicture *)photo {
    [self.tableView reloadData];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    //    NSLog(@"picker didFinishPickingMediaWithInfo");
    
    [picker dismissViewControllerAnimated:NO completion:^{
        
        [self saveImage:info[UIImagePickerControllerOriginalImage]];
        self.imagePickerController = nil;
        //        NSLog(@"dismiss UIImagePickerController");
        
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:NO completion:^{
        
    }];
    
//    [self.spinnerView removeFromSuperview];
    self.imagePickerController = nil;
    
}


#pragma mark - camera buttons

- (IBAction)cameraButtonPressed:(id)sender {
    
    //    NSLog(@"cameraButtonPressed");
    
    self.spinner = [STMSpinnerView spinnerViewWithFrame:self.view.bounds];
    [self.view addSubview:self.spinner];

    [self.imagePickerController.cameraOverlayView addSubview:[STMSpinnerView spinnerViewWithFrame:self.imagePickerController.cameraOverlayView.bounds]];

    [self.imagePickerController takePicture];
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    //    NSLog(@"cancelButtonPressed");
    
    [self imagePickerControllerDidCancel:self.imagePickerController];
    
}

- (IBAction)photoLibraryButtonPressed:(id)sender {
    
    [self cancelButtonPressed:sender];
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
}


#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return ([self.splitVC isMasterNCForViewController:self]) ? 0 : (IPHONE) ? 3 : 2;
            break;
            
        case 1:
            return ([self.splitVC isMasterNCForViewController:self]) ? 0 : (self.point.isReached.boolValue && [self unprocessedShipmentsCount] > 0 && [self enableAggregateShipment]) ? 2 : 1;
            break;
            
        case 2:
            return ([self.splitVC isMasterNCForViewController:self]) ? 0 : (self.point.shippingLocation.location) ? 2 : 1;
            break;
            
        case 3:
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
            return ([self.splitVC isMasterNCForViewController:self]) ? nil : NSLocalizedString(@"SHIPMENT ROUTE POINT", nil);
            break;
            
        case 3:
            return NSLocalizedString(@"SHIPMENTS", nil);
            break;
            
        default:
            return nil;
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return ([self.splitVC isMasterNCForViewController:self]) ? CGFLOAT_MIN : SINGLE_LINE_HEADER_HEIGHT;
            break;
            
        case 3:
            return SINGLE_LINE_HEADER_HEIGHT;
            break;
            
        default:
            return ([self.splitVC isMasterNCForViewController:self]) ? CGFLOAT_MIN : 0;
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return ([self.splitVC isMasterNCForViewController:self]) ? CGFLOAT_MIN : 0;
}


- (CGFloat)estimatedHeightForRow {
    return self.standardCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self estimatedHeightForRow];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 1:
                    return (self.showOrdPicker) ? ORD_PICKER_CELL_HEIGHT : [self heightForRoutePointCell];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 2:
            switch (indexPath.row) {
                case 1:
                    return CELL_IMAGES_SIZE + IMAGE_PADDING * 2;
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 3:
            return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    
    return [self tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
    
}

- (CGFloat)heightForRoutePointCell {
    
    CGFloat diff = [self heightDiffForText:[STMFunctions shortCompanyName:(NSString *)self.point.name]];
    
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

- (void)putCachedHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    
    NSManagedObject *object = [self.resultsController objectAtIndexPath:indexPath];
    NSManagedObjectID *objectID = object.objectID;
    
    if (objectID) {
        self.cachedCellsHeights[objectID] = @(height);
    } else {
//        CLS_LOG(@"objectID is nil for %@", objectID);
    }
    
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];

    NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:indexPath] objectID];
    
    return self.cachedCellsHeights[objectID];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;

    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
            break;
            
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:self.arrivalButtonCellIdentifier forIndexPath:indexPath];
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:self.shippingLocationCellIdentifier forIndexPath:indexPath];
                    break;
                    
                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:self.picturesViewCellIdentifier forIndexPath:indexPath];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 3:
            cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
            break;
            
        default:
            break;
    }

    [self flushCellBeforeUse:cell];
    [self fillCell:cell atIndexPath:indexPath];

    cell.selectionStyle = (indexPath.section == 3) ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (void)flushCellBeforeUse:(UITableViewCell *)cell {
    
    cell.textLabel.text = nil;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.detailTextLabel.text = nil;
    cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.imageView.image = nil;
    
    if ([cell conformsToProtocol:@protocol(STMTDCell)]) {
        
        UITableViewCell <STMTDCell> *customCell = (UITableViewCell <STMTDCell> *)cell;
        
        customCell.titleLabel.text = nil;
        customCell.titleLabel.attributedText = nil;
        customCell.titleLabel.textAlignment = NSTextAlignmentLeft;
        customCell.detailLabel.text = nil;
        customCell.detailLabel.attributedText = nil;
        customCell.detailLabel.textAlignment = NSTextAlignmentLeft;
        
    }

}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    (self.showOrdPicker) ? [self fillChangePointNumberTitleCell:cell] : [self fillCell:cell withRoute:self.point.shipmentRoute];
                    break;
                    
                case 1:
                    self.pointNumberCellIndexPath = (self.showOrdPicker) ? indexPath : nil;
                    (self.showOrdPicker) ? [self fillOrdPickerCell:cell] : [self fillCell:cell withRoutePoint:self.point];
                    break;

                case 2:
                    self.pointNumberCellIndexPath = (self.showOrdPicker) ? nil : indexPath;
                    (self.showOrdPicker) ? [self fillPickerToolbarCell:cell] : [self fillPointNumberCell:cell];
                    break;

                default:
                    break;
            }
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                    [self fillArrivalButtonCell:cell atIndexPath:indexPath];
                    break;
                    
                case 1:
                    [self fillProcessingShipmentsButtonCell:cell atIndexPath:indexPath];
                    break;

                case 2:
                    [self fillDoneShipmentsButtonCell:cell atIndexPath:indexPath];
                    break;

                default:
                    break;
            }
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0:
                    [self fillCell:cell withShippingLocation:self.point.shippingLocation];
                    break;
                    
                case 1:
//                    [self fillCell:cell withPhotos:self.point.shippingLocation.shippingLocationPictures];
                    [self fillCellWithPhotos:cell];
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 3:
            [self fillShipmentCell:cell withShipment:self.resultsController.fetchedObjects[indexPath.row]];
            [super fillCell:cell atIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
            break;
            
        default:
            break;
    }
    
}

- (void)fillCell:(UITableViewCell *)cell withRoute:(STMShipmentRoute *)route {
    
    if (route.date) {
        
        cell.textLabel.text = [STMFunctions dayWithDayOfWeekFromDate:(NSDate *)route.date];
        cell.detailTextLabel.text = @"";

    }

}

- (void)fillChangePointNumberTitleCell:(UITableViewCell *)cell {
    
    cell.textLabel.text = NSLocalizedString(@"PICK A NEW POINT NUMBER", nil);
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    cell.detailTextLabel.text = @"";
    
}

- (void)fillCell:(UITableViewCell *)cell withRoutePoint:(STMShipmentRoutePoint *)point {

    cell.textLabel.text = [STMFunctions shortCompanyName:(NSString *)point.name];
    cell.textLabel.numberOfLines = 0;
    
    cell.detailTextLabel.text = [point shortInfo];

}

- (void)fillOrdPickerCell:(UITableViewCell *)cell {

//    cell.contentView.clipsToBounds = YES;

    self.ordPicker.center = cell.contentView.center;
    [cell.contentView addSubview:self.ordPicker];
    
}

- (void)fillPointNumberCell:(UITableViewCell *)cell {
    
    UIColor *textColor = ACTIVE_BLUE_COLOR; //cell.textLabel.textColor
    UIFont *font = (cell.textLabel.font) ? cell.textLabel.font : [UIFont systemFontOfSize:14];
    
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: textColor};
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"POINT NUMBER", nil) attributes:attributes];

    [text appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];

    attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize],
                   NSForegroundColorAttributeName: textColor};

    NSString *ordString = (self.point.ord) ? self.point.ord.stringValue : @"N/A";
    
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:ordString attributes:attributes]];

    cell.textLabel.attributedText = text;

}

- (void)fillPickerToolbarCell:(UITableViewCell *)cell {
    
    [cell.contentView addSubview:self.pickerToolbar];
    
}

- (void)fillArrivalButtonCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        
        STMCustom7TVCell *buttonCell = (STMCustom7TVCell *)cell;

        buttonCell.titleLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
        buttonCell.titleLabel.text = NSLocalizedString(@"ARRIVAL BUTTON TITLE", nil);
        buttonCell.titleLabel.textColor = (self.point.isReached.boolValue) ? [UIColor lightGrayColor] : ACTIVE_BLUE_COLOR;
        buttonCell.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        if (self.point.reachedAtLocation) {
            buttonCell.detailLabel.text = [[STMFunctions dateMediumTimeMediumFormatter] stringFromDate:(NSDate *)self.point.reachedAtLocation.timestamp];
        } else {
            buttonCell.detailLabel.text = @"";
        }
        
        buttonCell.detailLabel.textColor = [UIColor lightGrayColor];
        buttonCell.detailLabel.textAlignment = NSTextAlignmentCenter;

        self.arrivalButtonCellIndexPath = indexPath;
        
    }
    
}

- (void)fillProcessingShipmentsButtonCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        
        STMCustom7TVCell *buttonCell = (STMCustom7TVCell *)cell;
        
        buttonCell.titleLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
        buttonCell.titleLabel.text = NSLocalizedString(@"PROCESSING ALL SHIPMENT", nil);
        buttonCell.titleLabel.textColor = ACTIVE_BLUE_COLOR;
        buttonCell.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        buttonCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    }

}

- (void)fillDoneShipmentsButtonCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        
        STMCustom7TVCell *buttonCell = (STMCustom7TVCell *)cell;
        
        buttonCell.titleLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
        buttonCell.titleLabel.text = NSLocalizedString(@"DONE ALL SHIPMENT", nil);
        buttonCell.titleLabel.textColor = ACTIVE_BLUE_COLOR;
        buttonCell.titleLabel.textAlignment = NSTextAlignmentCenter;

    }

}

- (void)fillCell:(UITableViewCell *)cell withShippingLocation:(STMShippingLocation *)shippingLocation {

    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        
        STMCustom7TVCell *customCell = (STMCustom7TVCell *)cell;
    
        customCell.titleLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
        customCell.titleLabel.text = @"";
        customCell.titleLabel.textColor = [UIColor blackColor];
        customCell.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        customCell.detailLabel.text = @"";
        customCell.detailLabel.textColor = [UIColor blackColor];
        customCell.detailLabel.textAlignment = NSTextAlignmentCenter;
        
        [[customCell viewWithTag:666] removeFromSuperview];
                
        if (shippingLocation.location) {
            
            customCell.titleLabel.text = NSLocalizedString(@"SHOW MAP", nil);
            
            if (!shippingLocation.isLocationConfirmed.boolValue) {
                
                customCell.detailLabel.text = NSLocalizedString(@"LOCATION NEEDS CONFIRMATION", nil);
                customCell.detailLabel.textColor = [UIColor redColor];

            }
            
        } else {
            
            customCell.titleLabel.text = NSLocalizedString(@"SET LOCATION", nil);
            customCell.titleLabel.textColor = ACTIVE_BLUE_COLOR;
            
        }
        
    }

    cell.accessoryType = UITableViewCellAccessoryNone;

}

- (void)fillCellWithPhotos:(UITableViewCell *)cell {
    [self fillCell:cell withPhotos:[self currentPhotos]];
}

- (void)fillCell:(UITableViewCell *)cell withPhotos:(NSSet *)photos {

    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    [self.picturesView removeFromSuperview];

    self.picturesView = [[UIView alloc] init];

    if (photos.count == 0) {
        
        UIView *blankPicture = [self blankPicture];
        
        blankPicture.frame = CGRectMake(0, 0, CELL_IMAGES_SIZE, CELL_IMAGES_SIZE);
        
        [self.picturesView addSubview:blankPicture];

    } else {
        
        NSUInteger showCount = (photos.count > LIMIT_COUNT) ? LIMIT_COUNT : photos.count;

        NSSortDescriptor *sortDesriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceTs" ascending:NO selector:@selector(compare:)];
        NSRange range = NSMakeRange(0, showCount);
        NSArray *photoArray = [[photos sortedArrayUsingDescriptors:@[sortDesriptor]] subarrayWithRange:range];
        
        for (STMPicture *picture in photoArray) {

            UIView *pictureButton = (picture.imageThumbnail) ? [self pictureButtonWithPicture:picture] : self.downloadPlaceholder;
            
            CGFloat cellImageSize = (picture.imageThumbnail) ? CELL_IMAGES_SIZE : CELL_IMAGES_SIZE - 5;
            
            NSUInteger count = self.picturesView.subviews.count;
            CGFloat x = (count > 0) ? count * (cellImageSize + IMAGE_PADDING) : 0;
            
            pictureButton.frame = CGRectMake(x, 0, cellImageSize, cellImageSize);
            
            [self.picturesView addSubview:pictureButton];
            
        }
        
    }
    
    UIView *addButton = [self addPhotoButton];
    
    CGFloat x = self.picturesView.subviews.count * (CELL_IMAGES_SIZE + IMAGE_PADDING);
    
    addButton.frame = CGRectMake(x, 0, CELL_IMAGES_SIZE, CELL_IMAGES_SIZE);
    
    [self.picturesView addSubview:addButton];
    
    CGFloat picturesWidth = CELL_IMAGES_SIZE * self.picturesView.subviews.count + IMAGE_PADDING * (self.picturesView.subviews.count - 1);
    x = ceil((cell.contentView.frame.size.width - picturesWidth) / 2);
    CGFloat y = ceil((cell.contentView.frame.size.height - CELL_IMAGES_SIZE) / 2);

    self.picturesView.frame = CGRectMake(x, y, picturesWidth, CELL_IMAGES_SIZE);

    [cell.contentView addSubview:self.picturesView];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
}

- (void)fillShipmentCell:(UITableViewCell *)cell withShipment:(STMShipment *)shipment {
    
    if ([cell conformsToProtocol:@protocol(STMTDCell)]) {
        
        UITableViewCell <STMTDCell> *shipmentCell = (UITableViewCell <STMTDCell> *)cell;
        
        [self fillCell:shipmentCell withShipment:shipment];

        UIColor *textColor = [UIColor blackColor];
        
        if (self.point.isReached.boolValue) {
            textColor = (shipment.isShipped.boolValue) ? [UIColor lightGrayColor] : [UIColor redColor];
        }
        
        shipmentCell.titleLabel.textColor = textColor;
        shipmentCell.detailLabel.textColor = textColor;

        if (shipment.shipmentPositions.count > 0) {
            shipmentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            shipmentCell.accessoryType = UITableViewCellAccessoryNone;
        }

    }
    
}

- (void)fillCell:(UITableViewCell <STMTDCell> *)cell withShipment:(STMShipment *)shipment {
    
    cell.titleLabel.text = shipment.ndoc;
    
    NSString *positions = [shipment positionsCountString];
    
    NSString *detailText = @"";
    
    if (shipment.commentText) {
        detailText = [detailText stringByAppendingString:[NSString stringWithFormat:@"%@\n", shipment.commentText]];
    }
    
    if ([shipment.needCashing boolValue]) {
        
        detailText = [detailText stringByAppendingString:[NSString stringWithFormat:@"%@\n", NSLocalizedString(@"NEED CASHING", nil)]];

//        cell.imageView.image = [STMFunctions resizeImage:[UIImage imageNamed:@"banknotes-128"] toSize:CGSizeMake(30, 30)];
        
    } else {
//        cell.imageView.image = nil;
    }
    
    if (shipment.shipmentPositions.count > 0) {
        
        NSString *boxes = [shipment approximateBoxCountString];
        NSString *bottles = [shipment bottleCountString];
        
        detailText = [detailText stringByAppendingString:[NSString stringWithFormat:@"%@, %@, %@", positions, boxes, bottles]];
        
    } else {
        
        detailText = [detailText stringByAppendingString:NSLocalizedString(positions, nil)];
        
    }
    
    cell.detailLabel.text = detailText;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    cell.contentView.clipsToBounds = (self.showOrdPicker && indexPath.section == 0);
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath compare:self.pointNumberCellIndexPath] == NSOrderedSame) {
        
        [self showOrdPickerView];
        
    }
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                if (!self.point.isReached.boolValue) [self showArriveConfirmationAlert];
                break;
                
            case 1:
                [self startAllShipmentsProcessing];
                break;

            case 2:
                [self showDoneAllShipmentsAlert];
                break;

            default:
                break;
        }

    }
    
    if (indexPath.section == 2) {
        
        switch (indexPath.row) {
            case 0:
                [self performSegueWithIdentifier:@"showShippingLocationMap" sender:self.point.shippingLocation];
                break;
                
            default:
                break;
        }
        
    }
    
    if (indexPath.section == 3) {
        
        STMShipment *shipment = self.resultsController.fetchedObjects[indexPath.row];
        
        if ([self.splitVC isMasterNCForViewController:self]) {
            
            [self.splitVC didSelectShipment:shipment inVC:self];
            
        } else {
        
            if (shipment.shipmentPositions.count > 0) {
                [self performSegueWithIdentifier:@"showShipmentPositions" sender:indexPath];
            }

        }
        
    }
    
}

- (void)highlightSelectedShipment {
    
    NSIndexPath *indexPath = [self.resultsController indexPathForObject:self.splitVC.selectedShipment];
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+3];
    
    if (indexPath) {
        
        UITableViewScrollPosition scrollPosition = ([[self.tableView indexPathsForVisibleRows] containsObject:indexPath]) ? UITableViewScrollPositionNone : UITableViewScrollPositionTop;
        
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:scrollPosition];
        
    }

}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
//    [self.tableView reloadData];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    [super controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    
}


#pragma mark - point number picker

- (void)showOrdPickerView {
    
    [self.ordPicker selectRow:(self.point.ord.integerValue - 1) inComponent:0 animated:NO];

    self.showOrdPicker = YES;

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

}

- (void)hideOrdPicker {

    self.showOrdPicker = NO;

    [self.pickerToolbar removeFromSuperview];
    [self.ordPicker removeFromSuperview];

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.point.shipmentRoute.shipmentRoutePoints.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return @(row+1).stringValue;
}

- (void)pickerCancel {
    [self hideOrdPicker];
}

- (void)pickerDone {
    
    NSInteger fromIndex = self.point.ord.integerValue - 1;
    NSInteger toIndex = [self.ordPicker selectedRowInComponent:0];
    
    NSUInteger minIndex = MIN(fromIndex, toIndex);
    NSUInteger loc = (minIndex == fromIndex) ? minIndex + 1 : minIndex;
    
    NSRange affectedPointsRange = NSMakeRange(loc, labs(fromIndex - toIndex));
    
    NSArray *points = [self.point.shipmentRoute.shipmentRoutePoints allObjects];
    
    NSSortDescriptor *ordDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord" ascending:YES selector:@selector(compare:)];
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];

    points = [points sortedArrayUsingDescriptors:@[ordDescriptor, nameDescriptor]];
    
    NSArray *affectedPoints = [points subarrayWithRange:affectedPointsRange];
    
    for (STMShipmentRoutePoint *point in affectedPoints) {
        point.ord = (minIndex == fromIndex) ? @(point.ord.integerValue - 1) : @(point.ord.integerValue + 1);
    }
    
    self.point.ord = @(toIndex + 1);
    
    if (self.pointNumberCellIndexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[self.pointNumberCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [self.document saveDocument:^(BOOL success) {
//        [self.session.syncer setSyncerState:STMSyncerSendDataOnce];
    }];
    
    [self hideOrdPicker];
    
}

#pragma mark - alerts

- (void)showArriveConfirmationAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CONFIRM ARRIVAL?", nil)
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                              otherButtonTitles:NSLocalizedString(@"YES", nil), nil];
        
        alert.tag = 333;
        [alert show];
        
    }];
    
}

- (void)showDoneAllShipmentsAlert {

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DONE ALL SHIPMENT ALERT TITLE", nil)
                                                        message:NSLocalizedString(@"DONE ALL SHIPMENT ALERT MESSAGE", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"NO", nil)
                                              otherButtonTitles:NSLocalizedString(@"YES", nil), nil];

        alert.tag = 444;
        [alert show];
        
    }];

}

- (void)shippingProcessWasInterrupted {

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SHIPMENT PROCESS WAS INTERRUPTED TITLE", nil)
                                                        message:NSLocalizedString(@"SHIPMENT PROCESS WAS INTERRUPTED MESSAGE", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        
        [alert show];

    }];
    
}

- (void)showSelectPhotoTypeActionSheet {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if (self.point.photos.count) {
            
            self.currentPhotoType = NSStringFromClass([STMShipmentRoutePointPhoto class]);
            [self showImagePicker];
            return;
            
        }
        
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SELECT SHIPMENTROUTEPOINT PHOTO TYPE TITLE", nil)
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        actionSheet.tag = 111;
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"SHIPPINGLOCATION PHOTO TYPE", nil)];
        [actionSheet addButtonWithTitle:NSLocalizedString(@"SHIPMENTROUTEPOINT PHOTO TYPE", nil)];
        
        [actionSheet showInView:self.view];
        
    }];

}

- (void)shippingDidDone {
    
    [self.navigationController popToViewController:self animated:YES];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];

    }];
    
}

- (void)checkShipments {
    
    if (self.point.isReached.boolValue) {
        
        if ([self unprocessedShipmentsCount] > 0) {
            [self showUnprocessedShipmentsAlert];
        }
        
    }
    
}

- (void)showUnprocessedShipmentsAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"UNPROCESSED SHIPMENTS ALERT TITLE", nil)
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        
        [alert show];
        
    }];
    
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    switch (alertView.tag) {
        case 333:
            
            switch (buttonIndex) {
                case 1:
                    [self arrivalWasConfirmed];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case 444:
            
            switch (buttonIndex) {
                case 1:
                    [self markAllShipmentsAsDone];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }

}

- (void)arrivalWasConfirmed {
    
    self.point.isReached = @YES;
    
    if (self.arrivalButtonCellIndexPath) {
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.arrivalButtonCellIndexPath.section]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
                
    }
    
    self.isWaitingLocation = YES;
    [self.session.locationTracker getLocation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"routePointIsReached" object:self];
    
}

- (void)markAllShipmentsAsDone {
    
    NSSet *unprocessedShipments = [self unprocessedShipments];
    
    STMShippingProcessController *shippingController = [STMShippingProcessController sharedInstance];
    
    for (STMShipment *shipment in unprocessedShipments) {
        
        [shippingController startShippingWithShipment:shipment];
        [shippingController markUnprocessedPositionsAsDoneForShipment:shipment];
        [shippingController doneShippingWithShipment:shipment withCompletionHandler:^(BOOL success) {
            
        }];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"routePointAllShipmentsIsDone" object:self.point];
    
    [self.tableView reloadData];
    
}


- (void)startAllShipmentsProcessing {
    
    for (STMShipment *shipment in self.resultsController.fetchedObjects) {
        [[STMShippingProcessController sharedInstance] startShippingWithShipment:shipment];
    }
    
    [self performSegueWithIdentifier:@"showShipping" sender:self];
    
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 111) {
        NSLog(@"buttonIndex %@", @(buttonIndex));
        
        switch (buttonIndex) {
            case 0:
                NSLog(@"cancel button pressed");
                self.currentPhotoType = nil;
                break;
            case 1:
                NSLog(@"shipping location photo type");
                self.currentPhotoType = NSStringFromClass([STMShippingLocationPicture class]);
                break;
            case 2:
                NSLog(@"shipment route point photo type");
                self.currentPhotoType = NSStringFromClass([STMShipmentRoutePointPhoto class]);
                break;
                
            default:
                break;
        }
        
        if (buttonIndex) [self showImagePicker];
    
    }
    
}

- (void)showImagePicker {
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
//    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];

}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showShipmentPositions"] &&
        [segue.destinationViewController isKindOfClass:[STMShipmentTVC class]]) {

        STMShipmentTVC *shipmentTVC = (STMShipmentTVC *)segue.destinationViewController;
        shipmentTVC.point = self.point;
        shipmentTVC.parentVC = self;

        if ([sender isKindOfClass:[NSIndexPath class]]) {
            
            STMShipment *shipment = self.resultsController.fetchedObjects[[(NSIndexPath *)sender row]];            
            shipmentTVC.shipment = shipment;

            [self.splitVC didSelectShipment:shipment inVC:self];

        } else if ([sender isEqual:self.splitVC]) {
            
            shipmentTVC.shipment = self.splitVC.selectedShipment;
            
        }
        
    } else if ([segue.identifier isEqualToString:@"showShippingLocationMap"]) {
        
        STMShippingLocationMapVC *mapVC = nil;
        
        if ([segue.destinationViewController isKindOfClass:[STMShippingLocationMapVC class]]) {
        
            mapVC = (STMShippingLocationMapVC *)segue.destinationViewController;
            
        } else if ([segue.destinationViewController isKindOfClass:[UINavigationController class]] &&
                   [[(UINavigationController *)segue.destinationViewController topViewController] isKindOfClass:[STMShippingLocationMapVC class]]) {
            
            mapVC = (STMShippingLocationMapVC *)[(UINavigationController *)segue.destinationViewController topViewController];
            mapVC.splitVC = self.splitVC;
            
        }
        
        mapVC.point = self.point;
        
    } else if ([segue.identifier isEqualToString:@"showPhotos"] &&
               [sender isKindOfClass:[UIView class]] &&
               [segue.destinationViewController isKindOfClass:[STMShippingLocationPicturesPVC class]]) {
        
        STMShippingLocationPicturesPVC *picturesPVC = (STMShippingLocationPicturesPVC *)segue.destinationViewController;
        
        NSSortDescriptor *sortDesriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceTs" ascending:NO selector:@selector(compare:)];
        NSArray *photoArray = [[self currentPhotos] sortedArrayUsingDescriptors:@[sortDesriptor]];
        
        picturesPVC.photoArray = photoArray.mutableCopy;
        picturesPVC.currentIndex = [self.picturesView.subviews indexOfObject:sender];
        picturesPVC.parentVC = self;
        
    } else if ([segue.identifier isEqualToString:@"showRoute"]) {
        
        STMRouteMapVC *routeMapVC = nil;
        
        if ([segue.destinationViewController isKindOfClass:[STMRouteMapVC class]]) {
            
            routeMapVC = (STMRouteMapVC *)segue.destinationViewController;

        } else if ([segue.destinationViewController isKindOfClass:[UINavigationController class]] &&
                   [[(UINavigationController *)segue.destinationViewController topViewController] isKindOfClass:[STMRouteMapVC class]]) {
            
            routeMapVC = (STMRouteMapVC *)[(UINavigationController *)segue.destinationViewController topViewController];
            routeMapVC.splitVC = self.splitVC;
            
        }

        routeMapVC.shippingLocation = self.point.shippingLocation;
        routeMapVC.destinationPointName = self.point.shortName;
        routeMapVC.destinationPointAddress = self.point.address;
        
    } else if ([segue.identifier isEqualToString:@"showShipping"]) {
        
        STMShippingVC *shippingVC = nil;
        
        if ([segue.destinationViewController isKindOfClass:[STMShippingVC class]]) {
            
            shippingVC = (STMShippingVC *)segue.destinationViewController;
            
        } else if ([segue.destinationViewController isKindOfClass:[UINavigationController class]] &&
                   [[(UINavigationController *)segue.destinationViewController topViewController] isKindOfClass:[STMShippingVC class]]) {
            
            shippingVC = (STMShippingVC *)[(UINavigationController *)segue.destinationViewController topViewController];
            shippingVC.splitVC = self.splitVC;
            
        }
        
        shippingVC.shipments = self.resultsController.fetchedObjects;
        
        self.shipmentTVC = [[STMShipmentTVC alloc] init];
        shippingVC.parentVC = self.shipmentTVC;
        shippingVC.sortOrder = self.shipmentTVC.sortOrder;
        
    }
    
}


#pragma mark - notifications

//- (void)currentAccuracyUpdated:(NSNotification *)notification {
//    
//    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
//    
//}

- (void)currentLocationWasUpdated:(NSNotification *)notification {
    
    if (self.isWaitingLocation) {
        
        CLLocation *currentLocation = notification.userInfo[@"currentLocation"];

        STMLocation *location = [STMLocationController locationObjectFromCLLocation:currentLocation];

        self.point.reachedAtLocation = location;
        
        [self.session.document saveDocument:^(BOOL success) {
            
        }];
        
        self.isWaitingLocation = NO;
        
        if (self.arrivalButtonCellIndexPath) {
            [self.tableView reloadRowsAtIndexPaths:@[self.arrivalButtonCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
    }
    
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//
//    if ([object isEqual:self.point]) {
//        [self.tableView reloadData];
//    }
//    
//}

- (void)shippingLocationUpdated {
    [self.tableView reloadData];
}

#pragma mark - navbar

- (void)setupNavBar {
    
    if (![self.splitVC isMasterNCForViewController:self] && self.point.shippingLocation.location) {
        
        STMBarButtonItem *waypointButton = [[STMBarButtonItem alloc] initWithCustomView:[self waypointView]];
        self.navigationItem.rightBarButtonItem = waypointButton;
        
    } else {

        self.navigationItem.rightBarButtonItem = nil;

    }

}

- (UIView *)waypointView {
    
    CGFloat imageSize = 22;
    CGFloat imagePadding = 0;
    
    UIImage *image = [[UIImage imageNamed:@"single_waypoint_map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(imagePadding, imagePadding, imageSize, imageSize);
    imageView.tintColor = (self.point.shippingLocation.location) ? ACTIVE_BLUE_COLOR : [UIColor lightGrayColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, imageSize + imagePadding * 2, imageSize + imagePadding * 2)];
    [button addTarget:self action:@selector(waypointButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [button addSubview:imageView];
    
    return button;
    
}

- (void)waypointButtonPressed {
    [self performSegueWithIdentifier:@"showRoute" sender:self];
}


#pragma mark - CLGeocode

- (void)checkPointLocation {
    
    if (!self.point.shippingLocation.location && self.point.address) {
        
        [[[CLGeocoder alloc] init] geocodeAddressString:(NSString *)self.point.address completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if (!error) {
                
                CLPlacemark *placemark = placemarks.firstObject;
                
                [self.point updateShippingLocationWithGeocodedLocation:(CLLocation *)placemark.location];
                
                [self.tableView reloadData];
                [self setupNavBar];

            }
            
        }];
        
    }
    
}


#pragma mark - view lifecycle

- (void)addObservers {
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
//    [nc addObserver:self selector:@selector(currentAccuracyUpdated:) name:@"currentAccuracyUpdated" object:self.session.locationTracker];
    [nc addObserver:self
           selector:@selector(currentLocationWasUpdated:)
               name:@"currentLocationWasUpdated"
             object:self.session.locationTracker];

    [nc addObserver:self
           selector:@selector(shippingLocationUpdated)
               name:@"shippingLocationUpdated"
             object:self.point];
    
//    [self.point addObserver:self forKeyPath:@"shippingLocation.location" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [self.point removeObserver:self forKeyPath:@"shippingLocation.location"];
    
}

- (void)customInit {

    UINib *custom7TVCellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom7TVCell class]) bundle:nil];
    [self.tableView registerNib:custom7TVCellNib forCellReuseIdentifier:self.shippingLocationCellIdentifier];
    [self.tableView registerNib:custom7TVCellNib forCellReuseIdentifier:self.arrivalButtonCellIdentifier];
    [self.tableView registerNib:custom7TVCellNib forCellReuseIdentifier:self.cellIdentifier];
    [self.tableView registerNib:custom7TVCellNib forCellReuseIdentifier:self.picturesViewCellIdentifier];
    
    [self addObservers];
    [self performFetch];
    [self checkPointLocation];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
    [self setupNavBar];

    if ([self.splitVC isMasterNCForViewController:self]) [self highlightSelectedShipment];
    if ([self.splitVC isDetailNCForViewController:self]) [self.navigationItem setHidesBackButton:YES animated:NO];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([self isMovingFromParentViewController]) {
        
//        [self checkShipments];
        [self removeObservers];
        [self.splitVC backButtonPressed];
        
    }
    [super viewWillDisappear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
