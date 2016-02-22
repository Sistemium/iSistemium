//
//  STMPickingOrderPositionsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingOrderPositionsTVC.h"

#import "STMObjectsController.h"

#import "STMBarCodeScanner.h"
#import "STMSoundController.h"

#import "STMPickingOrdersProcessController.h"

#import "STMWorkflowController.h"
#import "STMWorkflowEditablesVC.h"

//#import "STMPickingPositionVolumeTVC.h"
//#import "STMPickingOrderPositionsPickedTVC.h"

#import "STMPickedPositionsListTVC.h"
#import "STMPickedPositionsInfoTVC.h"


#define SLIDE_THRESHOLD 20
#define ACTION_THRESHOLD 100


@interface STMPickingOrderPositionsTVC () <UIGestureRecognizerDelegate, UIActionSheetDelegate, STMBarCodeScannerDelegate>

@property (nonatomic, strong) NSArray <STMPickingOrderPosition *> *tableData;

@property (nonatomic, strong) NSString *pickingOrderWorkflow;
@property (nonatomic, strong) NSString *nextProcessing;

@property (nonatomic) CGFloat slideStartPoint;
@property (nonatomic, strong) UITableViewCell *slidedCell;
@property (nonatomic) CGRect initialFrame;
@property (nonatomic) BOOL cellStartSliding;

@property (nonatomic, strong) STMBarButtonItem *pickedPositionsButton;

@property (nonatomic, strong) STMBarCodeScanner *cameraBarCodeScanner;
@property (nonatomic, strong) STMBarCodeScanner *HIDBarCodeScanner;
@property (nonatomic, strong) STMBarCodeScanner *iOSModeBarCodeScanner;

@property (nonatomic, strong) STMBarCodeScan *currentBarCodeScan;
//@property (nonatomic, strong) NSString *currentStockToken;

//@property (nonatomic, strong) NSString *scannedBarCode;
//@property (nonatomic, strong) NSMutableArray *scannedStockBatches;
//@property (nonatomic, strong) NSMutableArray *scannedArticles;


@end


@implementation STMPickingOrderPositionsTVC

- (NSString *)pickingOrderWorkflow {
    
    if (!_pickingOrderWorkflow) {
        _pickingOrderWorkflow = [STMWorkflowController workflowForEntityName:NSStringFromClass([STMPickingOrder class])];
    }
    return _pickingOrderWorkflow;
    
}

- (BOOL)orderIsProcessed {
    return [STMWorkflowController isEditableProcessing:self.pickingOrder.processing inWorkflow:self.pickingOrderWorkflow];
}

- (NSArray <STMPickingOrderPosition *> *)tableData {
    
    if (!_tableData) {
        
        if (self.pickingOrder) {
            
            NSSortDescriptor *ordDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ord"
                                                                            ascending:YES
                                                                             selector:@selector(compare:)];

            NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"article.name"
                                                                            ascending:YES
                                                                             selector:@selector(caseInsensitiveCompare:)];

            NSArray *positions = [self.pickingOrder.pickingOrderPositions sortedArrayUsingDescriptors:@[ordDescriptor, nameDescriptor]];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nonPickedVolume > 0"];
            
            positions = [positions filteredArrayUsingPredicate:[STMPredicate predicateWithNoFantomsFromPredicate:predicate]];
            
            _tableData = positions;
            
        } else {
            
            _tableData = @[];
            
        }

    }
    return _tableData;
    
}

- (NSSet <STMPickingOrderPositionPicked *> *)pickedPositions {
    return [self.pickingOrder.pickingOrderPositions valueForKeyPath:@"@distinctUnionOfSets.pickingOrderPositionsPicked"];
}


// ---- ?
- (void)position:(STMPickingOrderPosition *)position wasPickedWithVolume:(NSUInteger)volume andProductionInfo:(NSString *)info {

//    [STMPickingOrdersProcessController position:position wasPickedWithVolume:volume andProductionInfo:info andBarCode:self.scannedBarCode];
//    [self positionWasUpdated:position];
//    [self.navigationController popToViewController:self animated:YES];

}
// ----

