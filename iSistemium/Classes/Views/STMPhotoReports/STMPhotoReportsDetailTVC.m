//
//  STMPhotoReportsDetailTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPhotoReportsDetailTVC.h"

#import "STMPhotoReportsSVC.h"
#import "STMPhotoReportVC.h"
#import "STMPhotoReportMapVC.h"
#import "STMPhotoReportAddPhotoTVC.h"

#import "STMImagePickerOwnerProtocol.h"

#import "STMPicturesController.h"
#import "STMObjectsController.h"
#import "STMLocationController.h"
#import "STMPhotosController.h"


#define LOCATION_IMAGE_SIZE 25
#define CAMERA_IMAGE_SIZE 25


@interface STMPhotoReportsDetailTVC () <UIActionSheetDelegate,
                                        UINavigationControllerDelegate,
                                        UIImagePickerControllerDelegate,
                                        STMImagePickerOwnerProtocol>

@property (nonatomic, strong) UIImage *locationImage;

@property (weak, nonatomic) IBOutlet STMBarButtonItem *groupSwitcher;
@property (weak, nonatomic) IBOutlet STMBarButtonItem *cameraButton;

@property (nonatomic, weak) STMPhotoReportsSVC *splitVC;

@property (nonatomic, strong) STMSpinnerView *spinner;


@end


@implementation STMPhotoReportsDetailTVC

@synthesize resultsController = _resultsController;

- (STMPhotoReportsSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMPhotoReportsSVC class]]) {
            _splitVC = (STMPhotoReportsSVC *)self.splitViewController;
        }
        
    }
    
    return _splitVC;
    
}

- (STMSpinnerView *)spinner {
    
    if (!_spinner) {
        _spinner = [STMSpinnerView spinnerViewWithFrame:self.view.bounds];
    }
    return _spinner;
    
}

- (NSString *)cellIdentifier {
    return @"photoReportCell";
}

- (UIImage *)locationImage {
    
    if (!_locationImage) {
        
        UIImage *image = [UIImage imageNamed:@"location.png"];
        image = [STMFunctions resizeImage:image toSize:CGSizeMake(LOCATION_IMAGE_SIZE, LOCATION_IMAGE_SIZE)];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

        _locationImage = image;
        
    }
    return _locationImage;
    
}

- (void)setSelectedCampaignGroup:(STMCampaignGroup *)selectedCampaignGroup {
    
    if (![_selectedCampaignGroup isEqual:selectedCampaignGroup]) {
        
        _selectedCampaignGroup = selectedCampaignGroup;
        
        if (!selectedCampaignGroup && [self.navigationController.topViewController isKindOfClass:[STMPhotoReportAddPhotoTVC class]]) {
            [self.navigationController popViewControllerAnimated:YES];
        }

        [self updateTitle];
        [self performFetch];
        
    }
    
}

- (void)setSelectedCampaign:(STMCampaign *)selectedCampaign {
    
    if (![_selectedCampaign isEqual:selectedCampaign]) {
        
        _selectedCampaign = selectedCampaign;

        [self updateCameraButton];
        [self updateTitle];
        [self performFetch];

    }
    
}

- (void)setSelectedOutlet:(STMOutlet *)selectedOutlet {
    
    if (![_selectedOutlet isEqual:selectedOutlet]) {
        
        _selectedOutlet = selectedOutlet;
        
        [self updateCameraButton];
        [self updateTitle];
        [self performFetch];
        
    }
    
}

- (void)setSelectedCampaignForPhotoReport:(STMCampaign *)selectedCampaignForPhotoReport {
    
    _selectedCampaignForPhotoReport = selectedCampaignForPhotoReport;
    
    [self addNewPhotoReport];
    
}

- (void)setSelectedOutletForPhotoReport:(STMOutlet *)selectedOutletForPhotoReport {
    
    _selectedOutletForPhotoReport = selectedOutletForPhotoReport;

    [self addNewPhotoReport];

}

- (void)setCurrentGrouping:(STMPhotoReportGrouping)currentGrouping {
    
    _currentGrouping = currentGrouping;
    
    switch (currentGrouping) {
        case STMPhotoReportGroupingCampaign: {
            self.selectedCampaign = nil;
            break;
        }
        case STMPhotoReportGroupingOutlet: {
            self.selectedOutlet = nil;
            break;
        }
        default: {
            break;
        }
    }
    
    [self updateGroupSwitcher];
    [self.filterTVC photoReportGroupingChanged];
    
}

