//
//  STMCampaignPhotoReportCVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCampaignPhotoReportCVC.h"
#import "STMOutlet.h"
#import "STMDocument.h"
#import "STMSessionManager.h"
#import "STMPhotoReport.h"
#import "STMPhoto.h"
#import "STMPhotoReportPVC.h"
#import "STMFunctions.h"

@interface STMCampaignPhotoReportCVC ()  <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) STMDocument *document;
@property (nonatomic, strong) NSFetchedResultsController *photoReportPicturesResultsController;
@property (nonatomic, strong) STMPhotoReport *selectedPhotoReport;
@property (nonatomic) NSUInteger currentSection;
@property (nonatomic, strong) NSArray *outlets;
@property (nonatomic) BOOL isTakingPhoto;
@property (nonatomic, strong) UIView *spinnerView;

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
        
        self.photoReportPicturesResultsController = nil;
        [self fetchPhotoReport];
        
    }
    
}

- (NSArray *)outlets {
    
    if (!_outlets) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMOutlet class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        //        request.predicate = [NSPredicate predicateWithFormat:@"photoReport.campaign == %@", self.campaign];
        
        NSError *error;
        _outlets = [self.document.managedObjectContext executeFetchRequest:request error:&error];
        
    }
    
    return _outlets;
    
}

- (UIView *)spinnerView {
    
    if (!_spinnerView) {
        
        UIView *view = [[UIView alloc] initWithFrame:self.view.frame];
        view.backgroundColor = [UIColor grayColor];
        view.alpha = 0.75;
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.center = view.center;
        [spinner startAnimating];
        [view addSubview:spinner];
 
        _spinnerView = view;
        
    }
    
    return _spinnerView;
    
}

#pragma mark - methods

- (void)fetchPhotoReport {
    
    NSError *error;
    if (![self.photoReportPicturesResultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
        [self.collectionView reloadData];
        
    }
    
}

- (NSArray *)photoReportInOutlet:(STMOutlet *)outlet {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"outlet == %@", outlet];
    return [self.photoReportPicturesResultsController.fetchedObjects filteredArrayUsingPredicate:predicate];
    
}

- (void)photoButtonPressed:(UIButton *)sender {
    
    STMOutlet *outlet = self.outlets[sender.tag];
    self.selectedPhotoReport = [self photoReportInOutlet:outlet].lastObject;
    
    if (!self.selectedPhotoReport) {
        
        STMPhotoReport *photoReport = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMPhotoReport class]) inManagedObjectContext:self.document.managedObjectContext];
        photoReport.outlet = outlet;
        photoReport.campaign = self.campaign;
        
        [self.document saveDocument:^(BOOL success) {
            if (success) {
                NSLog(@"create new photoReport");
            }
        }];
        
        self.selectedPhotoReport = photoReport;

    }

    self.currentSection = sender.tag;
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)imageSourceType {
    
    if ([UIImagePickerController isSourceTypeAvailable:imageSourceType]) {
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = imageSourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{
            
            [self.view addSubview:self.spinnerView];
//            NSLog(@"presentViewController:UIImagePickerController");
            
        }];
        
    }
    
}

- (void)saveImage:(UIImage *)image {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        STMPhoto *photo = (STMPhoto *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMPhoto class]) inManagedObjectContext:[self document].managedObjectContext];
        photo.image = UIImagePNGRepresentation(image);
        
        UIImage *imageThumbnail = [STMFunctions resizeImage:image toSize:CGSizeMake(150, 150)];
        photo.imageThumbnail = UIImagePNGRepresentation(imageThumbnail);
        
        [self.selectedPhotoReport addPhotosObject:photo];

        dispatch_async(dispatch_get_main_queue(), ^{

            self.photoReportPicturesResultsController = nil;
            [self fetchPhotoReport];
            [self.spinnerView removeFromSuperview];
            
        });

        [[self document] saveDocument:^(BOOL success) {
            if (success) {
//                NSLog(@"photo UIDocumentSaveForOverwriting success");
//                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:self.currentSection]];
            }
        }];

    });
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:NO completion:^{
        
        [self saveImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
//        NSLog(@"dismiss UIImagePickerController");
        
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:NO completion:^{
        
        [self.spinnerView removeFromSuperview];
//        NSLog(@"imagePickerControllerDidCancel");
        
    }];
    
}

