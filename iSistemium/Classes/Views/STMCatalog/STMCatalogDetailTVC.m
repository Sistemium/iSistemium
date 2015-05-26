//
//  STMCatalogDetailTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCatalogDetailTVC.h"
#import "STMArticleInfoVC.h"
#import "STMPicturesController.h"
#import "STMArticlePicturePVC.h"


static NSString *Custom4CellIdentifier = @"STMCustom4TVCell";
static NSString *Custom5CellIdentifier = @"STMCustom5TVCell";


@interface STMCatalogDetailTVC () <UIPopoverControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) STMCatalogSVC *splitVC;

@property (weak, nonatomic) IBOutlet STMBarButtonItem *infoLabel;
@property (weak, nonatomic) IBOutlet STMBarButtonItem *priceTypeLabel;
@property (weak, nonatomic) IBOutlet STMBarButtonItem *priceTypeSelector;
@property (weak, nonatomic) IBOutlet STMBarButtonItem *stockVolumeLabel;
@property (weak, nonatomic) IBOutlet STMBarButtonItem *stockVolumeButton;
@property (weak, nonatomic) IBOutlet STMBarButtonItem *picturesButton;

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) BOOL searchFieldIsScrolledAway;

@property (nonatomic, strong) UIPopoverController *articleInfoPopover;
@property (nonatomic) BOOL articleInfoPopoverIsVisible;

@property (nonatomic, strong) UIActionSheet *priceTypeSelectorActionSheet;
@property (nonatomic, strong) UIActionSheet *stockVolumeFilterActionSheet;

@property (nonatomic, strong) STMArticle *selectedArticle;

@property (strong, nonatomic) NSMutableDictionary *cachedCellsHeights;


@end


@implementation STMCatalogDetailTVC

@synthesize resultsController = _resultsController;


- (STMCatalogSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMCatalogSVC class]]) {
            _splitVC = (STMCatalogSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (STMPriceType *)selectedPriceType {
    return self.splitVC.selectedPriceType;
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPrice class])];
        
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        NSSortDescriptor *volumeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.pieceVolume" ascending:YES selector:@selector(compare:)];

//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMArticle class])];
//        
//        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
//        NSSortDescriptor *volumeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pieceVolume" ascending:YES selector:@selector(compare:)];
        
        request.sortDescriptors = @[nameDescriptor, volumeDescriptor];
        
        NSCompoundPredicate *predicate = [self requestPredicate];
        if (predicate.subpredicates.count > 0) request.predicate = predicate;
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (NSCompoundPredicate *)requestPredicate {
    
    NSCompoundPredicate *predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:@[]];
    
    if (self.splitVC.currentArticleGroup) {
        
        NSArray *filterArray = [self.splitVC nestedArticleGroups];
        NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"article.articleGroup IN %@", filterArray];
//        NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"articleGroup IN %@", filterArray];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, groupPredicate]];
        
    }
    
    if (self.selectedPriceType) {
        
        NSPredicate *priceTypePredicate = [NSPredicate predicateWithFormat:@"priceType == %@", self.selectedPriceType];

//        NSPredicate *priceTypePredicate = [NSPredicate predicateWithFormat:@"ANY prices.priceType == %@", self.selectedPriceType];
//        NSPredicate *priceTypePredicate = [NSPredicate predicateWithFormat:@"SUBQUERY(prices, $x, $x.priceType == %@ AND $x.price > 0).@count > 0", self.selectedPriceType];
//        NSPredicate *priceTypePredicate = [NSPredicate predicateWithFormat:@"SUBQUERY(prices, $x, $x.priceType == %@).@count > 0", self.selectedPriceType];
        
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, priceTypePredicate]];
        
    }
    
    if (!self.splitVC.showZeroStock) {
        
        NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"article.stock.volume.integerValue > 0"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, groupPredicate]];
        
    }

    if (self.splitVC.showOnlyWithPictures) {

        NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"article.pictures.@count > 0"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, groupPredicate]];

    }
    
    NSPredicate *pricePredicate = [NSPredicate predicateWithFormat:@"price > 0"];
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, pricePredicate]];

    NSPredicate *fantomPredicate = [NSPredicate predicateWithFormat:@"article.isFantom == NO"];
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, fantomPredicate]];

    return predicate;

}

