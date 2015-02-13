//
//  STMAddEtceteraVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/02/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMAddEtceteraVC.h"
#import "STMDatePickerVC.h"

@interface STMAddEtceteraVC ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *sumLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UITextField *sumTextField;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;

@property (weak, nonatomic) IBOutlet UIToolbar *doneButton;
@property (weak, nonatomic) IBOutlet UIToolbar *cancelButton;


@end

@implementation STMAddEtceteraVC


@synthesize selectedDate = _selectedDate;

- (NSDate *)selectedDate {
    
    if (!_selectedDate) {
        
        _selectedDate = [NSDate date];
        
    }
    
    return _selectedDate;
    
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    
    if (_selectedDate != selectedDate) {
        
        _selectedDate = selectedDate;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterLongStyle;
        
        [self.dateButton setTitle:[dateFormatter stringFromDate:_selectedDate] forState:UIControlStateNormal];
        
    }
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.parentVC dismissAddCashingPopover];
}

- (IBAction)doneButtonPressed:(id)sender {
    
    [self.parentVC dismissAddCashingPopover];
    
}



#pragma mark - view lifecycle

- (void)customInit {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    
    [self.dateButton setTitle:[dateFormatter stringFromDate:self.selectedDate] forState:UIControlStateNormal];
    
    self.dateLabel.text = NSLocalizedString(@"DOC DATE", nil);
    self.numberLabel.text = NSLocalizedString(@"DOC NUMBER", nil);
    self.sumLabel.text = NSLocalizedString(@"SUM", nil);
    
    self.numberTextField.delegate = self;
    self.numberTextField.keyboardType = UIKeyboardTypeDefault;
    
    self.sumTextField.delegate = self;
    self.sumTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showDatePicker"] && [segue.destinationViewController isKindOfClass:[STMDatePickerVC class]]) {
        
        STMDatePickerVC *datePickerVC = (STMDatePickerVC *)segue.destinationViewController;
        datePickerVC.parentVC = self;
        datePickerVC.selectedDate = self.selectedDate;
        
    }
    
}


@end
