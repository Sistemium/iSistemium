//
//  STMUncashingInfoVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUncashingInfoVC.h"

@interface STMUncashingInfoVC ()
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *sumLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmButton;

@end

@implementation STMUncashingInfoVC

- (IBAction)cancelButtonPressed:(id)sender {

    [self.parentVC dismissInfoPopover];
    
}

- (IBAction)confirmButtonPressed:(id)sender {
    
    [self.parentVC confirmButtonPressed];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    if (self.uncashing) {
        
        self.toolbar.hidden = YES;
        
        self.mainLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"UNCASHING DATE", nil), [dateFormatter stringFromDate:self.uncashing.date]];
        self.sumLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"UNCASHING SUM", nil), [numberFormatter stringFromNumber:self.uncashing.summ]];
        
        NSString *type = nil;
        
        if ([self.uncashing.type isEqualToString:@"bankOffice"]) {
            type = NSLocalizedString(@"BANK OFFICE", nil);
        } else if ([self.uncashing.type isEqualToString:@"cashDesk"]) {
            type = NSLocalizedString(@"CASH DESK2", nil);
        }
        
        if (type) {
            self.typeLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"UNCASHING TYPE", nil), type];
        } else {
            self.typeLabel.text = nil;
        }

        
    } else {
    
        [self.confirmButton setTitle:NSLocalizedString(@"CONFIRM", nil)];

        self.mainLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"UNCASHING", nil)];
        self.sumLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"UNCASHING SUM", nil), [numberFormatter stringFromNumber:self.sum]];
        
        NSString *type = nil;
        
        if ([self.type isEqualToString:@"bankOffice"]) {
            type = NSLocalizedString(@"BANK OFFICE", nil);
        } else if ([self.type isEqualToString:@"cashDesk"]) {
            type = NSLocalizedString(@"CASH DESK2", nil);
        }
        
        if (type) {
            self.typeLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"UNCASHING TYPE", nil), type];
        } else {
            self.typeLabel.text = nil;
        }

    }
    
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
