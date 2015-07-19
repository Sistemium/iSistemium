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


@interface STMRegradeArticleVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic, strong) STMBarButtonItemCancel *cancelButton;
@property (nonatomic, strong) STMBarButtonItemDone *doneButton;

@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSString *cellIdentifier;


@end


@implementation STMRegradeArticleVC

- (STMDocument *)document {
    return [[STMSessionManager sharedManager].currentSession document];
}

- (NSString *)cellIdentifier {
    return @"regradeArticleCell";
}

- (void)prepareTableData {
    
    STMFetchRequest *request = [STMFetchRequest fetchRequestWithEntityName:NSStringFromClass([STMArticle class])];
    
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSSortDescriptor *volumeDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"pieceVolume" ascending:YES selector:@selector(compare:)];
    
    request.sortDescriptors = @[nameDescriptor, volumeDescriptor];
    
    request.predicate = [STMPredicate predicateWithNoFantoms];
    
    self.tableData = [[self document].managedObjectContext executeFetchRequest:request error:nil];

}


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


#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    STMArticle *article = self.tableData[indexPath.row];
    
    cell.textLabel.text = article.name;
    
    return cell;
    
}


#pragma mark - view lifecycle

- (void)customInit {
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
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
