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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"catalogMasterCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    STMArticleGroup *articleGroup = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = articleGroup.name;
    cell.detailTextLabel.text = nil;
    
    cell.accessoryType = (articleGroup.articleGroups.count > 0) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    if ([STMArticleGroupController numberOfArticlesInGroup:articleGroup] == 0) {
        cell.detailTextLabel.text = NSLocalizedString(@"NO ARTICLES", nil);
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
