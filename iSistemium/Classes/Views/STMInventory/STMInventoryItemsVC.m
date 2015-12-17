//
//  STMInventoryItemsVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMInventoryItemsVC.h"

#import "STMInventoryNC.h"
#import "STMInventoryArticleVC.h"
#import "STMInventoryBatchItemsTVC.h"


@interface STMInventoryItemsVC () <UIAlertViewDelegate>

@property (nonatomic, strong) STMInventoryArticleVC *articleVC;
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

//- (void)setInventoryArticle:(STMArticle *)inventoryArticle {
//    
//    _inventoryArticle = inventoryArticle;
//    self.articleVC.article = _inventoryArticle;
//
//}

- (void)setProductionInfo:(NSString *)productionInfo {
    
    _productionInfo = productionInfo;
    self.articleVC.productionInfo = _productionInfo;
    
}

- (void)setInventoryBatch:(STMInventoryBatch *)inventoryBatch {
    
    _inventoryBatch = inventoryBatch;
    
    self.itemsTVC.batch = _inventoryBatch;
    self.articleVC.article = [_inventoryBatch operatingArticle];
    
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
    
    if ([segue.identifier isEqualToString:@"articleVC"] &&
        [segue.destinationViewController isKindOfClass:[STMInventoryArticleVC class]]) {
        
        self.articleVC = (STMInventoryArticleVC *)segue.destinationViewController;
        self.articleVC.article = [self.inventoryBatch operatingArticle];
        self.articleVC.productionInfo = self.productionInfo;
        self.articleVC.parentVC = self;
        
    } else if ([segue.identifier isEqualToString:@"itemsTVC"] &&
               [segue.destinationViewController isKindOfClass:[STMInventoryBatchItemsTVC class]]) {
        
        self.itemsTVC = (STMInventoryBatchItemsTVC *)segue.destinationViewController;
        self.itemsTVC.batch = self.inventoryBatch;
        self.itemsTVC.parentVC = self;
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    [self updateButtons];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
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
