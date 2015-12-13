//
//  STMStockBatchCodesTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 13/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMStockBatchCodesTVC.h"

@interface STMStockBatchCodesTVC ()

@property (nonatomic, strong) NSMutableArray *stockBatchCodes;


@end

@implementation STMStockBatchCodesTVC

- (NSMutableArray *)stockBatchCodes {
    
    if (!_stockBatchCodes) {
        _stockBatchCodes = @[].mutableCopy;
    }
    return _stockBatchCodes;
    
}

- (void)addStockBatchCode:(NSString *)code {
    
    if (code) {
        
        [self.stockBatchCodes addObject:@{
                                          @"ts": [NSDate date],
                                          @"code": code
                                          }];
    }
    
    NSSortDescriptor *tsDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ts" ascending:NO selector:@selector(compare:)];
    self.stockBatchCodes = [self.stockBatchCodes sortedArrayUsingDescriptors:@[tsDescriptor]].mutableCopy;
    
    [self.tableView reloadData];
    
}


#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stockBatchCodes.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return NSLocalizedString(@"STOCK BATCH CODES", nil);
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewSubtitleStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.stockBatchCodes[indexPath.row][@"code"];
    
    return cell;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