- (void)positionWasUpdated:(STMPickingOrderPosition *)position {
    
    [self updatePickedPositionsButton];

    if (position) {
        
        if ([self.tableData containsObject:position]) {
            
            if ([position nonPickedVolume] > 0) {
                
                NSUInteger positionIndex = [self.tableData indexOfObject:position];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:positionIndex inSection:0];
                
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
            } else {
                
                self.tableData = nil;
                [self.tableView reloadData];
                
            }
            
        } else if ([self.pickingOrder.pickingOrderPositions containsObject:position]) {
            
            self.tableData = nil;
            [self.tableView reloadData];

        }
        
    }

}


#pragma mark - cell's height caching

- (void)putCachedHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *object = self.tableData[indexPath.row];
    NSManagedObjectID *objectID = object.objectID;
    
    if (objectID) {
        self.cachedCellsHeights[objectID] = @(height);
    }
    
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObjectID *objectID = [self.tableData[indexPath.row] objectID];
    
    return self.cachedCellsHeights[objectID];
    
}


#pragma mark - table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.pickingOrder.ndoc;
}

- (UITableViewCell *)cellForHeightCalculationForIndexPath:(NSIndexPath *)indexPath {
    
    static STMCustom5TVCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    });
    
    return cell;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom5TVCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self fillCell:cell atIndexPath:indexPath];

    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom5TVCell class]]) {
        [self fillPickingOrderArticleCell:(STMCustom5TVCell *)cell atIndexPath:indexPath];
    }
    
    [super fillCell:cell atIndexPath:indexPath];
    
}

- (void)fillPickingOrderArticleCell:(STMCustom5TVCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    STMPickingOrderPosition *pickingPosition = self.tableData[indexPath.row];
    
    cell.titleLabel.text = pickingPosition.article.name;
    cell.detailLabel.text = pickingPosition.ord.stringValue;
    cell.infoLabel.text = [STMFunctions volumeStringWithVolume:[pickingPosition nonPickedVolume] andPackageRel:pickingPosition.article.packageRel.integerValue];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    if ([self orderIsProcessed]) {
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self orderIsProcessed]) {
        
//        STMPickingOrderPosition *position = self.tableData[indexPath.row];
        
//        NSLog(@"%@", [position.article.stockBatches valueForKeyPath:@"@distinctUnionOfObjects.barCodes"]);
        
//        [self performSegueWithIdentifier:@"showPositionVolume" sender:position];

    }
    
}


#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showPositionVolume"]) {
        
//        if ([segue.destinationViewController isKindOfClass:[STMPickingPositionVolumeTVC class]] &&
//            [sender isKindOfClass:[STMPickingOrderPosition class]]) {
//            
//            STMPickingPositionVolumeTVC *volumeTVC = (STMPickingPositionVolumeTVC *)segue.destinationViewController;
//            volumeTVC.position = (STMPickingOrderPosition *)sender;
//            volumeTVC.positionsTVC = self;
//            
//        }
        
    } else if ([segue.identifier isEqualToString:@"showPickedPositions"]) {
        
//        if ([segue.destinationViewController isKindOfClass:[STMPickingOrderPositionsPickedTVC class]]) {
//            
//            STMPickingOrderPositionsPickedTVC *pickedPositionsTVC = (STMPickingOrderPositionsPickedTVC *)segue.destinationViewController;
//            pickedPositionsTVC.pickingOrder = self.pickingOrder;
//            pickedPositionsTVC.positionsTVC = self;
//            
//        }
        
    } else if ([segue.identifier isEqualToString:@"showPickedInfo"]) {
        
        if ([segue.destinationViewController isKindOfClass:[STMPickedPositionsListTVC class]]) {

            STMPickedPositionsListTVC *pickedPositionsListTVC = (STMPickedPositionsListTVC *)segue.destinationViewController;
            pickedPositionsListTVC.pickingOrder = self.pickingOrder;
            
        }
        
    } else if ([segue.identifier isEqualToString:@"showPickedPositionInfo"]) {
        
        if ([segue.destinationViewController isKindOfClass:[STMPickedPositionsInfoTVC class]] &&
            [sender isKindOfClass:[STMPickingOrderPosition class]]) {
            
            STMPickedPositionsInfoTVC *pickedPositionsInfoTVC = (STMPickedPositionsInfoTVC *)segue.destinationViewController;
            pickedPositionsInfoTVC.position = (STMPickingOrderPosition *)sender;
            
        }

    }
    
}


