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
#import "STMCashingProcessController.h"
#import "STMUI.h"

@interface STMDebtsDetailsPVC () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
//@property (nonatomic, strong) UIPopoverController *popover;

@property (nonatomic, strong) STMDocument *document;

@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic) NSUInteger nextIndex;

@property (nonatomic, strong) UIBarButtonItem *addDebtButton;
@property (nonatomic, strong) UIBarButtonItem *editDebtsButton;
@property (nonatomic, strong) UIPopoverController *addDebtPopover;
@property (nonatomic, strong) STMUIBarButtonItemDone *cashingButton;

@end

@implementation STMDebtsDetailsPVC

- (STMDocument *)document {
    
    if (!_document) {
        
        _document = (STMDocument *)[[STMSessionManager sharedManager].currentSession document];
        
    }
    
    return _document;
    
}

- (STMUIBarButtonItemDone *)cashingButton {
    
    if (!_cashingButton) {
        
        _cashingButton = [[STMUIBarButtonItemDone alloc] initWithTitle:NSLocalizedString(@"CASHING", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cashingButtonPressed)];

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
        
//        NSUInteger maxLength = 36;
//        
//        if (self.outlet.name.length > maxLength) {
//            
//            self.navigationItem.leftBarButtonItem.title = [NSString stringWithFormat:@"%@…", [self.outlet.name substringToIndex:maxLength]];
//            
//        } else {
//            
//            self.navigationItem.leftBarButtonItem.title = self.outlet.name;
//            
//        }
        
//        [self editButtonForVC:self.viewControllers[0]];
        [self buttonsForVC:self.viewControllers[0]];

//        [self.popover dismissPopoverAnimated:YES];

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

- (UIBarButtonItem *)editDebtsButton {
    
    if (!_editDebtsButton) {
        
        _editDebtsButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"EDIT DEBTS", nil) style:UIBarButtonItemStylePlain target:self action:@selector(editDebtsButtonPressed:)];
        
    }
    
    return _editDebtsButton;
    
}

- (UIPopoverController *)addDebtPopover {
    
    if (!_addDebtPopover) {
        
        STMAddDebtVC *addDebtVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addDebtVC"];
        addDebtVC.parentVC = self;
        
        _addDebtPopover = [[UIPopoverController alloc] initWithContentViewController:addDebtVC];
        _addDebtPopover.delegate = self;
        
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
            [self setToolbarItems:@[self.editDebtsButton, flexibleSpace, self.addDebtButton] animated:YES];
            
            self.navigationItem.rightBarButtonItem = self.cashingButton;
            
        } else {
            
            [self setToolbarItems:nil];
            
        }
        
    }

}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    if (editing) {
        
        self.editDebtsButton.title = NSLocalizedString(@"DONE", nil);
        
    } else {
        
        self.editDebtsButton.title = NSLocalizedString(@"EDIT DEBTS", nil);
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"editingButtonPressed" object:self userInfo:@{@"editing": @(editing)}];
    
}

- (void)cashingButtonPressed {
    
    if ([STMCashingProcessController sharedInstance].state == STMCashingProcessRunning) {

        [[NSNotificationCenter defaultCenter] postNotificationName:@"textFieldsShouldResignResponder" object:self];
        [[STMCashingProcessController sharedInstance] doneCashingProcess];

    } else if ([STMCashingProcessController sharedInstance].state == STMCashingProcessIdle) {
        
        [self setEditing:NO animated:YES];
        [[STMCashingProcessController sharedInstance] startCashingProcessForOutlet:self.outlet];
        
    }
    
}

- (void)cashingProcessStart {
    
    [self.cashingButton setTitle:NSLocalizedString(@"DONE", nil)];
    self.addDebtButton.enabled = NO;
    self.editDebtsButton.enabled = NO;
    
//    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
//        
//        [self.popover presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//        
//    }

}

- (void)cashingProcessDone {

    [self.cashingButton setTitle:NSLocalizedString(@"CASHING", nil)];
    self.addDebtButton.enabled = YES;
    self.editDebtsButton.enabled = YES;

}

- (void)cashingProcessCancel {

    [self cashingProcessDone];

}

- (void)addDebtButtonPressed:(id)sender {

    self.addDebtPopover = nil;
    [self.addDebtPopover presentPopoverFromBarButtonItem:self.addDebtButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.editDebtsButton.enabled = NO;
    
}

- (void)editDebtsButtonPressed:(id)sender {
    
    [self setEditing:!self.editing animated:YES];
    
}

- (void)dismissAddDebt {
    
    [self.addDebtPopover dismissPopoverAnimated:YES];
    self.addDebtPopover = nil;
    self.editDebtsButton.enabled = YES;
    
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

/*
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
*/


#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    
    return NO;
    
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

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cashingProcessStart)
                                                 name:@"cashingProcessStart"
                                               object:[STMCashingProcessController sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cashingProcessDone)
                                                 name:@"cashingProcessDone"
                                               object:[STMCashingProcessController sharedInstance]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cashingProcessCancel)
                                                 name:@"cashingProcessCancel"
                                               object:[STMCashingProcessController sharedInstance]];

}

- (void)removeObsevers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)customInit {

    [self addObservers];

    NSDictionary *settings = [[STMSessionManager sharedManager].currentSession.settingsController currentSettingsForGroup:@"appSettings"];
    BOOL toolbarHidden = ![[settings valueForKey:@"enableDebtsEditing"] boolValue];
    
    self.navigationController.toolbarHidden = toolbarHidden;
    
    [self setToolbarItems:nil];
    [self.addDebtButton setTitle:NSLocalizedString(@"ADD DEBT", nil)];
    
    self.dataSource = self;
    self.delegate = self;
    
    self.currentIndex = 0;
    [self setVCAtIndex:self.currentIndex direction:UIPageViewControllerNavigationDirectionForward];
    
    self.view.autoresizesSubviews = YES;
    
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
