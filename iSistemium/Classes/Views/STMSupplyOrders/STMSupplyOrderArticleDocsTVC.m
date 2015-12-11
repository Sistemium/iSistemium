//
//  STMSupplyOrderArticleDocsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOrderArticleDocsTVC.h"

#import "STMSupplyOrdersSVC.h"


@interface STMSupplyOrderArticleDocsTVC ()

@property (nonatomic, weak) STMSupplyOrdersSVC *splitVC;


@end


@implementation STMSupplyOrderArticleDocsTVC

@synthesize resultsController =_resultsController;

- (STMSupplyOrdersSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMSupplyOrdersSVC class]]) {
            _splitVC = (STMSupplyOrdersSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
    
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSupplyOrderArticleDoc class])];
        
        NSSortDescriptor *ordDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord" ascending:YES selector:@selector(compare:)];
        NSSortDescriptor *articleNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[ordDescriptor, articleNameDescriptor];
        
        request.predicate = [NSPredicate predicateWithFormat:@"supplyOrder == %@", self.supplyOrder];
        
    }
    return _resultsController;
    
}

- (void)setSupplyOrder:(STMSupplyOrder *)supplyOrder {
    
    _supplyOrder = supplyOrder;
    
    [self performFetch];
    
}


#pragma mark - view lifecycle

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewSubtitleStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
 
    if ([cell isKindOfClass:[STMTableViewSubtitleStyleCell class]]) {
        [self fillArticleDocCell:(STMTableViewSubtitleStyleCell *)cell atIndexPath:indexPath];
    }
    
}

- (void)fillArticleDocCell:(STMTableViewSubtitleStyleCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMSupplyOrderArticleDoc *articleDoc = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = articleDoc.article.name;

    NSMutableArray *dates = @[].mutableCopy;

    if (articleDoc.articleDoc.dateProduction) {
        [dates addObject:[[STMFunctions dateShortNoTimeFormatter] stringFromDate:(NSDate * _Nonnull)articleDoc.articleDoc.dateProduction]];
    }
    
    if (articleDoc.articleDoc.dateImport) {
        [dates addObject:[[STMFunctions dateShortNoTimeFormatter] stringFromDate:(NSDate * _Nonnull)articleDoc.articleDoc.dateImport]];
    }
    
    cell.detailTextLabel.text  = [dates componentsJoinedByString:@" / "];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
