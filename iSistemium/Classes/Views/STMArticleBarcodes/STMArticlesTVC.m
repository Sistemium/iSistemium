//
//  STMArticlesTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 26/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticlesTVC.h"

#import "STMArticleCodesTVC.h"


@interface STMArticlesTVC ()


@end


@implementation STMArticlesTVC

@synthesize resultsController = _resultsController;


- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
    
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMArticle class])];
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
        
        if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
            request.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchBar.text];
        }
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (void)performFetch {
    
    [super performFetch];
    [self updateArticleCountInfo];
    
}

#pragma mark - table view data

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewSubtitleStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    STMArticle *article = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", article.name, (article.extraLabel) ? article.extraLabel : @""];
    cell.detailTextLabel.text = @(article.barCodes.count).stringValue;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (IPHONE) {
        [self performSegueWithIdentifier:@"showCodes" sender:indexPath];
    }
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showCodes"] &&
        [segue.destinationViewController isKindOfClass:[STMArticleCodesTVC class]] &&
        [sender isKindOfClass:[NSIndexPath class]]) {
        
        STMArticle *article = [self.resultsController objectAtIndexPath:(NSIndexPath *)sender];
        
        STMArticleCodesTVC *codesTVC = (STMArticleCodesTVC *)segue.destinationViewController;
        codesTVC.article = article;
        
    }
    
}


#pragma mark - toolbars

- (void)updateArticleCountInfo {
    
    NSInteger articleCount = self.resultsController.fetchedObjects.count;
    NSString *pluralType = [STMFunctions pluralTypeForCount:articleCount];
    NSString *articlePluralString = [pluralType stringByAppendingString:@"ARTICLES"];
    
    NSString *articleCountString = nil;
    
    if (articleCount == 0) {
        articleCountString = NSLocalizedString(articlePluralString, nil);
    } else {
        articleCountString = [NSString stringWithFormat:@"%@ %@", @(articleCount), NSLocalizedString(articlePluralString, nil)];
    }
    
    STMBarButtonItemLabel *label = [[STMBarButtonItemLabel alloc] initWithTitle:articleCountString
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:nil
                                                                         action:nil];
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
    
    [self setToolbarItems:@[flexibleSpace, label, flexibleSpace] animated:NO];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    
    self.navigationItem.title = NSLocalizedString(@"ARTICLES", nil);
    
    [self performFetch];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