- (void)performFetch {
    
    self.resultsController = nil;
    
    NSError *error;

// Just a time checking
//
//    TICK;
//    [self.resultsController performFetch:&error];
//    TOCK;
//
    
    if (![self.resultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
        [self.tableView reloadData];
        
//        self.navigationItem.title = self.splitVC.currentArticleGroup.name;
        
        if (self.searchDisplayController.active) {
            self.searchBar.text = self.searchBar.text;
        }

    }
    
//    [self nsLogCatalogDetails];

}

- (void)refreshTable {
    
    [self performFetch];
//    [self setupToolbar];
    
}

- (NSArray *)currentArticles {
    
    NSArray *currentPrices = nil;
    
    if (self.searchDisplayController.active) {
        currentPrices = self.searchResults;
    } else {
        currentPrices = self.resultsController.fetchedObjects;
    }
    
    return [currentPrices valueForKeyPath:@"article"];
    
}

- (STMArticle *)selectPreviousArticle {
    
    NSArray *currentArticles = [self currentArticles];
    NSUInteger index = [currentArticles indexOfObject:self.selectedArticle];
    
    if (index > 0) {
        
        index--;
        
        UITableView *currentTableView = (self.searchDisplayController.active) ? self.searchDisplayController.searchResultsTableView : self.tableView;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [currentTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        
        self.selectedArticle = currentArticles[index];
        return self.selectedArticle;
        
    } else {
        return nil;
    }
    
}

- (STMArticle *)selectNextArticle {

    NSArray *currentArticles = [self currentArticles];
    NSUInteger index = [currentArticles indexOfObject:self.selectedArticle];
    
    if (index < currentArticles.count-1) {
        
        index++;

        UITableView *currentTableView = (self.searchDisplayController.active) ? self.searchDisplayController.searchResultsTableView : self.tableView;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [currentTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        
        self.selectedArticle = currentArticles[index];
        return self.selectedArticle;
        
    } else {
        return nil;
    }

}

#pragma mark - toolbar items

- (void)setupBarButton:(UIBarButtonItem *)barButton asLabelWithColor:(UIColor *)color {
    
    if (!color) color = [UIColor blackColor];

    barButton.enabled = NO;
    NSDictionary *attributes = @{NSForegroundColorAttributeName:color};
    [barButton setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [barButton setTitleTextAttributes:attributes forState:UIControlStateDisabled];

}

- (void)priceTypeLabelSetup {
    
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    NSString *title = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? nil : NSLocalizedString(@"PRICE_TYPE_LABEL", nil);
    
    self.priceTypeLabel.title = title;
    [self setupBarButton:self.priceTypeLabel asLabelWithColor:nil];
    
}

- (void)priceTypeSelectorSetup {
    
    self.priceTypeSelector.title = self.selectedPriceType.name;
    self.priceTypeSelector.target = self;
    self.priceTypeSelector.action = @selector(showPriceTypeSelector);
    
}

- (void)stockVolumeLabelSetup {

    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    NSString *title = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? nil : NSLocalizedString(@"SHOW ARTICLES", nil);

    self.stockVolumeLabel.title = title;
    [self setupBarButton:self.stockVolumeLabel asLabelWithColor:nil];
    
}

- (void)stockVolumeButtonSetup {
    
    NSString *title = (self.splitVC.showZeroStock) ? NSLocalizedString(@"SHOW ALL ARTICLES", nil) : NSLocalizedString(@"SHOW NONZERO STOCK ARTICLES", nil);
    
    self.stockVolumeButton.title = title;
    self.stockVolumeButton.target = self;
    self.stockVolumeButton.action = @selector(showStockVolumeFilter);
    
}

- (void)picturesFilterButtonSetup {
    
    [self picturesButtonImageSetup];
    self.picturesButton.target = self;
    self.picturesButton.action = @selector(picturesButtonPressed);
    
}

- (void)picturesButtonImageSetup {

    NSString *imageName = (self.splitVC.showOnlyWithPictures) ? @"Picture Filled-25.png" : @"Picture-25.png";
    UIImage *image = [UIImage imageNamed:imageName];
    self.picturesButton.image = image;

}

- (void)infoLabelSetup {
    
    self.infoLabel.title = @"";
    [self setupBarButton:self.infoLabel asLabelWithColor:nil];

}

- (void)updateInfoLabel {

    NSUInteger count;
    
    if (self.searchDisplayController.active) {
        count = self.searchResults.count;
    } else {
        count = self.resultsController.fetchedObjects.count;
    }
    
    [self updateInfoLabelWithArticleCount:count];
    
}

- (void)updateInfoLabelWithArticleCount:(NSUInteger)count {
    
//    NSUInteger count = self.resultsController.fetchedObjects.count;
    
    NSString *pluralType = [STMFunctions pluralTypeForCount:count];
    NSString *labelString = [pluralType stringByAppendingString:@"ARTICLES"];
    
    NSString *numberString = (count > 0) ? [NSString stringWithFormat:@"%lu ", (unsigned long)count] : @"";
    
    NSString *infoString = [numberString stringByAppendingString:NSLocalizedString(labelString, nil)];
    
    self.infoLabel.title = infoString;
 
}


#pragma mark

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification {
    
    [self toolbarLabelsSetup];
    self.cachedCellsHeights = nil;
    [self.tableView reloadData];
    
}

- (void)toolbarLabelsSetup {
    
    [self priceTypeLabelSetup];
    [self stockVolumeLabelSetup];
    
}

#pragma mark - NSLogs

- (void)nsLogCatalogDetails {
    
    NSArray *result = [STMObjectsController objectsForEntityName:NSStringFromClass([STMArticle class])];
    
    NSMutableArray *resultsGorod = [NSMutableArray array];
    NSMutableArray *resultsDobronom = [NSMutableArray array];
    NSMutableArray *resultsRoznica = [NSMutableArray array];
    
    for (STMArticle *article in result) {
        
        BOOL isCurrentGroup = [article.articleGroup isEqual:self.splitVC.currentArticleGroup];
        BOOL insideCurrentGroup = [self articleGroup:article.articleGroup hasInParents:self.splitVC.currentArticleGroup];
        
        if (isCurrentGroup || insideCurrentGroup) {
            
            BOOL zeroStock = NO;
            
            if (!self.splitVC.showZeroStock) {
                if ([article.stock.volume integerValue] <= 0) zeroStock = YES;
            }
            
            BOOL checkGorod = NO;
            BOOL checkDobronom = NO;
            BOOL checkRoznica = NO;
            
            for (STMPrice *price in article.prices) {
                
                if ([price.price integerValue] > 0) {
                    
                    if ([price.priceType.name isEqualToString:@"Город Изобилия"]) {
                        checkGorod = YES;
                    } else if ([price.priceType.name isEqualToString:@"Доброном"]) {
                        checkDobronom = YES;
                    } else if ([price.priceType.name isEqualToString:@"Розница"]) {
                        checkRoznica = YES;
                    }

                }
                
            }
            
            if (checkGorod && !zeroStock) {
                [resultsGorod addObject:article];
            }
            if (checkDobronom && !zeroStock) {
                [resultsDobronom addObject:article];
            }
            if (checkRoznica && !zeroStock) {
                [resultsRoznica addObject:article];
            }
            
        }
        
    }

    NSLog(@"-------------------------------s");

    NSLog(@"resultsGorod.count %d", resultsGorod.count);
    NSLog(@"resultsDobronom.count %d", resultsDobronom.count);
    NSLog(@"resultsRoznica.count %d", resultsRoznica.count);
    
    NSLog(@"-------------------------------f");

}

- (BOOL)articleGroup:(STMArticleGroup *)articleGroup hasInParents:(STMArticleGroup *)parentArticleGroup {
    
    if (!parentArticleGroup) {
        return YES;
    } else {
        
        if (!articleGroup.articleGroup) {
            return NO;
        } else if ([articleGroup.articleGroup isEqual:parentArticleGroup]) {
            return YES;
        } else {
            return [self articleGroup:articleGroup.articleGroup hasInParents:parentArticleGroup];
        }

    }

}


#pragma mark - priceType selector

- (void)showPriceTypeSelector {
    
    if (!self.priceTypeSelectorActionSheet.isVisible) {
        [self.priceTypeSelectorActionSheet showFromBarButtonItem:self.priceTypeSelector animated:YES];
    }
    
}

- (UIActionSheet *)priceTypeSelectorActionSheet {

    if (!_priceTypeSelectorActionSheet) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"PRICE_TYPE_LABEL", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        NSArray *priceTypes = self.splitVC.availablePriceTypes;
        
        for (STMPriceType *priceType in priceTypes) {
            
            [actionSheet addButtonWithTitle:priceType.name];
            
        }
        
        actionSheet.delegate = self;
        
        _priceTypeSelectorActionSheet = actionSheet;
        
    }
    return _priceTypeSelectorActionSheet;
    
}


#pragma mark - stockVolume filter

- (void)showStockVolumeFilter {
    
    if (!self.stockVolumeFilterActionSheet.isVisible) {
        [[self stockVolumeFilterActionSheet] showFromBarButtonItem:self.stockVolumeButton animated:YES];
    }
    
}

- (UIActionSheet *)stockVolumeFilterActionSheet {
    
    if (!_stockVolumeFilterActionSheet) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SHOW ARTICLES", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"SHOW NONZERO STOCK ARTICLES", nil), NSLocalizedString(@"SHOW ALL ARTICLES", nil), nil];
        
        actionSheet.delegate = self;

        _stockVolumeFilterActionSheet = actionSheet;
        
    }
    return _stockVolumeFilterActionSheet;
    
}


#pragma mark - pictures filter

- (void)picturesButtonPressed {
    
    self.splitVC.showOnlyWithPictures = !self.splitVC.showOnlyWithPictures;
    [self picturesButtonImageSetup];
    
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet.title isEqualToString:NSLocalizedString(@"PRICE_TYPE_LABEL", nil)]) {
        
        if (buttonIndex != -1) {
            
            self.splitVC.selectedPriceType = self.splitVC.availablePriceTypes[buttonIndex];
            [self priceTypeSelectorSetup];
            
        }
        
    } else if ([actionSheet.title isEqualToString:NSLocalizedString(@"SHOW ARTICLES", nil)]) {
        
        if (buttonIndex != -1) {

            self.splitVC.showZeroStock = [@(buttonIndex) boolValue];
            [self stockVolumeButtonSetup];
            
        }
        
    }
    
}

