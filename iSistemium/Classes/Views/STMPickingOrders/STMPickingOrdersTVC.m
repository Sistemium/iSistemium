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


@interface STMPickingOrdersTVC () <UIActionSheetDelegate>

@property (nonatomic, strong) NSString *pickingOrderWorkflow;


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
        NSSortDescriptor *ndocDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ndoc" ascending:NO selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[dateDescriptor, ndocDescriptor];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:@"date"
                                                                            cacheName:nil];
        
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
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
    
    static STMCustom1TVCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    });
    
    return cell;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom1TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom1TVCell class]]) {
        [self fillPickingOrderCell:(STMCustom1TVCell *)cell atIndexPath:indexPath];
    }
    
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillPickingOrderCell:(STMCustom1TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMPickingOrder *pickingOrder = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = pickingOrder.ndoc;
    cell.detailLabel.text = [pickingOrder positionsCountString];
    
    [self setupMessageLabelForCell:cell andPickingOrder:pickingOrder];
    [self setupInfoLabelForCell:cell andPickingOrder:pickingOrder];
    
//    if (pickingOrder.pickingOrderPositions.count > 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    } else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }

}

- (void)setupMessageLabelForCell:(STMCustom1TVCell *)cell andPickingOrder:(STMPickingOrder *)pickingOrder {
    
    if (pickingOrder.pickingOrderPositions.count > 0) {
        
        NSString *boxes = [pickingOrder approximateBoxCountString];
        NSString *bottles = [pickingOrder bottleCountString];
        
        cell.messageLabel.text = [NSString stringWithFormat:@"%@, %@", boxes, bottles];

    } else {
        
        cell.messageLabel.text = nil;
        
    }

}

- (void)setupInfoLabelForCell:(STMCustom1TVCell *)cell andPickingOrder:(STMPickingOrder *)pickingOrder {
    
    NSString *processing = pickingOrder.processing;
    NSString *workflow = self.pickingOrderWorkflow;
    
    NSString *processingLabel = [STMWorkflowController labelForProcessing:processing inWorkflow:workflow];
    
    cell.infoLabel.text = (processingLabel) ? processingLabel : processing;
    
    for (UIGestureRecognizer *gestures in cell.infoLabel.gestureRecognizers) {
        [cell.infoLabel removeGestureRecognizer:gestures];
    }
    
    cell.infoLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoLabelTapped:)];
    [cell.infoLabel addGestureRecognizer:tap];
    
    UIColor *processingColor = [STMWorkflowController colorForProcessing:processing inWorkflow:workflow];
    
    cell.infoLabel.textColor = (processingColor) ? processingColor : [UIColor blackColor];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMPickingOrder *pickingOrder = [self.resultsController objectAtIndexPath:indexPath];

    STMPickingOrderPositionsTVC *positionsTVC = [[STMPickingOrderPositionsTVC alloc] initWithStyle:UITableViewStyleGrouped];
    positionsTVC.pickingOrder = pickingOrder;
    
    [self.navigationController pushViewController:positionsTVC animated:YES];
    
    
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

- (void)infoLabelTapped:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
        
        CGPoint currentTouchPosition = [tap locationInView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
        
        STMPickingOrder *pickingOrder = [self.resultsController objectAtIndexPath:indexPath];
        
        STMWorkflowAS *workflowActionSheet = [STMWorkflowController workflowActionSheetForProcessing:pickingOrder.processing
                                                                                          inWorkflow:self.pickingOrderWorkflow
                                                                                        withDelegate:self];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [workflowActionSheet showInView:self.view];
        }];
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom1TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];

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
