//
//  STMCampaignPhotoReportCVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCampaignPhotoReportCVC.h"
#import "STMOutlet+photoReportsArePresent.h"
#import "STMDocument.h"
#import "STMSessionManager.h"
#import "STMSession.h"
#import "STMLocationTracker.h"
#import "STMPhotoReport.h"
#import "STMPhoto.h"
#import "STMPhotoReportPVC.h"
#import "STMFunctions.h"
#import "STMObjectsController.h"
#import "STMPicturesController.h"
#import "STMCampaignsSVC.h"
#import "STMConstants.h"
#import "STMEntityDescription.h"
#import "STMImagePickerController.h"

@interface STMCampaignPhotoReportCVC ()  <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) STMDocument *document;
@property (nonatomic, strong) NSFetchedResultsController *photoReportPicturesResultsController;
@property (nonatomic, strong) STMPhotoReport *selectedPhotoReport;
@property (nonatomic, strong) STMOutlet *selectedOutlet;

@property (nonatomic, strong) NSArray *outlets;
@property (nonatomic) BOOL isTakingPhoto;
@property (nonatomic, strong) UIView *spinnerView;
@property (nonatomic, strong) NSBlockOperation *changeOperation;
@property (nonatomic, strong) STMCampaign *updatingCampaign;
@property (nonatomic) BOOL isUpdating;
@property (nonatomic) BOOL isPhotoLocationProcessing;
@property (nonatomic, strong) NSMutableArray *waitingLocationPhotos;
@property (nonatomic, strong) STMLocationTracker *locationTracker;

@property (nonatomic, strong) STMImagePickerController *imagePickerController;
@property (strong, nonatomic) IBOutlet UIView *cameraOverlayView;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) CGFloat shiftDistance;
@property (nonatomic) BOOL viewFrameWasChanged;

@property (nonatomic) UIImagePickerControllerSourceType selectedSourceType;

@end

@implementation STMCampaignPhotoReportCVC

@synthesize campaign = _campaign;


#pragma mark - variables setters & getters

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
    
}

- (NSFetchedResultsController *)photoReportPicturesResultsController {
    
    if (!_photoReportPicturesResultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhotoReport class])];
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
        
        request.predicate = [self campaignPredicate];
        
        _photoReportPicturesResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];

//        _photoReportPicturesResultsController.delegate = self;
        
    }
    
    return _photoReportPicturesResultsController;
    
}

- (NSPredicate *)campaignPredicate {
    
    NSMutableArray *subpredicates = [NSMutableArray array];
    
    NSPredicate *campaignPredicate = [NSPredicate predicateWithFormat:@"campaign == %@", self.campaign];
    
    [subpredicates addObject:campaignPredicate];
    
//    if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
//        [subpredicates addObject:[NSPredicate predicateWithFormat:@"outlet.name CONTAINS[cd] %@", self.searchBar.text]];
//    }
    
    [subpredicates addObject:[STMPredicate predicateWithNoFantoms]];
    
    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    
    return predicate;
    
}

- (NSPredicate *)outletPredicate {
    
    NSMutableArray *subpredicates = [NSMutableArray array];
    
    NSPredicate *outletPredicate = [NSPredicate predicateWithFormat:@"name != %@", nil];
    
    [subpredicates addObject:outletPredicate];
    
    if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
        [subpredicates addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchBar.text]];
    }
    
    [subpredicates addObject:[STMPredicate predicateWithNoFantoms]];
    
    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    
    return predicate;

}

- (void)setCampaign:(STMCampaign *)campaign {
    
    if (campaign != _campaign) {
        
        _campaign = campaign;
        
        self.selectedPhotoReport = nil;
        [self fetchPhotoReport];
        
    }
    
}

