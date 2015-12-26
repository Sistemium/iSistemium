//
//  STMArticleCodesTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 26/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticleCodesTVC.h"

#import "STMObjectsController.h"
#import "STMBarCodeController.h"


@interface STMArticleCodesTVC ()

@property (nonatomic, strong) NSArray *tableData;


@end


@implementation STMArticleCodesTVC

- (NSArray *)tableData {
    
    if (!_tableData) {

        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"code"
                                                                         ascending:YES
                                                                          selector:@selector(caseInsensitiveCompare:)];
        
        _tableData = [self.article.barCodes sortedArrayUsingDescriptors:@[sortDescriptor]];
        
    }
    return _tableData;
    
}

- (void)performFetch {
    
    self.tableData = nil;
    
    [self.tableView reloadData];
    
}

- (void)setArticle:(STMArticle *)article {
    
    _article = article;
    
    [self performFetch];
    
}


#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewSubtitleStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    STMBarCode *barcode = self.tableData[indexPath.row];
    
    cell.textLabel.text = barcode.code;
    
    return cell;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    
    [self performFetch];
    
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
