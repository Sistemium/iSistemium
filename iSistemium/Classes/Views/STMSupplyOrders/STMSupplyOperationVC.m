//
//  STMSupplyOperationVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOperationVC.h"

#import "STMStockBatchCodesTVC.h"
#import "STMObjectsController.h"

#import "STMSupplyOrdersProcessController.h"


@interface STMSupplyOperationVC ()

@property (weak, nonatomic) IBOutlet UILabel *articleLabel;
@property (weak, nonatomic) IBOutlet STMVolumePicker *volumePicker;
@property (weak, nonatomic) IBOutlet UIView *barcodesTableContainer;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *repeatButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) STMStockBatchCodesTVC *codesTVC;


@end


@implementation STMSupplyOperationVC

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)repeatButtonPressed:(id)sender {
    
    [self saveData];
    self.parentTVC.repeatLastOperation = YES;
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)doneButtonPressed:(id)sender {
    
    [self saveData];
    self.parentTVC.repeatLastOperation = NO;
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)addStockBatchCode:(NSString *)code {
    [self.codesTVC addStockBatchCode:code];
}

- (void)saveData {
    
    if (self.supplyOperation) {
        
        [STMSupplyOrdersProcessController changeOperation:self.supplyOperation
                                                newVolume:self.volumePicker.selectedVolume];
        
    } else if (self.supplyOrderArticleDoc) {
    
        [STMSupplyOrdersProcessController createOperationForSupplyOrderArticleDoc:self.supplyOrderArticleDoc
                                                                        withCodes:[self.codesTVC.stockBatchCodes valueForKeyPath:@"code"]
                                                                        andVolume:self.volumePicker.selectedVolume];

    }
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"stockBatchCodes"] &&
        [segue.destinationViewController isKindOfClass:[STMStockBatchCodesTVC class]]) {
        
        self.codesTVC = (STMStockBatchCodesTVC *)segue.destinationViewController;
        
        if (self.supplyOperation && [self.supplyOperation.destinationAgent isKindOfClass:[STMStockBatch class]]) {
            
            STMStockBatch *stockBatch = (STMStockBatch *)self.supplyOperation.destinationAgent;
            
            for (STMStockBatchBarCode *barCode in stockBatch.barCodes) {
                [self.codesTVC addStockBatchCode:barCode.code];
            }
            
        } else if (self.initialBarcode) {
            
            [self.codesTVC addStockBatchCode:self.initialBarcode];

        }
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    if (self.supplyOperation && [self.supplyOperation.sourceAgent isKindOfClass:[STMSupplyOrderArticleDoc class]]) {
        
        NSMutableArray *toolbarButtons = [self.toolbar.items mutableCopy];
        
        [toolbarButtons removeObject:self.repeatButton];
        [self.toolbar setItems:toolbarButtons animated:YES];

        self.supplyOrderArticleDoc = (STMSupplyOrderArticleDoc *)self.supplyOperation.sourceAgent;
        
        self.articleLabel.text = (self.supplyOrderArticleDoc.article) ? self.supplyOrderArticleDoc.article.name : self.supplyOrderArticleDoc.articleDoc.article.name;
        
        self.volumePicker.packageRel = (self.supplyOrderArticleDoc.article) ? self.supplyOrderArticleDoc.article.packageRel.integerValue : self.supplyOrderArticleDoc.articleDoc.article.packageRel.integerValue;

        self.volumePicker.volume = [self.supplyOrderArticleDoc volumeRemainingToSupply] + self.supplyOperation.volume.integerValue;
        
        self.volumePicker.selectedVolume = self.supplyOperation.volume.integerValue;

    } else if (self.supplyOrderArticleDoc) {

        self.repeatButton.title = NSLocalizedString(@"SUPPLY REPEAT BUTTON TITLE", nil);
        
        self.articleLabel.text = (self.supplyOrderArticleDoc.article) ? self.supplyOrderArticleDoc.article.name : self.supplyOrderArticleDoc.articleDoc.article.name;
        
        self.volumePicker.packageRel = (self.supplyOrderArticleDoc.article) ? self.supplyOrderArticleDoc.article.packageRel.integerValue : self.supplyOrderArticleDoc.articleDoc.article.packageRel.integerValue;

        self.volumePicker.volume = [self.supplyOrderArticleDoc volumeRemainingToSupply];
        
        self.volumePicker.selectedVolume = (self.supplyOrderArticleDoc.sourceOperations.count > 0) ? [self.supplyOrderArticleDoc lastSourceOperationVolume] : 0;

    }
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
