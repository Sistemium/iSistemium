//
//  STMCatalogDetailTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCatalogDetailTVC.h"
#import "STMCatalogSVC.h"

@interface STMCatalogDetailTVC ()

@property (nonatomic, weak) STMCatalogSVC *splitVC;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoLabel;
@property (nonatomic, strong) NSArray *searchResults;

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
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMArticle class])];
        
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[nameDescriptor];
        
        if (self.splitVC.currentArticleGroup) {
            
            NSArray *filterArray = [self.splitVC nestedArticleGroups];
            request.predicate = [NSPredicate predicateWithFormat:@"articleGroup IN %@", filterArray];
    
        }
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (void)performFetch {
    
    self.resultsController = nil;
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
        [self.tableView reloadData];
//        NSLog(@"articles count %d", self.resultsController.fetchedObjects.count);
        [self updateInfoLabel];
        
    }
    
}

- (void)refreshTable {
    
    [self performFetch];
    
}

- (void)infoLabelSetup {
    
    self.infoLabel.title = @"";
    self.infoLabel.enabled = NO;
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.infoLabel setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [self.infoLabel setTitleTextAttributes:attributes forState:UIControlStateDisabled];

}

- (void)updateInfoLabel {
    
    NSUInteger count = self.resultsController.fetchedObjects.count;
    
    NSString *pluralType = [STMFunctions pluralTypeForCount:count];
    NSString *labelString = [pluralType stringByAppendingString:@"ARTICLES"];
    
    NSString *numberString = (count > 0) ? [NSString stringWithFormat:@"%lu ", (unsigned long)count] : @"";
    
    NSString *infoString = [numberString stringByAppendingString:NSLocalizedString(labelString, nil)];
    
    [self.infoLabel setTitle:infoString];
    
}

- (NSString *)detailedTextForArticle:(STMArticle *)article {
    
    NSString *detailedText = @"";
    NSString *appendString = @"";
    
    if (article.extraLabel) {
        
        appendString = [NSString stringWithFormat:@"%@ ", article.extraLabel];
        detailedText = [detailedText stringByAppendingString:appendString];
        
    }
    
    appendString = [NSString stringWithFormat:@"%@, ", article.code];
    detailedText = [detailedText stringByAppendingString:appendString];
    
    NSString *packageString = NSLocalizedString(@"PACKAGE REL", nil);
    appendString = [NSString stringWithFormat:@"%@: %@, ", packageString, article.packageRel];
    detailedText = [detailedText stringByAppendingString:appendString];

    NSString *factorString = NSLocalizedString(@"FACTOR", nil);
    appendString = [NSString stringWithFormat:@"%@: %@, ", factorString, article.factor];
    detailedText = [detailedText stringByAppendingString:appendString];

    NSString *volumeString = NSLocalizedString(@"VOLUME", nil);
    NSString *volumeUnitString = NSLocalizedString(@"VOLUME UNIT", nil);
    appendString = [NSString stringWithFormat:@"%@: %@%@", volumeString, article.pieceVolume, volumeUnitString];
    detailedText = [detailedText stringByAppendingString:appendString];

    return detailedText;
    
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    
//    if (tableView == self.searchDisplayController.searchResultsTableView) {
//        return 1;
//    } else {
//        return [super numberOfSectionsInTableView:tableView];
//    }
//
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResults.count;
    } else {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    
//    if (tableView == self.searchDisplayController.searchResultsTableView) {
//        return nil;
//    } else {
//        return [super tableView:tableView titleForHeaderInSection:section];
//    }
//    
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"catalogDetailCell";
    
    STMUIInfoTableViewCell *cell = [[STMUIInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];

    STMArticle *article = nil;

    if (tableView == self.searchDisplayController.searchResultsTableView) {
        article = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        article = [self.resultsController objectAtIndexPath:indexPath];
    }

    
    cell.textLabel.text = article.name;
    
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@: %@, %@, %@, %@", article.code, volumeString, article.pieceVolume, article.extraLabel, article.factor, article.packageRel];
    
    cell.detailTextLabel.text = [self detailedTextForArticle:article];
    
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
    cell.infoLabel.text = [numberFormatter stringFromNumber:article.price];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell = nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    STMArticle *article = [self.resultsController objectAtIndexPath:indexPath];
//    NSLog(@"article %@", article);
    
    return indexPath;
    
}


#pragma mark - UISearchDisplayDelegate
#warning self.searchDisplayController is deprecated — have to find workaround

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    [self filterContentForSearchText:searchString];
//                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
//                                      objectAtIndex:[self.searchDisplayController.searchBar
//                                                     selectedScopeButtonIndex]]];
    
    return YES;
}


- (void)filterContentForSearchText:(NSString*)searchText/* scope:(NSString*)scope*/ {
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
    self.searchResults = [self.resultsController.fetchedObjects filteredArrayUsingPredicate:resultPredicate];
    
}



#pragma mark - view lifecycle

- (void)customInit {
    
    [self infoLabelSetup];
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
