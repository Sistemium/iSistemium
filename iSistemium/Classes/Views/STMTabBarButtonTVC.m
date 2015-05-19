//
//  STMTabBarButtonTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/05/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMTabBarButtonTVC.h"
#import "STMConstants.h"


@interface STMTabBarButtonTVC ()

@property (nonatomic) BOOL hasSiblings;
@property (nonatomic) BOOL hasActions;


@end


@implementation STMTabBarButtonTVC


- (BOOL)hasSiblings {
    
    if (!_hasSiblings) {
        _hasSiblings = (self.siblings) ? YES : NO;
    }
    return _hasSiblings;
    
}

- (BOOL)hasActions {
    
    if (!_hasActions) {
        _hasActions = (self.actions) ? YES : NO;
    }
    return _hasActions;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.hasSiblings && self.hasActions) {
        return 2;
    } else if (self.hasSiblings || self.hasActions) {
        return 1;
    } else {
        return 0;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.hasSiblings && self.hasActions) {
        
        switch (section) {
            case 0:
                return self.siblings.count;
                break;
            case 1:
                return self.actions.count;
                break;
                
            default:
                return 0;
                break;
        }
        
    } else if (self.hasSiblings || self.hasActions) {

        return MAX(self.siblings.count, self.actions.count);
    
    } else {
        
        return 0;
        
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseIdentifier = @"tabBarTVCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = ACTIVE_BLUE_COLOR;
    
    if (self.hasSiblings && self.hasActions) {
        
        switch (indexPath.section) {
            case 0:
                [self fillSiblingCell:cell forIndex:indexPath.row];
                break;
            case 1:
                [self fillActionCell:cell forIndex:indexPath.row];
                break;
                
            default:
                return 0;
                break;
        }
        
    } else if (self.hasSiblings) {
        
        [self fillSiblingCell:cell forIndex:indexPath.row];
        
    } else if (self.hasActions) {
        
        [self fillActionCell:cell forIndex:indexPath.row];
        
    } else {

    }

    
    return cell;
    
}

- (void)fillSiblingCell:(UITableViewCell *)cell forIndex:(NSUInteger)index {
    
    UIViewController *vc = self.siblings[index];
    
    cell.textLabel.text = vc.title;
    cell.imageView.image = vc.tabBarItem.image;
    
    if (vc == self.parentVC) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}

- (void)fillActionCell:(UITableViewCell *)cell forIndex:(NSUInteger)index {
    cell.textLabel.text = self.actions[index];
}


#pragma mark - view lifecycle

- (void)customInit {
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self customInit];
    
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
