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


@interface STMInventoryItemsVC ()

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

- (void)setInventoryArticle:(STMArticle *)inventoryArticle {
    
    _inventoryArticle = inventoryArticle;
    self.articleVC.article = _inventoryArticle;

}

- (void)setProductionInfo:(NSString *)productionInfo {
    
    _productionInfo = productionInfo;
    self.articleVC.productionInfo = _productionInfo;
    
}

- (void)setInventoryBatch:(STMInventoryBatch *)inventoryBatch {
    
    _inventoryBatch = inventoryBatch;
    self.itemsTVC.batch = _inventoryBatch;
    
    [self updateButtons];
    
}

- (void)updateButtons {
 
    (!_inventoryBatch || [self.inventoryNC.currentlyProcessedBatch isEqual:_inventoryBatch]) ? [self showButtonsForProcessing] : [self hideButtonsForProcessing];

}

- (void)showButtonsForProcessing {

    self.navigationItem.hidesBackButton = YES;
    self.navigationController.toolbarHidden = NO;

    if (self.inventoryBatch) {

        STMBarButtonItemDone *doneButton = [[STMBarButtonItemDone alloc] initWithTitle:NSLocalizedString(@"DONE", nil)
                                                                                 style:UIBarButtonItemStyleDone
                                                                                target:self
                                                                                action:@selector(doneButtonPressed)];

        [self setToolbarItems:@[[STMBarButtonItem flexibleSpace], doneButton, [STMBarButtonItem flexibleSpace]]];

    } else {
    
        STMBarButtonItemCancel *cancelButton = [[STMBarButtonItemCancel alloc] initWithTitle:NSLocalizedString(@"CANCEL", nil)
                                                                                       style:UIBarButtonItemStylePlain
                                                                                      target:self
                                                                                      action:@selector(cancelButtonPressed)];
        
        [self setToolbarItems:@[[STMBarButtonItem flexibleSpace], cancelButton, [STMBarButtonItem flexibleSpace]]];

    }
    
}

- (void)hideButtonsForProcessing {

    [self setToolbarItems:nil];
    self.navigationController.toolbarHidden = YES;
    self.navigationItem.hidesBackButton = NO;

}

- (void)cancelButtonPressed {
    
    [self.inventoryNC cancelCurrentInventoryProcessing];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)doneButtonPressed {

    [self.inventoryNC doneCurrentInventoryProcessing];
    [self.navigationController popViewControllerAnimated:YES];

}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"articleVC"] &&
        [segue.destinationViewController isKindOfClass:[STMInventoryArticleVC class]]) {
        
        self.articleVC = (STMInventoryArticleVC *)segue.destinationViewController;
        self.articleVC.article = self.inventoryArticle;
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
