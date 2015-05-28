//
//  STMCatalogSettingsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCatalogSettingsTVC.h"
#import "STMCatalogParametersTVC.h"


#define VIEW_MAX_HEIGHT 512
#define VIEW_WIDTH 512


@interface STMCatalogSettingsTVCell : UITableViewCell

@end

@implementation STMCatalogSettingsTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
    
}

@end


@interface STMCatalogSettingsTVC ()

@property (nonatomic, strong) NSString *cellReuseIdentifier;

@end

@implementation STMCatalogSettingsTVC

- (instancetype)initWithSettings:(NSArray *)settings {
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.settings = settings;
    }
    return self;
    
}

- (NSString *)cellReuseIdentifier {
    
    if (!_cellReuseIdentifier) {
        _cellReuseIdentifier = @"catalogSettingsTVCell";
    }
    return _cellReuseIdentifier;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settings.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"SETTINGS", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier forIndexPath:indexPath];

    NSDictionary *setting = self.settings[indexPath.row];
    NSUInteger currentParameterIndex = [setting[@"current"] integerValue];
    NSArray *availableParameters = setting[@"available"];
    
    cell.textLabel.text = setting[@"name"];
    cell.detailTextLabel.text = availableParameters[currentParameterIndex];
    
    cell.accessoryType = (availableParameters.count > 1) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCatalogParametersTVC *parametersTVC = [[STMCatalogParametersTVC alloc] initWithStyle:UITableViewStyleGrouped];
    parametersTVC.parameters =self.settings[indexPath.row];
    
    [self.navigationController pushViewController:parametersTVC animated:YES];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [self.tableView registerClass:[STMCatalogSettingsTVCell class] forCellReuseIdentifier:self.cellReuseIdentifier];
    
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    
    CGFloat height = MIN(VIEW_MAX_HEIGHT, self.tableView.contentSize.height);
    self.tableView.frame = CGRectMake(0, 0, VIEW_WIDTH, height);

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
