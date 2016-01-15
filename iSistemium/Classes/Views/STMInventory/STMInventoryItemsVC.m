//
//  STMInventoryItemsVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMInventoryItemsVC.h"

#import "STMInventoryNC.h"
#import "STMInventoryInfoTVC.h"
#import "STMInventoryBatchItemsTVC.h"
#import "STMStockBatchInfoTVC.h"


@interface STMInventoryItemsVC () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *infoTVCContainer;

@property (nonatomic, strong) STMInventoryInfoTVC *infoTVC;
@property (nonatomic, strong) STMInventoryBatchItemsTVC *itemsTVC;
@property (nonatomic, weak) STMInventoryNC *inventoryNC;


@end


@implementation STMInventoryItemsVC

- (STMInventoryNC *)inventoryNC {
    
    if (!_inventoryNC) {
        
        if ([self.navigationController isKindOfClass:[STMInventoryNC class]]) {
            _inventoryNC = (STMInventoryNC *)self.navigationController;
        }

    }
    return _inventoryNC;
    
}

- (void)setProductionInfo:(NSString *)productionInfo {
    
    _productionInfo = productionInfo;
    self.infoTVC.productionInfo = _productionInfo;
    [self.infoTVC refreshInfo];
    
}

- (void)setInventoryBatch:(STMInventoryBatch *)inventoryBatch {
    
    _inventoryBatch = inventoryBatch;
    
    self.itemsTVC.batch = _inventoryBatch;
    self.infoTVC.inventoryBatch = _inventoryBatch;
    [self.infoTVC refreshInfo];
    
    if (!_inventoryBatch.isDone.boolValue) {
        [self.inventoryNC editInventoryBatch:_inventoryBatch];
    }
    
    [self updateButtons];
    
}

- (void)updateButtons {

    self.navigationController.toolbarHidden = NO;
    
    if (self.inventoryBatch.isDone.boolValue) {
        
        self.navigationItem.hidesBackButton = NO;

        STMBarButtonItemEdit *editButton = [[STMBarButtonItemEdit alloc] initWithTitle:NSLocalizedString(@"EDIT", nil)
                                                                                 style:UIBarButtonItemStyleDone
                                                                                target:self
                                                                                action:@selector(editButtonPressed)];

        [self setToolbarItems:@[[STMBarButtonItem flexibleSpace], editButton, [STMBarButtonItem flexibleSpace]]];

    } else {

        self.navigationItem.hidesBackButton = YES;
        
        STMBarButtonItemDelete *deleteButton = [[STMBarButtonItemDelete alloc] initWithTitle:NSLocalizedString(@"DELETE", nil)
                                                                                       style:UIBarButtonItemStyleDone
                                                                                      target:self
                                                                                      action:@selector(deleteButtonPressed)];

        STMBarButtonItemDone *doneButton = [[STMBarButtonItemDone alloc] initWithTitle:NSLocalizedString(@"DONE", nil)
                                                                                 style:UIBarButtonItemStyleDone
                                                                                target:self
                                                                                action:@selector(doneButtonPressed)];

        [self setToolbarItems:@[deleteButton, [STMBarButtonItem flexibleSpace], doneButton]];

    }

}

- (void)cancelButtonPressed {
    
    [self.inventoryNC cancelCurrentInventoryProcessing];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)editButtonPressed {
    
    [self.inventoryNC editInventoryBatch:self.inventoryBatch];
    [self updateButtons];
    
    [self.infoTVC refreshInfo];

}

- (void)deleteButtonPressed {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"DELETE INVENTORY BATCH?", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alert.tag = 342;
        
        [alert show];
        
    }];

}

- (void)doneButtonPressed {

    [self.inventoryNC doneCurrentInventoryProcessing];
    [self.navigationController popViewControllerAnimated:YES];

}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    switch (alertView.tag) {
        case 342:

            switch (buttonIndex) {
                case 1:
                    
                    [self.inventoryNC deleteInventoryBatch:self.inventoryBatch];
                    [self.navigationController popToRootViewControllerAnimated:YES];

                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"infoTVC"] &&
        [segue.destinationViewController isKindOfClass:[STMInventoryInfoTVC class]]) {
        
        self.infoTVC = (STMInventoryInfoTVC *)segue.destinationViewController;
        self.infoTVC.inventoryBatch = self.inventoryBatch;
        self.infoTVC.productionInfo = self.productionInfo;
        self.infoTVC.parentVC = self;

    } else if ([segue.identifier isEqualToString:@"itemsTVC"] &&
               [segue.destinationViewController isKindOfClass:[STMInventoryBatchItemsTVC class]]) {
        
        self.itemsTVC = (STMInventoryBatchItemsTVC *)segue.destinationViewController;
        self.itemsTVC.batch = self.inventoryBatch;
        self.itemsTVC.parentVC = self;
        
    } else if ([segue.identifier isEqualToString:@"showStockBatchInfo"] &&
               [segue.destinationViewController isKindOfClass:[STMStockBatchInfoTVC class]]) {
        
        STMStockBatchInfoTVC *stockBatchInfoTVC = (STMStockBatchInfoTVC *)segue.destinationViewController;
        stockBatchInfoTVC.stockBatch = self.inventoryBatch.stockBatch;
        stockBatchInfoTVC.parentVC = self;
        
    }
    
}

- (void)showStockBatchInfo {
    [self performSegueWithIdentifier:@"showStockBatchInfo" sender:nil];
}

- (void)updateStockBatchInfo {
    
    self.inventoryBatch.article = self.inventoryBatch.stockBatch.article;
    self.infoTVC.productionInfo = [self.inventoryBatch.stockBatch displayProductionInfo];
    [self.infoTVC refreshInfo];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [self updateButtons];
    
    if (!self.inventoryBatch.isDone.boolValue) {
        [self.inventoryNC editInventoryBatch:self.inventoryBatch];
    }

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.navigationController.toolbarHidden = NO;

    if ([self isMovingToParentViewController]) {
        self.inventoryNC.itemsVC = self;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        self.inventoryNC.itemsVC = nil;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
