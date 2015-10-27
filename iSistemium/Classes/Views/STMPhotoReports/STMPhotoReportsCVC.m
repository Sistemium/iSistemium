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
#import "STMUI.h"


@interface STMPhotoReportsCVC () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) STMDocument *document;
@property (nonatomic, strong) NSFetchedResultsController *resultsController;
@property (nonatomic) CGSize cellSize;


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

- (CGSize)cellSize {
    
    static CGSize cellSize;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([STMCustom1CVCell class]) bundle:nil];
        UIView *rootView = [[nib instantiateWithOwner:nil options:nil] lastObject];
        cellSize = rootView.frame.size;
        
    });

    return cellSize;
    
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.resultsController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom1CVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    STMPhotoReport *photoReport = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.imageView.image = [UIImage imageWithData:photoReport.imageThumbnail];
    cell.label.text = photoReport.campaign.name;

    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.cellSize;
    
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
    
    self.collectionView.backgroundColor = [UIColor whiteColor];

    UINib *customCellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom1CVCell class]) bundle:nil];
    [self.collectionView registerNib:customCellNib forCellWithReuseIdentifier:reuseIdentifier];
    
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


@end