#pragma mark - setup toolbars

- (void)addPickedPositionsButton {
    
    self.pickedPositionsButton = [[STMBarButtonItem alloc] initWithTitle:NSLocalizedString(@"PICKED POSITIONS", nil)
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(pickedPositionsButtonPressed)];
    
    [self updatePickedPositionsButton];
    
    [self setToolbarItems:@[[STMBarButtonItem flexibleSpace], self.pickedPositionsButton, [STMBarButtonItem flexibleSpace]]];
    
}

- (void)pickedPositionsButtonPressed {

//    [self performSegueWithIdentifier:@"showPickedPositions" sender:nil];
//    [self performSegueWithIdentifier:@"showPickedInfo" sender:nil];
    
}

- (void)updatePickedPositionsButton {
    
    NSSet *pickedPositions = [self.pickingOrder.pickingOrderPositions valueForKeyPath:@"@distinctUnionOfSets.pickingOrderPositionsPicked"];
    
    self.pickedPositionsButton.enabled = (pickedPositions.count > 0);
    self.pickedPositionsButton.title = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"PICKED POSITIONS", nil), @(pickedPositions.count).stringValue];
    
}

- (void)updateToolbars {
    
    BOOL orderIsProcessed = [self orderIsProcessed];
    
    if (orderIsProcessed) {
        
        ([self.iOSModeBarCodeScanner isDeviceConnected]) ? [self addBarcodeImage] : [self removeBarcodeImage];
        
    } else {
        
        [self removeBarcodeImage];
        
    }
    
//    self.navigationItem.hidesBackButton = orderIsProcessed;
    
    self.navigationController.toolbarHidden = NO;
    
    [self addProcessingButton];

}

- (void)addProcessingButton {
    
    NSString *title = [STMWorkflowController labelForProcessing:self.pickingOrder.processing inWorkflow:self.pickingOrderWorkflow];
    
    STMBarButtonItem *processingButton = [[STMBarButtonItem alloc] initWithTitle:title
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(processingButtonPressed)];
    
    processingButton.tintColor = [STMWorkflowController colorForProcessing:self.pickingOrder.processing inWorkflow:self.pickingOrderWorkflow];
    
    self.navigationItem.rightBarButtonItem = processingButton;
    
}

- (void)processingButtonPressed {
    
    STMWorkflowAS *workflowActionSheet = [STMWorkflowController workflowActionSheetForProcessing:self.pickingOrder.processing
                                                                                      inWorkflow:self.pickingOrderWorkflow
                                                                                    withDelegate:self];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [workflowActionSheet showInView:self.view];
    }];
    
}

- (void)addBarcodeImage {
    
    UIImage *image = [STMFunctions resizeImage:[UIImage imageNamed:@"barcode.png"] toSize:CGSizeMake(25, 25)];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    
}

- (void)removeBarcodeImage {
    self.navigationItem.titleView = nil;
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
        
        if ([self.pickingOrder.entity.propertiesByName.allKeys containsObject:field]) {
            [self.pickingOrder setValue:editableValues[field] forKey:field];
        }
        
    }
    
    [self updateWorkflowSelectedOrder];
    
}

- (void)updateWorkflowSelectedOrder {
    
    if (self.nextProcessing) {
        
        self.pickingOrder.processing = self.nextProcessing;
        [self orderProcessingChanged];
        
    }

}

