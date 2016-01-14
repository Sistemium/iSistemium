//
//  STMSupplyOrderArticleDocsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 11/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOrderArticleDocsTVC.h"

#import "STMSupplyOrdersNC.h"
#import "STMSupplyOrdersSVC.h"

#import "STMWorkflowEditablesVC.h"
#import "STMSupplyOrderOperationsTVC.h"


@interface STMSupplyOrderArticleDocsTVC () <UIActionSheetDelegate, STMWorkflowable>

@property (nonatomic, weak) STMSupplyOrdersSVC *splitVC;
@property (nonatomic, weak) STMSupplyOrdersNC *rootNC;
@property (nonatomic, strong) STMSupplyOrderOperationsTVC *operationsTVC;

@property (nonatomic, strong) NSString *supplyOrderWorkflow;

@property (nonatomic, strong) NSString *nextProcessing;

@property (nonatomic) BOOL isMasterNC;
@property (nonatomic) BOOL isDetailNC;


@end


@implementation STMSupplyOrderArticleDocsTVC

@synthesize resultsController =_resultsController;
@synthesize supplyOrder = _supplyOrder;


- (STMSupplyOrdersSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMSupplyOrdersSVC class]]) {
            _splitVC = (STMSupplyOrdersSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (STMSupplyOrdersNC *)rootNC {
    
    if (!_rootNC) {
        
        if ([self.navigationController isKindOfClass:[STMSupplyOrdersNC class]]) {
            _rootNC = (STMSupplyOrdersNC *)self.navigationController;
        }
    }
    return _rootNC;
    
}

- (NSString *)supplyOrderWorkflow {
    
    if (!_supplyOrderWorkflow) {
        
        if (IPAD) return self.splitVC.supplyOrderWorkflow;
        if (IPHONE) return self.rootNC.supplyOrderWorkflow;
        
    }
    return _supplyOrderWorkflow;

}

- (BOOL)orderIsProcessed {
    return [STMWorkflowController isEditableProcessing:self.supplyOrder.processing inWorkflow:self.supplyOrderWorkflow];
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
                                                                   sectionNameKeyPath:@"supplyOrder.title"
                                                                            cacheName:nil];
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (STMSupplyOrder *)supplyOrder {
    
    if (!_supplyOrder) {
        _supplyOrder = self.splitVC.selectedSupplyOrder;
    }
    return _supplyOrder;
}

- (void)setSupplyOrder:(STMSupplyOrder *)supplyOrder {
    
    _supplyOrder = supplyOrder;
    
    [self updateToolbars];
    [self performFetch];
    
}

- (void)updateToolbars {
    
    [[self.navigationController.toolbar viewWithTag:1] removeFromSuperview];

    [self addProcessingButton];
    
}

#pragma mark - processing button

- (void)addProcessingButton {
    
    NSString *processing = self.supplyOrder.processing;
    NSString *workflow = self.supplyOrderWorkflow;
    
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
                                                                                      inWorkflow:self.supplyOrderWorkflow
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

        if (self.isMasterNC) {
            [self.splitVC orderProcessingChanged];
        }

    }
    
}

- (void)orderProcessingChanged {
    
    [self updateToolbars];
    [self.operationsTVC orderProcessingChanged];
    
    [self.document saveDocument:^(BOOL success) {
    }];
    
}


#pragma mark - table view data

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom9TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];

    [self fillArticleDocCell:(STMCustom9TVCell *)cell atIndexPath:indexPath];
    
    return cell;
    
}

- (void)fillArticleDocCell:(STMCustom9TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMSupplyOrderArticleDoc *articleDoc = [self.resultsController objectAtIndexPath:indexPath];

    [self fillTextLabelForCell:cell withSupplyOrderArticleDoc:articleDoc];
    
    if (articleDoc.articleDoc.dateImport) {
        
        NSString *dateImport = [[STMFunctions dateShortNoTimeFormatter] stringFromDate:(NSDate * _Nonnull)articleDoc.articleDoc.dateImport];
        dateImport = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"DATE IMPORT", nil), dateImport];
        
        cell.detailLabel.text = dateImport;
        
    } else if (articleDoc.articleDoc.dateProduction) {
        
        
        NSString *dateProduction = [[STMFunctions dateShortNoTimeFormatter] stringFromDate:(NSDate * _Nonnull)articleDoc.articleDoc.dateProduction];
        dateProduction = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"DATE PRODUCTION", nil), dateProduction];

        cell.detailLabel.text = dateProduction;
        
    } else {

        cell.detailLabel.text = @"";

    }
    
    STMLabel *volumeLabel = [[STMLabel alloc] initWithFrame:CGRectMake(0, 0, 46, 21)];
    volumeLabel.text = [articleDoc volumeText];
    volumeLabel.textAlignment = NSTextAlignmentRight;
    volumeLabel.adjustsFontSizeToFitWidth = YES;
    
    cell.accessoryView = volumeLabel;
    
    if ([articleDoc isEqual:self.splitVC.selectedSupplyOrderArticleDoc]) {
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
//    UIImage *ordImage = [UIImage imageWithData:[NSData data]];
//    
//    ordImage = [STMFunctions drawText:articleDoc.ord.stringValue withFont:nil color:nil inImage:nil atCenter:YES];
//    
//    cell.imageView.image = ordImage;

    cell.infoLabel.text = articleDoc.ord.stringValue;
    
}