#pragma mark - search

- (void)searchButtonPressed {

    self.navigationItem.rightBarButtonItem = nil;
    [self.searchDisplayController setActive:YES animated:YES];
    
}

- (void)showSearchButton {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonPressed)];
}

- (UISearchBar *)searchBar {
    return self.searchDisplayController.searchBar;
}

- (void)setSearchFieldIsScrolledAway:(BOOL)searchFieldIsScrolledAway {
    
    if (_searchFieldIsScrolledAway != searchFieldIsScrolledAway) {
        
        _searchFieldIsScrolledAway = searchFieldIsScrolledAway;
        
        if (_searchFieldIsScrolledAway) {
            [self showSearchButton];
        } else {
            self.navigationItem.rightBarButtonItem = nil;
        }
        
    }
    
}


- (void)hideKeyboard {
    
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }

}

#pragma mark - articleInfo popover

- (UIPopoverController *)articleInfoPopover {
    
    if (!_articleInfoPopover) {
        
        STMArticleInfoVC *articleInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"articleInfoVC"];
        articleInfoVC.parentVC = self;
        articleInfoVC.article = self.selectedArticle;
        
        _articleInfoPopover = [[UIPopoverController alloc] initWithContentViewController:articleInfoVC];
        _articleInfoPopover.delegate = self;
        
    }
    return _articleInfoPopover;
    
}

