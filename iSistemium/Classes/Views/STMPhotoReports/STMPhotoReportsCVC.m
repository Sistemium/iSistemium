//
//  STMPhotoReportsCVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 26/10/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPhotoReportsCVC.h"
#import "STMSessionManager.h"
#import "STMDataModel.h"
#import "STMFunctions.h"


@interface STMPhotoReportsCVC () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) STMDocument *document;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@end

@implementation STMPhotoReportsCVC

static NSString * const reuseIdentifier = @"photoReportCell";


#pragma mark - variables setters & getters

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPhotoReport class])];
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES selector:@selector(compare:)]];
        
//        request.predicate = [self campaignPredicate];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (void)performFetch {
    
    [self.resultsController performFetch:nil];
    
}

//- (NSPredicate *)campaignPredicate {
//    
//    NSMutableArray *subpredicates = [NSMutableArray array];
//    
//    NSPredicate *campaignPredicate = [NSPredicate predicateWithFormat:@"campaign == %@", self.campaign];
//    
//    [subpredicates addObject:campaignPredicate];
//    
//    //    if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
//    //        [subpredicates addObject:[NSPredicate predicateWithFormat:@"outlet.name CONTAINS[cd] %@", self.searchBar.text]];
//    //    }
//    
//    [subpredicates addObject:[STMPredicate predicateWithNoFantoms]];
//    
//    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
//    
//    return predicate;
//    
//}
//
//- (NSPredicate *)outletPredicate {
//    
//    NSMutableArray *subpredicates = [NSMutableArray array];
//    
//    NSPredicate *outletPredicate = [NSPredicate predicateWithFormat:@"name != %@", nil];
//    
//    [subpredicates addObject:outletPredicate];
//    
//    if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
//        [subpredicates addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchBar.text]];
//    }
//    
//    [subpredicates addObject:[STMPredicate predicateWithNoFantoms]];
//    
//    NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
//    
//    return predicate;
//    
//}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.resultsController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    STMPhotoReport *photoReport = [self.resultsController objectAtIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
//    imageView.image = [UIImage imageWithContentsOfFile:[STMFunctions absolutePathForPath:photoReport.resizedImagePath]];
    imageView.image = [UIImage imageWithData:photoReport.imageThumbnail];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;

//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:photoReport.imageThumbnail]];
    
    [cell.contentView addSubview:imageView];
    
    return cell;
    
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView reloadData];
}


#pragma mark - view lifecycle

- (void)customInit {
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self performFetch];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
