//
//  STMPickingOrdersTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingOrdersTVC.h"

#import "STMPickingOrderArticlesTVC.h"


@interface STMPickingOrdersTVC ()


@end


@implementation STMPickingOrdersTVC

@synthesize resultsController = _resultsController;

- (NSString *)cellIdentifier {
    return @"pickingOrderCell";
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPickingOrder class])];
        
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        request.sortDescriptors = @[dateDescriptor];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}


#pragma mark - table view data source

- (UITableViewCell *)cellForHeightCalculationForIndexPath:(NSIndexPath *)indexPath {
    
    static UITableViewCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    });
    
    return cell;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMPickingOrder *pickingOrder = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = pickingOrder.ndoc;
    
    cell.detailTextLabel.text = (pickingOrder.date) ? [[STMFunctions dateLongNoTimeFormatter] stringFromDate:(NSDate * _Nonnull)pickingOrder.date] : NSLocalizedString(@"NO DATA", nil);
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMPickingOrder *pickingOrder = [self.resultsController objectAtIndexPath:indexPath];

    STMPickingOrderArticlesTVC *articlesTVC = [[STMPickingOrderArticlesTVC alloc] initWithStyle:UITableViewStyleGrouped];
    articlesTVC.pickingOrder = pickingOrder;
    
    [self.navigationController pushViewController:articlesTVC animated:YES];
    
    
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:pickingOrder.ndoc
//                                                        message:nil
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
//                                              otherButtonTitles:nil];
//        
//        [alert show];
//        
//    }];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    self.title = NSLocalizedString(@"PICKING ORDERS", nil);
    
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
