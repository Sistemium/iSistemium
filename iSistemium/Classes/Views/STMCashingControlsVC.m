//
//  STMCashingControlsVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMCashingControlsVC.h"
#import "STMDebtsCombineVC.h"
#import "STMConstants.h"

@interface STMCashingControlsVC ()

@property (nonatomic, strong) STMDebtsCombineVC *parentVC;

@property (weak, nonatomic) IBOutlet UIView *controlsView;
@property (weak, nonatomic) IBOutlet UIButton *cashingButton;

@end

@implementation STMCashingControlsVC


- (STMDebtsCombineVC *)parentVC {
    
    return (STMDebtsCombineVC *)self.parentViewController;
    
}

- (void)setOutlet:(STMOutlet *)outlet {
    
    if (_outlet != outlet) {
        
        _outlet = outlet;
        
        if (_outlet) {
            [self showControls];
        }
        
    }
    
}

/*
- (UIButton *)cashingButton {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    NSString *title = NSLocalizedString(@"CASHING", nil);
    UIFont *font = [UIFont boldSystemFontOfSize:24];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:ACTIVE_BLUE_COLOR forState:UIControlStateNormal];
    button.titleLabel.font = font;
    
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGSize size = [title sizeWithAttributes:attributes];
    
    CGFloat x = self.controlsView.center.x - size.width / 2;
    CGFloat y = self.controlsView.center.y - size.height / 2;
    
    button.frame = CGRectMake(x, y, size.width, size.height);
    
    [button addTarget:self action:@selector(cashingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
    
}
*/

- (IBAction)cashingButtonPressed:(id)sender {

    NSLog(@"cashingButtonPressed");

}

- (void)hideControls {
    
    self.controlsView.hidden = YES;
    
}

- (void)showControls {
    
    self.controlsView.hidden = NO;
//    [self showCashingButton];
    
}

/*
- (void)showCashingButton {
    
    [self.controlsView addSubview:self.cashingButton];
    
}
*/

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    if (!self.outlet) {
        [self hideControls];
    }
    
    [self.cashingButton setTitle:NSLocalizedString(@"CASHING", nil) forState:UIControlStateNormal];
    
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
