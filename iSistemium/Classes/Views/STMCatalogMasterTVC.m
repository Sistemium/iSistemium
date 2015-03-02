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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"ord %@, groups %lu", articleGroup.ord, (unsigned long)articleGroup.articleGroups.count];
    
    return cell;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    STMArticleGroup *articleGroup = [self.resultsController objectAtIndexPath:indexPath];
    NSLog(@"articleGroup %@", articleGroup);
    
    for (STMArticleGroup *childGroup in articleGroup.articleGroups) {
        NSLog(@"childGroup.name %@", childGroup.name);
    }
    
    return indexPath;
    
}

#pragma mark - view lifecycle

- (void)customInit {
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
