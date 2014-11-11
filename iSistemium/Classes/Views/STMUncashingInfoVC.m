//
//  STMUncashingInfoVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUncashingInfoVC.h"
#import "STMUncashingPicture.h"

@interface STMUncashingInfoVC ()
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *sumLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmButton;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;

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
    
    NSDecimalNumber *sum = nil;
    NSString *type = nil;
    NSString *comment = nil;
    UIImage *image = nil;
    
    if (self.uncashing) {
        
        self.toolbar.hidden = YES;
        
        self.mainLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"UNCASHING DATE", nil), [dateFormatter stringFromDate:self.uncashing.date]];
        
        sum = self.uncashing.summ;
        type = self.uncashing.type;
        comment = self.uncashing.commentText;
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCTS" ascending:YES];
        
        STMUncashingPicture *picture = [[self.uncashing.pictures sortedArrayUsingDescriptors:@[sortDescriptor]] lastObject];
        
        image = [UIImage imageWithData:picture.imageThumbnail];
        
    } else {
    
        [self.confirmButton setTitle:NSLocalizedString(@"CONFIRM", nil)];

        self.mainLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"UNCASHING", nil)];
        
        sum = self.sum;
        type = self.type;
        comment = self.comment;
        image = self.image;

    }
    
    self.sumLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"UNCASHING SUM", nil), [numberFormatter stringFromNumber:sum]];
    
    if ([type isEqualToString:@"bankOffice"]) {
        
        type = NSLocalizedString(@"BANK OFFICE", nil);
        
    } else if ([type isEqualToString:@"cashDesk"]) {
        
        type = NSLocalizedString(@"CASH DESK2", nil);
        
    }
    
    if (type) {
        
        self.typeLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"UNCASHING TYPE", nil), type];
        
    } else {
        
        self.typeLabel.text = nil;
        
    }

    self.commentTextView.text = comment;
    
    self.imageView.image = image;

//    NSLog(@"self.uncashing %@", self.uncashing);
    
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
