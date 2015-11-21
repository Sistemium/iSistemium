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


@interface STMPickingOrdersTVC () <UIActionSheetDelegate>

@property (nonatomic, strong) NSString *pickingOrderWorkflow;
@property (nonatomic, strong) STMPickingOrder *workflowSelectedOrder;
@property (nonatomic, strong) NSString *nextProcessing;


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
    
    cell.accessoryType = UITableViewCellAccessoryNone;

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
    [self showPositionsForPickingOrder:pickingOrder];

}

- (void)infoLabelTapped:(id)sender {
    
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
        
        CGPoint currentTouchPosition = [tap locationInView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
        
        STMPickingOrder *pickingOrder = [self.resultsController objectAtIndexPath:indexPath];
        
        self.workflowSelectedOrder = pickingOrder;
        
        STMWorkflowAS *workflowActionSheet = [STMWorkflowController workflowActionSheetForProcessing:pickingOrder.processing
                                                                                          inWorkflow:self.pickingOrderWorkflow
                                                                                        withDelegate:self];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [workflowActionSheet showInView:self.view];
        }];
        
    }
    
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if ([actionSheet isKindOfClass:[STMWorkflowAS class]] && buttonIndex != actionSheet.cancelButtonIndex) {
        
        STMWorkflowAS *workflowAS = (STMWorkflowAS *)actionSheet;
        
        NSDictionary *result = [STMWorkflowController workflowActionSheetForProcessing:workflowAS.processing
                                                              didSelectButtonWithIndex:buttonIndex
                                                                            inWorkflow:workflowAS.workflow];
        
        self.nextProcessing = result[@"nextProcessing"];
        
        if (self.nextProcessing) {
            
            if ([result[@"editableProperties"] isKindOfClass:[NSArray class]]) {
                
                STMWorkflowEditablesVC *editablesVC = [[STMWorkflowEditablesVC alloc] init];
                
                editablesVC.workflow = workflowAS.workflow;
                editablesVC.toProcessing = self.nextProcessing;
                editablesVC.editableFields = result[@"editableProperties"];
                editablesVC.parent = self;
                
                [self presentViewController:editablesVC animated:YES completion:^{
                    
                }];
                
            } else {
                
                [self updateWorkflowSelectedOrder];
                
            }
            
        }
        
    }
    
}

- (void)takeEditableValues:(NSDictionary *)editableValues {

    for (NSString *field in editableValues.allKeys) {
        
        if ([self.workflowSelectedOrder.entity.propertiesByName.allKeys containsObject:field]) {
            [self.workflowSelectedOrder setValue:editableValues[field] forKey:field];
        }
        
    }
    
    [self updateWorkflowSelectedOrder];
    
}

- (void)updateWorkflowSelectedOrder {
    
    if (self.nextProcessing) {
     
        self.workflowSelectedOrder.processing = self.nextProcessing;
    
        if ([STMWorkflowController isEditableProcessing:self.nextProcessing inWorkflow:self.pickingOrderWorkflow]) {
            [self showPositionsForPickingOrder:self.workflowSelectedOrder];
        }

    }
    
    [self.document saveDocument:^(BOOL success) {
    }];
    
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
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom1TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];

    self.navigationItem.title = NSLocalizedString(@"PICKING ORDERS", nil);
    
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
