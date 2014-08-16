//
//  STMDebtDetailsPVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 31/07/14.
//  Copyright (c) 2014 Sistemium UAB. All rights reserved.
//

#import "STMDebtsDetailsPVC.h"
#import "STMDocument.h"
#import "STMSessionManager.h"
#import "STMDebtsDetailsVC.h"
#import "STMRootTBC.h"

@interface STMDebtsDetailsPVC () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) UIPopoverController *popover;

@property (nonatomic, strong) STMDocument *document;

@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic) NSUInteger nextIndex;


@end

@implementation STMDebtsDetailsPVC

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
    
}


- (void)setOutlet:(STMOutlet *)outlet {
    
    if (outlet != _outlet) {
        
        self.title = outlet.name;
        
        for (STMDebtsDetailsVC *view in self.viewControllers) {
            view.outlet = outlet;
        }
        
        BOOL isFirstAssign = NO;
        
        if (!_outlet) {
            
            isFirstAssign = YES;
            [self setupSegmentedControl];
            
        }
        
        _outlet = outlet;

        if (isFirstAssign) {
            self.dataSource = nil;
            self.dataSource = self;
        }
        
        NSUInteger maxLength = 36;
        
        if (self.outlet.name.length > maxLength) {
            
            self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:@"%@…", [self.outlet.name substringToIndex:maxLength]];
            
        } else {
            
            self.navigationItem.leftBarButtonItem.title = self.outlet.name;
            
        }

        [self.popover dismissPopoverAnimated:YES];

    }
    
}

- (STMDebtsDetailsVC *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    
    STMDebtsDetailsVC *vc = nil;
    
    switch (index) {
            
        case 0:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"debtsCombineVC"];
            break;
            
        case 1:
            if (self.outlet) {
                vc = [storyboard instantiateViewControllerWithIdentifier:@"outletCashingVC"];
            }
            break;
            
        default:
            break;
            
    }
    
    vc.index = index;
    vc.outlet = self.outlet;
    
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
    
    STMDebtsDetailsVC *pendingVC = pendingViewControllers[0];
    pendingVC.outlet = self.outlet;
    self.nextIndex = pendingVC.index;
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        
        STMDebtsDetailsVC *previousVC = previousViewControllers[0];
        previousVC.outlet = self.outlet;
        self.currentIndex = self.nextIndex;
        
        self.segmentedControl.selectedSegmentIndex = self.currentIndex;
        
    }
}


#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    
    NSString *barButtonTitle = self.outlet ? self.outlet.name : NSLocalizedString(@"OUTLETS", nil);
    
    NSUInteger maxLength = 36;
    
    if (barButtonTitle.length > maxLength) {
        
        barButtonTitle = [NSString stringWithFormat:@"%@…", [barButtonTitle substringToIndex:maxLength]];
        
    }
    
    barButtonItem.title = barButtonTitle;
    
    //    barButtonItem.title = NSLocalizedString(@"AD CAMPAIGNS", nil);
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    self.popover = pc;
    
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button {
    
    self.navigationItem.leftBarButtonItem = nil;
    
    self.popover = nil;
    
}


#pragma mark

- (void)deviceOrientationDidChangeNotification:(NSNotification *)notification {
    
}

- (void)setupSegmentedControl {
    
    NSArray *titles = @[@"DEBTS", @"CASHING"];
    
    for (int i = 0; i < titles.count; i++) {
        [self.segmentedControl insertSegmentWithTitle:NSLocalizedString(titles[i], nil) atIndex:i animated:YES];
    }
    
    self.segmentedControl.selectedSegmentIndex = self.currentIndex;
    
    [self.segmentedControl addTarget:self action:@selector(selectSegmentedControlSegment) forControlEvents:UIControlEventValueChanged];
    
}

- (void)selectSegmentedControlSegment {
    
    UIPageViewControllerNavigationDirection direction;
    
    if (self.segmentedControl.selectedSegmentIndex > self.currentIndex) {
        direction = UIPageViewControllerNavigationDirectionForward;
    } else {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    
    self.currentIndex = self.segmentedControl.selectedSegmentIndex;
    
    [self setVCAtIndex:self.currentIndex direction:direction];
    
}

- (void)setVCAtIndex:(NSUInteger)index direction:(UIPageViewControllerNavigationDirection)direction {
    
    STMDebtsDetailsVC *vc = [self viewControllerAtIndex:index storyboard:self.storyboard];
    NSArray *viewControllers = @[vc];
    [self setViewControllers:viewControllers direction:direction animated:YES completion:NULL];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.dataSource = self;
    self.delegate = self;
    
    self.currentIndex = 0;
    [self setVCAtIndex:self.currentIndex direction:UIPageViewControllerNavigationDirectionForward];
    
    self.view.autoresizesSubviews = YES;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self customInit];

    [self.segmentedControl removeAllSegments];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
