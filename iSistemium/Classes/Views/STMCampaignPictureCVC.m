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
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
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
        
        self.campaignPicturesResultsController = nil;
        [self fetchPictures];
        
    }
    
}


- (void)fetchPictures {
    
    NSError *error;
    if (![self.campaignPicturesResultsController performFetch:&error]) {
        
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
        
        [self.collectionView reloadData];
        
    }
    
}

#pragma mark - UICollectionViewDataSource, Delegate, DelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
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

    if (!picture.imageThumbnail) {

        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = imageView.center;
        [spinner startAnimating];
        [imageView addSubview:spinner];
        
        imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        imageView.layer.borderWidth = 1.0f;

        if (picture.image) {
            [STMObjectsController setImagesFromData:picture.image forPicture:picture];
        } else {
            [STMObjectsController hrefProcessingForObject:picture];
        }

        
    } else {
    
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
    
    return cell;
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [self performSegueWithIdentifier:@"showCampaignPicture" sender:indexPath];
    
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
    
    NSLog(@"controller didChangeObject");
    NSLog(@"anObject %@", anObject);
    NSLog(@"indexPath %@", indexPath);
    NSLog(@"newIndexPath %@", newIndexPath);
    NSLog(@"campaign.name %@", self.campaign.name);
    
    if (type == NSFetchedResultsChangeDelete) {
        
        NSLog(@"NSFetchedResultsChangeDelete");
        [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
        
    } else if (type == NSFetchedResultsChangeInsert) {

        NSLog(@"NSFetchedResultsChangeInsert");
        [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
        
    } else if (type == NSFetchedResultsChangeUpdate) {

        NSLog(@"NSFetchedResultsChangeUpdate");

        STMCampaignPicture *object = anObject;
        if (object.imageThumbnail) {
            [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        }
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
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
