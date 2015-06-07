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
@property (nonatomic) NSUInteger selectedSettingIndex;

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

- (void)updateParameters:(NSDictionary *)newParameters {

    NSMutableArray *newSettings = [self.settings mutableCopy];
    [newSettings replaceObjectAtIndex:self.selectedSettingIndex withObject:newParameters];
    
    [self.parentNC updateSettings:newSettings];
    self.settings = newSettings;
    
    [self.tableView reloadData];
    
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
    id availableParameters = setting[@"available"];
    
    cell.textLabel.text = setting[@"name"];
    
    if ([availableParameters isKindOfClass:[NSArray class]]) {
        
        NSArray *param = (NSArray *)availableParameters;
        
        if (param.count > 0) {
            
            cell.detailTextLabel.text = param[currentParameterIndex];
            cell.accessoryType = (param.count > 1) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
            
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    } else if ([availableParameters isKindOfClass:[NSString class]]) {
        
        NSString *param = (NSString *)availableParameters;
        
        if ([param isEqualToString:@"switch"]) {
            [self addSwitchToCell:cell atIndexPath:indexPath selected:currentParameterIndex];
        }
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (void)addSwitchToCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    
    UISwitch *cellSwitch = [[UISwitch alloc] init];
    cellSwitch.on = selected;
    cellSwitch.tag = indexPath.row;
    
    [cellSwitch addTarget:self action:@selector(switchWasSwitched:) forControlEvents:UIControlEventValueChanged];
    
    cell.accessoryView = cellSwitch;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id available = self.settings[indexPath.row][@"available"];
    
    if ([available isKindOfClass:[NSArray class]] && [(NSArray *)available count] > 0) {
        
        self.selectedSettingIndex = indexPath.row;
        
        STMCatalogParametersTVC *parametersTVC = [[STMCatalogParametersTVC alloc] initWithStyle:UITableViewStyleGrouped];
        parametersTVC.parameters = [self.settings[indexPath.row] mutableCopy];
        parametersTVC.settingsTVC = self;
        
        [self.navigationController pushViewController:parametersTVC animated:YES];

    }
    
}


- (void)switchWasSwitched:(id)sender {
    
    if ([sender isKindOfClass:[UISwitch class]]) {
        
        UISwitch *cellSwitch = (UISwitch *)sender;
        
        NSUInteger index = cellSwitch.tag;
        self.selectedSettingIndex = index;
        
        NSMutableDictionary *setting = [self.settings[index] mutableCopy];
        setting[@"current"] = @(cellSwitch.on);
        
        [self updateParameters:setting];
        
    }
    
}

- (void)closeButtonPressed {
    [self.parentNC dismissSelf];
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.title = NSLocalizedString(@"CATALOG SETTINGS", nil);
    self.navigationItem.rightBarButtonItem = [[STMBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLOSE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed)];
    
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
