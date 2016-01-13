//
//  STMSupplyOrderOperationsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 12/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOrderOperationsTVC.h"

#import "STMSupplyOrdersNC.h"
#import "STMSupplyOrdersSVC.h"
#import "STMSupplyOperationVC.h"
#import "STMArticleSelectionTVC.h"

#import "STMBarCodeScanner.h"
#import "STMSoundController.h"
#import "STMSupplyOrdersProcessController.h"
#import "STMBarCodeController.h"
#import "STMObjectsController.h"

#define POPOVER_SIZE 512


@interface STMSupplyOrderOperationsTVC () <STMBarCodeScannerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) STMSupplyOrdersSVC *splitVC;
@property (nonatomic, weak) STMSupplyOrdersNC *rootNC;
@property (nonatomic, strong) STMSupplyOperationVC *operationVC;

@property (nonatomic, strong) STMBarCodeScanner *iOSModeBarCodeScanner;

@property (nonatomic) NSInteger remainingVolume;
@property (nonatomic, strong) NSMutableArray *stockBatchCodes;
@property (nonatomic, strong) NSString *articleBarCode;

@property (nonatomic, strong) UIPopoverController *articleSelectionPopover;

@property (nonatomic) NSInteger lastSourceOperationNumberOfBarcodes;
@property (nonatomic) NSInteger lastSourceOperationVolume;

@property (nonatomic, strong) UIAlertView *remainingBarcodesAlert;
@property (nonatomic, strong) UIAlertView *illegalArticleChangeAlert;

@property (nonatomic, strong) NSString *supplyOrderWorkflow;


@end


@implementation STMSupplyOrderOperationsTVC

@synthesize resultsController = _resultsController;


- (STMSupplyOrdersNC *)rootNC {

    if (!_rootNC) {
        
        if ([self.navigationController isKindOfClass:[STMSupplyOrdersNC class]]) {
            _rootNC = (STMSupplyOrdersNC *)self.navigationController;
        }
    }
    return _rootNC;
    
}

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

- (void)setRepeatLastOperation:(BOOL)repeatLastOperation {
    
    _repeatLastOperation = repeatLastOperation;
    
    if (_repeatLastOperation) {
        
        self.lastSourceOperationNumberOfBarcodes = [self.supplyOrderArticleDoc lastSourceOperationNumberOfBarcodes];
        self.lastSourceOperationVolume = [self.supplyOrderArticleDoc lastSourceOperationVolume];
        
    } else {
        
        self.lastSourceOperationNumberOfBarcodes = 0;
        self.lastSourceOperationVolume = 0;
        self.stockBatchCodes = nil;
        
    }
    
    [self setupToolbar];
    
}

- (NSMutableArray *)stockBatchCodes {
    
    if (!_stockBatchCodes) {
        _stockBatchCodes = @[].mutableCopy;
    }
    return _stockBatchCodes;
    
}

- (NSString *)supplyOrderWorkflow {
    
    if (!_supplyOrderWorkflow) {
    
        if (IPAD) return self.splitVC.supplyOrderWorkflow;
        if (IPHONE) return self.rootNC.supplyOrderWorkflow;
        
    }
    return _supplyOrderWorkflow;
    
}

- (BOOL)orderIsProcessed {
    return [STMWorkflowController isEditableProcessing:self.supplyOrderArticleDoc.supplyOrder.processing inWorkflow:self.supplyOrderWorkflow];
}

- (void)orderProcessingChanged {
    
    [self.tableView reloadData];
    [self checkIfBarcodeScanerIsNeeded];
    
}

