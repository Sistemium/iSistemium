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
#import "STMDebtsDetailsTVC.h"
#import "STMRootTBC.h"

@interface STMDebtsDetailsPVC () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) UIBarButtonItem *homeButton;

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
        
        for (STMDebtsDetailsTVC *view in self.viewControllers) {
            view.outlet = outlet;
        }
        
        BOOL isFirstAssign = NO;
        
        if (!_outlet) {
            
            isFirstAssign = YES;
//            [self setupSegmentedControl];
            
        }
        
        _outlet = outlet;

        if (isFirstAssign) {
            self.dataSource = nil;
            self.dataSource = self;
        }
        
//        self.navigationItem.leftBarButtonItem.title = self.outlet.name;
        [self.popover dismissPopoverAnimated:YES];

    }
    
}

- (UIBarButtonItem *)homeButton {
    
    if (!_homeButton) {
        
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"HOME", nil) style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonPressed)];
        
        _homeButton = button;
        
    }
    
    return _homeButton;
    
}

- (void)homeButtonPressed {
    
    //    NSLog(@"homeButtonPressed");
    [[STMRootTBC sharedRootVC] showTabWithName:@"STMAuthTVC"];
    
    
}

- (STMDebtsDetailsTVC *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    
    STMDebtsDetailsTVC *vc = nil;
    
    switch (index) {
            
        case 0:
            vc = [storyboard instantiateViewControllerWithIdentifier:@"outletDebtsTVC"];
            break;
            
        case 1:
            if (self.outlet) {
                vc = [storyboard instantiateViewControllerWithIdentifier:@"outletCashingTVC"];
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
    
    STMDebtsDetailsTVC *pendingVC = pendingViewControllers[0];
    pendingVC.outlet = self.outlet;
    self.nextIndex = pendingVC.index;
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        
        STMDebtsDetailsTVC *previousVC = previousViewControllers[0];
        previousVC.outlet = self.outlet;
        self.currentIndex = self.nextIndex;
        
//        self.segmentedControl.selectedSegmentIndex = self.currentIndex;
        
    }
}


#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    
    //    NSString *barButtonTitle = self.campaign ? self.campaign.name : NSLocalizedString(@"AD CAMPAIGNS", nil);
    NSString *barButtonTitle = NSLocalizedString(@"DEBTS", nil);
    barButtonItem.title = barButtonTitle;
    
    //    barButtonItem.title = NSLocalizedString(@"AD CAMPAIGNS", nil);
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    self.popover = pc;
    
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button {
    
    self.navigationItem.leftBarButtonItem = nil;
    
    self.popover = nil;
    
}


- (void)setVCAtIndex:(NSUInteger)index direction:(UIPageViewControllerNavigationDirection)direction {
    
    STMDebtsDetailsTVC *vc = [self viewControllerAtIndex:index storyboard:self.storyboard];
    NSArray *viewControllers = @[vc];
    [self setViewControllers:viewControllers direction:direction animated:YES completion:NULL];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.navigationItem.rightBarButtonItem = self.homeButton;
    
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
