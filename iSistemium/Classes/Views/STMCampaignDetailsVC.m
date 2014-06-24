//
//  STMCampaignDetailsVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/06/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCampaignDetailsVC.h"
#import "STMRootTBC.h"
#import "STMCampaignPicture.h"
#import "STMSessionManager.h"
#import "STMDocument.h"
#import "STMObjectsController.h"
#import "STMCampaignPicturePVC.h"

@interface STMCampaignDetailsVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *homeButton;
@property (nonatomic, strong) STMDocument *document;

@property (weak, nonatomic) IBOutlet UICollectionView *campiagnPicturesCV;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@property (weak, nonatomic) IBOutlet UICollectionView *photoReportsCV;


@property (weak, nonatomic) IBOutlet UIView *separationView;


@end


@implementation STMCampaignDetailsVC

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCampaignPicture class])];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(compare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"ANY campaigns == %@", self.campaign];
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        _resultsController.delegate = self;
        
//        NSLog(@"_resultsController %@", _resultsController);
        
    }
    
    return _resultsController;
    
}

- (void)setCampaign:(STMCampaign *)campaign {
    
    if (campaign != _campaign) {
        
        self.title = campaign.name;
        
        _campaign = campaign;
        
        self.resultsController = nil;
        [self fetchPictures];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    
}

- (void)fetchPictures {
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {

        NSLog(@"performFetch error %@", error);
        
    } else {
        
        for (STMCampaignPicture *picture in self.resultsController.fetchedObjects) {
            
            if (!picture.image) {
//                NSLog(@"no image");
                [STMObjectsController hrefProcessingForObject:picture];
            }
            
        }
        [self.campiagnPicturesCV reloadData];
        
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

    return 1;

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

//    NSLog(@"fetchedObjects.count %d", self.resultsController.fetchedObjects.count);
    return self.resultsController.fetchedObjects.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"campaignPictureCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [[cell.contentView viewWithTag:1] removeFromSuperview];
    [[cell.contentView viewWithTag:2] removeFromSuperview];
    
    STMCampaignPicture *picture = self.resultsController.fetchedObjects[indexPath.row];
//    NSLog(@"picture %@", picture);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, cell.contentView.frame.size.width, 50)];
    label.text = picture.name;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 1;
    [cell.contentView addSubview:label];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 150)];
    imageView.image = [UIImage imageWithData:picture.image];
    imageView.tag = 2;
    [cell.contentView addSubview:imageView];
    
//    cell.backgroundColor = [UIColor blueColor];
    
    return cell;
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"showCampaignPicture" sender:indexPath];
    
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
        
        [self.campiagnPicturesCV deleteItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
        NSLog(@"NSFetchedResultsChangeDelete");
        
    } else if (type == NSFetchedResultsChangeInsert) {
        
        [self.campiagnPicturesCV insertItemsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]];
        NSLog(@"NSFetchedResultsChangeInsert");
        
        
    } else if (type == NSFetchedResultsChangeUpdate) {
        
        [self.campiagnPicturesCV reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        NSLog(@"NSFetchedResultsChangeUpdate");
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationItem.rightBarButtonItem = self.homeButton;
    
    self.campiagnPicturesCV.dataSource = self;
    self.campiagnPicturesCV.delegate = self;
    self.campiagnPicturesCV.backgroundColor = [UIColor whiteColor];
    
    self.photoReportsCV.backgroundColor = [UIColor whiteColor];
    
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
