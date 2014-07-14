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
#import "STMPhotoReport.h"
#import "STMPhoto.h"
#import "STMPhotoReportPVC.h"
#import "STMFunctions.h"
#import "STMObjectsController.h"
#import "STMCampaignsSVC.h"


@interface STMCampaignPhotoReportCVC ()  <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) STMDocument *document;
@property (nonatomic, strong) NSFetchedResultsController *photoReportPicturesResultsController;
@property (nonatomic, strong) STMPhotoReport *selectedPhotoReport;
@property (nonatomic) NSUInteger currentSection;
@property (nonatomic, strong) NSArray *outlets;
@property (nonatomic) BOOL isTakingPhoto;
@property (nonatomic, strong) UIView *spinnerView;
@property (nonatomic, strong) NSBlockOperation *changeOperation;
@property (nonatomic, strong) STMCampaign *updatingCampaign;
@property (nonatomic) BOOL isUpdating;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) IBOutlet UIView *cameraOverlayView;


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
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"campaign == %@", self.campaign];
        _photoReportPicturesResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];

    }
    
    return _photoReportPicturesResultsController;
    
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
//
//        request.sortDescriptors = [NSArray arrayWithObject:nameSortDescriptor];
        
        NSError *error;
        NSArray *outlets = [self.document.managedObjectContext executeFetchRequest:request error:&error];

        NSMutableSet *outletsSet = [NSMutableSet setWithArray:outlets];
        
        NSMutableSet *outletsWithPhotoReports = [NSMutableSet set];
        
        for (STMOutlet *outlet in outlets) {
            
            NSMutableArray *campaigns = [NSMutableArray array];
            
            for (STMPhotoReport *photoReport in outlet.photoReports) {
                [campaigns addObject:photoReport.campaign];
            }
            
            if ([campaigns containsObject:self.campaign]) {
                [outletsWithPhotoReports addObject:outlet];
            }
            
        }
        
        [outletsSet minusSet:outletsWithPhotoReports];
        NSSet *outletsWithOutPhotoReports = outletsSet;
        
        NSMutableArray *outletsWPR = [[outletsWithPhotoReports sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameSortDescriptor]] mutableCopy];
        NSArray *outletsWOPR = [outletsWithOutPhotoReports sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameSortDescriptor]];
        
        [outletsWPR addObjectsFromArray:outletsWOPR];
        outlets = outletsWPR;
        
//        NSSortDescriptor *photoReportsCountSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"photoReportsArePresent" ascending:NO selector:@selector(compare:)];

//        outlets = [outlets sortedArrayUsingDescriptors:[NSArray arrayWithObject:photoReportsCountSortDescriptor]];
        
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

- (void)setCurrentSection:(NSUInteger)currentSection {
    
    if (currentSection != _currentSection) {
        
        NSUInteger previousSection = _currentSection;
        
        _currentSection = currentSection;

        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:previousSection]];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:currentSection]];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:currentSection];
        
//        if ([self.collectionView cellForItemAtIndexPath:indexPath]) {
        
//            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        
            UICollectionViewLayoutAttributes *headerAttribute = [self.collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
            [self.collectionView scrollRectToVisible:headerAttribute.frame animated:YES];

        
//        }
        
    }
    
}

- (UIImagePickerController *)imagePickerController {
    
    if (!_imagePickerController) {
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.showsCameraControls = NO;

        [[NSBundle mainBundle] loadNibNamed:@"STMCameraOverlayView" owner:self options:nil];
        self.cameraOverlayView.backgroundColor = [UIColor clearColor];
        self.cameraOverlayView.autoresizesSubviews = YES;
        self.cameraOverlayView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        imagePickerController.cameraOverlayView = self.cameraOverlayView;
        
        _imagePickerController = imagePickerController;
        
    }
    
    return _imagePickerController;
    
}

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
    
    [self.imagePickerController dismissViewControllerAnimated:NO completion:^{
        
        [self.spinnerView removeFromSuperview];
        
//        if (self.selectedPhotoReport.photos.count == 0) {
//            [self.document.managedObjectContext deleteObject:self.selectedPhotoReport];
//            //            NSLog(@"delete empty photoReport");
//        }

        self.imagePickerController = nil;
//        NSLog(@"cancel button pressed");
        
    }];
    
}



#pragma mark - methods