- (void)orderProcessingChanged {
    
    [self checkIfBarcodeScanerIsNeeded];
    [self updateToolbars];
    [self.tableView reloadData];

    [self.document saveDocument:^(BOOL success) {
    }];

}


#pragma mark - barcode scanning

- (void)checkIfBarcodeScanerIsNeeded {
    
    ([self orderIsProcessed]) ? [self startBarcodeScanning] : [self stopBarcodeScanning];
    
}

- (void)startBarcodeScanning {

    [self startCameraScanner];
    
    [self startIOSModeScanner];
    
    //    [self startHIDModeScanner];

    ([self.iOSModeBarCodeScanner isDeviceConnected]) ? [self addBarcodeImage] : [self removeBarcodeImage];

}

- (void)startCameraScanner {
    
    if ([STMBarCodeScanner isCameraAvailable]) {
        
        self.cameraBarCodeScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerCameraMode];
        self.cameraBarCodeScanner.delegate = self;
        
        STMBarButtonItem *cameraButton = [[STMBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                        target:self
                                                                                        action:@selector(cameraBarCodeScannerButtonPressed)];
        
        self.navigationItem.leftBarButtonItem = cameraButton;
        
    }
    
}

- (void)startIOSModeScanner {
    
    self.iOSModeBarCodeScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerIOSMode];
    self.iOSModeBarCodeScanner.delegate = self;
    [self.iOSModeBarCodeScanner startScan];
    
}

- (void)startHIDModeScanner {
    
    self.HIDBarCodeScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerHIDKeyboardMode];
    self.HIDBarCodeScanner.delegate = self;
    [self.HIDBarCodeScanner startScan];
    
}


- (void)stopBarcodeScanning {

    [self stopCameraScanner];
    
    [self stopHIDModeScanner];
    
    [self stopIOSModeScanner];
    
}

- (void)stopCameraScanner {
    
    [self.cameraBarCodeScanner stopScan];
    self.cameraBarCodeScanner = nil;
    self.navigationItem.leftBarButtonItem = nil;
    
}

- (void)stopIOSModeScanner {
    
    [self.iOSModeBarCodeScanner stopScan];
    self.iOSModeBarCodeScanner = nil;
    
}

- (void)stopHIDModeScanner {
    
    [self.HIDBarCodeScanner stopScan];
    self.HIDBarCodeScanner = nil;
    
}

- (void)cameraBarCodeScannerButtonPressed {
    
    if (self.cameraBarCodeScanner.status == STMBarCodeScannerStarted) {
        
        [self.cameraBarCodeScanner stopScan];
        
    } else if (self.cameraBarCodeScanner.status == STMBarCodeScannerStopped) {
    
        [self.cameraBarCodeScanner startScan];

    }

}


#pragma mark - STMBarCodeScannerDelegate

- (UIView *)viewForScanner:(STMBarCodeScanner *)scanner {
    return self.view;
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCodeScan:(STMBarCodeScan *)barCodeScan withType:(STMBarCodeScannedType)type {
    
    if (type == STMBarCodeTypeStockBatch) {
        [self receiveStockBatchBarCodeScan:barCodeScan];
    }

}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCode:(NSString *)barcode withType:(STMBarCodeScannedType)type {
    
    NSLog(@"barCodeScanner receiveBarCode: %@", barcode);
//    self.scannedBarCode = barcode;
//    [self searchBarCode:self.scannedBarCode];
    
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


#pragma mark - barcodes

- (void)receiveStockBatchBarCodeScan:(STMBarCodeScan *)barcodeScan {
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMStockBatch class])];
    request.predicate = [NSPredicate predicateWithFormat:@"stockToken != nil AND ANY barCodes.code == %@", barcodeScan.code];
    
    NSArray *stockBatches = [self.document.managedObjectContext executeFetchRequest:request error:nil];
    
    if (stockBatches.count > 0) {
        
        self.currentBarCodeScan = barcodeScan;
        
        STMStockBatch *stockBatch = stockBatches.firstObject;
        
        [self receiveBarCodeScanOfStockBatch:stockBatch];
        
    } else {
        
        [STMSoundController playAlert];
        
    }
    
}

