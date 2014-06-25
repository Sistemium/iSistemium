//
//  STMCampaignDetailsVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

//#import <QuartzCore/QuartzCore.h>

#import "STMCampaignDetailsVC.h"
#import "STMRootTBC.h"
#import "STMCampaignPicture.h"
#import "STMSessionManager.h"
#import "STMDocument.h"
#import "STMObjectsController.h"
#import "STMCampaignPicturePVC.h"
#import "STMPhotoReport.h"
#import "STMPhoto.h"
#import "STMOutlet.h"

@interface STMCampaignDetailsVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *homeButton;
@property (nonatomic, strong) STMDocument *document;

@property (weak, nonatomic) IBOutlet UICollectionView *campaignPicturesCV;
@property (nonatomic, strong) NSFetchedResultsController *campaignPicturesResultsController;

@property (weak, nonatomic) IBOutlet UICollectionView *photoReportsPicturesCV;
@property (nonatomic, strong) NSFetchedResultsController *photoReportPicturesResultsController;


@property (weak, nonatomic) IBOutlet UIView *separationView;


@end


@implementation STMCampaignDetailsVC

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
    
}

- (NSFetchedResultsController *)campaignPicturesResultsController {
    
    if (!_campaignPicturesResultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCampaignPicture class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"ANY campaigns == %@", self.campaign];
        _campaignPicturesResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _campaignPicturesResultsController.delegate = self;
        
//        NSLog(@"_resultsController %@", _resultsController);
        
    }
    
    return _campaignPicturesResultsController;
    
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
        
        self.title = campaign.name;
        
        _campaign = campaign;
        
        self.campaignPicturesResultsController = nil;
        self.photoReportPicturesResultsController = nil;
        [self fetchPictures];
        [self fetchPhotoReport];
        [self.navigationController popToRootViewControllerAnimated:YES];

    }
    
}

- (void)fetchPictures {
    
    NSError *error;
    if (![self.campaignPicturesResultsController performFetch:&error]) {

        NSLog(@"performFetch error %@", error);
        
    } else {
        
        for (STMCampaignPicture *picture in self.campaignPicturesResultsController.fetchedObjects) {
            
            if (!picture.image) {
//                NSLog(@"no image");
                [STMObjectsController hrefProcessingForObject:picture];
            }
            
        }
        [self.campaignPicturesCV reloadData];
        
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
        
        [self.photoReportsPicturesCV reloadData];
        
    }

}

- (UIBarButtonItem *)homeButton {
    
    if (!_homeButton) {
        
        //        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(homeButtonPressed)];
        
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"HOME", nil) style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonPressed)];
        
        _homeButton = button;
        
    }
    
    return _homeButton;
    
}

- (void)homeButtonPressed {
    
    //    NSLog(@"homeButtonPressed");
    [[STMRootTBC sharedRootVC] showTabWithName:@"STMAuthTVC"];
    
    
}



