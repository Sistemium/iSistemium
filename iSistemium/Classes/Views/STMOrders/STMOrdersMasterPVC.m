//
//  STMOrdersMasterPVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 07/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMOrdersMasterPVC.h"
#import "STMOrdersSVC.h"

#import "STMOrdersMasterTVC.h"
#import "STMOrdersDateTVC.h"
#import "STMOrdersOutletTVC.h"
#import "STMOrdersSalesmanTVC.h"

@interface STMOrdersMasterPVC () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic) NSUInteger nextIndex;


@end


@implementation STMOrdersMasterPVC

- (UISegmentedControl *)segmentedControl {
 
    if (!_segmentedControl) {
        
        NSArray *controlItems = @[NSLocalizedString(@"OUTLETS", nil),
                                  NSLocalizedString(@"DATES", nil),
                                  NSLocalizedString(@"SALESMANS", nil)];
        
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:controlItems];
        segmentedControl.selectedSegmentIndex = self.currentIndex;
        [segmentedControl addTarget:self action:@selector(segmentedControlValueChanged) forControlEvents:UIControlEventValueChanged];
        
        _segmentedControl = segmentedControl;
        
    }
    return _segmentedControl;
    
}

- (void)segmentedControlValueChanged {
    
    UIPageViewControllerNavigationDirection direction;
    
    if (self.segmentedControl.selectedSegmentIndex > self.currentIndex) {
        direction = UIPageViewControllerNavigationDirectionForward;
    } else {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }

    [self rewindToIndex:self.segmentedControl.selectedSegmentIndex direction:direction];
    
}

- (void)rewindToIndex:(NSUInteger)index direction:(UIPageViewControllerNavigationDirection)direction {
    
    NSUInteger nextIndex;
    
    if (direction == UIPageViewControllerNavigationDirectionForward) {
        nextIndex = self.currentIndex + 1;
    } else {
        nextIndex = self.currentIndex - 1;
    }
    
    [self setVCAtIndex:nextIndex direction:direction];

    if (nextIndex != index) {
        [self rewindToIndex:index direction:direction];
    }
    
}

- (void)setVCAtIndex:(NSUInteger)index direction:(UIPageViewControllerNavigationDirection)direction {
    
    STMOrdersMasterTVC *vc = [self viewControllerAtIndex:index storyboard:self.storyboard];
    NSArray *viewControllers = @[vc];
    [self setViewControllers:viewControllers direction:direction animated:YES completion:NULL];
    self.currentIndex = index;
    
}


- (STMOrdersMasterTVC *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    
    STMOrdersMasterTVC *vc = nil;
    
    switch (index) {
            
        case 0:
            vc = (STMOrdersMasterTVC *)[[STMOrdersOutletTVC alloc] initWithStyle:UITableViewStyleGrouped];
            break;

        case 1:
            vc = (STMOrdersMasterTVC *)[[STMOrdersDateTVC alloc] init];
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
        self.segmentedControl.selectedSegmentIndex = self.currentIndex;
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationItem.titleView = self.segmentedControl;
    
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
