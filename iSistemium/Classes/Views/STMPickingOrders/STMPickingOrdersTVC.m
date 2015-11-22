//
//  STMPickingOrdersTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingOrdersTVC.h"

#import "STMPickingOrderPositionsTVC.h"
#import "STMWorkflowController.h"
#import "STMWorkflowEditablesVC.h"


@interface STMPickingOrdersTVC ()

@property (nonatomic, strong) NSString *pickingOrderWorkflow;
@property (nonatomic, strong) STMPickingOrder *workflowSelectedOrder;

@property (nonatomic, strong) NSString *selectedProcessing;


@end


@implementation STMPickingOrdersTVC

@synthesize resultsController = _resultsController;

- (NSString *)pickingOrderWorkflow {
    
    if (!_pickingOrderWorkflow) {
        _pickingOrderWorkflow = [STMWorkflowController workflowForEntityName:NSStringFromClass([STMPickingOrder class])];
    }
    return _pickingOrderWorkflow;
    
}

- (NSString *)cellIdentifier {
    return @"pickingOrderCell";
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPickingOrder class])];
        
        NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
        NSSortDescriptor *ndocDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ndoc" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[dateDescriptor, ndocDescriptor];
        
        request.predicate = [self currentPredicate];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:@"date"
                                                                            cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (NSPredicate *)currentPredicate {
    
    NSMutableArray *subpredicates = @[].mutableCopy;
    
    NSPredicate *positionsCountPredicate = [NSPredicate predicateWithFormat:@"pickingOrderPositions.@count > 0"];
    [subpredicates addObject:positionsCountPredicate];

    if (self.selectedProcessing) {
        
        NSPredicate *processingPredicate = [NSPredicate predicateWithFormat:@"processing == %@", self.selectedProcessing];
        [subpredicates addObject:processingPredicate];
        
    }
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    
}

- (NSArray <NSString *>*)actions {
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMPickingOrder class])];
    
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO selector:@selector(compare:)];
    NSSortDescriptor *ndocDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ndoc" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    request.sortDescriptors = @[dateDescriptor, ndocDescriptor];

    request.predicate = [NSPredicate predicateWithFormat:@"pickingOrderPositions.@count > 0"];
    
    NSArray *pickingOrders = [self.document.managedObjectContext executeFetchRequest:request error:nil];
    
    NSArray *processings = [pickingOrders valueForKeyPath:@"@distinctUnionOfObjects.processing"];
    
    if (processings.count > 0) {
        
        NSMutableArray *actions = @[NSLocalizedString(@"SHOW ALL DATA", nil)].mutableCopy;
        
        for (NSString *processing in processings) {
            [actions addObject:[STMWorkflowController labelForProcessing:processing inWorkflow:self.pickingOrderWorkflow]];
        }
        
        return actions;

    } else {
        
        return nil;
        
    }
    
}

- (void)selectAction:(NSString *)action {
    self.selectedProcessing = [STMWorkflowController processingForLabel:action inWorkflow:self.pickingOrderWorkflow];
}

- (void)setSelectedProcessing:(NSString *)selectedProcessing {
    
    if (![_selectedProcessing isEqualToString:selectedProcessing]) {
        
        _selectedProcessing = selectedProcessing;
        
        [self updateTitle];
        [self performFetch];
        
    }
    
}

- (void)updateTitle {
    
    if (self.selectedProcessing) {
        
        NSString *label = [STMWorkflowController labelForProcessing:self.selectedProcessing inWorkflow:self.pickingOrderWorkflow];
        self.navigationItem.title = label;
        
    } else {
        
        self.navigationItem.title = NSLocalizedString(@"PICKING ORDERS", nil);

    }
    
}


#pragma mark - table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (self.resultsController.sections.count > 0) {
        
        id <NSFetchedResultsSectionInfo> sectionInfo = self.resultsController.sections[section];
        
        STMSaleOrder *saleOrder = [[sectionInfo objects] lastObject];
        
        NSString *dateString = [STMFunctions dayWithDayOfWeekFromDate:saleOrder.date];
        
        return dateString;
        
    } else {
        
        return nil;
        
    }
    
}

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
    
    [self fillCell:cell atIndexPath:indexPath];

    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMPickingOrder *pickingOrder = [self.resultsController objectAtIndexPath:indexPath];
    UIColor *processingColor = [STMWorkflowController colorForProcessing:pickingOrder.processing inWorkflow:self.pickingOrderWorkflow];

    [[cell.contentView viewWithTag:1] removeFromSuperview];

    CGFloat fillWidth = 5;

    CGRect rect = CGRectMake(1, 1, fillWidth, cell.frame.size.height-2);
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.tag = 1;
    view.backgroundColor = (processingColor) ? processingColor : [UIColor blackColor];

    [cell.contentView addSubview:view];
    [cell.contentView sendSubviewToBack:view];

}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        [self fillPickingOrderCell:(UITableViewCell *)cell atIndexPath:indexPath];
    }
    
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillPickingOrderCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMPickingOrder *pickingOrder = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ / %@", pickingOrder.ndoc, [pickingOrder positionsCountString]];

    if (pickingOrder.pickingOrderPositions.count > 0) {
        
        NSString *boxes = [pickingOrder approximateBoxCountString];
        NSString *bottles = [pickingOrder bottleCountString];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", boxes, bottles];
        
    } else {
        
        cell.detailTextLabel.text = nil;
        
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMPickingOrder *pickingOrder = [self.resultsController objectAtIndexPath:indexPath];
    [self showPositionsForPickingOrder:pickingOrder];

}


#pragma mark - Navigation

- (void)showPositionsForPickingOrder:(STMPickingOrder *)pickingOrder {
    [self performSegueWithIdentifier:@"showPositions" sender:pickingOrder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showPositions"]) {
        
        if ([segue.destinationViewController isKindOfClass:[STMPickingOrderPositionsTVC class]] &&
            [sender isKindOfClass:[STMPickingOrder class]]) {
            
            STMPickingOrderPositionsTVC *positionsTVC = (STMPickingOrderPositionsTVC *)segue.destinationViewController;
            positionsTVC.pickingOrder = (STMPickingOrder *)sender;
            
        }
        
    }

}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    [self.tableView registerClass:[STMTableViewCellStyleSubtitle class] forCellReuseIdentifier:self.cellIdentifier];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    [self updateTitle];
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