- (NSArray *)outlets {
    
    if (!_outlets) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMOutlet class])];
        
        NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        
        request.predicate = [self outletPredicate];
        
        NSError *error;
        NSArray *outlets = [self.document.managedObjectContext executeFetchRequest:request error:&error];

        NSMutableSet *outletsSet = [NSMutableSet setWithArray:outlets];
        
        NSMutableSet *outletsWithPhotoReports = [NSMutableSet set];
        
        for (STMOutlet *outlet in outlets) {
            
            NSMutableArray *campaigns = [NSMutableArray array];
            
            for (STMPhotoReport *photoReport in outlet.photoReports) {
                
                if (photoReport.campaign) {
                    [campaigns addObject:photoReport.campaign];
                }
                
            }
            
            if ([campaigns containsObject:self.campaign]) {
                [outletsWithPhotoReports addObject:outlet];
            }
            
        }
        
        [outletsSet minusSet:outletsWithPhotoReports];
        NSSet *outletsWithOutPhotoReports = outletsSet;
        
        NSMutableArray *outletsWPR = [[outletsWithPhotoReports sortedArrayUsingDescriptors:@[nameSortDescriptor]] mutableCopy];
        NSArray *outletsWOPR = [outletsWithOutPhotoReports sortedArrayUsingDescriptors:@[nameSortDescriptor]];
        
        [outletsWPR addObjectsFromArray:outletsWOPR];
        outlets = outletsWPR;
        
        _outlets = outlets;
        
    }
    
    return _outlets;
    
}

- (UIView *)spinnerView {
    
    if (!_spinnerView) {
        
        UIView *view = [[UIView alloc] initWithFrame:self.splitViewController.view.frame];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor grayColor];
        view.alpha = 0.75;
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = view.center;
        spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [spinner startAnimating];
        [view addSubview:spinner];
 
        _spinnerView = view;
        
    }
    
    return _spinnerView;
    
}

- (STMImagePickerController *)imagePickerController {
    
    if (!_imagePickerController) {
        
        STMImagePickerController *imagePickerController = [[STMImagePickerController alloc] init];
        imagePickerController.delegate = self;
                
        imagePickerController.sourceType = self.selectedSourceType;
        
        if (imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
            
            imagePickerController.showsCameraControls = NO;
            
            [[NSBundle mainBundle] loadNibNamed:@"STMCameraOverlayView" owner:self options:nil];
            self.cameraOverlayView.backgroundColor = [UIColor clearColor];
            self.cameraOverlayView.autoresizesSubviews = YES;
            self.cameraOverlayView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                
                UIView *rootView = [[[UIApplication sharedApplication] keyWindow] rootViewController].view;
                CGRect originalFrame = [[UIScreen mainScreen] bounds];
                CGRect screenFrame = [rootView convertRect:originalFrame fromView:nil];
                self.cameraOverlayView.frame = screenFrame;
                
            }
            
            imagePickerController.cameraOverlayView = self.cameraOverlayView;

        }
        
        _imagePickerController = imagePickerController;
        
    }
    
    return _imagePickerController;
    
}

- (NSMutableArray *)waitingLocationPhotos {
    
    if (!_waitingLocationPhotos) {
        _waitingLocationPhotos = [NSMutableArray array];
    }
    
    return _waitingLocationPhotos;
    
}

- (STMLocationTracker *)locationTracker {
    
    if (!_locationTracker) {
        
        _locationTracker = [(STMSession *)[STMSessionManager sharedManager].currentSession locationTracker];
        
    }
    
    return _locationTracker;
    
}


#pragma mark - image picker view buttons

- (IBAction)cameraButtonPressed:(id)sender {
    
    UIView *view = [[UIView alloc] initWithFrame:self.imagePickerController.cameraOverlayView.frame];
    view.backgroundColor = [UIColor grayColor];
    view.alpha = 0.75;
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = view.center;
    [spinner startAnimating];
    [view addSubview:spinner];

    [self.imagePickerController.cameraOverlayView addSubview:view];
    
    [self.imagePickerController takePicture];
    
}

- (IBAction)cancelButtonPressed:(id)sender {

    [self imagePickerControllerDidCancel:self.imagePickerController];
    
}