- (void)updateTitle {
    
    NSMutableArray *titleArray = @[].mutableCopy;
    
    if (self.selectedCampaign.name) {
        [titleArray addObject:(NSString * _Nonnull)self.selectedCampaign.name];
    } else {
        if (self.selectedCampaignGroup.name) [titleArray addObject:(NSString * _Nonnull)self.selectedCampaignGroup.name];
    }
    
    if (self.selectedOutlet.name) [titleArray addObject:(NSString * _Nonnull)self.selectedOutlet.name];
    
    self.title = [titleArray componentsJoinedByString:@" / "];
    
}

- (BOOL)shouldEnableAddPhotoButton {
    
    switch (self.currentGrouping) {
        case STMPhotoReportGroupingCampaign: {
            return (self.selectedOutlet) ? YES : NO;
            break;
        }
        case STMPhotoReportGroupingOutlet: {
            return (self.selectedCampaign) ? YES : NO;
            break;
        }
        default: {
            break;
        }
    }

}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhotoReport class])];
        
        NSString *sectionNameKeyPath = nil;
        
        switch (self.currentGrouping) {
            case STMPhotoReportGroupingCampaign: {
                
                request.sortDescriptors = @[[self campaignNameDescriptor], [self outletNameDescriptor], [self deviceCtsDescriptor]];
                sectionNameKeyPath = @"campaign.name";
                
                break;
            }
            case STMPhotoReportGroupingOutlet: {
                
                request.sortDescriptors = @[[self outletNameDescriptor], [self campaignNameDescriptor], [self deviceCtsDescriptor]];
                sectionNameKeyPath = @"outlet.name";

                break;
            }
            default: {
                break;
            }
        }
        
        request.predicate = [self currentPredicate];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:sectionNameKeyPath
                                                                            cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (NSSortDescriptor *)outletNameDescriptor {
 
    return [NSSortDescriptor sortDescriptorWithKey:@"outlet.name"
                                         ascending:YES
                                          selector:@selector(caseInsensitiveCompare:)];

}

- (NSSortDescriptor *)campaignNameDescriptor {

    return [NSSortDescriptor sortDescriptorWithKey:@"campaign.name"
                                         ascending:YES
                                          selector:@selector(caseInsensitiveCompare:)];

}

- (NSSortDescriptor *)deviceCtsDescriptor {
 
    return [NSSortDescriptor sortDescriptorWithKey:@"deviceCts"
                                         ascending:NO
                                          selector:@selector(compare:)];

}

- (NSPredicate *)currentPredicate {
    
    NSMutableArray *subpredicates = @[].mutableCopy;
    
    if (self.selectedCampaignGroup) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"campaign.campaignGroup == %@", self.selectedCampaignGroup];
        [subpredicates addObject:predicate];
        
    }

    if (self.selectedCampaign) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"campaign == %@", self.selectedCampaign];
        [subpredicates addObject:predicate];
        
    }

    if (self.selectedOutlet) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"outlet == %@", self.selectedOutlet];
        [subpredicates addObject:predicate];
        
    }

    NSPredicate *imageThumbnailPredicate = [NSPredicate predicateWithFormat:@"imageThumbnail != %@", nil];
    [subpredicates addObject:imageThumbnailPredicate];

    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    
    return predicate;
    
}

- (void)performFetch {

    self.resultsController = nil;
    
    if ([self.resultsController performFetch:nil]) {
        
        [self.tableView reloadData];
        
    }
    
}

- (void)deletePhotoReport:(STMPhotoReport *)photoReport {
    
// Notification to inform STMCampaignsTVC.m
    if (photoReport.campaign) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"photoReportsChanged"
                                                            object:self.splitViewController
                                                          userInfo:@{@"campaign": photoReport.campaign}];
        
    }
// End of notification

// Notification to inform STMCampaignPhotoReportCVC
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photosCountChanged"
                                                        object:self];
// End of notification


    [STMObjectsController createRecordStatusAndRemoveObject:photoReport];
    
}