- (void)receiveBarCodeScanOfStockBatch:(STMStockBatch *)stockBatch {
    
    if (!stockBatch.stockToken) return;

    NSString *stockToken = stockBatch.stockToken;
    
    NSPredicate *articlePredicate = [NSPredicate predicateWithFormat:@"article == %@", stockBatch.article];

    NSSet *filteredPositions = [self.pickingOrder.pickingOrderPositions filteredSetUsingPredicate:articlePredicate];
    
    STMPickingOrderPosition *position = filteredPositions.anyObject;
    
    if (position) {
        
        [self performSegueWithIdentifier:@"showPickedPositionInfo" sender:position];
        
        if (position.pickingOrderPositionsPicked.count > 0) {

            NSPredicate *stockTokenPredicate = [NSPredicate predicateWithFormat:@"stockToken == %@", stockToken];
            
            STMPickingOrderPositionPicked *positionPicked = [position.pickingOrderPositionsPicked filteredSetUsingPredicate:stockTokenPredicate].anyObject;
            
            if (positionPicked) {
                
                [self updateVolumeForPositionPicked:positionPicked withPosition:position];
                [self linkCurrentBarCodeScanWithPositionPicked:positionPicked];

            } else {
                
                STMPickingOrderPositionPicked *positionPicked = [self createPositionPickedForStockBatch:stockBatch andPosition:position];
                [self updateVolumeForPositionPicked:positionPicked withPosition:position];
                
            }

        } else {
            
            [self createPositionPickedForStockBatch:stockBatch andPosition:position];

        }
        
        [self positionWasUpdated:position];
        
    } else {
        
        [STMSoundController playAlert];
        
    }
    
}

- (STMPickingOrderPositionPicked *)createPositionPickedForStockBatch:(STMStockBatch *)stockBatch andPosition:(STMPickingOrderPosition *)position {
    
    STMPickingOrderPositionPicked *positionPicked = (STMPickingOrderPositionPicked *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMPickingOrderPositionPicked class]) isFantom:NO];
    
    positionPicked.pickingOrderPosition = position;
    positionPicked.volume = position.volume;
    positionPicked.stockToken = stockBatch.stockToken;
    positionPicked.article = stockBatch.article;
    
    if (stockBatch.article.productionInfoType) {
        positionPicked.productionInfo = stockBatch.productionInfo;
    }
    
    [self linkCurrentBarCodeScanWithPositionPicked:positionPicked];

    [self.document saveDocument:^(BOOL success) {
        
    }];
    
    return positionPicked;
    
}

- (void)linkCurrentBarCodeScanWithPositionPicked:(STMPickingOrderPositionPicked *)positionPicked {

    self.currentBarCodeScan.destinationEntity = NSStringFromClass([positionPicked class]);
    self.currentBarCodeScan.destinationXid = positionPicked.xid;

}

- (void)updateVolumeForPositionPicked:(STMPickingOrderPositionPicked *)positionPicked withPosition:(STMPickingOrderPosition *)position {
    
    NSSortDescriptor *ctsDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts"
                                                                    ascending:YES
                                                                     selector:@selector(compare:)];
    
    NSArray *sortedPositionsPicked = [position.pickingOrderPositionsPicked sortedArrayUsingDescriptors:@[ctsDescriptor]];
    
    STMPickingOrderPositionPicked *firstPositionPicked = sortedPositionsPicked.firstObject;
    
    if (![positionPicked isEqual:firstPositionPicked]) {
        
        NSInteger packageRel = position.article.packageRel.integerValue;
        
        NSUInteger volumeStep = (position.volume.integerValue > 2 * packageRel) ? packageRel : 1;
        
        positionPicked.volume = @(positionPicked.volume.integerValue + volumeStep);
        firstPositionPicked.volume = @(firstPositionPicked.volume.integerValue - volumeStep);
        
    }

}


