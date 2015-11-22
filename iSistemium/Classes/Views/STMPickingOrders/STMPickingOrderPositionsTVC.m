//
//  STMPickingOrderPositionsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 17/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingOrderPositionsTVC.h"

#import "STMWorkflowController.h"
#import "STMWorkflowEditablesVC.h"
#import "STMPickingPositionVolumeTVC.h"
#import "STMPickingOrderPositionsPickedTVC.h"
#import "STMObjectsController.h"

#import "STMBarCodeScanner.h"


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

- (void)position:(STMPickingOrderPosition *)position wasPickedWithVolume:(NSUInteger)volume andProductionInfo:(NSString *)info {
    
    NSString *entityName = NSStringFromClass([STMPickingOrderPositionPicked class]);
    STMPickingOrderPositionPicked *pickedPosition = (STMPickingOrderPositionPicked *)[STMObjectsController newObjectForEntityName:entityName isFantom:NO];
    
    pickedPosition.productionInfo = info;
    pickedPosition.article = position.article;
    pickedPosition.pickingOrderPosition = position;
    pickedPosition.volume = @(volume);
    
    [[[STMSessionManager sharedManager].currentSession document] saveDocument:^(BOOL success) {
        
    }];

    [self.navigationController popToViewController:self animated:YES];
    
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
    
    if ([self orderIsProcessed]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self orderIsProcessed]) {
        
        STMPickingOrderPosition *position = self.tableData[indexPath.row];
        [self performSegueWithIdentifier:@"showPositionVolume" sender:position];

    }
    
}


#pragma mark - navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showPositionVolume"]) {
        
        if ([segue.destinationViewController isKindOfClass:[STMPickingPositionVolumeTVC class]] &&
            [sender isKindOfClass:[STMPickingOrderPosition class]]) {
            
            STMPickingPositionVolumeTVC *volumeTVC = (STMPickingPositionVolumeTVC *)segue.destinationViewController;
            volumeTVC.position = (STMPickingOrderPosition *)sender;
            volumeTVC.mainVC = self;
            
        }
        
    } else if ([segue.identifier isEqualToString:@"showPickedPositions"]) {
        
        if ([segue.destinationViewController isKindOfClass:[STMPickingOrderPositionsPickedTVC class]]) {
            
            STMPickingOrderPositionsPickedTVC *pickedPositionsTVC = (STMPickingOrderPositionsPickedTVC *)segue.destinationViewController;
            pickedPositionsTVC.pickingOrder = self.pickingOrder;
            
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
    [self performSegueWithIdentifier:@"showPickedPositions" sender:nil];
}

- (void)updatePickedPositionsButton {
    
    NSSet *pickedPositions = [self.pickingOrder.pickingOrderPositions valueForKeyPath:@"@distinctUnionOfSets.pickingOrderPositionsPicked"];
    
    self.pickedPositionsButton.enabled = (pickedPositions.count > 0);
    self.pickedPositionsButton.title = [NSString stringWithFormat:@"%@ (%@)", NSLocalizedString(@"PICKED POSITIONS", nil), @(pickedPositions.count).stringValue];
    
}

- (void)updateToolbars {
    
    BOOL orderIsProcessed = [self orderIsProcessed];
    
    self.navigationItem.hidesBackButton = orderIsProcessed;
    self.navigationController.toolbarHidden =  !orderIsProcessed;
    
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
    
    if ([STMBarCodeScanner isCameraAvailable]) {
    
        self.cameraBarCodeScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerCameraMode];
        self.cameraBarCodeScanner.delegate = self;

        STMBarButtonItem *cameraButton = [[STMBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                        target:self
                                                                                        action:@selector(cameraBarCodeScannerButtonPressed)];
        
        self.navigationItem.leftBarButtonItem = cameraButton;
        
    }
    
    self.HIDBarCodeScanner = [[STMBarCodeScanner alloc] initWithMode:STMBarCodeScannerHIDKeyboardMode];
    self.HIDBarCodeScanner.delegate = self;
    [self.HIDBarCodeScanner startScan];

}

- (void)stopBarcodeScanning {
    
    [self.cameraBarCodeScanner stopScan];
    self.cameraBarCodeScanner = nil;
    self.navigationItem.leftBarButtonItem = nil;
    
    [self.HIDBarCodeScanner stopScan];
    self.HIDBarCodeScanner = nil;
    
}

- (void)cameraBarCodeScannerButtonPressed {
    NSLogMethodName;
}


#pragma mark - STMBarCodeScannerDelegate

- (UIView *)viewForScanner:(STMBarCodeScanner *)scanner {
    return self.view;
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveBarCode:(NSString *)barcode {
    
    NSLog(@"barCodeScanner receiveBarCode: %@", barcode);
    
//    if (scanner == self.cameraBarCodeScanner) {
//        [self.HIDBarCodeScanner startScan];
//    }

    [self searchBarCode:barcode];
    
}

- (void)barCodeScanner:(STMBarCodeScanner *)scanner receiveError:(NSError *)error {
    NSLog(@"barCodeScanner receiveError: %@", error.localizedDescription);
}

- (void)searchBarCode:(NSString *)barcode {
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMArticle class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"ANY barcodes.barcode == %@", barcode];
    
    NSArray *articlesArray = [[[STMSessionManager sharedManager].currentSession document].managedObjectContext executeFetchRequest:request error:nil];
    
    if (articlesArray.count > 1) {
        NSLog(@"articlesArray.count > 1");
    }
    
    STMArticle *article = articlesArray.firstObject;
    
    if (article) {
        
    } else {
        
    }
    
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
