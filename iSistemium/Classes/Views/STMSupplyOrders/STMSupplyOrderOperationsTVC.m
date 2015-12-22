//
//  STMSupplyOrderOperationsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOrderOperationsTVC.h"

#import "STMSupplyOrdersSVC.h"
#import "STMSupplyOperationVC.h"
#import "STMArticleSelectionTVC.h"

#import "STMBarCodeScanner.h"
#import "STMSoundController.h"
#import "STMSupplyOrdersProcessController.h"
#import "STMBarCodeController.h"
#import "STMObjectsController.h"


@interface STMSupplyOrderOperationsTVC () <STMBarCodeScannerDelegate>

@property (nonatomic, weak) STMSupplyOrdersSVC *splitVC;
@property (nonatomic, strong) STMSupplyOperationVC *operationVC;

@property (nonatomic, strong) STMBarCodeScanner *iOSModeBarCodeScanner;

@property (nonatomic) NSInteger remainingVolume;
@property (nonatomic, strong) NSMutableArray *stockBatchCodes;
@property (nonatomic, strong) NSString *articleBarCode;

@property (nonatomic, strong) UIPopoverController *articleSelectionPopover;


@end


@implementation STMSupplyOrderOperationsTVC

@synthesize resultsController = _resultsController;


- (STMSupplyOrdersSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMSupplyOrdersSVC class]]) {
            _splitVC = (STMSupplyOrdersSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (void)setSupplyOrderArticleDoc:(STMSupplyOrderArticleDoc *)supplyOrderArticleDoc {
    
    _supplyOrderArticleDoc = supplyOrderArticleDoc;
    
    self.repeatLastOperation = NO;
    
    [self setupToolbar];
    [self performFetch];

}

- (NSMutableArray *)stockBatchCodes {
    
    if (!_stockBatchCodes) {
        _stockBatchCodes = @[].mutableCopy;
    }
    return _stockBatchCodes;
    
}

- (BOOL)orderIsProcessed {
    return [STMWorkflowController isEditableProcessing:self.supplyOrderArticleDoc.supplyOrder.processing inWorkflow:self.splitVC.supplyOrderWorkflow];
}

- (void)orderProcessingChanged {
    [self checkIfBarcodeScanerIsNeeded];
}

- (void)confirmArticle:(STMArticle *)article {
    
    self.supplyOrderArticleDoc.article = article;
    self.supplyOrderArticleDoc.code = self.articleBarCode;
    
}

- (NSFetchedResultsController *)resultsController {
    
    if (!_resultsController) {
        
        STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMStockBatchOperation class])];
        
        NSSortDescriptor *deviceCtsDecriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:NO selector:@selector(compare:)];
        request.sortDescriptors = @[deviceCtsDecriptor];
        
        request.predicate = [NSPredicate predicateWithFormat:@"sourceAgent == %@", self.supplyOrderArticleDoc];
        
        _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                 managedObjectContext:self.document.managedObjectContext
                                                                   sectionNameKeyPath:nil
                                                                            cacheName:nil];
        _resultsController.delegate = self;
        
    }
    return _resultsController;
    
}


#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;

        case 1:
            if (self.resultsController.fetchedObjects.count > 0) {
                return [super tableView:tableView numberOfRowsInSection:section-1];
            } else {
                return 1;
            }
            break;

        default:
            return 0;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    switch (section) {
        case 0:
            return NSLocalizedString(@"ARTICLE", nil);
            break;

        case 1:
            return NSLocalizedString(@"OPERATIONS", nil);
            break;

        default:
            return nil;
            break;
    }
    
    //    return (self.supplyOrderArticleDoc.article) ? self.supplyOrderArticleDoc.article.name : self.supplyOrderArticleDoc.articleDoc.article.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    STMTableViewSubtitleStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:
            [self fillArticleCell:cell];
            break;

        case 1:
            [self fillOperationCell:cell atIndexPath:indexPath];
            break;

        default:
            break;
    }
    
    return cell;
    
}

- (void)fillArticleCell:(STMTableViewSubtitleStyleCell *)cell {
    
    STMArticle *article = [self.supplyOrderArticleDoc operatingArticle];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textColor = (self.supplyOrderArticleDoc.article) ? [UIColor blackColor] : [UIColor redColor];
    cell.textLabel.text = article.name;
    
    NSMutableArray *dates = @[].mutableCopy;
    
    if (self.supplyOrderArticleDoc.articleDoc.dateProduction) {
        
        NSString *dateProduction = [[STMFunctions dateShortNoTimeFormatter] stringFromDate:(NSDate * _Nonnull)self.supplyOrderArticleDoc.articleDoc.dateProduction];
        dateProduction = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"DATE PRODUCTION", nil), dateProduction];
        
        [dates addObject:dateProduction];
        
    }
    
    if (self.supplyOrderArticleDoc.articleDoc.dateImport) {
        
        NSString *dateImport = [[STMFunctions dateShortNoTimeFormatter] stringFromDate:(NSDate * _Nonnull)self.supplyOrderArticleDoc.articleDoc.dateImport];
        dateImport = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"DATE IMPORT", nil), dateImport];
        [dates addObject:dateImport];
        
    }
    
    cell.detailTextLabel.text  = [dates componentsJoinedByString:@" / "];
    
}

