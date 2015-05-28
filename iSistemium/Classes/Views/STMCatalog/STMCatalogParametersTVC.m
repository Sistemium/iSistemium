//
//  STMCatalogParametersTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCatalogParametersTVC.h"
#import "STMConstants.h"


@interface STMCatalogParametersTVCell : UITableViewCell

@end

@implementation STMCatalogParametersTVCell

@end


@interface STMCatalogParametersTVC ()

@property (nonatomic, strong) NSString *cellReuseIdentifier;


@end

@implementation STMCatalogParametersTVC


- (NSString *)cellReuseIdentifier {
    
    if (!_cellReuseIdentifier) {
        _cellReuseIdentifier = @"catalogParametersTVCell";
    }
    return _cellReuseIdentifier;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *availableParameters = self.parameters[@"available"];
    return availableParameters.count;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.parameters[@"name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier forIndexPath:indexPath];
    
    NSArray *availableParameters = self.parameters[@"available"];
    NSUInteger selectedParameterIndex = [self.parameters[@"current"] integerValue];
    
    cell.textLabel.text = availableParameters[indexPath.row];
    
    cell.accessoryType = (selectedParameterIndex == indexPath.row) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    cell.tintColor = ACTIVE_BLUE_COLOR;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.parameters[@"current"] = @(indexPath.row);
    [self.settingsTVC updateParameters:self.parameters];
    [self.tableView reloadData];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self.tableView registerClass:[STMCatalogParametersTVCell class] forCellReuseIdentifier:self.cellReuseIdentifier];
    
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