#pragma mark - UICollectionViewDataSource, Delegate, DelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  
    return self.outlets.count;
//    return self.photoReportPicturesResultsController.fetchedObjects.count;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    STMOutlet *outlet = self.outlets[section];
    STMPhotoReport *photoReport = [self photoReportInOutlet:outlet].lastObject;
    
    return photoReport.photos.count;

}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    //    if (kind == UICollectionElementKindSectionHeader) {
    //
    //    }
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"outletHeader" forIndexPath:indexPath];
    
    STMOutlet *outlet = self.outlets[indexPath.section];
    
    UILabel *label;
    UIButton *photoButton;
    
    for (UIView *view in headerView.subviews) {
        
        if ([view isKindOfClass:[UILabel class]]) {
            
            label = (UILabel *)view;
            
            label.text = outlet.name;
            label.textColor = [UIColor blackColor];
            
        } else if ([view isKindOfClass:[UIButton class]]) {
            
            photoButton = (UIButton *)view;
            
            for (UIView *subview in photoButton.subviews) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    [subview removeFromSuperview];
                }
            }
            
            UIImage *image = [UIImage imageNamed:@"photo-icon.png"];
            CGFloat k = 0.666;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width * k, image.size.height * k)];
            imageView.image = image;
            [photoButton addSubview:imageView];
            
            [photoButton setTitle:@"" forState:UIControlStateNormal];
            
            photoButton.tag = indexPath.section;
            
            [photoButton addTarget:self action:@selector(photoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 1)];
    line.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:line];
    
    return headerView;
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"photoReportCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [[cell.contentView viewWithTag:1] removeFromSuperview];
    
    STMOutlet *outlet = self.outlets[indexPath.section];
    STMPhotoReport *photoReport = [self photoReportInOutlet:outlet].lastObject;
    
    CGRect frame = CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    STMPhoto *photo = [photoReport.photos sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:NO]]][indexPath.row];
    imageView.image = [UIImage imageWithData:photo.imageThumbnail];
    imageView.tag = 1;
    [cell.contentView addSubview:imageView];
    
    return cell;
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    STMOutlet *outlet = self.outlets[indexPath.section];
    self.selectedPhotoReport = [self photoReportInOutlet:outlet].lastObject;

    [self performSegueWithIdentifier:@"showPhotoReport" sender:indexPath];
    
    return YES;
    
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    NSLog(@"controllerWillChangeContent");
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    NSLog(@"controllerDidChangeContent");
//    [self.document saveDocument:^(BOOL success) {
//        if (success) {
//            
//        }
//    }];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSLog(@"controller didChangeObject");
    //    NSLog(@"anObject %@", anObject);

    if ([anObject isKindOfClass:[STMPhotoReport class]]) {
        
        STMPhotoReport *photoReport = anObject;
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[self.outlets indexOfObject:photoReport.outlet]]];
        
    }

    if (type == NSFetchedResultsChangeDelete) {
        
//        [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
        NSLog(@"NSFetchedResultsChangeDelete");
        
    } else if (type == NSFetchedResultsChangeInsert) {
        
//        [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
        NSLog(@"NSFetchedResultsChangeInsert");
        
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
//        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        NSLog(@"NSFetchedResultsChangeUpdate");
        
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
        
        [(STMPhotoReportPVC *)segue.destinationViewController setPhotoReport:self.selectedPhotoReport];
        [(STMPhotoReportPVC *)segue.destinationViewController setCurrentIndex:[(NSIndexPath *)sender row]];
        
    }

}

@end
