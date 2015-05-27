//
//  STMCatalogSettingsTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 27/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMCatalogSettingsTVC.h"

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
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(@"SETTINGS", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellReuseIdentifier forIndexPath:indexPath];

    cell.textLabel.text = @"MAIN";
    cell.detailTextLabel.text = @"DETAIL";
    
    return cell;
    
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
