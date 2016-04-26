//
//  ItemStore.h
//  Homepwner
//
//  Created by Sen on 6/16/15.
//  Copyright (c) 2015 SLboat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;

@interface ItemStore : NSObject

@property(nonatomic, readonly) NSArray *allItems;

// Notice that this is a class method and prefixed with a + instead a -
+ (instancetype)sharedStore;

- (Item *)createItem;

/**
 *  删除一个玩意-对私有数组
 *
 *  @param item 删除的对象
 */
- (void)removeItem:(Item *)item;

- (void)moveItemAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

- (BOOL)saveChanges;

///所有的资产类别...
- (NSArray *)allAssetTypes;

@end