- (void)confirmArticle:(STMArticle *)article {
    
    self.supplyOrderArticleDoc.article = article;
    self.supplyOrderArticleDoc.code = self.articleBarCode;
    
    [STMSoundController playOk];
    [self setupToolbar];
    
    [self.document saveDocument:^(BOOL success) {
        
    }];
    
    [self.tableView reloadData];
    
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

- (BOOL)isInActiveTab {
    
    if (IPHONE) {
        return [self.tabBarController.selectedViewController isEqual:self.navigationController];
    }
    
    if (IPAD) {
        return [self.tabBarController.selectedViewController isEqual:self.splitViewController];
    }
    
    return NO;
    
}


#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return (self.supplyOrderArticleDoc.article) ? 2 : 1;
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
            [self fillArticleCell:cell atIndexPath:indexPath];
            break;

        case 1:
            [self fillOperationCell:cell atIndexPath:indexPath];
            break;

        default:
            break;
    }
    
    return cell;
    
}

- (void)fillArticleCell:(STMTableViewSubtitleStyleCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            [self fillArticleCell:cell];
            break;
            
        case 1:
            [self fillRemainingCell:cell];
            break;
            
        default:
            break;
    }
    
}

- (void)fillArticleCell:(STMTableViewSubtitleStyleCell *)cell {

    cell.textLabel.numberOfLines = 0;
    
    if (self.supplyOrderArticleDoc.article) {
     
        cell.textLabel.textColor = [UIColor blackColor];
        
        if (self.supplyOrderArticleDoc.code) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@", self.supplyOrderArticleDoc.code, self.supplyOrderArticleDoc.article.name];
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", self.supplyOrderArticleDoc.article.name];
        }
        
        NSMutableArray *detailTexts = @[].mutableCopy;
        
        if (self.supplyOrderArticleDoc.articleDoc.dateProduction) {
            
            NSString *dateProduction = [[STMFunctions dateShortNoTimeFormatter] stringFromDate:(NSDate * _Nonnull)self.supplyOrderArticleDoc.articleDoc.dateProduction];
            dateProduction = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"DATE PRODUCTION", nil), dateProduction];
            
            [detailTexts addObject:dateProduction];
            
        }
        
        if (self.supplyOrderArticleDoc.articleDoc.dateImport) {
            
            NSString *dateImport = [[STMFunctions dateShortNoTimeFormatter] stringFromDate:(NSDate * _Nonnull)self.supplyOrderArticleDoc.articleDoc.dateImport];
            dateImport = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"DATE IMPORT", nil), dateImport];
            [detailTexts addObject:dateImport];
            
        }
        
        cell.detailTextLabel.text  = [detailTexts componentsJoinedByString:@" / "];
        
    } else {
        
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.text = ([self orderIsProcessed]) ? NSLocalizedString(@"CONFIRM ARTICLE FOR START", nil) : NSLocalizedString(@"START SUPPLY PROCESS", nil);

    }
    
}

- (void)fillRemainingCell:(STMTableViewSubtitleStyleCell *)cell {
    
    self.remainingVolume = [self.supplyOrderArticleDoc volumeRemainingToSupply];
    
    NSString *title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"REMAIN TO SUPPLY", nil), [STMFunctions volumeStringWithVolume:self.remainingVolume andPackageRel:[self.supplyOrderArticleDoc operatingArticle].packageRel.integerValue]];

    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = title;

    cell.detailTextLabel.text = @"";

}

