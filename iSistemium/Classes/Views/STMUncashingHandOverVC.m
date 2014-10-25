//
//  STMUncashingHandOverVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/10/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMUncashingHandOverVC.h"

@interface STMUncashingHandOverVC () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *uncashingLabel;
@property (weak, nonatomic) IBOutlet UILabel *uncashingSumLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;


@end

@implementation STMUncashingHandOverVC

- (IBAction)doneButtonPressed:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TEST" message:@"TEST" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
    
}

- (void)handOverProcessingChanged:(NSNotification *)notification {
    
    if (!self.splitVC.isUncashingHandOverProcessing) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}

#pragma mark - view lifecycle

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handOverProcessingChanged:) name:@"handOverProcessingChanged" object:self.splitVC];
    
}

- (void)removeObservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (void)customInit {

    [self addObservers];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
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
