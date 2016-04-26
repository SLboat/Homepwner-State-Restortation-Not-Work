//
//  ImageStore.h
//  Homepwner
//
//  Created by Sen on 7/5/15.
//  Copyright (c) 2015 SLboat. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface ImageStore : NSObject

+ (instancetype)sharedStore;

- (void)     setImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;
- (void)     deleteImageForKey:(NSString *)key;

@end
