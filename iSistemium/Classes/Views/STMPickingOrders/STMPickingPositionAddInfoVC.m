//
//  STMPickingPositionAddInfoVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 20/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingPositionAddInfoVC.h"

#import "STMObjectsController.h"
#import "STMFunctions.h"


@interface STMPickingPositionAddInfoVC ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;


@end


@implementation STMPickingPositionAddInfoVC

- (IBAction)doneButtonPressed:(id)sender {
    
    if (![self.infoType.datatype isEqualToString:@"date"]) {
        
        if ([self isCorrectTextFieldValue]) {
            
            [self saveProductionInfo:self.textField.text];
            
        }
        
    } else {
        
        NSString *info = [[STMFunctions dateNumbersFormatter] stringFromDate:self.datePicker.date];
        [self saveProductionInfo:info];
        
    }
    
}

- (BOOL)isCorrectTextFieldValue {
    return YES;
}

- (void)saveProductionInfo:(NSString *)info {
    
    STMArticleProductionInfo *productionInfo = (STMArticleProductionInfo *)[STMObjectsController newObjectForEntityName:NSStringFromClass([STMArticleProductionInfo class]) isFantom:NO];
    
    productionInfo.info = info;
    productionInfo.article = self.position.article;
    productionInfo.productionInfoType = self.infoType;
    
    self.parentVC.selectedProductionInfo = productionInfo;
    
    [self.navigationController popViewControllerAnimated:YES];

}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self.doneButton setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
    [self.doneButton setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateDisabled];
    
    self.datePicker.maximumDate = [NSDate date];
    
    if (![self.infoType.datatype isEqualToString:@"date"]) {
        
        self.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        [self.textField becomeFirstResponder];
        
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