- (void)fillTextLabelForCell:(STMCustom9TVCell *)cell withSupplyOrderArticleDoc:(STMSupplyOrderArticleDoc *)supplyOrderArticleDoc {
    
//    cell.textLabel.numberOfLines = 0;
    cell.titleLabel.textColor = (supplyOrderArticleDoc.article) ? [UIColor blackColor] : [UIColor redColor];
    
    if (supplyOrderArticleDoc.article && ![supplyOrderArticleDoc.article isEqual:supplyOrderArticleDoc.articleDoc.article]) {
        
        UIFont *font = cell.textLabel.font;
        
        NSDictionary *attributes = @{NSForegroundColorAttributeName     : [UIColor blackColor],
                                     NSFontAttributeName                : font};

        NSString *articleName = (supplyOrderArticleDoc.article.name) ? supplyOrderArticleDoc.article.name : NSLocalizedString(@"UNKNOWN ARTICLE", nil);
        
        NSMutableAttributedString *labelTitle = [[NSMutableAttributedString alloc] initWithString:articleName attributes:attributes];
        
        [labelTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attributes]];

        font = [UIFont systemFontOfSize:font.pointSize - 4];
        
        attributes = @{NSForegroundColorAttributeName     : [UIColor grayColor],
                       NSStrikethroughStyleAttributeName  : @(NSUnderlinePatternSolid | NSUnderlineStyleSingle),
                       NSFontAttributeName                : font};

        NSString *articleDocName = (supplyOrderArticleDoc.articleDoc.article.name) ? supplyOrderArticleDoc.articleDoc.article.name : NSLocalizedString(@"UNKNOWN ARTICLE", nil);

        [labelTitle appendAttributedString:[[NSAttributedString alloc] initWithString:articleDocName attributes:attributes]];
        
        cell.titleLabel.attributedText = labelTitle;

    } else {

        cell.titleLabel.text = (supplyOrderArticleDoc.article.name) ? supplyOrderArticleDoc.article.name : supplyOrderArticleDoc.articleDoc.article.name;

    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMSupplyOrderArticleDoc *articleDoc = [self.resultsController objectAtIndexPath:indexPath];

    self.splitVC.selectedSupplyOrderArticleDoc = articleDoc;
    
    if (self.isDetailNC || IPHONE) {
        [self performSegueWithIdentifier:@"showOperations" sender:articleDoc];
    }
    
}

- (void)selectSupplyOrderArticleDoc:(STMSupplyOrderArticleDoc *)articleDoc {
    
    NSIndexPath *indexPath = [self.resultsController indexPathForObject:articleDoc];
    
    if (indexPath) {
        
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        
        self.operationsTVC.supplyOrderArticleDoc = articleDoc;
        
    }
    
}


#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    [super controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
    
    if ([anObject isEqual:self.operationsTVC.supplyOrderArticleDoc]) {
        [self.operationsTVC.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showOperations"] &&
        [segue.destinationViewController isKindOfClass:[STMSupplyOrderOperationsTVC class]] &&
        [sender isKindOfClass:[STMSupplyOrderArticleDoc class]]) {
        
        STMSupplyOrderArticleDoc *articleDoc = (STMSupplyOrderArticleDoc *)sender;
        self.operationsTVC = (STMSupplyOrderOperationsTVC *)segue.destinationViewController;
        
        self.operationsTVC.supplyOrderArticleDoc = articleDoc;
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    self.isMasterNC = [self.splitVC isMasterNCForViewController:self];
    self.isDetailNC = [self.splitVC isDetailNCForViewController:self];
    
//    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([STMCustom9TVCell class]) bundle:nil] forCellReuseIdentifier:self.cellIdentifier];

    [self updateToolbars];
    [self performFetch];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.isDetailNC && ![self isMovingToParentViewController]) {
        self.operationsTVC = nil;
    }
    
    if (IPHONE) [self updateToolbars];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (self.isMasterNC && [self isMovingFromParentViewController]) {
        
        [self.splitVC masterBackButtonPressed];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
