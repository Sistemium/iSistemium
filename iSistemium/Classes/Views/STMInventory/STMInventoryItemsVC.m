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


@end


@implementation STMInventoryItemsVC

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if ([self isMovingToParentViewController]) {
        
        if ([self.navigationController isKindOfClass:[STMInventoryNC class]]) {
            [(STMInventoryNC *)self.navigationController setItemsVC:self];
        }
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        
        if ([self.navigationController isKindOfClass:[STMInventoryNC class]]) {
            [(STMInventoryNC *)self.navigationController setItemsVC:nil];
        }

    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