- (void)showArticleInfoPopover {
    
    if (!self.articleInfoPopover.isPopoverVisible) {

        CGRect rect = CGRectMake(self.splitVC.view.frame.size.width/2, self.splitVC.view.frame.size.height/2, 1, 1);
        [self.articleInfoPopover presentPopoverFromRect:rect inView:self.splitVC.view permittedArrowDirections:0 animated:YES];
        
    }
    
}

- (void)dismissArticleInfoPopover {
    
    [self.articleInfoPopover dismissPopoverAnimated:YES];
    self.articleInfoPopover = nil;
    
}

- (void)showFullscreen {
    
    [self dismissArticleInfoPopover];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"STMArticlePicturePVC" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"articlePicturePVC"];
    
    if ([vc isKindOfClass:[STMArticlePicturePVC class]]) {
        
        [(STMArticlePicturePVC *)vc setParentVC:self];
        [(STMArticlePicturePVC *)vc setCurrentArticle:self.selectedArticle];
        
    }
    
    [self presentViewController:vc animated:NO completion:^{
        
    }];
    
}

- (void)pictureViewTapped:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        
        NSIndexPath *indexPath = [self indexPathForPictureView:[(UITapGestureRecognizer *)sender view]];

        if (indexPath) {
            
            UITableView *currentTableView = (self.searchDisplayController.active) ? self.searchDisplayController.searchResultsTableView : self.tableView;
            [currentTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];

            STMPrice *price = nil;
            if (self.searchDisplayController.active) {
                price = [self.searchResults objectAtIndex:indexPath.row];
            } else {
                price = [self.resultsController objectAtIndexPath:indexPath];
            }
            self.selectedArticle = price.article;

        }
        
    }
    
    if (self.selectedArticle) {
        [self showFullscreen];
    }
    
}

