//
//  STMPositionVolumesVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 29/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMPositionVolumesVC.h"
#import "STMUI.h"

@interface STMPositionVolumesVC ()


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) STMBarButtonItemCancel *cancelButton;
@property (nonatomic, strong) STMBarButtonItemDone *doneButton;


@end


@implementation STMPositionVolumesVC

- (void)setupToolbar {
    
    self.cancelButton = [[STMBarButtonItemCancel alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self
                                                                             action:@selector(cancelButtonPressed:)];
    
    self.doneButton = [[STMBarButtonItemDone alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                         target:self
                                                                         action:@selector(doneButtonPressed:)];
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
    
    self.toolbar.items = @[self.cancelButton, flexibleSpace, self.doneButton];
    
}

- (void)cancelButtonPressed:(id)sender {
    [self dismissSelf];
}

- (void)doneButtonPressed:(id)sender {
    [self dismissSelf];
}

- (void)dismissSelf {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationController.navigationBarHidden = YES;

    [self setupToolbar];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
