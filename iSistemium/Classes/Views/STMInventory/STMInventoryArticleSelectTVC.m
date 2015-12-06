//
//  STMInventoryArticleSelectTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 06/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMInventoryArticleSelectTVC.h"


@interface STMInventoryArticleSelectTVC ()

@property (nonatomic, strong) STMBarButtonItem *doneButton;


@end


@implementation STMInventoryArticleSelectTVC

#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewCellStyleSubtitle *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    STMArticle *article = self.articles[indexPath.row];
    
    cell.textLabel.text = article.name;
    cell.textLabel.numberOfLines = 0;
    
    cell.detailTextLabel.text = article.extraLabel;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];

    if (selectedIndexPath && [selectedIndexPath compare:indexPath] == NSOrderedSame) {
        
        [self tableView:tableView willDeselectRowAtIndexPath:indexPath];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
        
        return nil;
        
    } else {
        
        return indexPath;
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self updateDoneButton];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self updateDoneButton];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;

}


#pragma mark - toolbar

- (void)setupToolbar {
    
    self.navigationController.toolbarHidden = NO;
    
    self.doneButton = [[STMBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DONE", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(doneButtonPressed)];
    
    [self updateDoneButton];
    
    [self setToolbarItems:@[[STMBarButtonItem flexibleSpace], self.doneButton, [STMBarButtonItem flexibleSpace]]];

}

- (void)updateDoneButton {
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    
    if (selectedIndexPath) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }
    
}

- (void)doneButtonPressed {
    
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];

    if (selectedIndexPath) {
        
        STMArticle *article = self.articles[selectedIndexPath.row];
        
        [self.parentNC selectArticle:article];
        
    }
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];

    [self.tableView registerClass:[STMTableViewCellStyleSubtitle class] forCellReuseIdentifier:self.cellIdentifier];

    [self setupToolbar];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if ([self isMovingToParentViewController]) {
        self.parentNC.scanEnabled = NO;
    }

    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        self.parentNC.scanEnabled = YES;
    }

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