- (NSIndexPath *)indexPathForPictureView:(UIView *)pictureView {
    
    UITableViewCell *cell = [self cellForView:pictureView];
    
    UITableView *currentTableView = (self.searchDisplayController.active) ? self.searchDisplayController.searchResultsTableView : self.tableView;
    NSIndexPath *indexPath = [currentTableView indexPathForCell:cell];
    
    return indexPath;
    
}

- (UITableViewCell *)cellForView:(UIView *)view {
    
    UIView *parentView = view.superview;
    
    if ([parentView isKindOfClass:[UITableViewCell class]]) {
        
        return (UITableViewCell *)parentView;
        
    } else {
        
        return (parentView) ? [self cellForView:parentView] : nil;
        
    }
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if (self.articleInfoPopoverIsVisible) {
        
        [self showArticleInfoPopover];
        self.articleInfoPopoverIsVisible = NO;
        
    }
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (self.articleInfoPopover.popoverVisible) {

        self.articleInfoPopoverIsVisible = YES;
        [self dismissArticleInfoPopover];
        
    }

    [self hideKeyboard];
    
}


#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.articleInfoPopover = nil;
}


#pragma mark - cell's height caching

- (NSMutableDictionary *)cachedCellsHeights {
    
    if (!_cachedCellsHeights) {
        _cachedCellsHeights = [NSMutableDictionary dictionary];
    }
    return _cachedCellsHeights;
    
}

- (void)putCachedHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:indexPath] objectID];
    
    self.cachedCellsHeights[objectID] = @(height);
    
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectID *objectID = [[self.resultsController objectAtIndexPath:indexPath] objectID];
    
    return self.cachedCellsHeights[objectID];
    
}


#pragma mark - Table view data source

