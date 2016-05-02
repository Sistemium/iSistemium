//
//  STMDatePickerVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 18/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMDatePickerVC.h"

@interface STMDatePickerVC ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@end

@implementation STMDatePickerVC

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)dateValueChanged:(id)sender {
    
    self.parentVC.selectedDate = self.datePicker.date;

}



- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.datePicker.date = self.selectedDate;
    _closeButton.title = NSLocalizedString(@"CLOSE", nil);
    self.navigationBar.topItem.title = NSLocalizedString(@"SELECT DATE", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
