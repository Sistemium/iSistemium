//
//  STMArticleInfoVC.m
//  iSistemium
//
//  Created by Maxim Grigoriev on 05/03/15.
//  Copyright (c) 2015 Sistemium UAB. All rights reserved.
//

#import "STMArticleInfoVC.h"

@interface STMArticleInfoVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *nameTextView;
@property (weak, nonatomic) IBOutlet UILabel *extraLabel;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *factorLabel;
@property (weak, nonatomic) IBOutlet UILabel *packageLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;


@end


@implementation STMArticleInfoVC

- (IBAction)cancelButtonPressed:(id)sender {
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

- (void)setupLabels {
    
    self.nameTextView.text = self.article.name;
    self.nameTextView.font = [UIFont boldSystemFontOfSize:18];
    self.nameTextView.textAlignment = NSTextAlignmentRight;

    if (self.article.extraLabel) {
        
        self.extraLabel.text = self.article.extraLabel;
        self.extraLabel.font = [UIFont systemFontOfSize:17];
        self.extraLabel.textAlignment = NSTextAlignmentRight;
        
    } else {
        self.extraLabel.text = nil;
    }
    
    NSString *volumeString = NSLocalizedString(@"VOLUME", nil);
    NSString *volumeUnitString = NSLocalizedString(@"VOLUME UNIT", nil);
    self.volumeLabel.text = [NSString stringWithFormat:@"%@: %@%@", volumeString, self.article.pieceVolume, volumeUnitString];
    self.volumeLabel.font = [UIFont systemFontOfSize:17];
    self.volumeLabel.textAlignment = NSTextAlignmentRight;
    
    NSString *priceString = NSLocalizedString(@"PRICE", nil);
    NSNumberFormatter *numberFormatter = [STMFunctions currencyFormatter];
    self.priceLabel.text = [NSString stringWithFormat:@"%@: %@", priceString, [numberFormatter stringFromNumber:self.article.price]];
    self.priceLabel.font = [UIFont boldSystemFontOfSize:17];
    self.priceLabel.textAlignment = NSTextAlignmentRight;

    NSString *factorString = NSLocalizedString(@"FACTOR", nil);
    self.factorLabel.text = [NSString stringWithFormat:@"%@: %@", factorString, self.article.factor];
    self.factorLabel.font = [UIFont systemFontOfSize:17];
    self.factorLabel.textAlignment = NSTextAlignmentRight;

    NSString *packageString = NSLocalizedString(@"PACKAGE REL", nil);
    self.packageLabel.text = [NSString stringWithFormat:@"%@: %@", packageString, self.article.packageRel];
    self.packageLabel.font = [UIFont systemFontOfSize:17];
    self.packageLabel.textAlignment = NSTextAlignmentRight;

    NSString *codeString = NSLocalizedString(@"CODE", nil);
    self.codeLabel.text = [NSString stringWithFormat:@"%@: %@", codeString, self.article.code];
    self.codeLabel.font = [UIFont systemFontOfSize:17];
    self.codeLabel.textAlignment = NSTextAlignmentRight;

}


#pragma mark - view lifecycle

- (void)customInit {
    
    if (self.article) {
        
        [self setupImage];
        [self setupLabels];
        
    }
    
}

- (void)viewDidLoad {

    [super viewDidLoad];
    [self customInit];

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