- (NSString *)detailedTextForArticle:(STMArticle *)article {
    
    NSString *detailedText = @"";
    NSString *appendString = @"";
    
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"priceType = %@", self.selectedPriceType];
    
    STMPrice *price = [article.prices filteredSetUsingPredicate:predicate].allObjects.lastObject;
    
    appendString = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:price.price]];
    detailedText = [detailedText stringByAppendingString:appendString];
    
    if (article.stock.volume.integerValue <= 0) {
        
        appendString = [NSString stringWithFormat:@", %@", NSLocalizedString(@"ZERO STOCK", nil)];
        detailedText = [detailedText stringByAppendingString:appendString];
        
    } else {
        
        appendString = [NSString stringWithFormat:@", %@", article.stock.displayVolume];
        detailedText = [detailedText stringByAppendingString:appendString];
        
    }

    if (article.extraLabel) {
        
        appendString = [NSString stringWithFormat:@", %@", article.extraLabel];
        detailedText = [detailedText stringByAppendingString:appendString];
        
    }
    
    return detailedText;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger count = (tableView == self.searchDisplayController.searchResultsTableView) ? self.searchResults.count : [super tableView:tableView numberOfRowsInSection:section];

    [self updateInfoLabelWithArticleCount:count];
    
    return count;
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static CGFloat standardCellHeight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        standardCellHeight = [[UITableViewCell alloc] init].frame.size.height;
    });
    
    return standardCellHeight + 1.0f;  // Add 1.0f for the cell separator height
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *cachedHeight = [self getCachedHeightForIndexPath:indexPath];
    CGFloat height = (cachedHeight) ? cachedHeight.floatValue : [self heightForCellAtIndexPath:indexPath];
    
    return height;
    
}

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    STMPrice *price = (self.tableView == self.searchDisplayController.searchResultsTableView) ? [self.searchResults objectAtIndex:indexPath.row] : [self.resultsController objectAtIndexPath:indexPath];
  
    if (price.article.pictures.count > 0) {
     
        static STMCustom4TVCell *cell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            cell = [self.tableView dequeueReusableCellWithIdentifier:Custom4CellIdentifier];
        });

        [self fillPictureCell:cell withPrice:price];
        
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(cell.bounds));
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        CGFloat height = size.height + 1.0f; // Add 1.0f for the cell separator height
        
        [self putCachedHeight:height forIndexPath:indexPath];
        
        return height;

    } else {
        
        static STMCustom5TVCell *cell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            cell = [self.tableView dequeueReusableCellWithIdentifier:Custom5CellIdentifier];
        });
        
        [self fillCell:cell withPrice:price];
        
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(cell.bounds));
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        CGFloat height = size.height + 1.0f; // Add 1.0f for the cell separator height
        
        [self putCachedHeight:height forIndexPath:indexPath];
        
        return height;
        
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMPrice *price = (tableView == self.searchDisplayController.searchResultsTableView) ? [self.searchResults objectAtIndex:indexPath.row] : [self.resultsController objectAtIndexPath:indexPath];
    
    if (price.article.pictures.count > 0) {
        
        STMCustom4TVCell *cell = [self.tableView dequeueReusableCellWithIdentifier:Custom4CellIdentifier forIndexPath:indexPath];
        [self fillPictureCell:cell withPrice:price];
        
        return cell;
        
    } else {
     
        STMCustom5TVCell *cell = [self.tableView dequeueReusableCellWithIdentifier:Custom5CellIdentifier forIndexPath:indexPath];
        [self fillCell:cell withPrice:price];
        
        return cell;
        
    }
    
}

- (void)fillCell:(STMCustom5TVCell *)cell withPrice:(STMPrice *)price {
    
    cell.titleLabel.text = price.article.name;
    cell.detailLabel.text = [self detailedTextForArticle:price.article];
    
    NSString *volumeUnitString = NSLocalizedString(@"VOLUME UNIT", nil);
    cell.infoLabel.text = [NSString stringWithFormat:@"%@%@", price.article.pieceVolume, volumeUnitString];
    
    UIColor *textColor = (price.article.stock.volume.integerValue <= 0) ? [UIColor lightGrayColor] : [UIColor blackColor];
    
    cell.titleLabel.textColor = textColor;
    cell.detailLabel.textColor = textColor;
    cell.infoLabel.textColor = textColor;
    
}

