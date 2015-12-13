//
//  STMSupplyOperationVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMSupplyOperationVC.h"

#import "STMStockBatchCodesTVC.h"


@interface STMSupplyOperationVC ()

@property (weak, nonatomic) IBOutlet UILabel *articleLabel;
@property (weak, nonatomic) IBOutlet STMVolumePicker *volumePicker;
@property (weak, nonatomic) IBOutlet UIView *barcodesTableContainer;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) STMStockBatchCodesTVC *codesTVC;


@end


@implementation STMSupplyOperationVC

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)doneButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"stockBatchCodes"] &&
        [segue.destinationViewController isKindOfClass:[STMStockBatchCodesTVC class]]) {
        
        self.codesTVC = (STMStockBatchCodesTVC *)segue.destinationViewController;
        
        [self.codesTVC addStockBatchCode:self.initialBarcode];
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.articleLabel.text = (self.supplyOrderArticleDoc.article) ? self.supplyOrderArticleDoc.article.name : self.supplyOrderArticleDoc.articleDoc.article.name;
    
    self.volumePicker.packageRel = (self.supplyOrderArticleDoc.article) ? self.supplyOrderArticleDoc.article.packageRel.integerValue : self.supplyOrderArticleDoc.articleDoc.article.packageRel.integerValue;

    self.volumePicker.volume = self.supplyOrderArticleDoc.volume.integerValue;
    self.volumePicker.selectedVolume = self.supplyOrderArticleDoc.volume.integerValue;
    
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