- (void)fillOperationCell:(STMTableViewSubtitleStyleCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
    
    if (self.resultsController.fetchedObjects.count > 0) {
        
        STMStockBatchOperation *operation = [self.resultsController objectAtIndexPath:indexPath];
        
        cell.textLabel.text = [[STMFunctions dateShortTimeShortFormatter] stringFromDate:operation.deviceCts];
        
        if ([operation.destinationAgent isKindOfClass:[STMStockBatch class]]) {
            
            NSMutableArray *codes = @[].mutableCopy;
            
            STMStockBatch *stockBatch = (STMStockBatch *)operation.destinationAgent;
            
            for (STMStockBatchBarCode *barcode in stockBatch.barCodes) {
                if (barcode.code) [codes addObject:(NSString * _Nonnull)barcode.code];
            }
            
            NSString *codesString = [codes componentsJoinedByString:@", "];
            
            cell.detailTextLabel.text = codesString;
            
        } else {
            
            cell.detailTextLabel.text = @"";
            
        }
        
        NSString *volumeString = [STMFunctions volumeStringWithVolume:operation.volume.integerValue
                                                        andPackageRel:[self.supplyOrderArticleDoc operatingArticle].packageRel.integerValue];
        
        STMLabel *volumeLabel = [[STMLabel alloc] initWithFrame:CGRectMake(0, 0, 46, 21)];
        volumeLabel.text = volumeString;
        volumeLabel.textAlignment = NSTextAlignmentRight;
        volumeLabel.adjustsFontSizeToFitWidth = YES;
        
        cell.accessoryView = volumeLabel;
        
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self orderIsProcessed]) {
     
        if (indexPath.section == 0) {
            
            if (!self.supplyOrderArticleDoc.article) {
                [self showArticleSelectionPopoverWithArticles:nil];
            }
            
        } else if (indexPath.section == 1) {
            
            [self performSegueWithIdentifier:@"showSupplyOperation" sender:indexPath];
            
        }
        
    }
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self orderIsProcessed] && self.resultsController.fetchedObjects.count > 0  && indexPath.section == 1) {
        
        return UITableViewCellEditingStyleDelete;
        
    } else {
        
        return UITableViewCellEditingStyleNone;
        
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        STMStockBatchOperation *operation = [self.resultsController objectAtIndexPath:indexPath];
        [STMSupplyOrdersProcessController removeOperation:operation];
        
    }
    
}


#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView reloadData];
    [self setupToolbar];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
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
    
}

- (void)stopBarcodeScanning {
    [self stopIOSModeScanner];
}

- (void)stopIOSModeScanner {
    
    [self.iOSModeBarCodeScanner stopScan];
    self.iOSModeBarCodeScanner = nil;
    
}

- (void)receiveArticleBarcode:(NSString *)barcode {
    
    if (self.supplyOrderArticleDoc.article) {
        
    } else {
    
        self.articleBarCode = barcode;
        
        NSArray *articles = [STMBarCodeController articlesForBarcode:barcode];
        
        if (articles.count == 1) {
            
            STMArticle *article = articles.firstObject;
            [self confirmArticle:article];
            
        } else {
            
            [self showArticleSelectionPopoverWithArticles:articles];
            
        }

    }
    
}

- (void)receiveStockBatchBarcode:(NSString *)barcode {
    
    if (!self.supplyOrderArticleDoc.article) {
        
        [STMSoundController alertSay:NSLocalizedString(@"CONFIRM ARTICLE FOR START", nil)];
        
    } else {
    
        if ([self.presentedViewController isEqual:self.operationVC]) {
            
            [self.operationVC addStockBatchCode:barcode];
            
        } else {
            
            if ([self.supplyOrderArticleDoc volumeRemainingToSupply] < [self.supplyOrderArticleDoc lastSourceOperationVolume]) {
                self.repeatLastOperation = NO;
            }
            
            if (self.repeatLastOperation) {
                
                [self.stockBatchCodes addObject:barcode];
                
                if (self.stockBatchCodes.count >= [self.supplyOrderArticleDoc lastSourceOperationNumberOfBarcodes]) {
                    
                    [STMSupplyOrdersProcessController createOperationForSupplyOrderArticleDoc:self.supplyOrderArticleDoc
                                                                                    withCodes:self.stockBatchCodes
                                                                                    andVolume:[self.supplyOrderArticleDoc lastSourceOperationVolume]];
                    self.stockBatchCodes = nil;
                    
                }
                
            } else {
                
                [self performSegueWithIdentifier:@"showSupplyOperation" sender:barcode];
                
            }
            
        }

    }
    
}