- (void)fillPictureCell:(STMCustom4TVCell *)cell withPrice:(STMPrice *)price {
    
    cell.titleLabel.text = price.article.name;
    cell.detailLabel.text = [self detailedTextForArticle:price.article];
    
    NSString *volumeUnitString = NSLocalizedString(@"VOLUME UNIT", nil);
    cell.infoLabel.text = [NSString stringWithFormat:@"%@%@", price.article.pieceVolume, volumeUnitString];
    
    UIColor *textColor = (price.article.stock.volume.integerValue <= 0) ? [UIColor lightGrayColor] : [UIColor blackColor];
    
    cell.titleLabel.textColor = textColor;
    cell.detailLabel.textColor = textColor;
    cell.infoLabel.textColor = textColor;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES];
    STMArticlePicture *picture = [price.article.pictures sortedArrayUsingDescriptors:@[sortDescriptor]][0];

    if (!picture.imageThumbnail) {
        
        [STMPicturesController hrefProcessingForObject:picture];
        cell.pictureView.image = nil;
        [self addSpinnerToCell:cell];

    } else {

        [[cell.pictureView viewWithTag:555] removeFromSuperview];
        cell.pictureView.image = [UIImage imageWithData:picture.imageThumbnail];
        
    }
    
    cell.pictureView.userInteractionEnabled = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureViewTapped:)];
    cell.pictureView.gestureRecognizers = @[tap];
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
}

- (void)addSpinnerToCell:(STMCustom4TVCell *)cell {
    
    UIView *view = [[UIView alloc] initWithFrame:cell.pictureView.bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor whiteColor];
    view.alpha = 0.75;
    view.tag = 555;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = view.center;
    spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [spinner startAnimating];
    
    [view addSubview:spinner];
    
    [cell.pictureView addSubview:view];
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell = nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMPrice *price = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
//        self.selectedArticle = [self.searchResults objectAtIndex:indexPath.row];
        price = [self.searchResults objectAtIndex:indexPath.row];
        
    } else {
        
//        self.selectedArticle = [self.resultsController objectAtIndexPath:indexPath];
        price = [self.resultsController objectAtIndexPath:indexPath];
        
    }
    
    self.selectedArticle = price.article;
    
    [self.view endEditing:NO];

    [self showArticleInfoPopover];
    
    return indexPath;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (!self.searchDisplayController.active) {
        self.searchFieldIsScrolledAway = (scrollView.contentOffset.y > self.searchBar.frame.size.height);
    }
    
}

#pragma mark - UISearchDisplayDelegate / deprecated in >8.0

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    
//    [self setupSearchBar];
    [self updateInfoLabel];
    
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    
    [self updateInfoLabel];
    self.searchResults = nil;
    
    if (self.searchFieldIsScrolledAway) {
        [self showSearchButton];
    }
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString scope:self.searchBar.selectedScopeButtonIndex];
    return YES;
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    [self filterContentForSearchText:self.searchBar.text scope:searchOption];
    return YES;
    
}

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSInteger)searchScope {
    
    NSPredicate *scopePredicate = [NSPredicate predicateWithValue:YES];
    
    NSString *key = @"article.pieceVolume";
    
    switch (searchScope) {
        case 0:
            break;
            
        case 1:
            scopePredicate = [NSPredicate predicateWithFormat:@"%K < 0.2", key];
            break;
            
        case 2:
            scopePredicate = [NSPredicate predicateWithFormat:@"%K >= 0.2 AND %K < 0.5", key, key];
            break;
            
        case 3:
            scopePredicate = [NSPredicate predicateWithFormat:@"%K == 0.5", key];
            break;
            
        case 4:
            scopePredicate = [NSPredicate predicateWithFormat:@"%K > 0.5 AND %K < 1", key, key];
            break;
            
        case 5:
            scopePredicate = [NSPredicate predicateWithFormat:@"%K == 1", key];
            break;
            
        case 6:
            scopePredicate = [NSPredicate predicateWithFormat:@"%K > 1", key];
            break;
            
        default:
            break;
    }
    
    NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"article.name CONTAINS[cd] %@", searchText];
    NSPredicate *extraLabelPredicate = [NSPredicate predicateWithFormat:@"article.extraLabel CONTAINS[cd] %@", searchText];
    NSCompoundPredicate *textPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[namePredicate, extraLabelPredicate]];
    NSCompoundPredicate *resultPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[scopePredicate, textPredicate]];
    
    self.searchResults = [self.resultsController.fetchedObjects filteredArrayUsingPredicate:resultPredicate];
    
}