- (IBAction)photoLibraryButtonPressed:(id)sender {
    
    [self cancelButtonPressed:sender];
    
    STMOutlet *outlet = self.selectedOutlet;
    STMPhotoReport *photoReport = (STMPhotoReport *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMPhotoReport class])];
    photoReport.isFantom = @NO;
    photoReport.outlet = outlet;
    self.selectedPhotoReport = photoReport;

    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
}


#pragma mark - methods

- (void)fetchPhotoReport {
    
    self.photoReportPicturesResultsController = nil;
    self.outlets = nil;
    
    NSError *error;
    if (![self.photoReportPicturesResultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
        if (!self.isUpdating) {
            
            BOOL searchBarWasActive = [self.searchBar isFirstResponder];
            
            [self.collectionView reloadData];
            
            if (searchBarWasActive) {
                [self.searchBar becomeFirstResponder];
            }

        }
        
    }
    
}

- (NSArray *)photoReportsInOutlet:(STMOutlet *)outlet {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"outlet == %@", outlet];
    return [self.photoReportPicturesResultsController.fetchedObjects filteredArrayUsingPredicate:predicate];
    
}

- (void)outletHeaderPressed:(id)sender {
    
    NSInteger tag = [sender view].tag;
    
    STMOutlet *outlet = self.outlets[tag];
    
    STMPhotoReport *photoReport = (STMPhotoReport *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMPhotoReport class])];
    photoReport.isFantom = @NO;
    photoReport.outlet = outlet;
    
    self.selectedOutlet = outlet;

//    [self.document saveDocument:^(BOOL success) {
//        if (success) {
//                NSLog(@"create new photoReport");
//        }
//    }];
    
    self.selectedPhotoReport = photoReport;

    [(UIView *)[sender view] setBackgroundColor:ACTIVE_BLUE_COLOR];
    
//    [self showImagePickerSelector];
    
    BOOL camera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibrary = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];

    if (camera) {
        
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
        
    } else if (photoLibrary) {
        
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
    } else {
        
        [STMObjectsController removeObject:self.selectedPhotoReport];

    }
    
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)imageSourceType {
    
    if ([UIImagePickerController isSourceTypeAvailable:imageSourceType]) {
        
        self.selectedSourceType = imageSourceType;
        
        [self.splitViewController presentViewController:self.imagePickerController animated:YES completion:^{
            
            [self.splitViewController.view addSubview:self.spinnerView];
//            NSLog(@"presentViewController:UIImagePickerController");
            
        }];
        
    }
    
}

