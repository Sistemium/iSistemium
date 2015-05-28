//
//  STMCatalogMasterTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 02/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCatalogMasterTVC.h"
#import "STMCatalogSVC.h"

@interface STMCatalogMasterTVC ()

@property (nonatomic, weak) STMCatalogSVC *splitVC;
@property (nonatomic) CGFloat heightCorrection;
@property (nonatomic, strong) NSArray *filteredFetchResults;

@property (nonatomic, strong) STMArticleGroup *baseArticleGroup;
@property (nonatomic) BOOL baseArticleIsAssigned;

@end


@implementation STMCatalogMasterTVC

@synthesize resultsController = _resultsController;


- (STMCatalogSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMCatalogSVC class]]) {
            _splitVC = (STMCatalogSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (STMArticleGroup *)baseArticleGroup {
    
    if (!_baseArticleGroup) {

        if (!self.baseArticleIsAssigned) {
            
            _baseArticleGroup = self.splitVC.currentArticleGroup;
            self.baseArticleIsAssigned = YES;
            
        }
        
    }
    return _baseArticleGroup;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMArticleGroup class])];
        
        NSSortDescriptor *ordDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord" ascending:YES selector:@selector(compare:)];
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[ordDescriptor, nameDescriptor];
        
        request.predicate = [NSPredicate predicateWithFormat:@"articleGroup == %@", self.baseArticleGroup];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    
    return _resultsController;
    
}

- (NSCompoundPredicate *)requestPredicate {
    
    NSCompoundPredicate *predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:@[]];
    
    NSPredicate *childlessPredicate = [NSPredicate predicateWithFormat:@"(articlesCount > 0) OR (ANY children.articlesCount > 0)"];
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, childlessPredicate]];
    
    if (self.splitVC.showOnlyNonZeroStock) {
        
        NSPredicate *zeroStockPredicate = [NSPredicate predicateWithFormat:@"(articlesStockVolume > 0) OR (ANY children.articlesStockVolume > 0)"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, zeroStockPredicate]];
        
    }
    
    if (self.splitVC.showOnlyWithPictures) {
        
        NSPredicate *showOnlyWithPicturesPredicate = [NSPredicate predicateWithFormat:@"(articlesPicturesCount > 0) OR (ANY children.articlesPicturesCount > 0)"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, showOnlyWithPicturesPredicate]];
        
    }
    
    if (self.splitVC.selectedPriceType) {
        
        NSPredicate *priceTypePredicate = [NSPredicate predicateWithFormat:@"(ANY articlesPriceTypes == %@) OR (ANY children.@distinctUnionOfSets.articlesPriceTypes == %@)", self.splitVC.selectedPriceType, self.splitVC.selectedPriceType];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, priceTypePredicate]];
        
    }
    
    return predicate;
    
}

- (NSCompoundPredicate *)refillParentsPredicate {
    
    NSCompoundPredicate *predicate = [[NSCompoundPredicate alloc] initWithType:NSAndPredicateType subpredicates:@[]];
    
    if (self.splitVC.showOnlyNonZeroStock) {
        
        NSPredicate *zeroStockPredicate = [NSPredicate predicateWithFormat:@"articlesStockVolume > 0"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, zeroStockPredicate]];
        
    }
    
    if (self.splitVC.showOnlyWithPictures) {
        
        NSPredicate *showOnlyWithPicturesPredicate = [NSPredicate predicateWithFormat:@"articlesPicturesCount > 0"];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, showOnlyWithPicturesPredicate]];
        
    }
    
    if (self.splitVC.selectedPriceType) {
        
        NSPredicate *priceTypePredicate = [NSPredicate predicateWithFormat:@"ANY articlesPriceTypes == %@", self.splitVC.selectedPriceType];
        predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicate, priceTypePredicate]];
        
    }
    
    return predicate;

}

- (void)performFetch {
    
    self.resultsController = nil;

//    TICK;
    [STMArticleGroupController refillParentsWithPredicate:[self refillParentsPredicate]];
//    TOCK;
    
    
    
    
    
    NSError *error;
    if (![self.resultsController performFetch:&error]) {
        
        NSLog(@"performFetch error %@", error);
        
    } else {
        
        [self filterFetchResults];
        //        [self.tableView reloadData];
        
    }
    
}

- (void)filterFetchResults {
    
    NSFetchRequest *request = self.resultsController.fetchRequest.copy;
    
    NSCompoundPredicate *predicate = [self requestPredicate];
    if (predicate.subpredicates.count > 0) request.predicate = predicate;

//    [self nsLogFetchResults:self.resultsController.fetchedObjects];
    
    self.filteredFetchResults = [self.resultsController.fetchedObjects filteredArrayUsingPredicate:predicate];
    
//    [self nsLogFetchResults:self.filteredFetchResults];
//    NSLog(@"catalogMasterTVC %@", self);
//    NSLog(@"filteredFetchResults.count %d", self.filteredFetchResults.count);
    
    [self.tableView reloadData];

}

- (void)nsLogFetchResults:(NSArray *)fetchResults {
    
    NSLog(@"------------------------------------------------s");
    
    for (STMArticleGroup *articleGroup in fetchResults) {
        
        NSLog(@"group %@ priceTypes %d", articleGroup.name, articleGroup.articlesPriceTypes.count);
        NSLog(@" articles.count %d", articleGroup.articles.count)
        
        for (STMPriceType *priceType in articleGroup.articlesPriceTypes) {
            
            NSLog(@"    priceType.name %@", priceType.name);
//            NSLog(@"    priceType.xid %@", priceType.xid);
            
            if ([priceType isEqual:self.splitVC.selectedPriceType]) {
                
                NSLog(@" isEqual:self.splitVC.selectedPriceType");
                
            }
            
        }
        
    }

    NSLog(@"------------------------------------------------f");
    
}

