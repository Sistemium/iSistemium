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
#import "STMRootTBC.h"
#import "STMOutletCashingVC.h"
#import "STMConstants.h"
#import "STMDebtsCombineVC.h"
#import "STMAddDebtVC.h"
#import "STMDatePickerVC.h"

@interface STMDebtsDetailsPVC () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIPopoverController *popover;

@property (nonatomic, strong) STMDocument *document;

@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic) NSUInteger nextIndex;

@property (nonatomic, strong) UIBarButtonItem *cashingButton;
@property (nonatomic, strong) UIBarButtonItem *addDebtButton;

@property (nonatomic, strong) UIPopoverController *addDebtPopover;

@end

@implementation STMDebtsDetailsPVC

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
    
}

- (UIBarButtonItem *)cashingButton {
    
    if (!_cashingButton) {
        
        _cashingButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CASHING", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cashingButtonPressed)];

    }

    return _cashingButton;
    
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
                
//        [self editButtonForVC:self.viewControllers[0]];
        [self buttonsForVC:self.viewControllers[0]];

        [self.popover dismissPopoverAnimated:YES];

    }
    
}

- (STMDebtsDetailsVC *)debtsCombineVC {
    
    if (!_debtsCombineVC) {
        
        _debtsCombineVC = [self.storyboard instantiateViewControllerWithIdentifier:@"debtsCombineVC"];
        
    }
    
    return _debtsCombineVC;
    
}

- (STMDebtsDetailsVC *)outletCashingVC {
    
    if (!_outletCashingVC) {
        
        _outletCashingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"outletCashingVC"];
        
    }
    
    return _outletCashingVC;
    
}

- (STMDebtsDetailsVC *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard {
    
    STMDebtsDetailsVC *vc = nil;
    
    switch (index) {
            
        case 0:
            vc = self.debtsCombineVC;
            break;
            
        case 1:
            if (self.outlet) {
                vc = self.outletCashingVC;
            }
            break;
            
        default:
            break;
            
    }
    
    vc.index = index;
    vc.outlet = self.outlet;
    
    return vc;
    
}

- (UIBarButtonItem *)addDebtButton {
    
    if (!_addDebtButton) {
        
        _addDebtButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"ADD DEBT", nil) style:UIBarButtonItemStylePlain target:self action:@selector(addDebtButtonPressed:)];
        
    }
    
    return _addDebtButton;
    
}

- (UIPopoverController *)addDebtPopover {
    
    if (!_addDebtPopover) {
        
        STMAddDebtVC *addDebtVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addDebtVC"];
//        uncashingInfoPopover.uncashing = self.uncashing;
        
        _addDebtPopover = [[UIPopoverController alloc] initWithContentViewController:addDebtVC];
        
    }
    
    return _addDebtPopover;
    
}

//- (void)editButtonForVC:(UIViewController *)vc {
//    
//    if ([vc isKindOfClass:[STMOutletCashingVC class]]) {
//        
//        self.navigationItem.rightBarButtonItem = self.editButtonItem;
//        
//    } else {
//        
//        if (self.outlet) {
//            self.navigationItem.rightBarButtonItem = self.cashingButton;
//        }
//        
//    }
//
//}

- (void)buttonsForVC:(UIViewController *)vc {

    if ([vc isKindOfClass:[STMOutletCashingVC class]]) {
        
        [self setToolbarItems:nil animated:YES];
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem;

    } else {
        
        if (self.outlet) {
            
            UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            [self setToolbarItems:@[flexibleSpace, self.addDebtButton] animated:YES];
            
            self.navigationItem.rightBarButtonItem = self.cashingButton;
            
        } else {
            
            [self setToolbarItems:nil];
            
        }
        
    }

}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"editingButtonPressed" object:self userInfo:@{@"editing": [NSNumber numberWithBool:editing]}];
    
//    NSLog(@"setEditing:editing %d", editing);
    
}

- (void)cashingButtonPressed {
    
    if (self.isCashingProcessing) {

        [self.cashingButton setTitle:NSLocalizedString(@"CASHING", nil)];
        [self.cashingButton setTintColor:ACTIVE_BLUE_COLOR];
        self.isCashingProcessing = NO;

    } else {
    
        [self.cashingButton setTitle:NSLocalizedString(@"CANCEL", nil)];
        [self.cashingButton setTintColor:[UIColor redColor]];
        self.isCashingProcessing = YES;
        
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"cashingButtonPressed" object:self userInfo:nil];
    
//    if ([self.debtsCombineVC isKindOfClass:[STMDebtsCombineVC class]]) {
//        
//        [[(STMDebtsCombineVC *)self.debtsCombineVC tableVC] setEditing:self.isCashingProcessing animated:NO];
//        
//    }

    
}

- (void)addDebtButtonPressed:(id)sender {

    self.addDebtPopover = nil;
    [self.addDebtPopover presentPopoverFromBarButtonItem:self.addDebtButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
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
        
        [self buttonsForVC:pageViewController.viewControllers[0]];
//        [self editButtonForVC:pageViewController.viewControllers[0]];
//        [self toolbarButtonForVC:pageViewController.viewControllers[0]];
        
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
    
    NSArray *titles = @[@"DEBTS", @"CASHED"];
    
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
    
//    [self editButtonForVC:vc];
    [self buttonsForVC:vc];
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [self setToolbarItems:nil];
    [self.addDebtButton setTitle:NSLocalizedString(@"ADD DEBT", nil)];
    
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



@end
