//
//  STMCashingControlsVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCashingControlsVC.h"
#import "STMDebtsCombineVC.h"

@interface STMCashingControlsVC ()

@property (nonatomic, strong) STMDebtsCombineVC *parentVC;

@property (weak, nonatomic) IBOutlet UIView *controlsView;

@property (nonatomic, strong) UIButton *takeCashingButton;

@end

@implementation STMCashingControlsVC


- (STMDebtsCombineVC *)parentVC {
    
    return (STMDebtsCombineVC *)self.parentViewController;
    
}

- (void)setOutlet:(STMOutlet *)outlet {
    
    if (_outlet != outlet) {
        
        _outlet = outlet;
        
    }
    
}

- (UIButton *)takeCashingButton {
    
    if (!_takeCashingButton) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"NDNDNDNDNDNDNND" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.frame = self.view.frame;
        
        NSLog(@"button %@", button);
        
        _takeCashingButton = button;
        
    }
    
    return _takeCashingButton;
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    self.controlsView.hidden = NO;

    NSLog(@"self.takeCashingButton %@", self.takeCashingButton);
    
    [self.controlsView addSubview:self.takeCashingButton];
    
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
