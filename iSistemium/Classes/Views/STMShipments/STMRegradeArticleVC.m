//
//  STMRegradeArticleVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 19/07/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMRegradeArticleVC.h"
#import "STMUI.h"
#import "STMNS.h"
#import "STMDataModel.h"
#import "STMSessionManagement.h"


@interface STMRegradeArticleVC () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) STMBarButtonItemCancel *cancelButton;
@property (nonatomic, strong) STMBarButtonItemDone *doneButton;

@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSString *cellIdentifier;

@property (strong, nonatomic) NSMutableDictionary *cachedCellsHeights;
@property (nonatomic) CGFloat standardCellHeight;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;


@end


@implementation STMRegradeArticleVC

- (STMDocument *)document {
    return [[STMSessionManager sharedManager].currentSession document];
}

- (NSString *)cellIdentifier {
    return @"regradeArticleCell";
}

#pragma mark - cell's height caching

- (NSMutableDictionary *)cachedCellsHeights {
    
    if (!_cachedCellsHeights) {
        _cachedCellsHeights = [NSMutableDictionary dictionary];
    }
    return _cachedCellsHeights;
    
}

- (void)putCachedHeight:(CGFloat)height forIndexPath:(NSIndexPath *)indexPath {
    
    STMArticle *article = self.tableData[indexPath.row];
    NSManagedObjectID *objectID = article.objectID;
    
    self.cachedCellsHeights[objectID] = @(height);
    
}

- (NSNumber *)getCachedHeightForIndexPath:(NSIndexPath *)indexPath {
    
    STMArticle *article = self.tableData[indexPath.row];
    NSManagedObjectID *objectID = article.objectID;

    return self.cachedCellsHeights[objectID];
    
}


#pragma mark - buttons

- (void)cancelButtonPressed:(id)sender {
    [self dismissSelf];
}

- (void)doneButtonPressed:(id)sender {

}

- (void)dismissSelf {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupToolbar {
    
    self.cancelButton = [[STMBarButtonItemCancel alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self
                                                                             action:@selector(cancelButtonPressed:)];
    
    self.doneButton = [[STMBarButtonItemDone alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                         target:self
                                                                         action:@selector(doneButtonPressed:)];
    
    STMBarButtonItem *flexibleSpace = [STMBarButtonItem flexibleSpace];
    
    self.toolbar.items = @[self.cancelButton, flexibleSpace, self.doneButton];
    
}


#pragma mark - table data

- (void)prepareTableData {
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMArticle class])];
    
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *volumeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pieceVolume" ascending:YES selector:@selector(compare:)];
    
    request.sortDescriptors = @[nameDescriptor, volumeDescriptor];
    
    if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", self.searchBar.text];
        request.predicate = [STMPredicate predicateWithNoFantomsFromPredicate:predicate];

    } else {
        request.predicate = [STMPredicate predicateWithNoFantoms];
    }
    
    self.tableData = [[self document].managedObjectContext executeFetchRequest:request error:nil];
    
    [self.tableView reloadData];
    
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self prepareTableData];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = YES;
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    searchBar.showsCancelButton = NO;
    searchBar.text = nil;
    self.selectedIndexPath = nil;
    
    [self hideKeyboard];
    [self prepareTableData];
    
}


- (void)hideKeyboard {
    
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self hideKeyboard];
    
}


#pragma mark - UITableViewDataSource, UITableViewDelegate

- (CGFloat)standardCellHeight {
    
    if (!_standardCellHeight) {
        
        static CGFloat standardCellHeight;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            standardCellHeight = [[UITableViewCell alloc] init].frame.size.height;
        });
        
        _standardCellHeight = standardCellHeight + 1.0f;  // Add 1.0f for the cell separator height
        
    }
    return _standardCellHeight;
    
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.standardCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForCellAtIndexPath:indexPath];
}

- (CGFloat)heightForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *cachedHeight = [self getCachedHeightForIndexPath:indexPath];
    
    if (cachedHeight) {
        
        return cachedHeight.floatValue;
        
    } else {
        
        static UITableViewCell *cell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
        });
        
        [self fillCell:cell atIndexPath:indexPath];
        
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds) - MAGIC_NUMBER_FOR_CELL_WIDTH, CGRectGetHeight(cell.bounds));
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        CGFloat height = size.height + 1.0f; // Add 1.0f for the cell separator height
        
        height = (height < self.standardCellHeight) ? self.standardCellHeight : height;
        
        [self putCachedHeight:height forIndexPath:indexPath];
        
        return height;
        
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    STMCustom7TVCell *cell = (STMCustom7TVCell *)[tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self fillCell:cell atIndexPath:indexPath];
    
    cell.tintColor = ([indexPath isEqual:self.selectedIndexPath]) ? ACTIVE_BLUE_COLOR : [UIColor clearColor];
    
    return cell;
    
}

- (void)fillCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell isKindOfClass:[STMCustom7TVCell class]]) {
        
        STMCustom7TVCell *customCell = (STMCustom7TVCell *)cell;
        
        STMArticle *article = self.tableData[indexPath.row];
        
        customCell.titleLabel.text = article.name;
        customCell.detailLabel.text = nil;
        
        customCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
    
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *previouslySelectedIndexPath = self.selectedIndexPath;
    self.selectedIndexPath = indexPath;
    
    if (previouslySelectedIndexPath) {
        [tableView reloadRowsAtIndexPaths:@[previouslySelectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if (self.selectedIndexPath) {
        [tableView reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    [self.tableView registerNib:[UINib nibWithNibName:@"STMCustom7TVCell" bundle:nil] forCellReuseIdentifier:self.cellIdentifier];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.searchBar.delegate = self;
    
    [self setupToolbar];
    
    [self prepareTableData];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self customInit];

}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:animated];
    
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