- (void)fetchPhotoReport {
    
    self.photoReportPicturesResultsController = nil;
    self.outlets = nil;
    
    STMOutlet *selectedOutlet = self.selectedPhotoReport.outlet;
    
    NSError *error;
    if (![self.photoReportPicturesResultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
        if (!self.isUpdating) {
            
            [self.collectionView reloadData];
            
            if (selectedOutlet) {
                
                self.currentSection = [self.outlets indexOfObject:selectedOutlet];
                
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
//    self.selectedPhotoReport = [self photoReportsInOutlet:outlet].lastObject;
    
//    if (!self.selectedPhotoReport) {
    
        STMPhotoReport *photoReport = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMPhotoReport class]) inManagedObjectContext:self.document.managedObjectContext];
        photoReport.outlet = outlet;
//        photoReport.campaign = self.campaign;
    
        [self.document saveDocument:^(BOOL success) {
            if (success) {
//                NSLog(@"create new photoReport");
            }
        }];
        
        self.selectedPhotoReport = photoReport;

//    }

    self.currentSection = tag;
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)imageSourceType {
    
    if ([UIImagePickerController isSourceTypeAvailable:imageSourceType]) {
        
        [self.splitViewController presentViewController:self.imagePickerController animated:YES completion:^{
            
            [self.splitViewController.view addSubview:self.spinnerView];
//            NSLog(@"presentViewController:UIImagePickerController");
            
        }];
        
    }
    
}

- (void)saveImage:(UIImage *)image {

//    STMPhotoReport *photoReport = (STMPhotoReport *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMPhotoReport class]) inManagedObjectContext:[self document].managedObjectContext];

//    [STMObjectsController setImagesFromData:UIImagePNGRepresentation(image) forPicture:photo];
    [STMObjectsController setImagesFromData:UIImageJPEGRepresentation(image, 0.0) forPicture:self.selectedPhotoReport];

    [self.selectedPhotoReport addObserver:self forKeyPath:@"imageThumbnail" options:NSKeyValueObservingOptionNew context:nil];
    
//    [self.selectedPhotoReport addPhotosObject:photo];
    
//    self.selectedPhotoReport = photoReport;
  
    self.selectedPhotoReport.campaign = self.campaign;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"photoReportsChanged" object:self.splitViewController userInfo:[NSDictionary dictionaryWithObject:self.campaign forKey:@"campaign"]];

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


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
//    NSLog(@"picker didFinishPickingMediaWithInfo");
    
    [picker dismissViewControllerAnimated:NO completion:^{
        
        [self saveImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
        self.imagePickerController = nil;
//        NSLog(@"dismiss UIImagePickerController");
        
    }];
    
}

//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    
//    [picker dismissViewControllerAnimated:NO completion:^{
//        
//        [self.spinnerView removeFromSuperview];
//        
//        if (self.selectedPhotoReport.photos.count == 0) {
//            [self.document.managedObjectContext deleteObject:self.selectedPhotoReport];
////            NSLog(@"delete empty photoReport");
//        }
//        
//        NSLog(@"imagePickerControllerDidCancel");
//        
//    }];
//    
//}

#pragma mark - UICollectionViewDataSource, Delegate, DelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  
    return self.outlets.count;
//    return self.photoReportPicturesResultsController.fetchedObjects.count;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    STMOutlet *outlet = self.outlets[section];
    NSArray *photoReports = [self photoReportsInOutlet:outlet];
    
    return photoReports.count;

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    //    if (kind == UICollectionElementKindSectionHeader) {
    //
    //    }
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"outletHeader" forIndexPath:indexPath];
    
    headerView.tag = indexPath.section;
    
    if (indexPath.section == self.currentSection && self.selectedPhotoReport) {

        headerView.backgroundColor = [UIColor colorWithRed:0.6 green:0.8 blue:1 alpha:1.0];
        headerView.backgroundColor = [UIColor yellowColor];

    } else {
     
        headerView.backgroundColor = [UIColor whiteColor];

    }
    
    STMOutlet *outlet = self.outlets[indexPath.section];
    
    UILabel *label;
    
    for (UIView *view in headerView.subviews) {
        
        if ([view isKindOfClass:[UILabel class]]) {
            
            label = (UILabel *)view;
            
            label.text = outlet.name;
            label.textColor = [UIColor blackColor];
            
        }
        
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 1)];
    line.backgroundColor = [UIColor colorWithRed:0.785 green:0.78 blue:0.8 alpha:1];
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
    self.currentSection = indexPath.section;
    
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
    
//    [self.document saveDocument:^(BOOL success) {
//        if (success) {
//            
//        }
//    }];
    
//    [self fetchPhotoReport];
    
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

- (void)customInit {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photosCountChanged) name:@"photosCountChanged" object:nil];
    [self addSpinner];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
        
//        [(STMPhotoReportPVC *)segue.destinationViewController setPhotoReport:self.selectedPhotoReport];
        [(STMPhotoReportPVC *)segue.destinationViewController setPhotoArray:[[self photoReportsInOutlet:self.selectedPhotoReport.outlet] mutableCopy]];
        [(STMPhotoReportPVC *)segue.destinationViewController setCurrentIndex:[(NSIndexPath *)sender row]];

        
    }

}

@end
