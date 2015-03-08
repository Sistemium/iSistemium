//
//  STMOrderInfoTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 08/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrderInfoTVC.h"
#import "STMOrderInfoNC.h"

@interface STMOrderInfoTVC ()

@property (nonatomic, weak) STMOrderInfoNC *parentNC;


@end


@implementation STMOrderInfoTVC

- (STMOrderInfoNC *)parentNC {
    
    if (!_parentNC) {
        
        if ([self.navigationController isKindOfClass:[STMOrderInfoNC class]]) {
            _parentNC = (STMOrderInfoNC *)self.navigationController;
        }
        
    }
    return _parentNC;
    
}


- (void)cancelButtonPressed {
    [self.parentNC cancelButtonPressed];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section) {
        case 0:
            return 3;
            break;
            
        case 1:
            return 5;
            break;
            
        default:
            return 0;
            break;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return NSLocalizedString(@"ORDER INFO", nil);
            break;
            
        case 1:
            return NSLocalizedString(@"ORDER POSITIONS", nil);
            break;
            
        default:
            return @"";
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"orderInfoCell";
    
    STMUIInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return cell;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];

    [self setToolbarItems:@[flexibleSpace, cancelButton]];

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
