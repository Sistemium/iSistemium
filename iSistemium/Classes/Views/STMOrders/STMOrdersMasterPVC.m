//
//  STMOrdersMasterPVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrdersMasterPVC.h"
#import "STMOrdersSVC.h"

@interface STMOrdersMasterPVC () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic) NSUInteger nextIndex;


@end


@implementation STMOrdersMasterPVC

- (STMOrdersMasterTVC *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    
    STMOrdersMasterTVC *vc = nil;
    
    switch (index) {
            
        case 0:
            vc = (STMOrdersMasterTVC *)[[STMOrdersDateTVC alloc] init];
            break;

        case 1:
            vc = (STMOrdersMasterTVC *)[[STMOrdersOutletTVC alloc] init];
            break;
            
        case 2:
            vc = (STMOrdersMasterTVC *)[[STMOrdersSalesmanTVC alloc] init];
            break;

        default:
            break;
            
    }
    
    vc.index = index;
    
    return vc;
    
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    return [self viewControllerAtIndex:self.currentIndex-1 storyboard:self.storyboard];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    return [self viewControllerAtIndex:self.currentIndex+1 storyboard:self.storyboard];
    
}

#pragma mark - Page View Controller Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    STMOrdersMasterTVC *pendingVC = pendingViewControllers[0];
    self.nextIndex = pendingVC.index;
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    if (completed) {
        
        self.currentIndex = self.nextIndex;
//        [self refreshTitle];
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.dataSource = self;
    self.delegate = self;

    STMOrdersMasterTVC *vc = [self viewControllerAtIndex:self.currentIndex storyboard:self.storyboard];
    NSArray *viewControllers = @[vc];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
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
