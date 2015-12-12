//
//  STMSupplyOrdersTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOrdersTVC.h"

#import "STMSupplyOrdersSVC.h"


@interface STMSupplyOrdersTVC ()

@property (nonatomic, weak) STMSupplyOrdersSVC *splitVC;


@end


@implementation STMSupplyOrdersTVC

@synthesize resultsController = _resultsController;

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
    
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSupplyOrder class])];
        
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        NSSortDescriptor *ndocDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ndoc" ascending:NO selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[dateDescriptor, ndocDescriptor];
        
        request.predicate = [STMPredicate predicateWithNoFantoms];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:@"dayAsString"
                                                                            cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}


#pragma mark - table view data

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewSubtitleStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self fillSupplyOrderCell:(STMTableViewSubtitleStyleCell *)cell atIndexPath:indexPath];

    return cell;
    
}

- (void)fillSupplyOrderCell:(STMTableViewSubtitleStyleCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMSupplyOrder *supplyOrder = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = supplyOrder.ndoc;
    
    NSUInteger positionsCount = supplyOrder.supplyOrderArticleDocs.count;
    NSString *pluralTypeString = [[STMFunctions pluralTypeForCount:positionsCount] stringByAppendingString:@"POSITIONS"];
    
    NSString *positionsCountString = nil;
    
    if (positionsCount == 0) {
        positionsCountString = [NSString stringWithFormat:@"%@",NSLocalizedString(pluralTypeString, nil)];
    } else {
        positionsCountString = [NSString stringWithFormat:@"%lu %@", (unsigned long)positionsCount, NSLocalizedString(pluralTypeString, nil)];
    }

    cell.detailTextLabel.text = positionsCountString;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMSupplyOrder *supplyOrder = [self.resultsController objectAtIndexPath:indexPath];
    UIColor *processingColor = [STMWorkflowController colorForProcessing:supplyOrder.processing inWorkflow:self.splitVC.supplyOrderWorkflow];
    
    [[cell.contentView viewWithTag:1] removeFromSuperview];
    
    CGFloat fillWidth = 5;
    
    CGRect rect = CGRectMake(1, 1, fillWidth, cell.frame.size.height-2);
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.tag = 1;
    view.backgroundColor = (processingColor) ? processingColor : [UIColor blackColor];
    
    [cell.contentView addSubview:view];
    [cell.contentView sendSubviewToBack:view];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMSupplyOrder *supplyOrder = [self.resultsController objectAtIndexPath:indexPath];

    self.splitVC.selectedSupplyOrder = supplyOrder;
    
}


#pragma mark - Navigation

- (void)segueToArticleDocs {
    
    if ([self.navigationController.topViewController isEqual:self]) {
        [self performSegueWithIdentifier:@"showArticleDocs" sender:nil];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showArticleDocs"] &&
        [segue.destinationViewController isKindOfClass:[STMSupplyOrderArticleDocsTVC class]]) {
        
        
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationItem.title = NSLocalizedString(@"SUPPLY ORDERS", nil);
    
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


@end
