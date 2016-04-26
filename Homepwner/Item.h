//
//  Item.h
//  Homepwner
//
//  Created by SLboat on 2/17/16.
//  Copyright © 2016 SLboat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface Item : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
-(void)setThumbnailFromImage: (UIImage *)image;

@end

NS_ASSUME_NONNULL_END

#import "Item+CoreDataProperties.h"
