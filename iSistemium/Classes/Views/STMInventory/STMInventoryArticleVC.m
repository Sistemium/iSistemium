//
//  STMInventoryArticleVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMInventoryArticleVC.h"


@interface STMInventoryArticleVC ()

@property (weak, nonatomic) IBOutlet UILabel *articleLabel;


@end


@implementation STMInventoryArticleVC

- (void)setArticle:(STMArticle *)article {
    
    _article = article;
    self.articleLabel.text = _article.name;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.articleLabel.text = self.article.name;
    
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
