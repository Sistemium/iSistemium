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

#import "STMSoundController.h"
#import "STMBarCodeScanner.h"


@interface STMSupplyOrderArticleDocsTVC () <UIActionSheetDelegate, STMWorkflowable, STMBarCodeScannerDelegate>

@property (nonatomic, weak) STMSupplyOrdersSVC *splitVC;
@property (nonatomic, weak) STMSupplyOrdersNC *rootNC;
@property (nonatomic, strong) STMSupplyOrderOperationsTVC *operationsTVC;

@property (nonatomic, strong) NSString *supplyOrderWorkflow;

@property (nonatomic, strong) NSString *nextProcessing;

@property (nonatomic) BOOL isMasterNC;
@property (nonatomic) BOOL isDetailNC;

@property (nonatomic, strong) STMBarCodeScanner *iOSModeBarCodeScanner;

@property (nonatomic, strong) NSString *scannedBarcode;


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
        
        request.predicate = [self predicate];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:@"supplyOrder.title"
                                                                            cacheName:nil];
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}

- (NSPredicate *)predicate {
    
    NSMutableArray *subpredicates = @[].mutableCopy;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"supplyOrder == %@", self.supplyOrder];
    [subpredicates addObject:predicate];

    if (self.scannedBarcode) {
    
        predicate = [NSPredicate predicateWithFormat:@"ANY articleDoc.article.barCodes.code == %@", self.scannedBarcode];
        [subpredicates addObject:predicate];
        
    }
    
    predicate = [super textSearchPredicateForField:@"articleDoc.article.name"];
    if (predicate) [subpredicates addObject:predicate];
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    
}

