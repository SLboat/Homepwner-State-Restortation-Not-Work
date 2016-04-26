//
//  ItemCell.h
//  Homepwner
//
//  Created by Sen on 10/13/15.
//  Copyright © 2015 SLboat. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface ItemCell : UITableViewCell;

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *nameLebel;
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

//copy: 它必须是copy的,因为它在栈里,不像其他的在堆里,必须被复制到堆里才能持续存在,否则方法返回的时候一起跟着局部变量摧毁.
@property(copy, nonatomic) void (^actionBlock) (void); //名称,参数,block!


@end