- (void)showArticleSelectionPopoverWithArticles:(NSArray *)articles {
    
    if (articles.count == 0) articles = [STMObjectsController objectsForEntityName:NSStringFromClass([STMArticle class])
                                                                           orderBy:@"name"
                                                                         ascending:YES
                                                                        fetchLimit:0
                                                                       withFantoms:NO
                                                            inManagedObjectContext:nil
                                                                             error:nil];

    STMArticleSelectionTVC *articleSelectionTVC = [[STMArticleSelectionTVC alloc] initWithStyle:UITableViewStyleGrouped];
    articleSelectionTVC.articles = articles;
    articleSelectionTVC.parentVC = self;

    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:articleSelectionTVC];

    self.articleSelectionPopover = [[UIPopoverController alloc] initWithContentViewController:nc];
    
    CGRect rect = CGRectMake(self.splitVC.view.frame.size.width/2, self.splitVC.view.frame.size.height/2, 1, 1);
    [self.articleSelectionPopover presentPopoverFromRect:rect inView:self.splitVC.view permittedArrowDirections:0 animated:YES];

}


#pragma mark - STMBarCodeScannerDelegate

- (UIView *)viewForScanner:(STMBarCodeScanner *)scanner {
    return self.view;
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCode:(NSString *)barcode withType:(STMBarCodeScannedType)type {
    
    NSLog(@"barCodeScanner receiveBarCode: %@ withType:%d", barcode, type);
    
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
            [self receiveStockBatchBarcode:barcode];
            break;
        }
    }

}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveError:(NSError *)error {
    NSLog(@"barCodeScanner receiveError: %@", error.localizedDescription);
}

- (void)deviceArrivalForBarCodeScanner:(STMBarCodeScanner *)scanner {
    
    if (scanner == self.iOSModeBarCodeScanner) {
        [STMSoundController say:NSLocalizedString(@"SCANNER DEVICE ARRIVAL", nil)];
    }
    
}

- (void)deviceRemovalForBarCodeScanner:(STMBarCodeScanner *)scanner {
    
    if (scanner == self.iOSModeBarCodeScanner) {
        [STMSoundController say:NSLocalizedString(@"SCANNER DEVICE REMOVAL", nil)];
    }
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"showSupplyOperation"] &&
        [segue.destinationViewController isKindOfClass:[STMSupplyOperationVC class]]) {

        self.operationVC = (STMSupplyOperationVC *)segue.destinationViewController;
        self.operationVC.supplyOrderArticleDoc = self.supplyOrderArticleDoc;
        self.operationVC.parentTVC = self;

        if ([sender isKindOfClass:[NSString class]]) {
            
            NSString *barcode = (NSString *)sender;
            self.operationVC.initialBarcode = barcode;

        } else if ([sender isKindOfClass:[NSIndexPath class]]) {
            
            NSIndexPath *indexPath = (NSIndexPath *)sender;
            STMStockBatchOperation *operation = [self.resultsController objectAtIndexPath:indexPath];
            self.operationVC.supplyOperation = operation;
            
        }
        
    }

}


#pragma mark - toolbar

- (void)setupToolbar {
    
    self.remainingVolume = [self.supplyOrderArticleDoc volumeRemainingToSupply];
    
    NSString *title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"REMAIN TO SUPPLY", nil), [STMFunctions volumeStringWithVolume:self.remainingVolume andPackageRel:[self.supplyOrderArticleDoc operatingArticle].packageRel.integerValue]];
    
    STMBarButtonItem *infoLabel = [[STMBarButtonItem alloc] initWithTitle:title
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:nil
                                                                   action:nil];
    
    infoLabel.enabled = NO;
    infoLabel.tintColor = [UIColor blackColor];
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
    
    [self setToolbarItems:@[flexibleSpace, infoLabel, flexibleSpace] animated:NO];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = self.supplyOrderArticleDoc.supplyOrder.ndoc;
    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    
    [self setupToolbar];
    
    [self performFetch];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self checkIfBarcodeScanerIsNeeded];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        
        [self stopBarcodeScanning];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
