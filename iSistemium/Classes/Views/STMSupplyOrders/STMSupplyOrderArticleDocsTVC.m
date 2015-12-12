//
//  STMSupplyOrderArticleDocsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOrderArticleDocsTVC.h"

#import "STMSupplyOrdersSVC.h"

#import "STMWorkflowEditablesVC.h"


@interface STMSupplyOrderArticleDocsTVC () <UIActionSheetDelegate, STMWorkflowable>

@property (nonatomic, weak) STMSupplyOrdersSVC *splitVC;
@property (nonatomic, strong) NSString *nextProcessing;


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

- (BOOL)orderIsProcessed {
    return [STMWorkflowController isEditableProcessing:self.supplyOrder.processing inWorkflow:self.splitVC.supplyOrderWorkflow];
}


- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
    
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMSupplyOrderArticleDoc class])];
        
        NSSortDescriptor *ordDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord" ascending:YES selector:@selector(compare:)];
        NSSortDescriptor *articleNameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        
        request.sortDescriptors = @[ordDescriptor, articleNameDescriptor];
        
        request.predicate = [NSPredicate predicateWithFormat:@"supplyOrder == %@", self.supplyOrder];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:@"supplyOrder.ndoc"
                                                                            cacheName:nil];
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (void)setSupplyOrder:(STMSupplyOrder *)supplyOrder {
    
    _supplyOrder = supplyOrder;
    
    [self updateToolbars];
    [self performFetch];
    
}

- (void)updateToolbars {
    [self addProcessingButton];
}

#pragma mark - processing button

- (void)addProcessingButton {
    
    NSString *processing = self.supplyOrder.processing;
    NSString *workflow = self.splitVC.supplyOrderWorkflow;
    
    NSString *title = [STMWorkflowController labelForProcessing:processing inWorkflow:workflow];
    
    STMBarButtonItem *processingButton = [[STMBarButtonItem alloc] initWithTitle:title
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(processingButtonPressed)];
    
    processingButton.tintColor = [STMWorkflowController colorForProcessing:processing inWorkflow:workflow];
    
    self.navigationItem.rightBarButtonItem = processingButton;
    
}

- (void)processingButtonPressed {
    
    STMWorkflowAS *workflowActionSheet = [STMWorkflowController workflowActionSheetForProcessing:self.supplyOrder.processing
                                                                                      inWorkflow:self.splitVC.supplyOrderWorkflow
                                                                                    withDelegate:self];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [workflowActionSheet showInView:self.view];
    }];
    
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
        
        if ([self.supplyOrder.entity.propertiesByName.allKeys containsObject:field]) {
            [self.supplyOrder setValue:editableValues[field] forKey:field];
        }
        
    }
    
    [self updateWorkflowSelectedOrder];
    
}

- (void)updateWorkflowSelectedOrder {
    
    if (self.nextProcessing) {
        
        self.supplyOrder.processing = self.nextProcessing;
        [self orderProcessingChanged];
        
    }
    
}

- (void)orderProcessingChanged {
    
//    [self checkIfBarcodeScanerIsNeeded];
    [self updateToolbars];
//    [self.tableView reloadData];
    
    [self.document saveDocument:^(BOOL success) {
    }];
    
}


#pragma mark - view lifecycle

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewSubtitleStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];

    [self fillArticleDocCell:(STMTableViewSubtitleStyleCell *)cell atIndexPath:indexPath];

    return cell;
    
}

- (void)fillArticleDocCell:(STMTableViewSubtitleStyleCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMSupplyOrderArticleDoc *articleDoc = [self.resultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textColor = (articleDoc.article) ? [UIColor blackColor] : [UIColor redColor];
    cell.textLabel.text = (articleDoc.article.name) ? articleDoc.article.name : articleDoc.articleDoc.article.name;

    NSMutableArray *dates = @[].mutableCopy;

    if (articleDoc.articleDoc.dateProduction) {
        
        NSString *dateProduction = [[STMFunctions dateShortNoTimeFormatter] stringFromDate:(NSDate * _Nonnull)articleDoc.articleDoc.dateProduction];
        dateProduction = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"DATE PRODUCTION", nil), dateProduction];
        
        [dates addObject:dateProduction];
        
    }
    
    if (articleDoc.articleDoc.dateImport) {
        
        NSString *dateImport = [[STMFunctions dateShortNoTimeFormatter] stringFromDate:(NSDate * _Nonnull)articleDoc.articleDoc.dateImport];
        dateImport = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"DATE IMPORT", nil), dateImport];
        [dates addObject:dateImport];
        
    }
    
    cell.detailTextLabel.text  = [dates componentsJoinedByString:@" / "];
    
    STMLabel *volumeLabel = [[STMLabel alloc] initWithFrame:CGRectMake(0, 0, 46, 21)];
    volumeLabel.text = [articleDoc volumeText];
    volumeLabel.textAlignment = NSTextAlignmentRight;
    volumeLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.accessoryView = volumeLabel;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    STMSupplyOrderArticleDoc *articleDoc = [self.resultsController objectAtIndexPath:indexPath];
//
//    NSLog(@"");
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    
    [self updateToolbars];
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
