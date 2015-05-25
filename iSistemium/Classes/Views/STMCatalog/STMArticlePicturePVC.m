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

@property (nonatomic, strong) NSMutableArray *articlesArray;

@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic) NSUInteger nextIndex;


@end

@implementation STMArticlePicturePVC

- (NSMutableArray *)articlesArray {
    
    return [self.parentVC currentArticles].mutableCopy;
    
//    if (!_articlesArray) {
//        _articlesArray = [self.parentVC currentArticles].mutableCopy;
//    }
//    return _articlesArray;
    
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

- (void)dismissView {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    UIViewController *vc = [self viewControllerAtIndex:self.currentIndex-1 storyboard:self.storyboard];
    return vc;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    UIViewController *vc = [self viewControllerAtIndex:self.currentIndex+1 storyboard:self.storyboard];
    return vc;
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    
    return self.articlesArray.count;
    
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    return self.currentIndex;
    
}


#pragma mark - Page View Controller Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    STMArticlePictureVC *pendingVC = pendingViewControllers[0];
    self.nextIndex = pendingVC.index;
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    if (completed) {
        self.currentIndex = self.nextIndex;
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
