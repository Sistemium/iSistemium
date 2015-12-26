//
//  STMArticlesSVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 26/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticlesSVC.h"

#import "STMArticleCodesTVC.h"


@interface STMArticlesSVC ()

@property (nonatomic, strong) UINavigationController *detailNC;
@property (nonatomic, strong) STMArticleCodesTVC *detailTVC;


@end


@implementation STMArticlesSVC

- (UINavigationController *)detailNC {
    
    if (!_detailNC) {
        if ([self.viewControllers[1] isKindOfClass:[UINavigationController class]]) {
            _detailNC = self.viewControllers[1];
        }
    }
    return _detailNC;
    
}

- (STMArticleCodesTVC *)detailTVC {
    
    if (!_detailTVC) {
        
        UIViewController *detailVC = self.detailNC.viewControllers[0];
        
        if ([detailVC isKindOfClass:[STMArticleCodesTVC class]]) {
            _detailTVC = (STMArticleCodesTVC *)detailVC;
        }
        
    }
    return _detailTVC;
    
}

- (void)setSelectedArticle:(STMArticle *)selectedArticle {
    
    _selectedArticle = selectedArticle;
    
    self.detailTVC.article = _selectedArticle;
    
}


#pragma mark - view lifecycle

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