#pragma mark - search bar setup

- (void)setupSearchBar {

//    NSArray *volumes = [self scopeButtonTitles];
//    NSString *minVolume = volumes[0];
//    NSString *maxVolume = [volumes lastObject];
//    NSString *firstButton = [NSString stringWithFormat:@"%@ - 0.5", minVolume];
//    NSString *lastButton = [NSString stringWithFormat:@"1 - %@", maxVolume];

//    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
//    self.searchBar.scopeButtonTitles = @[firstButton, @"0.5", @"0.5 - 1", @"1", lastButton];
    
    self.searchBar.scopeButtonTitles = @[NSLocalizedString(@"ALL", nil), @"< 0.2", @"~0.3", @"0.5", @"~0.7", @"1", @"> 1"];
    self.searchBar.selectedScopeButtonIndex = 0;

}

- (NSArray *)scopeButtonTitles {
    
    TICK;
    
    NSMutableArray *volumes = [NSMutableArray array];
    
    for (STMArticle *article in self.resultsController.fetchedObjects) {
        [volumes addObject:article.pieceVolume];
    }
    
    NSSet *volumesSet = [NSSet setWithArray:volumes];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES selector:@selector(compare:)];

    volumes = [[volumesSet sortedArrayUsingDescriptors:@[sortDescriptor]] mutableCopy];
    volumes = [volumes valueForKey:@"stringValue"];

    TOCK;
    
    NSLog(@"volumes %@", volumes);
    
    return volumes;
    
}

- (void)setupToolbar {
    
    [self priceTypeLabelSetup];
    [self priceTypeSelectorSetup];
    [self stockVolumeLabelSetup];
    [self stockVolumeButtonSetup];
    [self picturesFilterButtonSetup];
    [self infoLabelSetup];
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [super controllerDidChangeContent:controller];
        
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if ([anObject isKindOfClass:[NSManagedObject class]]) {
        
        NSManagedObjectID *objectID = [(NSManagedObject *)anObject objectID];
        [self.cachedCellsHeights removeObjectForKey:objectID];
        
    }
    
    [super controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    
}


- (void)pictureWasDownloaded:(NSNotification *)notification {
    
    if ([notification.object isKindOfClass:[STMArticlePicture class]]) {
        
        STMArticlePicture *articlePicture = (STMArticlePicture *)notification.object;
        
        NSSet *prices = [articlePicture.articles valueForKeyPath:@"@distinctUnionOfSets.prices"];
        
        for (STMPrice *price in prices) {
            
            NSIndexPath *indexPath = nil;
            UITableView *currentTableView = (self.searchDisplayController.active) ? self.searchDisplayController.searchResultsTableView : self.tableView;
            
            if (self.searchDisplayController.isActive) {
                
                NSUInteger index = [self.searchResults indexOfObject:price];
                indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                
            } else {
                
                indexPath = [self.resultsController indexPathForObject:price];
                
            }
            
            if (indexPath) [currentTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        }
        
    }

}

#pragma mark - view lifecycle

- (void)addObservers {

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(deviceOrientationDidChangeNotification:)
               name:UIDeviceOrientationDidChangeNotification
             object:nil];
    
    [nc addObserver:self selector:@selector(pictureWasDownloaded:) name:@"downloadPicture" object:nil];
    
}

- (void)customInit {
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom4TVCell" bundle:nil] forCellReuseIdentifier:Custom4CellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom5TVCell" bundle:nil] forCellReuseIdentifier:Custom5CellIdentifier];
    
    [self addObservers];
    
    [self setupToolbar];
    [self performFetch];
    [self setupSearchBar];
    
    
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