- (void)successfulFetchCallback {
    
    NSUInteger articlesCount = self.resultsController.fetchedObjects.count;
    
    switch (articlesCount) {
        case 0:
            if (self.scannedBarcode) {
                
                [STMSoundController alertSay:NSLocalizedString(@"NO ARTICLES FOR THIS BARCODE", nil)];
                self.scannedBarcode = nil;
                
            }
            break;
            
        case 1:
            if (self.scannedBarcode) {
                
                [self.tableView reloadData];
                
                STMSupplyOrderArticleDoc *articleDoc = self.resultsController.fetchedObjects.firstObject;
                [self didSelectArticleDoc:articleDoc];
                
            }
            break;
            
        default:
            [self.tableView reloadData];
            break;
    }
    
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

- (void)setScannedBarcode:(NSString *)scannedBarcode {
    
    if (![_scannedBarcode isEqualToString:scannedBarcode]) {
        
        _scannedBarcode = scannedBarcode;
        
        [self performFetch];
        [self updateBarcodeToolbar];
        
    }
    
}

- (void)updateToolbars {
    
    [[self.navigationController.toolbar viewWithTag:1] removeFromSuperview];

    [self addProcessingButton];
    
}

- (void)updateBarcodeToolbar {
    
    if (self.scannedBarcode) {
        
        STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
        
        STMBarButtonItemLabel *barcodeLabel = [[STMBarButtonItemLabel alloc] initWithTitle:self.scannedBarcode
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:nil
                                                                                    action:nil];
        
        STMBarButtonItem *clearFilterButton = [[STMBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Clear Filters-25"]
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(clearFilter)];
        
        [self setToolbarItems:@[flexibleSpace, barcodeLabel, flexibleSpace, clearFilterButton]];
        
    } else {
        
        [self setToolbarItems:nil];
        
    }
    
}

- (void)clearFilter {
    self.scannedBarcode = nil;
}


#pragma mark - search button

- (void)showSearchButton {

}

- (void)hideSearchButton {

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
    
    UIColor *textColor = ([articleDoc volumeRemainingToSupply] > 0) ? [UIColor blackColor] : [UIColor lightGrayColor];
    cell.titleLabel.textColor = textColor;

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
    
    cell.detailLabel.textColor = textColor;
    
    STMLabel *volumeLabel = [[STMLabel alloc] initWithFrame:CGRectMake(0, 0, 46, 21)];
    volumeLabel.text = [articleDoc volumeText];
    volumeLabel.textAlignment = NSTextAlignmentRight;
    volumeLabel.adjustsFontSizeToFitWidth = YES;
    volumeLabel.textColor = textColor;
    
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
    cell.infoLabel.textColor = textColor;
    
}

- (void)fillTextLabelForCell:(STMCustom9TVCell *)cell withSupplyOrderArticleDoc:(STMSupplyOrderArticleDoc *)supplyOrderArticleDoc {
    
//    cell.titleLabel.textColor = (supplyOrderArticleDoc.article) ? [UIColor blackColor] : [UIColor redColor];
    
    UIFont *font = cell.textLabel.font;
    
    NSDictionary *attributes = @{NSForegroundColorAttributeName     : [UIColor blackColor],
                                 NSFontAttributeName                : font};

    if (supplyOrderArticleDoc.article && ![supplyOrderArticleDoc.article isEqual:supplyOrderArticleDoc.articleDoc.article]) {
        
        NSString *articleName = (supplyOrderArticleDoc.article.name) ? supplyOrderArticleDoc.article.name : NSLocalizedString(@"UNKNOWN ARTICLE", nil);
        
        NSMutableAttributedString *labelTitle = [[NSMutableAttributedString alloc] initWithString:articleName attributes:attributes];
        [labelTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attributes]];

        [labelTitle appendAttributedString:[supplyOrderArticleDoc operatingPackageRelStringWithFontSize:font.pointSize]];
        [labelTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attributes]];
        
        font = [UIFont systemFontOfSize:font.pointSize - 4];
        
        attributes = @{NSForegroundColorAttributeName     : [UIColor grayColor],
                       NSStrikethroughStyleAttributeName  : @(NSUnderlinePatternSolid | NSUnderlineStyleSingle),
                       NSFontAttributeName                : font};

        NSString *articleDocName = (supplyOrderArticleDoc.articleDoc.article.name) ? supplyOrderArticleDoc.articleDoc.article.name : NSLocalizedString(@"UNKNOWN ARTICLE", nil);

        [labelTitle appendAttributedString:[[NSAttributedString alloc] initWithString:articleDocName attributes:attributes]];
        
        cell.titleLabel.attributedText = labelTitle;

    } else {
        
        NSString *titleText = [supplyOrderArticleDoc operatingArticle].name;
        
        NSMutableAttributedString *labelTitle = [[NSMutableAttributedString alloc] initWithString:titleText attributes:attributes];
        [labelTitle appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attributes]];

        [labelTitle appendAttributedString:[supplyOrderArticleDoc operatingPackageRelStringWithFontSize:font.pointSize]];

        cell.titleLabel.attributedText = labelTitle;

    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMSupplyOrderArticleDoc *articleDoc = [self.resultsController objectAtIndexPath:indexPath];
    [self didSelectArticleDoc:articleDoc];
    
}

- (void)didSelectArticleDoc:(STMSupplyOrderArticleDoc *)articleDoc {
    
    self.splitVC.selectedSupplyOrderArticleDoc = articleDoc;
    
    if (self.isDetailNC || IPHONE) {
        [self performSegueWithIdentifier:@"showOperations" sender:articleDoc];
    }

}

- (void)highlightSupplyOrderArticleDoc:(STMSupplyOrderArticleDoc *)articleDoc {
    
    NSIndexPath *indexPath = [self.resultsController indexPathForObject:articleDoc];
    
    if (indexPath) {
        
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        
        self.operationsTVC.supplyOrderArticleDoc = articleDoc;
        
    }
    
}


#pragma mark - barcode scanning

- (void)checkIfBarcodeScanerIsNeeded {
    ([self orderIsProcessed]) ? [self startBarcodeScanning] : [self stopBarcodeScanning];
}