#pragma mark - UICollectionViewDataSource, Delegate, DelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    if ([collectionView isEqual:self.campaignPicturesCV]) {
        
        return 1;
        
    } else if ([collectionView isEqual:self.photoReportsPicturesCV]) {
        
//        NSLog(@"photoReport count %d", [self.photoReportPicturesResultsController sections].count);
//        NSLog(@"outlets.count %d", self.campaign.outlets.count);
//        return [self.photoReportPicturesResultsController sections].count;
//        NSLog(@"outlet count %d", self.photoReportPicturesResultsController.fetchedObjects.count);
        return self.photoReportPicturesResultsController.fetchedObjects.count;
        
    } else {
        return 0;
    }

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    if ([collectionView isEqual:self.campaignPicturesCV]) {
        
        return self.campaignPicturesResultsController.fetchedObjects.count;
        
    } else if ([collectionView isEqual:self.photoReportsPicturesCV]) {
        
//        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.photoReportPicturesResultsController sections] objectAtIndex:section];
//        return [sectionInfo numberOfObjects] + 1;
        
        STMOutlet *outlet = self.photoReportPicturesResultsController.fetchedObjects[section];
        STMPhotoReport *photoReport = [outlet.photoReports anyObject];
//        NSLog(@"outlet.name %@", outlet.name);
//        NSLog(@"outlet.photoReports.count %d", outlet.photoReports.count);
//        NSLog(@"photoReport.photos.count %d", photoReport.photos.count);
        return photoReport.photos.count + 1;
        
    } else {
        return 0;
    }
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
//    if ([collectionView isEqual:self.photoReportsPicturesCV]) {
//        
//    }
//    
//    if (kind == UICollectionElementKindSectionHeader) {
//        
//    }
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"outletHeader" forIndexPath:indexPath];
    
    STMOutlet *outlet = self.photoReportPicturesResultsController.fetchedObjects[indexPath.section];

    UILabel *label;

    for (UIView *view in headerView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            label = (UILabel *)view;
        }
    }
    
    label.text = outlet.name;
    label.textColor = [UIColor grayColor];
    
    return headerView;
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.campaignPicturesCV]) {

        NSString *cellIdentifier = @"campaignPictureCell";
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        [[cell.contentView viewWithTag:1] removeFromSuperview];
        [[cell.contentView viewWithTag:2] removeFromSuperview];
        
        
        STMCampaignPicture *picture = self.campaignPicturesResultsController.fetchedObjects[indexPath.row];
        //    NSLog(@"picture %@", picture);
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 150)];
        imageView.image = [UIImage imageWithData:picture.image];
        imageView.tag = 1;
        [cell.contentView addSubview:imageView];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, cell.contentView.frame.size.width, 50)];
        label.text = picture.name;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = 2;
        [cell.contentView addSubview:label];
        
        return cell;

    } else if ([collectionView isEqual:self.photoReportsPicturesCV]) {
        
        NSString *cellIdentifier = @"photoReportCell";
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        [[cell.contentView viewWithTag:1] removeFromSuperview];

        STMOutlet *outlet = self.photoReportPicturesResultsController.fetchedObjects[indexPath.section];
        STMPhotoReport *photoReport = outlet.photoReports.anyObject;
        
//        NSLog(@"outlet %@", outlet);
//        NSLog(@"photoReport %@", photoReport);
        
//        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.photoReportPicturesResultsController sections] objectAtIndex:indexPath.section];

        CGRect frame = CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
        
        if (indexPath.row == photoReport.photos.count) {
            
            UILabel *label = [[UILabel alloc] initWithFrame:frame];
            label.text = NSLocalizedString(@"ADD PHOTO", nil);
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.numberOfLines = 0;
            label.textAlignment = NSTextAlignmentCenter;
            label.layer.borderColor = [UIColor lightGrayColor].CGColor;
            label.layer.borderWidth = 1.0;
            label.tag = 1;
            [cell.contentView addSubview:label];
            
        } else {

            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
            
//            STMPhoto *photo = [[sectionInfo objects] objectAtIndex:indexPath.row];
            STMPhoto *photo = [photoReport.photos sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"cts" ascending:YES]]][indexPath.row];
            imageView.image = [UIImage imageWithData:photo.image];
            imageView.tag = 1;
            [cell.contentView addSubview:imageView];
            
        }
        
        
        return cell;

    } else {
    
        return nil;
        
    }
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.campaignPicturesCV]) {
        
        [self performSegueWithIdentifier:@"showCampaignPicture" sender:indexPath];

    } else if ([collectionView isEqual:self.photoReportsPicturesCV]) {
        
        STMOutlet *outlet = self.photoReportPicturesResultsController.fetchedObjects[indexPath.section];
        STMPhotoReport *photoReport = outlet.photoReports.anyObject;

        if (indexPath.row == photoReport.photos.count) {
            NSLog(@"Start Photo");
        }
        
    }
    
    return YES;
    
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    
    barButtonItem.title = NSLocalizedString(@"AD CAMPAIGNS", nil);
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button {
    
    self.navigationItem.leftBarButtonItem = nil;
    
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
        
        [self.campaignPicturesCV deleteItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
        NSLog(@"NSFetchedResultsChangeDelete");
        
    } else if (type == NSFetchedResultsChangeInsert) {
        
        [self.campaignPicturesCV insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
        NSLog(@"NSFetchedResultsChangeInsert");
        
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
        [self.campaignPicturesCV reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        NSLog(@"NSFetchedResultsChangeUpdate");
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationItem.rightBarButtonItem = self.homeButton;
    
    self.campaignPicturesCV.dataSource = self;
    self.campaignPicturesCV.delegate = self;
    self.campaignPicturesCV.backgroundColor = [UIColor whiteColor];
    
    self.photoReportsPicturesCV.dataSource = self;
    self.photoReportsPicturesCV.delegate = self;
    self.photoReportsPicturesCV.backgroundColor = [UIColor whiteColor];
    
    self.separationView.backgroundColor = [UIColor whiteColor];
    CGFloat y = self.separationView.frame.size.height / 2;
    CGFloat width = self.separationView.frame.size.width;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, y, width, 2)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self.separationView addSubview:lineView];

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"showCampaignPicture"] && [segue.destinationViewController isKindOfClass:[STMCampaignPicturePVC class]]) {
        
        [(STMCampaignPicturePVC *)segue.destinationViewController setCampaign:self.campaign];
        [(STMCampaignPicturePVC *)segue.destinationViewController setCurrentIndex:[(NSIndexPath *)sender row]];
        
    }
    
    
}


@end
