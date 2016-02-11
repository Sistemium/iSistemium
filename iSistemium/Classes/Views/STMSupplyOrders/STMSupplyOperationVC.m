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


@interface STMSupplyOperationVC () <STMVolumePickerOwner>

@property (weak, nonatomic) IBOutlet UILabel *articleLabel;
@property (weak, nonatomic) IBOutlet STMVolumePicker *volumePicker;
@property (weak, nonatomic) IBOutlet UIView *barcodesTableContainer;
@property (weak, nonatomic) IBOutlet UILabel *expectedNumberOfBatchesLabel;

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
    [self updateRepeatButtonTitle];

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


#pragma mark - STMVolumePickerOwner

- (void)volumeSelected {
    
    NSInteger selectedVolume = self.volumePicker.selectedVolume;
    NSInteger remainingVolume = [self.supplyOrderArticleDoc volumeRemainingToSupply];
    
    BOOL volumeIsGoodForRepeating = (selectedVolume > 0);
        
    self.doneButton.enabled = volumeIsGoodForRepeating;

    if (selectedVolume > remainingVolume / 2) {
        volumeIsGoodForRepeating = NO;
    }
    
    self.repeatButton.enabled = volumeIsGoodForRepeating;
    
    if (selectedVolume > 0) {
        
        NSInteger expectedNumberOfBatches = remainingVolume / selectedVolume;
        
        NSString *pluralType = [STMFunctions pluralTypeForCount:expectedNumberOfBatches];
        NSString *pluralString = [pluralType stringByAppendingString:@"BATCHES"];
        
        NSString *expectedNumberOfBatchesLabelText = [NSString stringWithFormat:@"%@ %@", @(expectedNumberOfBatches), NSLocalizedString(pluralString, nil)];

        NSInteger remainder = remainingVolume % selectedVolume;
        
        if (remainder > 0) {
            
            expectedNumberOfBatchesLabelText = [expectedNumberOfBatchesLabelText stringByAppendingString:@" + "];
            
            NSString *remainderString = [STMFunctions volumeStringWithVolume:remainder
                                                               andPackageRel:[self.supplyOrderArticleDoc operatingArticle].packageRel.integerValue];

            expectedNumberOfBatchesLabelText = [expectedNumberOfBatchesLabelText stringByAppendingString:remainderString];
            
        }
        
        self.expectedNumberOfBatchesLabel.text = expectedNumberOfBatchesLabelText;

    } else {
        
        NSString *remainingVolumeString = [STMFunctions volumeStringWithVolume:remainingVolume
                                                        andPackageRel:[self.supplyOrderArticleDoc operatingArticle].packageRel.integerValue];

        self.expectedNumberOfBatchesLabel.text = remainingVolumeString;
        
    }
    
    [self updateRepeatButtonTitle];
    
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

- (void)updateRepeatButtonTitle {
    
    if (self.repeatButton.enabled) {
        
        NSInteger barcodesCount = self.codesTVC.stockBatchCodes.count;
        
        NSString *volumeString = [STMFunctions volumeStringWithVolume:self.volumePicker.selectedVolume
                                                        andPackageRel:[self.supplyOrderArticleDoc operatingArticle].packageRel.integerValue];
        
        NSString *pluralType = [STMFunctions pluralTypeForCount:barcodesCount];
        NSString *pluralString = [pluralType stringByAppendingString:@"CODES"];
        
        NSString *numberOfBarcodesString = nil;
        
        if (barcodesCount > 0) {
            numberOfBarcodesString = [NSString stringWithFormat:@"%@ %@", @(barcodesCount), NSLocalizedString(pluralString, nil)];
        } else {
            numberOfBarcodesString = NSLocalizedString(pluralString, nil);
        }
        
        NSString *repeatParameters = [NSString stringWithFormat:@"(%@, %@)", volumeString, numberOfBarcodesString];

        
        NSString *repeatButtonTitle = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"SUPPLY REPEAT BUTTON TITLE", nil), repeatParameters];
        self.repeatButton.title = repeatButtonTitle;

    } else {

        self.repeatButton.title = NSLocalizedString(@"SUPPLY REPEAT BUTTON TITLE", nil);

    }
    
}

- (NSString *)articleLabelForArticleDoc:(STMSupplyOrderArticleDoc *)articleDoc {
    
    NSString *articleLabel = [articleDoc operatingArticle].name;
    articleLabel = [articleLabel stringByAppendingString:@"\n"];
    
    NSString *packageRelString = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"PACKAGE REL", nil), [articleDoc operatingArticle].packageRel];
    articleLabel = [articleLabel stringByAppendingString:packageRelString];

    return articleLabel;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.volumePicker.owner = self;
    
    if (self.supplyOperation && [self.supplyOperation.sourceAgent isKindOfClass:[STMSupplyOrderArticleDoc class]]) {
        
        NSMutableArray *toolbarButtons = [self.toolbar.items mutableCopy];
        
        [toolbarButtons removeObject:self.repeatButton];
        [self.toolbar setItems:toolbarButtons animated:YES];

        self.supplyOrderArticleDoc = (STMSupplyOrderArticleDoc *)self.supplyOperation.sourceAgent;
        
        self.articleLabel.text = [self articleLabelForArticleDoc:self.supplyOrderArticleDoc];
        
        self.volumePicker.packageRel = [self.supplyOrderArticleDoc operatingArticle].packageRel.integerValue;

        self.volumePicker.volume = [self.supplyOrderArticleDoc volumeRemainingToSupply] + self.supplyOperation.volume.integerValue;
        
        self.volumePicker.selectedVolume = self.supplyOperation.volume.integerValue;

    } else if (self.supplyOrderArticleDoc) {
        
        self.articleLabel.text = [self articleLabelForArticleDoc:self.supplyOrderArticleDoc];
        
        self.volumePicker.packageRel = [self.supplyOrderArticleDoc operatingArticle].packageRel.integerValue;

        self.volumePicker.volume = [self.supplyOrderArticleDoc volumeRemainingToSupply];
        
        self.volumePicker.selectedVolume = (self.supplyOrderArticleDoc.sourceOperations.count > 0) ? [self.supplyOrderArticleDoc lastSourceOperationVolume] : 0;

        [self updateRepeatButtonTitle];

    }

    [self volumeSelected];
    
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