- (void)startBarcodeScanning {
    [self startIOSModeScanner];
}

- (void)startIOSModeScanner {
    
    self.iOSModeBarCodeScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerIOSMode];
    self.iOSModeBarCodeScanner.delegate = self;
    [self.iOSModeBarCodeScanner startScan];
    
    if ([self.iOSModeBarCodeScanner isDeviceConnected]) {
        [self addBarcodeImage];
    }
    
}

- (void)stopBarcodeScanning {
    
    [self stopIOSModeScanner];
    [self removeBarcodeImage];
    
}

- (void)stopIOSModeScanner {
    
    [self.iOSModeBarCodeScanner stopScan];
    self.iOSModeBarCodeScanner = nil;
    
}

- (void)receiveArticleBarcode:(NSString *)barcode {
    self.scannedBarcode = barcode;
}


#pragma mark - barcode image

- (void)addBarcodeImage {
    
    UIImage *image = [STMFunctions resizeImage:[UIImage imageNamed:@"barcode.png"] toSize:CGSizeMake(25, 25)];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
}

- (void)removeBarcodeImage {
    self.navigationItem.titleView = nil;
}


#pragma mark - STMBarCodeScannerDelegate

- (UIView *)viewForScanner:(STMBarCodeScanner *)scanner {
    return self.view;
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCodeScan:(STMBarCodeScan *)barCodeScan withType:(STMBarCodeScannedType)type {
    
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCode:(NSString *)barcode withType:(STMBarCodeScannedType)type {
    
    if (self.isInActiveTab) {
        
        NSLog(@"barCodeScanner receiveBarCode: %@ withType:%lu", barcode, (unsigned long)type);
        
        switch (type) {
            case STMBarCodeTypeUnknown: {
                
                break;
            }
            case STMBarCodeTypeArticle: {
                [self receiveArticleBarcode:barcode];
                break;
            }
            case STMBarCodeTypeExciseStamp: {
                
                break;
            }
            case STMBarCodeTypeStockBatch: {

                break;
            }
        }
        
    }
    
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveError:(NSError *)error {
    NSLog(@"barCodeScanner receiveError: %@", error.localizedDescription);
}

- (void)deviceArrivalForBarCodeScanner:(STMBarCodeScanner *)scanner {
    
    if (scanner == self.iOSModeBarCodeScanner) {
        
        [STMSoundController say:NSLocalizedString(@"SCANNER DEVICE ARRIVAL", nil)];
        [self addBarcodeImage];
        
    }
    
}

- (void)deviceRemovalForBarCodeScanner:(STMBarCodeScanner *)scanner {
    
    if (scanner == self.iOSModeBarCodeScanner) {
        
        [STMSoundController say:NSLocalizedString(@"SCANNER DEVICE REMOVAL", nil)];
        [self removeBarcodeImage];
        
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
    
    if (![self isMovingToParentViewController]) {
        
        BOOL orderIsProcessed = [self orderIsProcessed];
        NSNumber *remainingVolumes = [self.supplyOrder.supplyOrderArticleDocs valueForKeyPath:@"@sum.volumeRemainingToSupply"];
        
        if (orderIsProcessed && remainingVolumes.integerValue == 0) {
            
            [STMSoundController okSay:NSLocalizedString(@"ALL POSITIONS ARE SUPPLIED", nil)];
            [self processingButtonPressed];
            
        }

        if (self.isDetailNC) {
            self.operationsTVC = nil;
        }
        
        self.iOSModeBarCodeScanner.delegate = self;

    }
    
    if (IPHONE) [self updateToolbars];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if ([self isMovingToParentViewController]) {
        [self checkIfBarcodeScanerIsNeeded];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {

        [self stopBarcodeScanning];

        if (self.isMasterNC) {
            [self.splitVC masterBackButtonPressed];
        }

    } else {
        
        self.iOSModeBarCodeScanner.delegate = nil;
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
