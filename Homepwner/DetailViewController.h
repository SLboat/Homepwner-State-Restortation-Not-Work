//
//  DetailViewController.h
//  Homepwner
//
//  Created by Sen on 6/27/15.
//  Copyright (c) 2015 SLboat. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;

@interface DetailViewController : UIViewController <UIViewControllerRestoration>

/**
 *  一个block的属性!哈!
 */
@property(copy, nonatomic) void (^dismissBlock)(void);

- (instancetype)initForNewItem:(BOOL)isNew;

@property(nonatomic, strong) Item *item;

@end
