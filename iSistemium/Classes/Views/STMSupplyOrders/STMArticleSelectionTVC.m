//
//  STMArticleSelectionTVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 22/12/15.
//  Copyright © 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticleSelectionTVC.h"


@interface STMArticleSelectionTVC ()

@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) STMBarButtonItemDone *doneButton;
@property (nonatomic, strong) STMBarButtonItemCancel *cancelButton;

@property (nonatomic, weak) STMArticle *selectedArticle;


@end


@implementation STMArticleSelectionTVC

- (NSArray *)tableData {
    
    if (!_tableData) {
        
        if ([self.searchBar isFirstResponder] && ![self.searchBar.text isEqualToString:@""]) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchBar.text];
            
            _tableData = [self.articles filteredArrayUsingPredicate:predicate];
            
        } else {
            
            _tableData = self.articles;
            
        }
        
        
    }
    return _tableData;
    
}

- (void)performFetch {
    
    self.tableData = nil;
    [self.tableView reloadData];
    [self selectSelectedArticleCell];
    
}

- (void)selectSelectedArticleCell {
    
    if (self.selectedArticle) {
        
        NSInteger index = [self.tableData indexOfObject:(STMArticle * _Nonnull)self.selectedArticle];
        
        if (index != NSNotFound) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            
            if (indexPath) {
                
                UITableViewScrollPosition scrollPosition = (![self.searchBar.text isEqualToString:@""]) ? UITableViewScrollPositionNone : UITableViewScrollPositionTop;
                [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:scrollPosition];
                
            }
            
        }
        
    }
    
}

- (void)showVisibleArticle {
    
    if (self.visibleArticle && [self.tableData containsObject:self.visibleArticle]) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.tableData indexOfObject:self.visibleArticle] inSection:0];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];    
        }];
        
    }
    
}


#pragma mark - table view data

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMTableViewSubtitleStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    STMArticle *article = self.tableData[indexPath.row];
    
    cell.textLabel.text = article.name;
    cell.textLabel.numberOfLines = 0;
    
    cell.detailTextLabel.text = article.extraLabel;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.accessoryType = ([article isEqual:self.selectedArticle]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
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
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    self.selectedArticle = self.tableData[indexPath.row];
    
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
    
    self.doneButton = [[STMBarButtonItemDone alloc] initWithTitle:NSLocalizedString(@"DONE", nil)
                                                            style:UIBarButtonItemStyleDone
                                                           target:self
                                                           action:@selector(doneButtonPressed)];
    
    [self updateDoneButton];
    
    self.cancelButton = [[STMBarButtonItemCancel alloc] initWithTitle:NSLocalizedString(@"CANCEL", nil)
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(cancelButtonPressed)];
    
    [self setToolbarItems:@[self.cancelButton, [STMBarButtonItem flexibleSpace], self.doneButton]];
    
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
        
        STMArticle *article = self.tableData[selectedIndexPath.row];
        
        [self.parentVC confirmArticle:article];
        [self dismissViewControllerAnimated:NO completion:nil];

    }
    
}

- (void)cancelButtonPressed {
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - view lifecycle

- (void)customInit {
    
    [super customInit];
    
    [self.tableView registerClass:[STMTableViewSubtitleStyleCell class] forCellReuseIdentifier:self.cellIdentifier];
    
    [self setupToolbar];
//    [self selectSelectedArticleCell];
    [self showVisibleArticle];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if ([self isMovingToParentViewController]) {
//        self.parentNC.scanEnabled = NO;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if ([self isMovingFromParentViewController]) {
        
//        self.parentNC.scanEnabled = YES;
        
        self.navigationController.toolbarHidden = YES;
        
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