- (void)firstVersionOfPickingProcess {

    // ---- First version of picking process ----
    
    //- (void)searchBarCode:(NSString *)barcode {
    //
    //    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMBarCode class])];
    //    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES]];
    //    request.predicate = [NSPredicate predicateWithFormat:@"code == %@", barcode];
    //
    //    NSArray *barcodesArray = [[[STMSessionManager sharedManager].currentSession document].managedObjectContext executeFetchRequest:request error:nil];
    //
    //    if (barcodesArray.count > 0) {
    //
    ////        [STMSoundController playOk];
    //
    //        if (barcodesArray.count > 1) {
    //            NSLog(@"barcodesArray.count > 1");
    //        }
    //
    //        [self checkBarCodes:barcodesArray];
    //
    //    } else {
    //
    //        [STMSoundController alertSay:NSLocalizedString(@"UNKNOWN BARCODE", nil)];
    //        NSLog(@"unknown barcode %@", barcode);
    //
    //    }
    //
    //}
    
    //- (void)checkBarCodes:(NSArray <STMBarCode *> *)barcodesArray {
    //
    //    self.scannedArticles = @[].mutableCopy;
    //    self.scannedStockBatches = @[].mutableCopy;
    //
    //    for (STMBarCode *barcodeObject in barcodesArray) {
    //
    //        if ([barcodeObject isKindOfClass:[STMArticleBarCode class]]) {
    //
    //            STMArticle *article = [(STMArticleBarCode *)barcodeObject article];
    //            [self.scannedArticles addObject:article];
    //
    //            NSLog(@"article name %@", article.name);
    //
    //        } else if ([barcodeObject isKindOfClass:[STMStockBatchBarCode class]]) {
    //
    //            STMStockBatch *stockBatch = [(STMStockBatchBarCode *)barcodeObject stockBatch];
    //            [self.scannedStockBatches addObject:stockBatch];
    //
    //            NSLog(@"stockBatch article name %@", stockBatch.article.name);
    //
    //        } else {
    //
    //        }
    //
    //    }
    //
    //    if (self.scannedArticles.count > 1 && self.scannedStockBatches.count > 1) {
    //
    //        [STMSoundController alertSay:NSLocalizedString(@"ARTICLE COINCIDE WITH STOCKBATCH", nil)];
    //        NSLog(@"!!!article barcode coincide with stock batch barcode!!!");
    //
    //    }
    //
    //    [self searchScannedArticle];
    //
    //}
    
    //- (void)searchScannedArticle {
    //
    //    if (self.scannedStockBatches.count > 0) {
    //
    //        [self checkScannedStockBatches];
    //
    //    } else {
    //
    //        if (self.scannedArticles.count > 0) {
    //
    //            [self checkScannedArticles];
    //
    //        }
    //
    //    }
    //
    //}
    
    //- (void)checkScannedStockBatches {
    //
    //    if (self.scannedStockBatches.count > 1) {
    //
    //        [STMSoundController alertSay:NSLocalizedString(@"ERROR", nil)];
    //        NSLog(@"to many stock batches %@", self.scannedStockBatches);
    //
    //    } else {
    //
    //        STMStockBatch *stockBatch = self.scannedStockBatches.firstObject;
    //
    //        if ([stockBatch localVolume] > 0) {
    //
    //            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"article == %@", stockBatch.article];
    //
    //            NSArray *correspondingPositions = [self.tableData filteredArrayUsingPredicate:predicate];
    //
    //            if (correspondingPositions.count > 0) {
    //
    //                if (correspondingPositions.count > 1) {
    //
    //                    [STMSoundController alertSay:NSLocalizedString(@"ERROR", nil)];
    //                    NSLog(@"to many correspondingPositions %@", correspondingPositions);
    //
    //                } else {
    //
    //                    [STMSoundController playOk];
    //                    STMPickingOrderPosition *position = correspondingPositions.firstObject;
    //                    [self pickPosition:position fromStockBatch:stockBatch withBarCode:self.scannedBarCode];
    //
    //                }
    //
    //            } else {
    //
    //                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stockBatch == %@", stockBatch];
    //                NSSet *pickedPositions = [[self pickedPositions] filteredSetUsingPredicate:predicate];
    //
    //                if (pickedPositions.count > 0) {
    //
    //                    [STMSoundController alertSay:NSLocalizedString(@"THIS POSITION ALREADY PICKED", nil)];
    //                    NSLog(@"position %@ already picked", stockBatch.article.name);
    //
    //                } else {
    //
    //                    if (self.scannedArticles.count > 0) {
    //
    //                        [self checkScannedArticles];
    //
    //                    } else {
    //
    //                        [STMSoundController alertSay:NSLocalizedString(@"PICKING ORDER NAVE NOT THIS ARTICLE", nil)];
    //                        NSLog(@"picking order nave not this article %@", stockBatch.article.name);
    //
    //                    }
    //
    //                }
    //
    //            }
    //
    //        } else {
    //
    //            if (self.scannedArticles.count > 0) {
    //
    //                [self checkScannedArticles];
    //
    //            } else {
    //
    //                [STMSoundController alertSay:NSLocalizedString(@"STOCK BATCH IS EMPTY", nil)];
    //                NSLog(@"stock batch is empty %@", stockBatch);
    //
    //            }
    //
    //        }
    //
    //    }
    //
    //}
    
    //- (void)checkScannedArticles {
    //
    //    if (self.scannedArticles.count > 1) {
    //
    //        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"article IN %@", self.scannedArticles];
    //        NSArray *correspondingPositions = [self.tableData filteredArrayUsingPredicate:predicate];
    //
    //        if (correspondingPositions.count > 0) {
    //
    //            if (correspondingPositions.count > 1) {
    //
    //                [STMSoundController alertSay:NSLocalizedString(@"ERROR", nil)];
    //                NSLog(@"%@ correspondingPositions for articles %@", @(correspondingPositions.count), [self.scannedArticles valueForKeyPath:@"@unionOfObjects.name"]);
    //
    //            } else {
    //
    //                STMPickingOrderPosition *position = correspondingPositions.firstObject;
    //                [self performSegueWithIdentifier:@"showPositionVolume" sender:position];
    //
    //            }
    //
    //        } else {
    //
    //            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"article IN %@", self.scannedArticles];
    //            NSSet *pickedPositions = [[self pickedPositions] filteredSetUsingPredicate:predicate];
    //
    //            if (pickedPositions.count > 0) {
    //
    //                [STMSoundController alertSay:NSLocalizedString(@"THIS POSITION ALREADY PICKED", nil)];
    //                NSLog(@"position %@ already picked", [self.scannedArticles valueForKeyPath:@"@unionOfObjects.name"]);
    //
    //            } else {
    //
    //                [STMSoundController alertSay:NSLocalizedString(@"PICKING ORDER NAVE NOT THIS ARTICLE", nil)];
    //                NSLog(@"picking order have no following articles:");
    //                NSArray <NSString *> *articlesNames = [self.scannedArticles valueForKeyPath:@"@unionOfObjects.name"];
    //                for (NSString *articleName in articlesNames) {
    //                    NSLog(@"%@", articleName);
    //                }
    //
    //            }
    //
    //        }
    //
    //    } else {
    //
    //        STMArticle *article = self.scannedArticles.firstObject;
    //        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"article == %@", article];
    //        NSArray *correspondingPositions = [self.tableData filteredArrayUsingPredicate:predicate];
    //
    //        if (correspondingPositions.count > 0) {
    //
    //            if (correspondingPositions.count > 1) {
    //
    //                [STMSoundController alertSay:NSLocalizedString(@"ERROR", nil)];
    //                NSLog(@"%@ correspondingPositions for article %@", @(correspondingPositions.count), article);
    //
    //            } else {
    //
    //                STMPickingOrderPosition *position = correspondingPositions.firstObject;
    //                [self performSegueWithIdentifier:@"showPositionVolume" sender:position];
    //
    //            }
    //
    //        } else {
    //
    //            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"article == %@", article];
    //            NSSet *pickedPositions = [[self pickedPositions] filteredSetUsingPredicate:predicate];
    //
    //            if (pickedPositions.count > 0) {
    //                
    //                [STMSoundController alertSay:NSLocalizedString(@"THIS POSITION ALREADY PICKED", nil)];
    //                NSLog(@"position %@ already picked", article.name);
    //                
    //            } else {
    //            
    //                [STMSoundController alertSay:NSLocalizedString(@"PICKING ORDER NAVE NOT THIS ARTICLE", nil)];
    //                NSLog(@"picking order nave not this article %@", article.name);
    //                
    //            }
    //
    //        }
    //
    //    }
    //    
    //}
    
    //- (void)pickPosition:(STMPickingOrderPosition *)position fromStockBatch:(STMStockBatch *)stockBatch withBarCode:(NSString *)barcode {
    //    
    //    [STMPickingOrdersProcessController pickPosition:position fromStockBatch:stockBatch withBarCode:barcode];
    //    [self positionWasUpdated:position];
    //    
    //}
    
    // ---- End of First version of picking process ----

}


