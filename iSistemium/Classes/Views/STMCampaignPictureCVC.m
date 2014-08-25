//
//  STMCampaignPictureCVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCampaignPictureCVC.h"
#import "STMDocument.h"
#import "STMSessionManager.h"
#import "STMCampaignPicture.h"
#import "STMObjectsController.h"
#import "STMCampaignPicturePVC.h"
#import "STMFunctions.h"

@interface STMCampaignPictureCVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) STMDocument *document;
@property (nonatomic, strong) NSFetchedResultsController *campaignPicturesResultsController;
@property (nonatomic, strong) NSBlockOperation *changeOperation;
@property (nonatomic, strong) STMCampaign *updatingCampaign;
@property (nonatomic) BOOL isUpdating;


@end

@implementation STMCampaignPictureCVC

@synthesize campaign = _campaign;

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
    
}

- (NSFetchedResultsController *)campaignPicturesResultsController {
    
    if (!_campaignPicturesResultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCampaignPicture class])];
        
        NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        NSSortDescriptor *deviceCtsSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)];
        
        request.sortDescriptors = @[nameSortDescriptor, deviceCtsSortDescriptor];
        
        request.predicate = [NSPredicate predicateWithFormat:@"ANY campaigns == %@", self.campaign];
        _campaignPicturesResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _campaignPicturesResultsController.delegate = self;
        
        //        NSLog(@"_resultsController %@", _resultsController);
        
    }
    
    return _campaignPicturesResultsController;
    
}


- (void)setCampaign:(STMCampaign *)campaign {
    
    if (campaign != _campaign) {
        
        _campaign = campaign;
        
//        NSLog(@"set campaign %@", _campaign.name);
        
        [self fetchPictures];
        
    }
    
}


- (void)fetchPictures {

    self.campaignPicturesResultsController = nil;
    
    NSError *error;
    if (![self.campaignPicturesResultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {

        if (!self.isUpdating) {
            
            [self.collectionView reloadData];
            
        }
        
    }
    
}

#pragma mark - UICollectionViewDataSource, Delegate, DelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
//    NSLog(@"fetchedObjects.count %d", self.campaignPicturesResultsController.fetchedObjects.count);
    
    return self.campaignPicturesResultsController.fetchedObjects.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"campaignPictureCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [[cell.contentView viewWithTag:1] removeFromSuperview];
    [[cell.contentView viewWithTag:2] removeFromSuperview];
    
    
    STMCampaignPicture *picture = self.campaignPicturesResultsController.fetchedObjects[indexPath.row];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 150)];
    imageView.tag = 1;

    if (!picture.resizedImagePath) {
        [STMObjectsController hrefProcessingForObject:picture];
    }
    
    if (!picture.imageThumbnail) {

        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = imageView.center;
        [spinner startAnimating];
        [imageView addSubview:spinner];
        
        imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        imageView.layer.borderWidth = 1.0f;

//        if (picture.image) {
//            [STMObjectsController setImagesFromData:picture.image forPicture:picture];
//        } else {
//            
////            NSLog(@"picture.href %@", picture.href);
//            [STMObjectsController hrefProcessingForObject:picture];
//
//        }

        
    } else {
    
//        NSLog(@"self.campaign.name %@, picture.href %@", self.campaign.name, picture.href);
        
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageWithData:picture.imageThumbnail];
        
    }
    
    [cell.contentView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, cell.contentView.frame.size.width, 50)];
    label.text = picture.name;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 2;
    [cell.contentView addSubview:label];
    
//    NSLog(@"cell %@, indexPath %@", cell, indexPath);
    
    return cell;
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [self performSegueWithIdentifier:@"showCampaignPicture" sender:indexPath];
    
    return YES;
    
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
//    NSLog(@"controllerWillChangeContent");
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
    
//    NSLog(@"controller didChangeObject");
//    
//    for (STMCampaign *campaign in [anObject valueForKey:@"campaigns"]) {
//        
//        NSLog(@"name %@", campaign.name);
//        
//    }
//    
//    NSLog(@"indexPath %@", indexPath);
//    NSLog(@"newIndexPath %@", newIndexPath);
//    NSLog(@"campaign.name %@", self.campaign.name);

//    NSLog(@"didChangeObject isMainThread %d", [NSThread isMainThread]); // double???

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

- (void)customInit {
    
    self.isUpdating = NO;
    
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
