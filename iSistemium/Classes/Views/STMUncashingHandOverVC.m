//
//  STMUncashingHandOverVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/10/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUncashingHandOverVC.h"
#import "STMCashing.h"

@interface STMUncashingHandOverVC () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *uncashingLabel;
@property (weak, nonatomic) IBOutlet UILabel *uncashingSumLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) NSDecimalNumber *uncashingSum;


@end

@implementation STMUncashingHandOverVC

- (IBAction)doneButtonPressed:(id)sender {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HAND OVER BUTTON", nil) message:[numberFormatter stringFromNumber:self.uncashingSum] delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    alert.tag = 1;
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        
        if (buttonIndex == 1) {

            [self.splitVC.detailVC uncashingDoneWithSum:self.uncashingSum];
            
        } else {
            
        }
        
    }
    
}

- (void)handOverProcessingChanged:(NSNotification *)notification {
    
    if (!self.splitVC.isUncashingHandOverProcessing) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}

- (void)cashingDictionaryChanged {
    
    NSDecimalNumber *uncashingSum = [NSDecimalNumber zero];
    
    for (STMCashing *cashing in [self.splitVC.detailVC.cashingDictionary allValues]) {
        
        uncashingSum = [uncashingSum decimalNumberByAdding:cashing.summ];
        
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    self.uncashingSumLabel.text = [numberFormatter stringFromNumber:uncashingSum];
    
    self.uncashingSum = uncashingSum;
    
    if ([self.uncashingSum intValue] <= 0) {
        self.doneButton.enabled = NO;
    } else {
        self.doneButton.enabled = YES;
    }
    
}


#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handOverProcessingChanged:) name:@"handOverProcessingChanged" object:self.splitVC];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cashingDictionaryChanged) name:@"cashingDictionaryChanged" object:self.splitVC.detailVC];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)labelsInit {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    
    self.dateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    
    self.uncashingLabel.text = NSLocalizedString(@"CASHING SUMM", nil);

    [self cashingDictionaryChanged];
    
    [self.doneButton setTitle:NSLocalizedString(@"DONE", nil) forState:UIControlStateNormal];
    
}

- (void)customInit {

    [self addObservers];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [self labelsInit];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];
    
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
