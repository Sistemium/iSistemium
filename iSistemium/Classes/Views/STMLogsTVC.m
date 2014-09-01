//
//  STMLogsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 01/09/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMLogsTVC.h"
#import "STMSessionManager.h"

@interface STMLogsTVC ()

@end

@implementation STMLogsTVC

- (void)customInit {
    
    self.tableView.delegate = [[STMSessionManager sharedManager].currentSession logger];
    self.tableView.dataSource = [[STMSessionManager sharedManager].currentSession logger];
    
    [[[STMSessionManager sharedManager].currentSession logger] setTableView:self.tableView];

}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

@end
