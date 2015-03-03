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

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMArticleGroup class])];
        
        NSSortDescriptor *ordDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord" ascending:YES selector:@selector(compare:)];
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[ordDescriptor, nameDescriptor];
        
        request.predicate = [NSPredicate predicateWithFormat:@"articleGroup == %@", self.splitVC.currentArticleGroup];
        
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
        
        //        [self.tableView reloadData];
        
    }
    
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"catalogMasterCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    STMArticleGroup *articleGroup = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = articleGroup.name;
    cell.detailTextLabel.text = nil;
    
    if (articleGroup.articleGroups.count > 0) {
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (articleGroup.articles.count == 0) {
            cell.detailTextLabel.text = NSLocalizedString(@"NO ARTICLES", nil);
        }
        
    }
    
    return cell;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    STMArticleGroup *articleGroup = [self.resultsController objectAtIndexPath:indexPath];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [self performFetch];
    
    self.navigationItem.title = (self.splitVC.currentArticleGroup) ? self.splitVC.currentArticleGroup.name : NSLocalizedString(@"CATALOG", nil);
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        self.splitVC.currentArticleGroup = self.splitVC.currentArticleGroup.articleGroup;
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
