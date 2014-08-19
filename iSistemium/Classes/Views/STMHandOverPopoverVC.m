//
//  STMHandOverPopoverVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/08/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMHandOverPopoverVC.h"

@interface STMHandOverPopoverVC ()

@property (weak, nonatomic) IBOutlet UITextField *uncashingSumTextField;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;


@end

@implementation STMHandOverPopoverVC

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
