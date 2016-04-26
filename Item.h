//
//  BNRItem.h
//  RandomItems
//
//  Created by Sen on 5/14/15.
//  Copyright (c) 2015 SLboat. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface Item : NSObject <NSCoding>

@property(nonatomic, copy) NSString *itemName; //有变异的子类,设置copy总是奇妙的..
@property(nonatomic, copy) NSString *serialNumber;

@property(nonatomic, assign) int valueInDollars;
@property(nonatomic, readonly, strong) NSDate *dateCreated;

/**
 *  图片唯一的键值..
 */
@property(nonatomic, copy) NSString *itemKey;
@property(strong, nonatomic) UIImage *thumbnail;

- (void)setThumbnailFromImage:(UIImage *)image;

/**
 *  类方法在前面
 *
 *  @return 一个类的实例
 */
+ (instancetype)randomItem;

- (instancetype)initWithItemName:(NSString *)name valueInDollars:(int)value serialNumber:(NSString *)sNumber;

- (instancetype)initWithItemName:(NSString *)name serialNumber:(NSString *)sNumber;

- (instancetype)initWithItemName:(NSString *)name;

@end
