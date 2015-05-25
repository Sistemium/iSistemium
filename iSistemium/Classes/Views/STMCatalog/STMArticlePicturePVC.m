//
//  STMArticlePicturePVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 25/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticlePicturePVC.h"
#import "STMArticlePictureVC.h"

@interface STMArticlePicturePVC () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *articlesArray;


@end

@implementation STMArticlePicturePVC

- (NSMutableArray *)articlesArray {
    
    if (!_articlesArray) {
        _articlesArray = [[self.parentVC currentArticles] mutableCopy];
    }
    return _articlesArray;
    
}

- (STMArticlePictureVC *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    
    if ((self.articlesArray.count == 0) || (index >= self.articlesArray.count)) {
        
        return nil;
        
    } else {
        
        STMArticlePictureVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"articlePictureVC"];
        STMArticle *article = self.articlesArray[index];
        
        vc.index = index;
        vc.article = article;
        
        return vc;
        
    }
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    self.dataSource = self;
    self.delegate = self;
    
    self.currentIndex = [self.articlesArray indexOfObject:self.currentArticle];
    
    STMArticlePictureVC *vc = [self viewControllerAtIndex:self.currentIndex storyboard:self.storyboard];
    [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
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
