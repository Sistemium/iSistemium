//
//  STMCatalogDetailTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCatalogDetailTVC.h"
#import "STMCatalogSVC.h"
#import "STMArticleInfoVC.h"


@interface STMCatalogDetailTVC () <UIPopoverControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) STMCatalogSVC *splitVC;

@property (weak, nonatomic) IBOutlet STMBarButtonItem *infoLabel;
@property (weak, nonatomic) IBOutlet STMBarButtonItem *priceTypeLabel;
@property (weak, nonatomic) IBOutlet STMBarButtonItem *priceTypeSelector;
@property (weak, nonatomic) IBOutlet STMBarButtonItem *stockVolumeLabel;
@property (weak, nonatomic) IBOutlet STMBarButtonItem *stockVolumeButton;

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) BOOL searchFieldIsScrolledAway;

@property (nonatomic, strong) UIPopoverController *articleInfoPopover;
@property (nonatomic) BOOL articleInfoPopoverIsVisible;

@property (nonatomic, strong) UIActionSheet *priceTypeSelectorActionSheet;
@property (nonatomic, strong) UIActionSheet *stockVolumeFilterActionSheet;

@property (nonatomic, strong) STMArticle *selectedArticle;


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

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPrice class])];
        
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
    
    if (self.splitVC.selectedPriceType) {
        
        NSPredicate *priceTypePredicate = [NSPredicate predicateWithFormat:@"priceType == %@", self.splitVC.selectedPriceType];

//        NSPredicate *priceTypePredicate = [NSPredicate predicateWithFormat:@"ANY prices.priceType == %@", self.splitVC.selectedPriceType];
//        NSPredicate *priceTypePredicate = [NSPredicate predicateWithFormat:@"SUBQUERY(prices, $x, $x.priceType == %@ AND $x.price == 0).@count > 0", self.splitVC.selectedPriceType];
//        NSPredicate *priceTypePredicate = [NSPredicate predicateWithFormat:@"SUBQUERY(prices, $x, $x.priceType == %@).@count > 0", self.splitVC.selectedPriceType];
        
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, priceTypePredicate]];
        
    }
    
    if (!self.splitVC.showZeroStock) {
        
        NSPredicate *groupPredicate = [NSPredicate predicateWithFormat:@"article.stock.volume.integerValue > 0"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, groupPredicate]];
        
    }

    NSPredicate *pricePredicate = [NSPredicate predicateWithFormat:@"price > 0"];
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, pricePredicate]];

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
        
        if (self.searchDisplayController.active) {
            self.searchBar.text = self.searchBar.text;
        }

    }
    
}

- (void)refreshTable {
    
    [self performFetch];
//    [self setupToolbar];
    
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
    
    self.priceTypeLabel.title = NSLocalizedString(@"PRICE_TYPE_LABEL", nil);
    [self setupBarButton:self.priceTypeLabel asLabelWithColor:nil];
    
}

- (void)priceTypeSelectorSetup {
    
    self.priceTypeSelector.title = self.splitVC.selectedPriceType.name;
    self.priceTypeSelector.target = self;
    self.priceTypeSelector.action = @selector(showPriceTypeSelector);
    
}

- (void)stockVolumeLabelSetup {
    
    self.stockVolumeLabel.title = NSLocalizedString(@"SHOW ARTICLES", nil);
    [self setupBarButton:self.stockVolumeLabel asLabelWithColor:nil];
    
}

- (void)stockVolumeButtonSetup {
    
    NSString *title = (self.splitVC.showZeroStock) ? NSLocalizedString(@"SHOW ALL ARTICLES", nil) : NSLocalizedString(@"SHOW NONZERO STOCK ARTICLES", nil);
    
    self.stockVolumeButton.title = title;
    self.stockVolumeButton.target = self;
    self.stockVolumeButton.action = @selector(showStockVolumeFilter);
    
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
            [self refreshTable];
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
    
    CGRect rect = CGRectMake(self.splitVC.view.frame.size.width/2, self.splitVC.view.frame.size.height/2, 1, 1);
    [self.articleInfoPopover presentPopoverFromRect:rect inView:self.splitVC.view permittedArrowDirections:0 animated:YES];

}

- (void)dismissArticleInfoPopover {
    
    [self.articleInfoPopover dismissPopoverAnimated:YES];
    self.articleInfoPopover = nil;
    
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

#pragma mark - Table view data source

- (NSString *)detailedTextForArticle:(STMArticle *)article {
    
    NSString *detailedText = @"";
    NSString *appendString = @"";
    
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"priceType = %@", self.splitVC.selectedPriceType];
    
    STMPrice *price = [article.prices filteredSetUsingPredicate:predicate].allObjects.lastObject;
    
    appendString = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:price.price]];
    detailedText = [detailedText stringByAppendingString:appendString];
    
    if (article.extraLabel) {
        
        appendString = [NSString stringWithFormat:@", %@", article.extraLabel];
        detailedText = [detailedText stringByAppendingString:appendString];
        
    }
    
    if (article.stock.volume.integerValue <= 0) {
        
        appendString = [NSString stringWithFormat:@", %@", NSLocalizedString(@"ZERO STOCK", nil)];
        detailedText = [detailedText stringByAppendingString:appendString];
        
    }
    
    return detailedText;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger count = (tableView == self.searchDisplayController.searchResultsTableView) ? self.searchResults.count : [super tableView:tableView numberOfRowsInSection:section];

    [self updateInfoLabelWithArticleCount:count];
    
    return count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"catalogDetailCell";
    
    STMInfoTableViewCell *cell = [[STMInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];

//    STMArticle *article = nil;
    
    STMPrice *price = nil;

    if (tableView == self.searchDisplayController.searchResultsTableView) {

//        article = [self.searchResults objectAtIndex:indexPath.row];
        price = [self.searchResults objectAtIndex:indexPath.row];

    } else {
        
//        article = [self.resultsController objectAtIndexPath:indexPath];
        price = [self.resultsController objectAtIndexPath:indexPath];
        
    }
    
    cell.textLabel.text = price.article.name;
    cell.detailTextLabel.text = [self detailedTextForArticle:price.article];
    
    NSString *volumeUnitString = NSLocalizedString(@"VOLUME UNIT", nil);
    cell.infoLabel.text = [NSString stringWithFormat:@"%@%@", price.article.pieceVolume, volumeUnitString];
    
    if (price.article.stock.volume.integerValue <= 0) {
        
        UIColor *lightGrayColor = [UIColor lightGrayColor];
        
        cell.textLabel.textColor = lightGrayColor;
        cell.detailTextLabel.textColor = lightGrayColor;
        cell.infoLabel.textColor = lightGrayColor;

    }
    
    return cell;
    
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
    [self infoLabelSetup];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
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
