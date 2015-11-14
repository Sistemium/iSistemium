//
//  STMPhotoReportAddPhotoTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPhotoReportAddPhotoTVC.h"


@interface STMPhotoReportAddPhotoTVC ()


@end


@implementation STMPhotoReportAddPhotoTVC

@synthesize resultsController = _resultsController;
@synthesize cellIdentifier = _cellIdentifier;


- (NSString *)cellIdentifier {
    return @"addPhotoCell";
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
    
        STMFetchRequest *request = nil;
        NSString *sectionNameKeyPath = nil;
        NSMutableArray *subpredicates = [NSMutableArray array];
        
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                         ascending:YES
                                                                          selector:@selector(caseInsensitiveCompare:)];

        switch (self.parentVC.currentGrouping) {
                
            case STMPhotoReportGroupingCampaign: {
                
                request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMCampaign class])];
                
                request.sortDescriptors = @[nameDescriptor];
                sectionNameKeyPath = @"campaignGroup.displayName";
                
                [subpredicates addObject:[NSPredicate predicateWithFormat:@"campaignGroup == %@", self.parentVC.selectedCampaignGroup]];
                
                break;
            }
            case STMPhotoReportGroupingOutlet: {
                
                request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMOutlet class])];

                NSSortDescriptor *partnerNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"partner.name"
                                                                                        ascending:YES
                                                                                         selector:@selector(caseInsensitiveCompare:)];

                request.sortDescriptors = @[partnerNameDescriptor, nameDescriptor];
                sectionNameKeyPath = @"partner.name";

                break;
            }
            default: {
                break;
            }
                
        }
        
        if (request) {
            
            if ([self.searchBar isFirstResponder] && ![self.searchBar.text isEqualToString:@""]) {
                [subpredicates addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchBar.text]];
            }

            NSCompoundPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
            
            request.predicate = predicate;
            
            NSFetchedResultsController *rc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                 managedObjectContext:self.document.managedObjectContext
                                                                                   sectionNameKeyPath:sectionNameKeyPath
                                                                                            cacheName:nil];
            _resultsController = rc;

        }
        
    }
    return _resultsController;
    
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    return MAX(height, self.standardCellHeight);
    
}

- (UITableViewCell *)cellForHeightCalculationForIndexPath:(NSIndexPath *)indexPath {
    
    static STMCustom7TVCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    });
    
    return cell;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    STMCustom7TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];

    [self fillCell:cell atIndexPath:indexPath];

    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom7TVCell *customCell = nil;
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        
        customCell = (STMCustom7TVCell *)cell;
    
        switch (self.parentVC.currentGrouping) {
                
            case STMPhotoReportGroupingCampaign: {
                [self fillCampaignCell:customCell atIndexPath:indexPath];
                break;
            }
            case STMPhotoReportGroupingOutlet: {
                [self fillOutletCell:customCell atIndexPath:indexPath];
                break;
            }
            default: {
                break;
            }
                
        }

    }
    
    [super fillCell:cell atIndexPath:indexPath];

}

- (void)fillCampaignCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMCampaign *campaign = [self.resultsController objectAtIndexPath:indexPath];

    cell.titleLabel.text = campaign.name;
    cell.detailLabel.text = nil;
    
}

- (void)fillOutletCell:(STMCustom7TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMOutlet *outlet = [self.resultsController objectAtIndexPath:indexPath];

    UIColor *textColor = (!outlet.isActive || [outlet.isActive boolValue]) ? [UIColor blackColor] : [UIColor redColor];
    
    cell.titleLabel.textColor = textColor;

    cell.titleLabel.text = outlet.shortName;
    cell.detailLabel.text = nil;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (self.parentVC.currentGrouping) {
        case STMPhotoReportGroupingCampaign: {
            STMCampaign *campaign = [self.resultsController objectAtIndexPath:indexPath];
            self.parentVC.selectedCampaignForPhotoReport = campaign;
            break;
        }
        case STMPhotoReportGroupingOutlet: {
            STMOutlet *outlet = [self.resultsController objectAtIndexPath:indexPath];
            self.parentVC.selectedOutletForPhotoReport = outlet;
            break;
        }
        default: {
            break;
        }
    }
    
}


- (void)selectingCells {
    
    NSManagedObject *selectedObject = nil;
    
    switch (self.parentVC.currentGrouping) {
        case STMPhotoReportGroupingCampaign: {
            selectedObject = self.parentVC.selectedCampaignForPhotoReport;
            break;
        }
        case STMPhotoReportGroupingOutlet: {
            selectedObject = self.parentVC.selectedOutletForPhotoReport;
            break;
        }
        default: {
            break;
        }
    }
    
    if (selectedObject) {
        
        if ([self.resultsController.fetchedObjects containsObject:selectedObject]) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{

                NSIndexPath *selectedIndexPath = [self.resultsController indexPathForObject:selectedObject];
                [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];

            }];
            
        }
        
    }

}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom7TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];

    switch (self.parentVC.currentGrouping) {
        case STMPhotoReportGroupingCampaign: {
            self.title = NSLocalizedString(@"SELECT CAMPAIGN", nil);
            break;
        }
        case STMPhotoReportGroupingOutlet: {
            self.title = NSLocalizedString(@"SELECT OUTLET", nil);
            break;
        }
        default: {
            break;
        }
    }
    
    [self performFetchWithCompletionHandler:^(BOOL success) {
        if (success) {
            [self selectingCells];
        }
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if ([self isMovingFromParentViewController]) {
        self.parentVC.filterTVC.lockSelection = NO;
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