- (void)refreshTable {
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];

    STMCatalogMasterTVC *nextTVC = [self nextTVC];
    
    if (nextTVC) {
        [nextTVC refreshTable];
    }
    
    [self performFetch];

    if ([self isEqual:self.navigationController.topViewController]) {

        NSUInteger row = [self.filteredFetchResults indexOfObject:self.splitVC.currentArticleGroup];
        
        if (selectedIndexPath && row == NSNotFound) {
            self.splitVC.currentArticleGroup = self.splitVC.currentArticleGroup.articleGroup;
        }

    }

}

- (STMCatalogMasterTVC *)nextTVC {
    
    NSArray *vcs = self.navigationController.viewControllers;
    NSUInteger index = [vcs indexOfObject:self];
    index++;
    
    if (vcs.count > index) {
        
        UIViewController *vc = vcs[index];
        
        if ([vc isKindOfClass:[STMCatalogMasterTVC class]]) {
            
            return (STMCatalogMasterTVC *)vc;

        } else {
            return nil;
        }
        
    } else {
        return nil;
    }
    
}

#pragma mark - keyboard show / hide

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGFloat keyboardHeight = [self keyboardHeightFrom:[notification userInfo]];
    CGFloat tableViewHeight = self.tableView.frame.size.height;
    CGFloat tableViewOriginY = self.tableView.frame.origin.y;
    CGFloat splitViewHeight = self.splitVC.view.frame.size.height;
    
    self.heightCorrection = splitViewHeight - (tableViewOriginY + tableViewHeight) - keyboardHeight;
    
    CGRect frame = self.tableView.frame;
    self.tableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height + self.heightCorrection);
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    
    CGRect frame = self.tableView.frame;
    self.tableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - self.heightCorrection);
    
}

- (CGFloat)keyboardHeightFrom:(NSDictionary *)info {
    
    CGRect keyboardRect = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    keyboardRect = [[[UIApplication sharedApplication].delegate window] convertRect:keyboardRect fromView:self.view];
    
    return keyboardRect.size.height;
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.filteredFetchResults.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"catalogMasterCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    UIColor *blackColor = [UIColor blackColor];
    cell.textLabel.textColor = blackColor;
    cell.detailTextLabel.textColor = blackColor;
    
//    STMArticleGroup *articleGroup = [self.resultsController objectAtIndexPath:indexPath];
    STMArticleGroup *articleGroup = [self.filteredFetchResults objectAtIndex:indexPath.row];
    
    cell.textLabel.text = articleGroup.name;
    cell.detailTextLabel.text = nil;
    
    cell.accessoryType = (articleGroup.articleGroups.count > 0) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    if ([STMArticleGroupController numberOfArticlesInGroup:articleGroup] == 0) {
        cell.detailTextLabel.text = NSLocalizedString(@"NO ARTICLES", nil);
    }
    
    if (!self.splitVC.showOnlyNonZeroStock) {
        
        NSInteger stockVolume = articleGroup.articlesStockVolume;
        for (STMArticleGroup *child in articleGroup.children) stockVolume += child.articlesStockVolume;
        
        if (stockVolume <= 0) {
            
            UIColor *lightGrayColor = [UIColor lightGrayColor];
            cell.textLabel.textColor = lightGrayColor;
            cell.detailTextLabel.textColor = lightGrayColor;

            cell.detailTextLabel.text = NSLocalizedString(@"ZERO STOCK", nil);
            
        }

    }
    
    if ([articleGroup isEqual:self.splitVC.currentArticleGroup]) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

//    STMArticleGroup *articleGroup = [self.resultsController objectAtIndexPath:indexPath];
    STMArticleGroup *articleGroup = [self.filteredFetchResults objectAtIndex:indexPath.row];
    
    NSArray *selectedIndexPaths = [tableView indexPathsForSelectedRows];
    
    if ([selectedIndexPaths containsObject:indexPath]) {
        
        self.splitVC.currentArticleGroup = articleGroup.articleGroup;

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        return nil;
        
    } else {
        
        self.splitVC.currentArticleGroup = articleGroup;
        
        if (articleGroup.articleGroups.count > 0) {
            
            STMCatalogMasterTVC *nextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"catalogMasterTVC"];
            [self.navigationController pushViewController:nextVC animated:YES];
            
        }
        
        return indexPath;

    }
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
//    [super controllerDidChangeContent:controller];

    [self filterFetchResults];
    
}


#pragma mark - view lifecycle

- (void)addObservers {

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    
    [nc addObserver:self
           selector:@selector(keyboardWillBeHidden:)
               name:UIKeyboardWillHideNotification
             object:nil];

}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)customInit {
    
    [self addObservers];
    [self performFetch];
    
    self.navigationItem.title = (self.splitVC.currentArticleGroup) ? self.splitVC.currentArticleGroup.name : NSLocalizedString(@"CATALOG", nil);
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        
        NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
        
        if (selectedIndexPaths.count == 0) {
            self.splitVC.currentArticleGroup = self.splitVC.currentArticleGroup.articleGroup;
        } else {
            self.splitVC.currentArticleGroup = self.splitVC.currentArticleGroup.articleGroup.articleGroup;
        }
        
    }
    
    [super viewWillDisappear:animated];
    
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
