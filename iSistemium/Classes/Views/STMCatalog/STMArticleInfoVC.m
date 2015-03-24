//
//  STMArticleInfoVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticleInfoVC.h"

@interface STMArticleInfoVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *articleInfo;


@end


@implementation STMArticleInfoVC

- (NSMutableArray *)articleInfo {
    
    if (!_articleInfo) {
        _articleInfo = [NSMutableArray array];
    }
    return _articleInfo;
    
}

- (void)closeButtonPressed {
    [self.parentVC dismissArticleInfoPopover];
}

- (void)setupImage {
    
    if (self.article.pictures.count > 0) {

        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"deviceCts" ascending:YES];
        STMArticlePicture *picture = [self.article.pictures sortedArrayUsingDescriptors:@[sortDescriptor]][0];
        
        self.imageView.image = [UIImage imageWithContentsOfFile:[STMFunctions absolutePathForPath:picture.resizedImagePath]];
    
    } else {
        self.imageView.image = [UIImage imageNamed:@"wine_bottle-512.png"];
    }
    
}

- (void)setupToolbar {
    
    CGFloat height = 44;
    CGFloat width = self.view.frame.size.width;
    CGFloat x = self.view.frame.origin.x;
    CGFloat y = self.view.frame.size.height - height;
    
    CGRect frame = CGRectMake(x, y, width, height);
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:frame];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CLOSE", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeButtonPressed)];
    
    [toolbar setItems:@[flexibleSpace, closeButton]];

    [self.view addSubview:toolbar];
    
}

- (void)prepareInfo {

    [self.articleInfo addObject:@{
                                  @"key": @"name",
                                  @"value": (self.article.name) ? self.article.name : @""
                                  }];
    
    if (self.article.extraLabel) [self.articleInfo addObject:@{
                                                               @"key": @"extraLabel",
                                                               @"value": (self.article.extraLabel) ? self.article.extraLabel : @""
                                                               }];

    
    NSString *keyString = NSLocalizedString(@"VOLUME", nil);
    NSString *volumeUnitString = NSLocalizedString(@"VOLUME UNIT", nil);
    [self.articleInfo addObject:@{
                                  @"key": @"pieceVolume",
                                  @"value": [NSString stringWithFormat:@"%@: %@%@", keyString, self.article.pieceVolume, volumeUnitString]
                                  }];

    keyString = NSLocalizedString(@"FACTOR", nil);
    [self.articleInfo addObject:@{
                                  @"key": @"factor",
                                  @"value": [NSString stringWithFormat:@"%@: %@", keyString, self.article.factor]
                                  }];
    
    keyString = NSLocalizedString(@"PACKAGE REL", nil);
    [self.articleInfo addObject:@{
                                  @"key": @"packageRel",
                                  @"value": [NSString stringWithFormat:@"%@: %@", keyString, self.article.packageRel]
                                  }];

    NSSortDescriptor *priceDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priceType.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *prices = [self.article.prices sortedArrayUsingDescriptors:@[priceDescriptor]];
    
    for (STMPrice *price in prices) {
        
        keyString = NSLocalizedString(@"PRICE", nil);
        NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
        NSString *priceValue = [numberFormatter stringFromNumber:price.price];
        [self.articleInfo addObject:@{
                                      @"key": price.priceType.name,
                                      @"value": [NSString stringWithFormat:@"%@: %@", keyString, priceValue],
                                      @"detail": price.priceType.name
                                      }];
        
    }
    
    keyString = NSLocalizedString(@"CODE", nil);
    [self.articleInfo addObject:@{
                                  @"key": @"code",
                                  @"value": [NSString stringWithFormat:@"%@: %@", keyString, self.article.code]
                                  }];

    keyString = NSLocalizedString(@"SECTION", nil);
    [self.articleInfo addObject:@{
                                  @"key": @"section",
                                  @"value": [NSString stringWithFormat:@"%@: %@", keyString, self.article.articleGroup.name]
                                  }];

}


#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.articleInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"articleInfoCell";
    
    STMInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [self fillCell:cell forIndexPath:indexPath];
    
    cell.textLabel.textAlignment = NSTextAlignmentRight;
    cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
    
    return cell;
    
}

- (void)fillCell:(STMInfoTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *info = self.articleInfo[indexPath.row];
    
    cell.textLabel.text = info[@"value"];
    cell.detailTextLabel.text = info[@"detail"];
    
}

#pragma mark - view lifecycle

- (void)customInit {
    
    if (self.article) {
        
        [self setupImage];
        [self prepareInfo];
        
        [self.tableView registerClass:[STMInfoTableViewCell class] forCellReuseIdentifier:@"articleInfoCell"];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
    }
    
}

- (void)viewDidLoad {

    [super viewDidLoad];
    [self customInit];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self setupToolbar];

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