#pragma mark - pan gesture

- (void)addPanGesture {
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    
    [self.tableView addGestureRecognizer:pan];
    
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            
            break;
            
        }
        case UIGestureRecognizerStateChanged: {
            
            CGFloat slideShift = [pan translationInView:pan.view].x;

            if (!self.cellStartSliding) {
                
                if (slideShift > SLIDE_THRESHOLD) {
                    
                    self.cellStartSliding = YES;
                    
                    self.tableView.scrollEnabled = NO;
                    
                    CGPoint startPoint = [pan locationInView:pan.view];
                    
                    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:startPoint];
                    self.slidedCell = [self.tableView cellForRowAtIndexPath:indexPath];
                    self.initialFrame = self.slidedCell.contentView.frame;
                    
                    self.slideStartPoint = startPoint.x;

                }
                
            } else {
                
                [self slideCellWithShift:slideShift panGesture:pan];
                
            }
            
            break;
            
        }
        case UIGestureRecognizerStateEnded: {

            [self panGestureEnded];
            break;
            
        }
            
        case UIGestureRecognizerStateCancelled: {
            
            pan.enabled = YES;
            [self panGestureEnded];
            break;
            
        }
            
        default: {
            break;
        }
    }
    
}

- (void)panGestureEnded {
    
    self.slidedCell.contentView.frame = self.initialFrame;
    self.cellStartSliding = NO;
    self.tableView.scrollEnabled = YES;

}

- (void)slideCellWithShift:(CGFloat)slideShift panGesture:(UIPanGestureRecognizer *)pan {
    
    if (self.initialFrame.origin.x + slideShift > 0) {
        
        self.slidedCell.contentView.frame = CGRectMake(self.initialFrame.origin.x + slideShift, self.initialFrame.origin.y, self.initialFrame.size.width, self.initialFrame.size.height);
    
    } else {
        
        self.slidedCell.contentView.frame = self.initialFrame;
        
    }
    
    if (slideShift > ACTION_THRESHOLD && self.slideStartPoint + slideShift > self.tableView.frame.size.width - SLIDE_THRESHOLD) {
        
        NSLog(@"cell's slide did moved enough distance and achieve a right edge of the screen, it's a time to do something");
        
        pan.enabled = NO;
        
    }
    
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
//    [self addPanGesture];

    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self addPickedPositionsButton];
    [self updateToolbars];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([STMCustom5TVCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:self.cellIdentifier];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self checkIfBarcodeScanerIsNeeded];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [self stopBarcodeScanning];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {

    }
    
}


@end