- (void)fillOperationCell:(STMTableViewSubtitleStyleCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
    
    if (self.resultsController.fetchedObjects.count > 0) {
        
        cell.textLabel.textColor = [UIColor blackColor];

        STMStockBatchOperation *operation = [self.resultsController objectAtIndexPath:indexPath];
        
        if (operation.deviceCts) cell.textLabel.text = [[STMFunctions dateShortTimeShortFormatter] stringFromDate:(NSDate * _Nonnull)operation.deviceCts];
        
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
        
    } else {
        
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.text = (self.supplyOrderArticleDoc.article) ? NSLocalizedString(@"SCAN STOCK BATCH CODE", nil) : @"";
        
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self orderIsProcessed]) {
     
        if (indexPath.section == 0) {
            
            if (self.supplyOrderArticleDoc.article) {
                
                if (self.supplyOrderArticleDoc.sourceOperations.count > 0) {

                    NSLog(@"should delete all operations before changing article");
                    [self showIllegalArticleChangeAlert];
                    
                } else {
                    [self showArticleSelectionWithArticles:nil];
                }

            }
            
        } else if (indexPath.section == 1) {
            
            if (self.resultsController.fetchedObjects.count > 0) {

                indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
                [self performSegueWithIdentifier:@"showSupplyOperation" sender:indexPath];

            }
            
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
        
        indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];

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
    
    if (self.stockBatchCodes.count > 0 || [self.presentedViewController isEqual:self.operationVC] || self.supplyOrderArticleDoc.sourceOperations.count > 0) {
        
        [STMSoundController playAlert];
        [self showIllegalArticleChangeAlert];
        
    } else {
        
        NSArray *articles = [STMBarCodeController articlesForBarcode:barcode];
        
        if (articles.count > 0) {
    
            self.articleBarCode = barcode;

            if (articles.count == 1) {
                
                STMArticle *article = articles.firstObject;
                [self confirmArticle:article];
                
            } else {
                
                [STMSoundController alertSay:NSLocalizedString(@"NO ARTICLES FOR THIS BARCODE", nil)];
                [self showArticleSelectionWithArticles:articles];
                
            }
            
        } else {
            
            STMArticle *article = self.supplyOrderArticleDoc.articleDoc.article;
            
            if (article && article.barCodes.count == 0) {
                
                self.articleBarCode = barcode;
                [self confirmArticle:article];
                
            } else {
                
                [STMSoundController say:NSLocalizedString(@"MANUAL LINK BARCODE TO ARTICLE", nil)];
                
            }
            
        }

    }
    
}

- (void)receiveStockBatchBarcode:(NSString *)barcode {
    
    [self.illegalArticleChangeAlert dismissWithClickedButtonIndex:-1 animated:NO];
    
    if (!self.supplyOrderArticleDoc.article) {
        
        [STMSoundController alertSay:NSLocalizedString(@"CONFIRM ARTICLE FOR START", nil)];
        
    } else {
        
        if ([self.supplyOrderArticleDoc volumeRemainingToSupply] > 0) {
        
            if ([STMBarCodeController stockBatchForBarcode:barcode] || [self.stockBatchCodes containsObject:barcode]) {
                
                [STMSoundController alertSay:NSLocalizedString(@"THIS STOCK BATCH ALREADY EXIST", nil)];
                
            } else {
                
                if ([self.presentedViewController isEqual:self.operationVC]) {
                    
                    [self.operationVC addStockBatchCode:barcode];
                    
                } else {
                    
                    [self processStockBatchBarcode:barcode];
                    
                }
                
            }

        } else {
            
            [STMSoundController alertSay:NSLocalizedString(@"SUPPLY POSITION COMPLETE", nil)];
            
        }
        
    }
    
}

- (void)processStockBatchBarcode:(NSString *)barcode {
    
    if ([self.supplyOrderArticleDoc volumeRemainingToSupply] < self.lastSourceOperationVolume) {
        self.repeatLastOperation = NO;
    }
    
    if (self.repeatLastOperation) {
        
        [self.stockBatchCodes addObject:barcode];
        
        if (self.stockBatchCodes.count >= self.lastSourceOperationNumberOfBarcodes) {
            
            [STMSoundController say:NSLocalizedString(@"OPERATION COMPLETE", nil)];
            [self repeatOperationComplete];
            
        } else {
            
            [STMSoundController say:NSLocalizedString(@"ONE MORE CODE", nil)];
            [self showRemainingBarcodesAlert];
            
        }
        
    } else {
        
        [self performSegueWithIdentifier:@"showSupplyOperation" sender:barcode];
        
    }

}

