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


#pragma mark - view lifecycle

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
