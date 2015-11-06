//
//  STMBarCodeScanVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMBarCodeScanVC.h"

#import "STMSessionManager.h"
#import "STMDataModel.h"
#import "STMNS.h"


@interface STMBarCodeScanVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *barcodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *articleVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *articlePriceLabel;

@property (nonatomic, strong) UITextField *hiddenBarCodeTextField;


@end


@implementation STMBarCodeScanVC

- (void)searchBarCode:(NSString *)barcode {
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMBarCode class])];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"barcode" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"barcode == %@", barcode];
    
    NSArray *barcodesArray = [[[STMSessionManager sharedManager].currentSession document].managedObjectContext executeFetchRequest:request error:nil];
    
    STMBarCode *barcodeObject = barcodesArray.firstObject;
    
    self.articleNameLabel.text = barcodeObject.article.name;
    self.articleVolumeLabel.text = barcodeObject.article.pieceVolume.stringValue;
    self.articlePriceLabel.text = [(STMPrice *)barcodeObject.article.prices.allObjects.firstObject price].stringValue;
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    self.barcodeLabel.text = textField.text;
    [self searchBarCode:textField.text];
    textField.text = @"";
    return NO;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.hiddenBarCodeTextField = [[UITextField alloc] init];
    [self.hiddenBarCodeTextField becomeFirstResponder];
    self.hiddenBarCodeTextField.delegate = self;
    
    [self.view addSubview:self.hiddenBarCodeTextField];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
