//
//  STMArticleCodesTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 26/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticleCodesTVC.h"

#import "STMArticlesSVC.h"

#import "STMObjectsController.h"
#import "STMBarCodeController.h"


@interface STMArticleCodesTVC () <UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) STMBarCode *barcodeToRemove;

@property (nonatomic, weak) STMArticlesSVC *splitVC;


@end


@implementation STMArticleCodesTVC

- (STMArticlesSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMArticlesSVC class]]) {
            _splitVC = (STMArticlesSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

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

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.barcodeToRemove = self.tableData[indexPath.row];
        [self showRemoveBarcodeAlert];
        
    }
    
}


- (void)showRemoveBarcodeAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       
        NSString *alertMessage = [NSString stringWithFormat:NSLocalizedString(@"REMOVE BARCODE FROM ARTICLE?", nil), self.barcodeToRemove.code, self.article.name];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:alertMessage
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alert.tag = 678;
        [alert show];
        
    }];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case 678:
            
            switch (buttonIndex) {
                case 1:

                    self.splitVC.selectedArticle = nil;
                    
                    [STMObjectsController createRecordStatusAndRemoveObject:self.barcodeToRemove];
                    [self performFetch];
                
                    break;
                    
                default:
                    break;
            }
            
            self.barcodeToRemove = nil;

            break;
            
        default:
            break;
    }
    
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
