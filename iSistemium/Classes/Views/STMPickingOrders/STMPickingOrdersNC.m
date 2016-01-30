//
//  STMPickingOrdersNC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 16/11/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMPickingOrdersNC.h"

@interface STMPickingOrdersNC ()

@end

@implementation STMPickingOrdersNC

@synthesize actions = _actions;


- (NSArray <NSString *> *)actions {

    if (!_actions) {
        
        if ([self.topViewController respondsToSelector:@selector(actions)]) {
            
            if ([[self.topViewController performSelector:@selector(actions)] isKindOfClass:[NSArray <NSString *> class]]) {
                
                _actions = [self.topViewController performSelector:@selector(actions)];
                
            }
            
        }

    }
    return _actions;
}

#pragma mark - STMTabBarItemControllable protocol

- (BOOL)shouldShowOwnActions {
    return (BOOL)self.actions.count;
}

- (void)selectActionAtIndex:(NSUInteger)index {
    
    [super selectActionAtIndex:index];
    
    NSString *action = self.actions[index];
    
    SEL selectActionSelector = NSSelectorFromString(@"selectAction:");
    
    if ([self.topViewController respondsToSelector:selectActionSelector]) {
        [self.topViewController performSelector:selectActionSelector withObject:action afterDelay:0];
    }
    
    self.actions = nil;

}


#pragma mark - view lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