- (void)saveImage:(UIImage *)image {

    CGFloat jpgQuality = [STMPicturesController jpgQuality];
    [STMPicturesController setImagesFromData:UIImageJPEGRepresentation(image, jpgQuality) forPicture:self.selectedPhotoReport];

    [self.selectedPhotoReport addObserver:self forKeyPath:@"imageThumbnail" options:NSKeyValueObservingOptionNew context:nil];
    self.selectedPhotoReport.campaign = self.campaign;
    
    [self.waitingLocationPhotos addObject:self.selectedPhotoReport];
    [self.locationTracker getLocation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoReportsChanged" object:self.splitViewController userInfo:@{@"campaign": self.campaign}];

    [[self document] saveDocument:^(BOOL success) {
        if (success) {

        }
    }];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([object isKindOfClass:[STMPhoto class]]) {
        
        [self fetchPhotoReport];
        [self.spinnerView removeFromSuperview];
        self.spinnerView = nil;
        
        [object removeObserver:self forKeyPath:@"imageThumbnail" context:nil];
        
    }
    
}

- (void)photosCountChanged {
    
    [self fetchPhotoReport];
    
}

- (void)currentLocationWasUpdated:(NSNotification *)notification {
    
    if (self.waitingLocationPhotos.count > 0 && !self.isPhotoLocationProcessing) {
    
        CLLocation *currentLocation = (notification.userInfo)[@"currentLocation"];
        NSLog(@"currentLocation %@", currentLocation);

        STMLocation *location = [self.locationTracker locationObjectFromCLLocation:currentLocation];

        [self setLocationForWaitingLocationPhotos:location];

    }
    
}

- (void)setLocationForWaitingLocationPhotos:(STMLocation *)location {
    
    self.isPhotoLocationProcessing = YES;
    NSArray *photos = self.waitingLocationPhotos.copy;
    
    for (STMPhoto *photo in photos) {
        
        photo.location = location;
        
        [self.waitingLocationPhotos removeObject:photo];
        
    }
    
    if (self.waitingLocationPhotos.count > 0) {
        [self setLocationForWaitingLocationPhotos:location];
    } else {
        self.isPhotoLocationProcessing = NO;
    }

}

- (void)photoReportWasDeleted:(STMPhotoReport *)photoReport {
    [self.waitingLocationPhotos removeObject:photoReport];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
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

    [self.spinnerView removeFromSuperview];
    [STMObjectsController removeObject:self.selectedPhotoReport];
    self.imagePickerController = nil;

}

#pragma mark - UICollectionViewDataSource, Delegate, DelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  
    return self.outlets.count;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    STMOutlet *outlet = self.outlets[section];
    NSArray *photoReports = [self photoReportsInOutlet:outlet];
    
    return photoReports.count;

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"outletHeader" forIndexPath:indexPath];
    
    headerView.tag = indexPath.section;
    
    STMOutlet *outlet = self.outlets[indexPath.section];

    if (outlet == self.selectedOutlet) {

        headerView.backgroundColor = ACTIVE_BLUE_COLOR;

    } else {
     
        headerView.backgroundColor = [UIColor whiteColor];

    }
    
    UILabel *label;
    
    for (UIView *view in headerView.subviews) {
        
        if ([view isKindOfClass:[UILabel class]]) {
            
            label = (UILabel *)view;
            
            label.text = outlet.name;
            label.textColor = [UIColor blackColor];
            
        }
        
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 1)];
    line.backgroundColor = GREY_LINE_COLOR;
    [headerView addSubview:line];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outletHeaderPressed:)];
    [headerView addGestureRecognizer:tap];

    return headerView;
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"photoReportCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [[cell.contentView viewWithTag:1] removeFromSuperview];
    
    STMOutlet *outlet = self.outlets[indexPath.section];
    STMPhotoReport *photoReport = [self photoReportsInOutlet:outlet][indexPath.row];
    
    CGRect frame = CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    imageView.image = [UIImage imageWithData:photoReport.imageThumbnail];
    imageView.tag = 1;
    [cell.contentView addSubview:imageView];
    
    return cell;
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    STMOutlet *outlet = self.outlets[indexPath.section];
    self.selectedPhotoReport = [self photoReportsInOutlet:outlet].lastObject;
    
    [self performSegueWithIdentifier:@"showPhotoReport" sender:indexPath];
    
    return YES;
    
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    NSLog(@"controllerWillChangeContent");
    self.isUpdating = YES;
    self.changeOperation = [[NSBlockOperation alloc] init];
    self.updatingCampaign = self.campaign;

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
//    NSLog(@"controllerDidChangeContent");
    
    self.isUpdating = NO;
    
    if (self.updatingCampaign != self.campaign) {
        
        //        NSLog(@"campaign changed before updating");
        
        [self.collectionView reloadData];
        
    } else {
        
        [self.collectionView performBatchUpdates:^{
            
            [self.changeOperation start];
            
        } completion:^(BOOL finished) {
            
            if (finished) {
                
                if (self.updatingCampaign != self.campaign) {
                    
                    //                    NSLog(@"campaign changed while updating");
                    
                    [self.collectionView reloadData];
                    
                } else {
                    
                }
                
                [self.document saveDocument:^(BOOL success) {
                    if (success) {
                        
                    }
                }];
                
            }
            
        }];
        
    }
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSLog(@"controller didChangeObject");
    //    NSLog(@"anObject %@", anObject);

    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            
            [self.changeOperation addExecutionBlock:^{
                [collectionView insertSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] ];
            }];
            break;
            
        }
            
        case NSFetchedResultsChangeDelete: {
            
            [self.waitingLocationPhotos removeObject:anObject];
            [self.changeOperation addExecutionBlock:^{
                [collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            }];
            break;
            
        }
            
        case NSFetchedResultsChangeUpdate: {
            
            [self.changeOperation addExecutionBlock:^{
                [collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"campaignPictureUpdate" object:anObject];
            }];
            break;
            
        }
            
        case NSFetchedResultsChangeMove: {
            
            [self.changeOperation addExecutionBlock:^{
                [collectionView moveSection:indexPath.section toSection:newIndexPath.section];
            }];
            break;
            
        }
            
        default:
            break;
            
    }
 
}


