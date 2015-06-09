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

@property (nonatomic, weak) STMOrdersSVC *splitVC;
@property (nonatomic, strong) STMOrdersOutletTVC *outletTVC;
@property (nonatomic, strong) STMOrdersDateTVC *dateTVC;
@property (nonatomic, strong) STMOrdersSalesmanTVC *salesmanTVC;

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic) NSUInteger nextIndex;

@property (nonatomic, strong) UIBarButtonItem *resetFilterButton;

@end


@implementation STMOrdersMasterPVC

- (STMOrdersSVC *)splitVC {
    
    if (!_splitVC) {
        
        if ([self.splitViewController isKindOfClass:[STMOrdersSVC class]]) {
            _splitVC = (STMOrdersSVC *)self.splitViewController;
        }
        
    }
    return _splitVC;
    
}

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

- (UIBarButtonItem *)resetFilterButton {
    
    if (!_resetFilterButton) {

//        _resetFilterButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"RESET FILTER", nil) style:UIBarButtonItemStylePlain target:self action:@selector(resetFilter)];
        _resetFilterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Clear Filters-25"] style:UIBarButtonItemStylePlain target:self action:@selector(resetFilter)];

    }
    return _resetFilterButton;
    
}

- (void)resetFilter {
    
    self.splitVC.selectedDate = nil;
    self.splitVC.selectedOutlet = nil;
    self.splitVC.selectedSalesman = nil;
    self.splitVC.searchString = nil;
    
    STMOrdersMasterTVC *masterTVC = self.viewControllers[0];
    [masterTVC resetFilter];
    
}

- (void)updateResetFilterButtonState {
    
    self.resetFilterButton.enabled = (self.splitVC.selectedDate ||
                                      self.splitVC.selectedOutlet ||
                                      self.splitVC.selectedSalesman ||
                                      (self.splitVC.searchString && ![self.splitVC.searchString isEqualToString:@""])
                                      );
    
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
            vc = self.outletTVC;
            break;

        case 1:
            vc = self.dateTVC;
            break;

        case 2:
            vc = self.salesmanTVC;
            break;
            
        default:
            break;
            
    }
    
    vc.index = index;
    
    return vc;
    
}

- (STMOrdersOutletTVC *)outletTVC {
    
    if (!_outletTVC) {
        _outletTVC = [[STMOrdersOutletTVC alloc] initWithStyle:UITableViewStyleGrouped];
    }
    return _outletTVC;
    
}

- (STMOrdersDateTVC *)dateTVC {
    
    if (!_dateTVC) {
        _dateTVC = [[STMOrdersDateTVC alloc] init];
    }
    return _dateTVC;
    
}

- (STMOrdersSalesmanTVC *)salesmanTVC {
    
    if (!_salesmanTVC) {
        _salesmanTVC = [[STMOrdersSalesmanTVC alloc] init];
    }
    return _salesmanTVC;
    
}

- (void)refreshTables {
    
    [self.outletTVC refreshTable];
    [self.dateTVC refreshTable];
    [self.salesmanTVC refreshTable];
    
}

- (NSArray *)defaultToolbarItemsArray {
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    return @[self.resetFilterButton, flexibleSpace];

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

    [self setToolbarItems:[self defaultToolbarItemsArray]];
    
    [self updateResetFilterButtonState];
    
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
