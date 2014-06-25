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

@end

@implementation STMCampaignPhotoReportCVC

@synthesize campaign = _campaign;

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
    
}

- (NSFetchedResultsController *)photoReportPicturesResultsController {
    
    if (!_photoReportPicturesResultsController) {
        
        //        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhoto class])];
        //        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES selector:@selector(compare:)]];
        //        request.predicate = [NSPredicate predicateWithFormat:@"photoReport.campaign == %@", self.campaign];
        //        _photoReportPicturesResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:@"photoReport.outlet.name" cacheName:nil];
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMOutlet class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        //        request.predicate = [NSPredicate predicateWithFormat:@"photoReport.campaign == %@", self.campaign];
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

- (void)fetchPhotoReport {
    
    NSError *error;
    if (![self.photoReportPicturesResultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
        //        for (STMCampaignPicture *picture in self.campaignPicturesResultsController.fetchedObjects) {
        //
        //            if (!picture.image) {
        //                //                NSLog(@"no image");
        //                [STMObjectsController hrefProcessingForObject:picture];
        //            }
        //
        //        }
        
        for (STMOutlet *outlet in self.photoReportPicturesResultsController.fetchedObjects) {
            
            if (outlet.photoReports.count == 0) {
                
                STMPhotoReport *photoReport = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMPhotoReport class]) inManagedObjectContext:self.document.managedObjectContext];
                [outlet addPhotoReportsObject:photoReport];
                
            }
            
        }
        
        [self.collectionView reloadData];
        
    }
    
}

- (void)photoButtonPressed:(UIButton *)sender {
    
    STMOutlet *outlet = self.photoReportPicturesResultsController.fetchedObjects[sender.tag];
    self.selectedPhotoReport = outlet.photoReports.anyObject;
    self.currentSection = sender.tag;
    
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
//    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)imageSourceType {
    
    if ([UIImagePickerController isSourceTypeAvailable:imageSourceType]) {
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = imageSourceType;
        [self presentViewController:imagePickerController animated:YES completion:^{
            NSLog(@"presentViewController:UIImagePickerController");
        }];
        
    }
    
}

- (void)saveImage:(UIImage *)image {
    
    STMPhoto *photo = (STMPhoto *)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([STMPhoto class]) inManagedObjectContext:[self document].managedObjectContext];
    photo.image = UIImagePNGRepresentation(image);
    
    UIImage *imageThumbnail = [STMFunctions resizeImage:image toSize:CGSizeMake(150, 150)];
    photo.imageThumbnail = UIImagePNGRepresentation(imageThumbnail);
    
    [self.selectedPhotoReport addPhotosObject:photo];
    
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:self.currentSection]];
    
    [[self document] saveDocument:^(BOOL success) {
        NSLog(@"spotImage UIDocumentSaveForOverwriting success");
    }];
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        [self saveImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
        NSLog(@"dismiss UIImagePickerController");
        
    }];
    
}


#pragma mark - UICollectionViewDataSource, Delegate, DelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return self.photoReportPicturesResultsController.fetchedObjects.count;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    //        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.photoReportPicturesResultsController sections] objectAtIndex:section];
    //        return [sectionInfo numberOfObjects] + 1;
    
    STMOutlet *outlet = self.photoReportPicturesResultsController.fetchedObjects[section];
    STMPhotoReport *photoReport = [outlet.photoReports anyObject];
    //        NSLog(@"outlet.name %@", outlet.name);
    //        NSLog(@"outlet.photoReports.count %d", outlet.photoReports.count);
    //        NSLog(@"photoReport.photos.count %d", photoReport.photos.count);
    return photoReport.photos.count;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    //    if (kind == UICollectionElementKindSectionHeader) {
    //
    //    }
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"outletHeader" forIndexPath:indexPath];
    
    STMOutlet *outlet = self.photoReportPicturesResultsController.fetchedObjects[indexPath.section];
    
    UILabel *label;
    UIButton *photoButton;
    
    for (UIView *view in headerView.subviews) {
        
        if ([view isKindOfClass:[UILabel class]]) {
            
            label = (UILabel *)view;
            
            label.text = outlet.name;
            label.textColor = [UIColor grayColor];
            
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
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height-1, headerView.frame.size.width, 1)];
    line.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:line];
    
    return headerView;
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"photoReportCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [[cell.contentView viewWithTag:1] removeFromSuperview];
    
    STMOutlet *outlet = self.photoReportPicturesResultsController.fetchedObjects[indexPath.section];
    STMPhotoReport *photoReport = outlet.photoReports.anyObject;
    
    //        NSLog(@"outlet %@", outlet);
    //        NSLog(@"photoReport %@", photoReport);
    
    //        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.photoReportPicturesResultsController sections] objectAtIndex:indexPath.section];
    
    CGRect frame = CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
    
//    if (indexPath.row == photoReport.photos.count) {
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:frame];
//        label.text = NSLocalizedString(@"ADD PHOTO", nil);
//        label.lineBreakMode = NSLineBreakByWordWrapping;
//        label.numberOfLines = 0;
//        label.textAlignment = NSTextAlignmentCenter;
//        label.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        label.layer.borderWidth = 1.0;
//        label.tag = 1;
//        [cell.contentView addSubview:label];
//        
//    } else {
    
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        
        //            STMPhoto *photo = [[sectionInfo objects] objectAtIndex:indexPath.row];
        STMPhoto *photo = [photoReport.photos sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES]]][indexPath.row];
        imageView.image = [UIImage imageWithData:photo.imageThumbnail];
        imageView.tag = 1;
        [cell.contentView addSubview:imageView];
        
//    }
    
    
    return cell;
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    STMOutlet *outlet = self.photoReportPicturesResultsController.fetchedObjects[indexPath.section];
    self.selectedPhotoReport = outlet.photoReports.anyObject;

    [self performSegueWithIdentifier:@"showPhotoReport" sender:indexPath];
    
    return YES;
    
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    //    NSLog(@"controllerWillChangeContent");
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    //    NSLog(@"controllerDidChangeContent");
    [self.document saveDocument:^(BOOL success) {
        if (success) {
            
        }
    }];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    //    NSLog(@"controller didChangeObject");
    //    NSLog(@"anObject %@", anObject);
    
    if (type == NSFetchedResultsChangeDelete) {
        
        [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
        NSLog(@"NSFetchedResultsChangeDelete");
        
    } else if (type == NSFetchedResultsChangeInsert) {
        
        [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
        NSLog(@"NSFetchedResultsChangeInsert");
        
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        NSLog(@"NSFetchedResultsChangeUpdate");
        
    }
    
}


#pragma mark - view lifecycle


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