#pragma mark - table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom10TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    
    [self fillCell:cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillCell:(STMCustom10TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    [self flushCell:cell];
    
    STMPhotoReport *photoReport = [self.resultsController objectAtIndexPath:indexPath];
    [self fillCell:cell withPhotoReport:photoReport];

}

- (void)flushCell:(STMCustom10TVCell *)cell {
    
    cell.titleLabel.text = nil;
    cell.titleLabel.textAlignment = NSTextAlignmentLeft;
    cell.titleLabel.textColor = [UIColor blackColor];

    cell.detailLabel.text = nil;
    cell.detailLabel.textAlignment = NSTextAlignmentLeft;
    cell.detailLabel.textColor = [UIColor blackColor];

    cell.pictureView.image = nil;
    cell.accessoryView = nil;

}

- (void)fillCell:(STMCustom10TVCell *)cell withPhotoReport:(STMPhotoReport *)photoReport {
    
    cell.pictureView.contentMode = UIViewContentModeScaleAspectFill;
    cell.pictureView.clipsToBounds = YES;
    cell.pictureView.image = [UIImage imageWithData:photoReport.imageThumbnail];

    cell.titleLabel.text = [[STMFunctions dateMediumTimeShortFormatter] stringFromDate:photoReport.deviceCts];

    switch (self.currentGrouping) {
        case STMPhotoReportGroupingCampaign: {
            cell.detailLabel.text = photoReport.outlet.name;
            break;
        }
        case STMPhotoReportGroupingOutlet: {
            cell.detailLabel.text = photoReport.campaign.name;
            break;
        }
        default: {
            break;
        }
    }
    
    if (photoReport.location) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0.0, 0.0, self.locationImage.size.width, self.locationImage.size.height);
        [button setBackgroundImage:self.locationImage forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(locationButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        
        cell.accessoryView = button;
        
    } else {
        
        cell.accessoryView = nil;
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showPhotoReport" sender:indexPath];
}

- (void)locationButtonTapped:(id)sender event:(id)event {
    
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    
    if (indexPath != nil) {
        [self performSegueWithIdentifier:@"showPhotoReportMap" sender:indexPath];
    }
    
}


#pragma mark - add photoReport

- (void)addNewPhotoReport {

    if ([self.navigationController.topViewController isKindOfClass:[STMPhotoReportAddPhotoTVC class]]) {
        [self.navigationController popViewControllerAnimated:NO];
    }
    
    self.filterTVC.lockSelection = NO;
    
    [self showImagePicker];
    
}

- (void)showImagePicker {
    
    BOOL camera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibrary = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (camera) {
        
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
        
    } else if (photoLibrary) {
        
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
    } else {
        
        //        [STMObjectsController removeObject:self.selectedPhotoReport];
        
    }

}


#pragma mark - STMImagePickerOwnerProtocol

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)imageSourceType {
    
    if ([UIImagePickerController isSourceTypeAvailable:imageSourceType]) {
        
        STMImagePickerController *imagePickerController = [[STMImagePickerController alloc] initWithSourceType:imageSourceType];
        imagePickerController.ownerVC = self;
        
        [self.splitViewController presentViewController:imagePickerController animated:YES completion:^{
            
            [self.view addSubview:self.spinner];
            
        }];
        
    }
    
}

- (void)imagePickerWasDissmised:(UIImagePickerController *)picker {
    
    [self.spinner removeFromSuperview];
    self.spinner = nil;
    
}

- (void)saveImage:(UIImage *)image andWaitForLocation:(BOOL)waitForLocation {
    
    STMPhotoReport *savedPhotoReport = [self savePhotoReportWithImage:image];
    
    if (waitForLocation && savedPhotoReport) {
        
        [[STMPhotosController sharedController] addPhotoReportToWaitingLocation:savedPhotoReport];
                
    }

}

- (void)saveImage:(UIImage *)image withLocation:(CLLocation *)location {
    
    STMPhotoReport *savedPhotoReport = [self savePhotoReportWithImage:image];
    
    if (location) savedPhotoReport.location = [STMLocationController locationObjectFromCLLocation:location];

}

- (STMPhotoReport *)savePhotoReportWithImage:(UIImage *)image {
    
    CGFloat jpgQuality = [STMPicturesController jpgQuality];

    STMPhotoReport *photoReport = (STMPhotoReport *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMPhotoReport class])
                                                                                        isFantom:NO];
    
    [STMPicturesController setImagesFromData:UIImageJPEGRepresentation(image, jpgQuality)
                                  forPicture:photoReport
                                   andUpload:YES];
    
//    [photoReport addObserver:self forKeyPath:@"imageThumbnail" options:NSKeyValueObservingOptionNew context:nil];
    
    switch (self.currentGrouping) {
        case STMPhotoReportGroupingCampaign: {
            
            photoReport.campaign = self.selectedCampaignForPhotoReport;
            photoReport.outlet = self.selectedOutlet;
            
            break;
            
        }
        case STMPhotoReportGroupingOutlet: {
            
            photoReport.outlet = self.selectedOutletForPhotoReport;
            photoReport.campaign = self.selectedCampaign;
            
            break;
            
        }
        default: {
            break;
        }
    }
    
// Notification to inform STMCampaignsTVC.m
    if (photoReport.campaign) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"photoReportsChanged"
                                                            object:self.splitViewController
                                                          userInfo:@{@"campaign": photoReport.campaign}];
        
    }
// End of notification
    
