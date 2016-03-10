//
//  STMArticleCodesTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 26/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticleCodesTVC.h"

#import "STMArticlesSVC.h"
#import "STMArticlesNC.h"

#import "STMObjectsController.h"
#import "STMBarCodeController.h"


@interface STMArticleCodesTVC () <UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) STMArticleBarCode *barcodeToRemove;

@property (nonatomic, weak) STMArticlesSVC *splitVC;
@property (nonatomic, weak) STMArticlesNC *articlesNC;


@end


@implementation STMArticleCodesTVC

@synthesize selectedArticle = _selectedArticle;


- (STMArticlesSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMArticlesSVC class]]) {
            _splitVC = (STMArticlesSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

- (STMArticlesNC *)articlesNC {
    
    if (!_articlesNC) {
        
        if ([self.navigationController isKindOfClass:[STMArticlesNC class]]) {
            _articlesNC = (STMArticlesNC *)self.navigationController;
        }
        
    }
    return _articlesNC;
}

- (STMArticle *)selectedArticle {
    
    if (IPAD) {
        return self.splitVC.selectedArticle;
    }
    if (IPHONE) {
        return self.articlesNC.selectedArticle;
    }
    
    return nil;
    
}

- (void)setSelectedArticle:(STMArticle *)selectedArticle {

//    if (IPAD) {
//        self.splitVC.selectedArticle = selectedArticle;
//    }
//    
//    if (IPHONE) {
//        self.articlesNC.selectedArticle = selectedArticle;
//    }
    
    [self performFetch];
    
}

- (NSArray *)tableData {
    
    if (!_tableData) {

        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"code"
                                                                         ascending:YES
                                                                          selector:@selector(caseInsensitiveCompare:)];
        
        _tableData = [self.selectedArticle.barCodes sortedArrayUsingDescriptors:@[sortDescriptor]];
        
    }
    return _tableData;
    
}

- (void)performFetch {
    
    self.tableData = nil;
    
    [self.tableView reloadData];
    
}


#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (IPHONE) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (IPHONE) {
        
        switch (section) {
            case 0:
                return 1;
                break;
                
            case 1:
                return self.tableData.count;
                break;
                
            default:
                return 0;
                break;
        }
        
    } else {

        return self.tableData.count;

    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewSubtitleStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];

    cell.textLabel.numberOfLines = 0;

    if (IPHONE) {
        
        switch (indexPath.section) {
            case 0:
                cell.textLabel.text = self.selectedArticle.name;
                break;
                
            case 1: {
                STMArticleBarCode *barcode = self.tableData[indexPath.row];
                cell.textLabel.text = barcode.code;
            }
                break;
                
            default:
                break;
        }
        
    } else {
    
        STMArticleBarCode *barcode = self.tableData[indexPath.row];
        cell.textLabel.text = barcode.code;

    }
    
    return cell;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (IPHONE && indexPath.section == 0) ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.barcodeToRemove = self.tableData[indexPath.row];
        [self showRemoveBarcodeAlert];
        
    }
    
}


- (void)showRemoveBarcodeAlert {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
       
        NSString *alertMessage = [NSString stringWithFormat:NSLocalizedString(@"REMOVE BARCODE FROM ARTICLE?", nil), self.barcodeToRemove.code, self.selectedArticle.name];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:alertMessage
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"CANCEL", nil)
                                              otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alert.tag = 678;
        [alert show];
        
    }];
    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {

    switch (alertView.tag) {
        case 678:
            
            switch (buttonIndex) {
                case 1:
                    [STMObjectsController createRecordStatusAndRemoveObject:self.barcodeToRemove];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case 678:
            
            switch (buttonIndex) {
                case 1: {
                    
                    [self performFetch];

                    if (IPAD) {
                        self.selectedArticle = nil;
                    }

                }
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
