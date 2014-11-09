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
    
    if (self.uncashing) {
        
        self.toolbar.hidden = YES;
        
    } else {
    
        [self.confirmButton setTitle:NSLocalizedString(@"CONFIRM", nil)];

    }
    
    self.mainLabel.text = [self.uncashing.summ stringValue];
    
        
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
