//
//  STMUncashingInfoVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/11/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUncashingInfoVC.h"
#import "STMUncashingPicture.h"
#import "STMUncashingPhotoVC.h"

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
    if (_parentVC){
        [self.parentVC dismissInfoPopover];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (IBAction)confirmButtonPressed:(id)sender {
    
    [self.parentVC confirmButtonPressed];
    
}

- (void)imageViewTapped {

    STMUncashingPhotoVC *photoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"uncashingPhotoVC"];
    
    if (self.uncashing) {
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES];
        photoVC.picture = [[self.uncashing.pictures sortedArrayUsingDescriptors:@[sortDescriptor]] lastObject];
        
    } else {
        
        photoVC.image = self.image;
        photoVC.handOverController = self.parentVC;
        
    }
    
    [self presentViewController:photoVC animated:YES completion:^{
        
    }];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
    
    NSDecimalNumber *sum = nil;
    NSString *type = nil;
    NSString *comment = nil;
    UIImage *image = nil;
    NSString *placeName = nil;
    
    if (self.uncashing) {
        
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLOSE", nil)
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(cancelButtonPressed:)];
        self.toolbar.items = @[flexibleItem,closeButton,flexibleItem];
        
        self.mainLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"UNCASHING DATE", nil), [dateFormatter stringFromDate:(NSDate * _Nonnull)self.uncashing.date]];
        
        sum = self.uncashing.summ;
        type = self.uncashing.type;
        comment = self.uncashing.commentText;
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES];
        
        STMUncashingPicture *picture = [[self.uncashing.pictures sortedArrayUsingDescriptors:@[sortDescriptor]] lastObject];
        
        image = [UIImage imageWithData:(NSData * _Nonnull)picture.imageThumbnail];
        
        placeName = self.uncashing.uncashingPlace.name;
        
    } else {
    
        [self.confirmButton setTitle:NSLocalizedString(@"CONFIRM", nil)];

        self.mainLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"UNCASHING", nil)];
        
        sum = self.sum;
        type = self.type;
        comment = self.comment;
        image = self.image;
        placeName = self.place.name;

    }
    
    self.sumLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"UNCASHING SUM", nil), [numberFormatter stringFromNumber:sum]];
    
    if ([type isEqualToString:BANK_OFFICE_TYPE]) {
        
        type = NSLocalizedString(@"BANK OFFICE", nil);
        placeName = nil;
        
    } else if ([type isEqualToString:CASH_DESK_TYPE]) {
        
        type = NSLocalizedString(@"CASH DESK2", nil);
        image = nil;
        
    }
    
    if (type) {
        
        self.typeLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"UNCASHING TYPE", nil), type];
        
        if (placeName) {
            
            self.typeLabel.text = [self.typeLabel.text stringByAppendingString:[NSString stringWithFormat:@" %@", placeName]];
            
        }
        
    } else {
        
        self.typeLabel.text = nil;
        
    }

    self.commentTextView.text = comment;
    
    self.imageView.image = image;
    
    if (image) {
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped)];
        [self.imageView addGestureRecognizer:tap];

    }
    
//    NSLog(@"self.uncashing %@", self.uncashing);
    
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