// Notification to inform STMCampaignPhotoReportCVC
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photosCountChanged"
                                                        object:self];
// End of notification

    [[self document] saveDocument:^(BOOL success) {
        if (success) {
            
        }
    }];
    
    return photoReport;
    
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([sender isKindOfClass:[NSIndexPath class]]) {

        STMPhotoReport *photoReport = [self.resultsController objectAtIndexPath:(NSIndexPath *)sender];

        if ([segue.identifier isEqualToString:@"showPhotoReport"]) {
            
            if ([segue.destinationViewController isKindOfClass:[STMPhotoReportVC class]]) {
                
                STMPhotoReportVC *vc = (STMPhotoReportVC *)segue.destinationViewController;
                vc.photoReport = photoReport;
                vc.parentVC = self;
                
            }
            
        } else if ([segue.identifier isEqualToString:@"showPhotoReportMap"]) {
            
            if ([segue.destinationViewController isKindOfClass:[STMPhotoReportMapVC class]]) {
                
                STMPhotoReportMapVC *vc = (STMPhotoReportMapVC *)segue.destinationViewController;
                vc.photoReport = photoReport;
                
            }
            
        }

    }
    
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    [super controllerDidChangeContent:controller];
    
    [self.splitVC.masterVC photoReportsWasUpdated];
    [self.filterTVC photoReportsWasUpdated];
    
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    switch (actionSheet.tag) {
        case 234:
            
            switch (buttonIndex) {
                case 0:
                    self.currentGrouping = STMPhotoReportGroupingCampaign;
                    break;

                case 1:
                    self.currentGrouping = STMPhotoReportGroupingOutlet;
                    break;

                default:
                    break;
            }
            
            [self performFetch];
//            [self updateGroupSwitcher];
            
            break;
            
        default:
            break;
    }
    
}


#pragma mark - group switcher

- (IBAction)groupSwitcherPressed:(id)sender {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        
        NSString *campaignButtonTitle = NSLocalizedString(@"GROUPING BY CAMPAIGN", nil);
        NSString *outletButtonTitle = NSLocalizedString(@"GROUPING BY OUTLET", nil);
        
        switch (self.currentGrouping) {
            case STMPhotoReportGroupingCampaign: {
                campaignButtonTitle = [@"✓ " stringByAppendingString:campaignButtonTitle];
                break;
            }
            case STMPhotoReportGroupingOutlet: {
                outletButtonTitle = [@"✓ " stringByAppendingString:outletButtonTitle];
                break;
            }
            default: {
                break;
            }
        }
        
        [actionSheet addButtonWithTitle:campaignButtonTitle];
        [actionSheet addButtonWithTitle:outletButtonTitle];
        
        actionSheet.tag = 234;
        actionSheet.delegate = self;
        
        [actionSheet showFromBarButtonItem:self.groupSwitcher animated:YES];
        
    }];
    
}

- (void)setupGroupSwitcher {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [@"currentGrouping_" stringByAppendingString:[STMAuthController authController].userID];
    
    self.currentGrouping = [defaults integerForKey:key];

//    [self updateGroupSwitcher];
    
}

- (void)updateGroupSwitcher {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [@"currentGrouping_" stringByAppendingString:[STMAuthController authController].userID];
    [defaults setInteger:self.currentGrouping forKey:key];
    [defaults synchronize];
    
    switch (self.currentGrouping) {
        case STMPhotoReportGroupingCampaign: {
            self.groupSwitcher.title = NSLocalizedString(@"GROUPING BY CAMPAIGN", nil);
            break;
        }
        case STMPhotoReportGroupingOutlet: {
            self.groupSwitcher.title = NSLocalizedString(@"GROUPING BY OUTLET", nil);
            break;
        }
        default: {
            break;
        }
    }
    
}


#pragma mark - camera button

- (void)setupCameraButton {
    [self updateCameraButton];
}

- (void)updateCameraButton {
    
    BOOL shouldEnableAddPhotoButton = [self shouldEnableAddPhotoButton];
    
    self.cameraButton.enabled = shouldEnableAddPhotoButton;

}

- (IBAction)cameraButtonPressed:(id)sender {

    self.filterTVC.lockSelection = YES;
    
    STMPhotoReportAddPhotoTVC *addPhotoTVC = [[STMPhotoReportAddPhotoTVC alloc] initWithStyle:UITableViewStyleGrouped];
    addPhotoTVC.parentVC = self;
    
    [self.navigationController pushViewController:addPhotoTVC animated:YES];

}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];


    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom10TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
    
    [self setupGroupSwitcher];
    [self setupCameraButton];
    
    [self performFetch];
    
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
