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
                                  @"value": self.article.name
                                  }];
    
    if (self.article.extraLabel) [self.articleInfo addObject:@{
                                                               @"key": @"extraLabel",
                                                               @"value": self.article.extraLabel
                                                               }];

    
    NSString *volumeString = NSLocalizedString(@"VOLUME", nil);
    NSString *volumeUnitString = NSLocalizedString(@"VOLUME UNIT", nil);
    [self.articleInfo addObject:@{
                                  @"key": @"pieceVolume",
                                  @"value": [NSString stringWithFormat:@"%@: %@%@", volumeString, self.article.pieceVolume, volumeUnitString]
                                  }];
    
    NSSortDescriptor *priceDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priceType.name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *prices = [self.article.prices sortedArrayUsingDescriptors:@[priceDescriptor]];
    
    for (STMPrice *price in prices) {
        
        NSString *priceString = NSLocalizedString(@"PRICE", nil);
        NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
        NSString *priceValue = [numberFormatter stringFromNumber:price.price];
        [self.articleInfo addObject:@{
                                      @"key": price.priceType.name,
                                      @"value": [NSString stringWithFormat:@"%@: %@", priceString, priceValue],
                                      @"detail": price.priceType.name
                                      }];
        
    }

    NSString *factorString = NSLocalizedString(@"FACTOR", nil);
    [self.articleInfo addObject:@{
                                  @"key": @"factor",
                                  @"value": [NSString stringWithFormat:@"%@: %@", factorString, self.article.factor]
                                  }];
    
    NSString *packageString = NSLocalizedString(@"PACKAGE REL", nil);
    [self.articleInfo addObject:@{
                                  @"key": @"packageRel",
                                  @"value": [NSString stringWithFormat:@"%@: %@", packageString, self.article.packageRel]
                                  }];
    
    NSString *codeString = NSLocalizedString(@"CODE", nil);
    [self.articleInfo addObject:@{
                                  @"key": @"code",
                                  @"value": [NSString stringWithFormat:@"%@: %@", codeString, self.article.code]
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