#pragma mark - search & UISearchBarDelegate

- (void)searchButtonPressed {
    
    [self.searchBar becomeFirstResponder];
    [self.collectionView setContentOffset:CGPointZero animated:YES];
    
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self fetchPhotoReport];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = YES;
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = NO;
    searchBar.text = nil;
    
    [self hideKeyboard];
    [self fetchPhotoReport];
    
}


- (void)hideKeyboard {
    
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self hideKeyboard];
    
}


#pragma mark - keyboard show / hide

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGFloat keyboardHeight = [self keyboardHeightFrom:[notification userInfo]];
    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    CGFloat toolbarHeight = self.navigationController.toolbar.frame.size.height;
    
    self.shiftDistance = keyboardHeight - tabBarHeight - toolbarHeight;
    
    if (!self.viewFrameWasChanged) {
        
        [self changeViewFrameByDistance:self.shiftDistance];
        self.viewFrameWasChanged = YES;

    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    if (self.viewFrameWasChanged) {
        
        [self changeViewFrameByDistance:-self.shiftDistance];
        self.viewFrameWasChanged = NO;
        
    }
    
}

- (CGFloat)keyboardHeightFrom:(NSDictionary *)info {
    
    CGRect keyboardRect = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    keyboardRect = [[[UIApplication sharedApplication].delegate window] convertRect:keyboardRect fromView:self.view];
    
    return keyboardRect.size.height;
    
}

- (void)changeViewFrameByDistance:(CGFloat)distance {
    
    const float movementDuration = 0.5f;
    
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:movementDuration];
    
    CGFloat x = self.collectionView.frame.origin.x;
    CGFloat y = self.collectionView.frame.origin.y;
    CGFloat width = self.collectionView.frame.size.width;
    CGFloat height = self.collectionView.frame.size.height;
    
    self.collectionView.frame = CGRectMake(x, y, width, height - distance);
    
    [UIView commitAnimations];

}


#pragma mark - view lifecycle

- (void)addSpinner {
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    activity.hidesWhenStopped = YES;
    
    activity.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleWidth;
    
    [self.collectionView addSubview:activity];
    
    [activity startAnimating];
    
    [activity performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.5];
    
}

- (void)addObservers {

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
//    [nc addObserver:self
//           selector:@selector(keyboardWillShow:)
//               name:UIKeyboardWillShowNotification
//             object:nil];
//    
//    [nc addObserver:self
//           selector:@selector(keyboardWillBeHidden:)
//               name:UIKeyboardWillHideNotification
//             object:nil];

    [nc addObserver:self
           selector:@selector(photosCountChanged)
               name:@"photosCountChanged"
             object:nil];
    
    [nc addObserver:self
           selector:@selector(currentLocationWasUpdated:)
               name:@"currentLocationWasUpdated"
             object:self.locationTracker];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {

    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, 44)];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.delegate = self;

    [self.view addSubview:self.searchBar];
    self.collectionView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);

    [self addObservers];
    [self addSpinner];
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"showPhotoReport"] && [segue.destinationViewController isKindOfClass:[STMPhotoReportPVC class]]) {
        
        STMPhotoReportPVC *photoReportPVC = (STMPhotoReportPVC *)segue.destinationViewController;
        
        photoReportPVC.photoArray = [[self photoReportsInOutlet:self.selectedPhotoReport.outlet] mutableCopy];
        photoReportPVC.currentIndex = [(NSIndexPath *)sender row];
        photoReportPVC.parentVC = self;
        
    }

}

@end
