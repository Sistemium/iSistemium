//
//  STMDebtsCombineVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 03/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMDebtsCombineVC.h"

@interface STMDebtsCombineVC ()

@end


@implementation STMDebtsCombineVC

@synthesize outlet = _outlet;

- (void)setOutlet:(STMOutlet *)outlet {
    
    if (_outlet != outlet) {
        
        _outlet = outlet;
        self.tableVC.outlet = self.outlet;
//        self.controlsVC.outlet = self.outlet;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString: @"tableVC"]) {
        
        self.tableVC = (STMOutletDebtsTVC *)[segue destinationViewController];
        self.tableVC.outlet = self.outlet;
        
//    } else if ([segue.identifier isEqualToString: @"controlsVC"]) {
//     
//        self.controlsVC = (STMCashingControlsVC *)[segue destinationViewController];
//        self.controlsVC.outlet = self.outlet;
//        self.controlsVC.tableVC = self.tableVC;
//        
    }
    
//    NSLog(@"self %@", self);
    
}


@end
