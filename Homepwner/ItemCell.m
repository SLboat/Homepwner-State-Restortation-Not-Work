//
//  ItemCell.m
//  Homepwner
//
//  Created by Sen on 10/13/15.
//  Copyright © 2015 SLboat. All rights reserved.
//

#import "ItemCell.h"

@interface ItemCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;

@end

@implementation ItemCell


- (IBAction)showImage:(id)sender
{
    if (self.actionBlock) {
        self.actionBlock(); //函数的传递
    }
}

- (void)updateInterfaceForDynamicTypeSize
{
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody]; //身体字体?
    self.nameLebel.font = font;
    self.serialNumberLabel.font = font;
    self.valueLabel.font = font;

    //图片变换
    static NSDictionary *imageSizeDictionary; //存在,不需要初始化

    //想法:取得格子高度不会更简单吗?
    if (!imageSizeDictionary) {
        imageSizeDictionary = @{UIContentSizeCategoryExtraSmall: @40,
                                UIContentSizeCategorySmall: @40,
                                UIContentSizeCategoryMedium: @40,
                                UIContentSizeCategoryLarge: @40,
                                UIContentSizeCategoryExtraLarge: @45,
                                UIContentSizeCategoryExtraExtraLarge: @55,
                                UIContentSizeCategoryExtraExtraExtraLarge:@65};
    }

    NSString *userSize = [[UIApplication sharedApplication] preferredContentSizeCategory]; //获得大小值

    NSNumber *imageSize = imageSizeDictionary[userSize];
    self.imageViewHeightConstraint.constant = imageSize.floatValue;
}

- (void)awakeFromNib
{
    [self updateInterfaceForDynamicTypeSize];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateInterfaceForDynamicTypeSize) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.thumbnailView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.thumbnailView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]; //添加约束,起源的属性→关联→对象的属性→系数→约束值,结论是这是个等值约束,高度等于宽度.
    [self.thumbnailView addConstraint:constraint]; //添加约束进去
    
}

- (void)dealloc
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

@end