- (void)repeatOperationComplete {
    
    if (self.remainingBarcodesAlert.isVisible) {
        [self.remainingBarcodesAlert dismissWithClickedButtonIndex:-1 animated:NO];
    }
    
    [STMSupplyOrdersProcessController createOperationForSupplyOrderArticleDoc:self.supplyOrderArticleDoc
                                                                    withCodes:self.stockBatchCodes
                                                                    andVolume:self.lastSourceOperationVolume];
    self.stockBatchCodes = nil;
    
    [STMSoundController playOk];

}

- (void)showRemainingBarcodesAlert {
    
    NSInteger remainingBarcodesToScan = self.lastSourceOperationNumberOfBarcodes - self.stockBatchCodes.count;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        NSString *alertMessage = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"BARCODES REMAIN TO SCAN", nil), @(remainingBarcodesToScan)];
        
        if (self.remainingBarcodesAlert.isVisible) {
            
            self.remainingBarcodesAlert.message = alertMessage;
            
        } else {
            
            self.remainingBarcodesAlert = [[UIAlertView alloc] initWithTitle:@""
                                                                     message:alertMessage
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                                           otherButtonTitles:nil];
            self.remainingBarcodesAlert.tag = 341341;
            
            [self.remainingBarcodesAlert show];
            
        }
        
    }];

}


#pragma mark - article selection

- (void)showArticleSelectionWithArticles:(NSArray *)articles {
    
    if (!self.articleBarCode) self.articleBarCode = self.supplyOrderArticleDoc.code;
    
    if (articles.count == 0) articles = [STMBarCodeController articlesForBarcode:self.articleBarCode];
    
    if (articles.count > 0) {
        
        STMArticleSelectionTVC *articleSelectionTVC = [[STMArticleSelectionTVC alloc] initWithStyle:UITableViewStyleGrouped];
        articleSelectionTVC.articles = articles;
        articleSelectionTVC.parentVC = self;
        articleSelectionTVC.visibleArticle = [self.supplyOrderArticleDoc operatingArticle];
        articleSelectionTVC.articleDocArticle = self.supplyOrderArticleDoc.articleDoc.article;
        articleSelectionTVC.selectedArticle = self.supplyOrderArticleDoc.article;

        if (IPAD) [self showArticleSelectionPopoverWithTVC:articleSelectionTVC];
        if (IPHONE) [self showArticleSelectionTVC:articleSelectionTVC];
        
    }

}

- (void)showArticleSelectionTVC:(STMArticleSelectionTVC *)articleSelectionTVC {
    [self.navigationController pushViewController:articleSelectionTVC animated:YES];
}

- (void)showArticleSelectionPopoverWithTVC:(STMArticleSelectionTVC *)articleSelectionTVC {

    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:articleSelectionTVC];
    
    self.articleSelectionPopover = [[UIPopoverController alloc] initWithContentViewController:nc];
    self.articleSelectionPopover.popoverContentSize = CGSizeMake(POPOVER_SIZE, POPOVER_SIZE);
    
    CGRect rect = CGRectMake(self.splitVC.view.frame.size.width/2, self.splitVC.view.frame.size.height/2, 1, 1);
    [self.articleSelectionPopover presentPopoverFromRect:rect inView:self.splitVC.view permittedArrowDirections:0 animated:YES];

}

- (void)dismissArticleSelectionPopover {
    
    [self.articleSelectionPopover dismissPopoverAnimated:YES];
    self.articleSelectionPopover = nil;
    
}

- (void)showIllegalArticleChangeAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        NSString *alertMessage = NSLocalizedString(@"ILLEGAL ARTICLE CHANGE ATTEMPT", nil);
        
        if (!self.illegalArticleChangeAlert.isVisible) {
            
            self.illegalArticleChangeAlert = [[UIAlertView alloc] initWithTitle:@""
                                                                     message:alertMessage
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"CLOSE", nil)
                                                           otherButtonTitles:nil];
            self.illegalArticleChangeAlert.tag = 334411;
            
            [self.illegalArticleChangeAlert show];
            
        }
        
    }];

}


#pragma mark - rotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (self.articleSelectionPopover.popoverVisible) {
        [self dismissArticleSelectionPopover];
    }
    
}


#pragma mark - STMBarCodeScannerDelegate

- (UIView *)viewForScanner:(STMBarCodeScanner *)scanner {
    return self.view;
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCode:(NSString *)barcode withType:(STMBarCodeScannedType)type {
    
    if ([self isInActiveTab]) {
        
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


#pragma mark - toolbars

- (void)setupToolbar {
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    
//    self.remainingVolume = [self.supplyOrderArticleDoc volumeRemainingToSupply];
//    
//    NSString *title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"REMAIN TO SUPPLY", nil), [STMFunctions volumeStringWithVolume:self.remainingVolume andPackageRel:[self.supplyOrderArticleDoc operatingArticle].packageRel.integerValue]];
//    
//    STMBarButtonItem *infoLabel = [[STMBarButtonItem alloc] initWithTitle:title
//                                                                    style:UIBarButtonItemStylePlain
//                                                                   target:nil
//                                                                   action:nil];
//    
//    infoLabel.enabled = NO;
//    infoLabel.tintColor = [UIColor blackColor];
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
    
    if (self.repeatLastOperation) {
        
        NSString *repeatingButtonTitle = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"STOP REPEATING BUTTON TITLE", nil), [self repeatParameters]];
        
        STMBarButtonItem *stopRepeatingButton = [[STMBarButtonItem alloc] initWithTitle:repeatingButtonTitle
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(stopRepeatingButtonPressed)];

//        [self setToolbarItems:@[infoLabel, flexibleSpace, stopRepeatingButton] animated:NO];
        [self setToolbarItems:@[flexibleSpace, stopRepeatingButton, flexibleSpace] animated:NO];

    } else {
    
        [self setToolbarItems:@[] animated:NO];

    }
    
}

- (NSString *)repeatParameters {
    
    NSString *volumeString = [STMFunctions volumeStringWithVolume:self.lastSourceOperationVolume
                                                    andPackageRel:[self.supplyOrderArticleDoc operatingArticle].packageRel.integerValue];
    
    NSString *pluralType = [STMFunctions pluralTypeForCount:self.lastSourceOperationNumberOfBarcodes];
    NSString *pluralString = [pluralType stringByAppendingString:@"CODES"];
    
    NSString *numberOfBarcodesString = nil;
    
    if (self.lastSourceOperationNumberOfBarcodes > 0) {
        numberOfBarcodesString = [NSString stringWithFormat:@"%@ %@", @(self.lastSourceOperationNumberOfBarcodes), NSLocalizedString(pluralString, nil)];
    } else {
        numberOfBarcodesString = NSLocalizedString(pluralString, nil);
    }
    
    NSString *repeatParameters = [NSString stringWithFormat:@"(%@, %@)", volumeString, numberOfBarcodesString];

    return repeatParameters;
    
}

- (void)stopRepeatingButtonPressed {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"STOP REPEATING?", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        
        alert.tag = 341;
        
        [alert show];
        
    }];
    
}

- (void)addBarcodeImage {
    
    UIImage *image = [STMFunctions resizeImage:[UIImage imageNamed:@"barcode.png"] toSize:CGSizeMake(25, 25)];
    self.navigationItem.rightBarButtonItem = [[STMBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:image]];
    
}

- (void)removeBarcodeImage {
    self.navigationItem.rightBarButtonItem = nil;
}



#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case 341:
            switch (buttonIndex) {
                case 1:
                    self.repeatLastOperation = NO;
                    break;
                    
                default:
                    break;
            }
            break;

        case 341341:
            switch (buttonIndex) {
                case 0:
                    self.stockBatchCodes = nil;
                    break;
                    
                default:
                    break;
            }
            break;

        default:
            break;
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    self.navigationItem.hidesBackButton = IPAD;
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
